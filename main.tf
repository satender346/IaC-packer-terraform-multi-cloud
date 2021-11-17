terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.23.0"
    }
  }
  required_version = ">= 0.14.9"
}

# Configure the Amazon Provider
provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features{
  }
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

## AWS AMI DATA
data "aws_ami" "image" {
  most_recent = true
  name_regex  = "ubuntu-aws-ami-customized"
  owners = ["self"]                          
}

output "ami_id" {
  value = "${data.aws_ami.image.id}"
}

## AWS EC2 Instance Builder Block
resource "aws_instance" "controller_linux" {
  ami                         = "${data.aws_ami.image.id}"
  instance_type               = "t2.large"
  associate_public_ip_address = true
  subnet_id = "${var.subnet}"
  key_name                    = "ssh-key"
  root_block_device {
    volume_type           = "${var.volume_type}"
    volume_size           = 60
    delete_on_termination = true
    encrypted = true
  }
  tags = {
    Name = "IaC-Infra"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "${var.ssh_key}"
}


resource "aws_security_group" "k8s-cluster-sg" {
  name        = "k8s-cluster-sg"
  description = "Allow sall traffic"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.cidr_blocks}"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.cidr_blocks}"
  }
  tags = {
    Name = "k8s-cluster-sg"
  }
}


output "securitygroup_id" {
  value = aws_security_group.k8s-cluster-sg.id
}

resource "aws_network_interface_sg_attachment" "controller_sg_attachment" {
  security_group_id    = aws_security_group.k8s-cluster-sg.id
  network_interface_id = aws_instance.controller_linux.primary_network_interface_id
}


## Azure RM Instance Builder block
data "azurerm_image" "search" {
  name                = "Ubuntu18ServerImage-Customized"
  resource_group_name = "myResourceGroup"
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "RG-QA-Test-vNet"
    address_space       = ["10.0.0.0/16"]
    location            = var.azure_region
    resource_group_name = "myResourceGroup"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "RG-Terraform-in"
  virtual_network_name = "RG-QA-Test-vNet"
  resource_group_name  = "myResourceGroup"
  address_prefixes       = ["10.0.1.0/24"]
depends_on = [
  azurerm_virtual_network.myterraformnetwork,
]
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "RG-QA-Test-Dev"
  location            = var.azure_region
  resource_group_name = "myResourceGroup"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "main" {
  name                      = "RG-QA-Test-in"
  location                  = var.azure_region
  resource_group_name       = "myResourceGroup"
  #network_security_group_id = azurerm_network_security_group.main.id

  ip_configuration {
    name                          = "aicconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost("10.0.1.0/24", 4)
    public_ip_address_id = azurerm_public_ip.azure_public_ip.id
  }
}

resource "azurerm_public_ip" "azure_public_ip" {
  name                = "azure_public_ip"
  resource_group_name = "myResourceGroup"
  location            = var.azure_region
  allocation_method   = "Static"

  tags = {
    environment = "Terraform Demo"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}


# Create a new Virtual Machine based on the Golden Image
resource "azurerm_virtual_machine" "vm" {
  name                             = "Ubuntu-18-server"
  location                         = var.azure_region
  resource_group_name              = "myResourceGroup"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_DS12_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  
  storage_image_reference {
    id = data.azurerm_image.search.id
  }

  storage_os_disk {
    name              = "AZLXDEVOPS01-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "myvm"
    admin_username = "ubuntu"
    admin_password = "Ubuntu@123"
  }
  
  os_profile_linux_config{
    disable_password_authentication = false
  }
}

output "aws-instance_ip_linux_controller" {
  description = "The public ip for ssh access to linux controller"
  value       = aws_instance.controller_linux.public_ip
}

output "azure-instance_ip_linux_controller" {
  description = "The public ip for ssh access to linux controller"
  value       = azurerm_public_ip.azure_public_ip.ip_address
}
