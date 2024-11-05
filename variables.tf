// This file contains the variables used in the Terraform configuration.

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "admin_password" {
  description = "VM admin password"
  type        = string
}

// Common configuration variables

variable "common" {
  description = "Common configuration variables"
  type = object({
    resource_group_name = string
    location            = string
    admin_username      = string
  })
  default = {
    resource_group_name = "sandbox-resource-group"
    location            = "westeurope"
    admin_username      = "azureuser"
  }
}

// Network configuration variables

variable "network" {
  description = "Network configuration variables"
  type = object({
    virtual_network_name   = string
    address_space          = list(string)
    subnet_name            = string
    subnet_prefixes        = list(string)
    network_interface_name = string
    public_ip_name         = string
  })
  default = {
    virtual_network_name   = "sandbox-vnet"
    address_space          = ["10.0.0.0/16"]
    subnet_name            = "sandbox-subnet"
    subnet_prefixes        = ["10.0.1.0/24"]
    network_interface_name = "sandbox-nic"
    public_ip_name         = "sandbox-public-ip"
  }
}

// Security configuration variables

variable "security" {
  description = "Security configuration variables"
  type = object({
    nsg_name   = string
    ssh_port   = number
    http_port  = number
  })
  default = {
    nsg_name  = "sandbox-nsg"
    ssh_port  = 22
    http_port = 80
  }
}

// Compute configuration variables

variable "compute" {
  description = "Compute configuration variables"
  type = object({
    vm_name                      = string
    vm_size                      = string
    os_disk_caching              = string
    os_disk_storage_account_type = string
    source_image_publisher       = string
    source_image_offer           = string
    source_image_sku             = string
    source_image_version         = string
  })
  default = {
    vm_name                       = "sandbox-vm"
    vm_size                       = "Standard_B1s"
    os_disk_caching               = "ReadWrite"
    os_disk_storage_account_type  = "Standard_LRS"
    source_image_publisher        = "Canonical"
    source_image_offer            = "0001-com-ubuntu-server-jammy"
    source_image_sku              = "22_04-lts-gen2"
    source_image_version          = "latest"
  }
} 