variable "clientid" {
    description = "client id of azure account"
    default = ""
}

variable "clientsecret" {
    description = "client secret of azure account"
    default = ""
}

variable "tenantid" {
    description = "tenant id of azure account"
    default = ""
}

variable "subscriptionid" {
    description = "subscription id of azure account"
    default = ""
}

variable "resourcegroupname" {
    description = "resource group name"
    default = "myResourceGroup"
}

variable "awsregion" {
    description = "region name"
    default = "us-west-1"
}

variable "vpc" {
    description = "vpc id of the aws"
    default = "vpc-02d6d6f10e22e5bee"
}
