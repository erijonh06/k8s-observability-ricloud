variable "app_name" {
  type    = string
  default = "erijon-app"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the sandbox resource group"
}
}

variable "subscription_id" {
  type    = string
  description = "Azure subscription id (sensitive - set in terraform.tfvars)"
}