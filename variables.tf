variable "client_id" {
    description = "Azure Client id"
    default = ""
}

variable "client_secret" {
    description = "Azure client secret"
    default = ""
}

variable "tenant_id" {
    description = "Azure tenant id"
    default = ""
}

variable "subscription_id" {
    description = "azure subscription id"
    default = ""
}

variable "azure_region" {
  description = "azure region"
  default = "East US"
}

variable "linux_ami_id" {
  description = "Ami id of the linux image"
  default = "ami-07602004aec037ae7"
}

variable "ssh_key" {
    description = "user ssh public key"
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHOXZjK5EpSWj7A/rMkxKSU1PGO/5NdbJrJIJaP1275MUM4BeeKvqK6lcArqyiwtKSCPVxdRQM9BTctfO4wO9cRFujca0cnHmOMIiXPgpIBkW6UTAEpxU/FosODuKeYYvp+2Zbcymr89aLE2nDRKR2eIEbBBpUN5g6NLF0gObYm7pB1zQ6+AzdGjGVEwjLRFRV7Wo/q9Ncz7QTKJ5UYTK7mwRcrAa94w18PQoajYwUfd8ctAF45UJWmrOYce12k/pFFW6pTIwujXHV9Sp45hp6AVT6B94HMCMgVb1hCpCwWAA2LNru6se+MEMNrEg9MnTGWwiK/aWEO+pIsVxfA7/7 root@satender-Devops"
}
variable "vpc_id" {
    description = "vpc_id under which the resource group will create"
    default = ""
}
variable "subnet" {
    description = "subnet id of the vpc"
    default = ""
}
variable "cidr_blocks" {
    description = "subnet ip range in cidr block"
    default = ["0.0.0.0/0"]
}
variable "aws_region" {
    description = "aws region"
    default = "us-west-1"
}
variable "volume_type" {
    description = "type of the storage"
    default = "gp2"
}
