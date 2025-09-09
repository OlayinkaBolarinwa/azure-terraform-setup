provider "azurerm" {
  features {}
}

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 2
}

# Resource Group
resource "azurerm_resource_group" "project" {
  name     = "project-resources-${random_id.suffix.hex}"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "project_network" {
  name                = "project-vnet-${random_id.suffix.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
}

# Subnet
resource "azurerm_subnet" "project_subnet" {
  name                 = "project-subnet-${random_id.suffix.hex}"
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "project_nsg" {
  name                = "project-nsg-${random_id.suffix.hex}"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "project_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.project_subnet.id
  network_security_group_id = azurerm_network_security_group.project_nsg.id
}

# Public IP
resource "azurerm_public_ip" "project_public_ip" {
  name                = "project-public-ip-${random_id.suffix.hex}"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "project_nic" {
  name                = "project-nic-${random_id.suffix.hex}"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.project_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.project_public_ip.id
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "project_workspace" {
  name                = "project-law-${random_id.suffix.hex}"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "project_vm" {
  name                = "project-vm-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.project.name
  location            = azurerm_resource_group.project.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = var.admin_password 
  network_interface_ids = [
    azurerm_network_interface.project_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Variables for sensitive info
variable "admin_password" {
  type      = string
  sensitive = true
}
