// This is a Terraform configuration for creating a simple Azure VM with Nginx installed.
// It uses cloud-init to configure the VM after it's created.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
  }
}

// Configure the Azure provider

provider "azurerm" {
  resource_provider_registrations   = "none"
  subscription_id                   = var.subscription_id
  features {}
}

// Create a resource group

resource "azurerm_resource_group" "rg" {
  name     = var.common.resource_group_name
  location = var.common.location
}

// Create a virtual network

resource "azurerm_virtual_network" "vnet" {
  name                = var.network.virtual_network_name
  address_space       = var.network.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// Create a subnet

resource "azurerm_subnet" "subnet" {
  name                 = var.network.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.network.subnet_prefixes
}

// Create a public IP address

resource "azurerm_public_ip" "public_ip" {
  name                = var.network.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

// Create a network interface

resource "azurerm_network_interface" "nic" {
  name                = var.network.network_interface_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

// Create a network security group

resource "azurerm_network_security_group" "nsg" {
  name                = var.security.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.security.ssh_port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.security.http_port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

// Associate the network interface with the network security group

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

// Create a Linux virtual machine

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.compute.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.compute.vm_size

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_username                  = var.common.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = var.compute.os_disk_caching
    storage_account_type = var.compute.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.compute.source_image_publisher
    offer     = var.compute.source_image_offer
    sku       = var.compute.source_image_sku
    version   = var.compute.source_image_version
  }

  custom_data = filebase64("cloud-init.yaml")
}