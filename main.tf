terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate suffix for uniqueness
resource "random_id" "suffix" {
  byte_length = 2
}

# Resource Group
resource "azurerm_resource_group" "project" {
  name     = "project-resources-${random_id.suffix.hex}"
  location = "eastus2"

  tags = {
    environment = "dev"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "project_network" {
  name                = "project-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name

  tags = {
    environment = "dev"
  }
}

# Subnet
resource "azurerm_subnet" "project_subnet" {
  name                 = "project-subnet"
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "project_nsg" {
  name                = "project-nsg"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "project_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.project_subnet.id
  network_security_group_id = azurerm_network_security_group.project_nsg.id
}

# Public IP
resource "azurerm_public_ip" "project_public_ip" {
  name                = "project-public-ip"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

# Network Interface
resource "azurerm_network_interface" "project_nic" {
  name                = "project-nic"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.project_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.project_public_ip.id
  }
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "project_vm" {
  name                  = "project-vm"
  location              = azurerm_resource_group.project.location
  resource_group_name   = azurerm_resource_group.project.name
  size                  = "Standard_B1ms"
  admin_username        = "azureuser"
  admin_password        = "Yinkus1985@" # Use GitHub Secrets for production
  network_interface_ids = [azurerm_network_interface.project_nic.id]

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

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "project_workspace" {
  name                = "project-law-${random_id.suffix.hex}"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# VM Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "project_vm_diagnostics" {
  name                       = "vm-diagnostics"
  target_resource_id         = azurerm_windows_virtual_machine.project_vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.project_workspace.id

  log {
    category = "Administrative"
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "Security"
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# NSG Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "project_nsg_diagnostics" {
  name                       = "nsg-diagnostics"
  target_resource_id         = azurerm_network_security_group.project_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.project_workspace.id

  log {
    category = "NetworkSecurityGroupEvent"
    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
