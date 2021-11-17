packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
}
}

## Amazon EBS Linux Image 
source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-aws-ami-customized"
  instance_type = "t2.micro"
  vpc_id        = var.vpc
  region        = var.awsregion
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

## Azure Arm Linux Image

source "azure-arm" "azure-arm-ubuntu-18-image" {
  client_id = var.clientid
  client_secret = var.clientsecret
  tenant_id = var.tenantid
  subscription_id = var.subscriptionid

  managed_image_resource_group_name = var.resourcegroupname
  managed_image_name = "Ubuntu18ServerImage-Customized"

  os_type = "Linux"
  image_publisher = "Canonical"
  image_offer = "UbuntuServer"
  image_sku = "18.04-LTS"

  azure_tags = {
    dept = "Network_Cloud"
  }

  location = "East US"
  vm_size = "Standard_DS2_v2"
}

## Build block

build {
  name = "Pre-install-packages"
  sources = [
      "source.amazon-ebs.ubuntu",
      "sources.azure-arm.azure-arm-ubuntu-18-image"
      ]
  provisioner "shell" {
    expect_disconnect= true
    environment_vars = [
      "TEST=Installing pre-installation packeges"
    ]
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get -y install nginx",
      "sudo apt-get install git -y",
      "git clone https://github.com/satender346/devops-automation.git",
      "cd devops-automation && bash packer.sh",
      #"git clone https://github.com/satender346/jenkins-kubernetes-helm-deployment.git",
      #"cd jenkins-kubernetes-helm-deployment",
      #"bash deploy_jenkins_chart.sh",
    ]
    inline_shebang = "/bin/sh -x"
  }
  provisioner "file" {
    source = "/var/jenkins_home/aws_credentials"
    destination = "/var/jenkins_home/aws_credentials"
  }
}