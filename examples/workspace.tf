provider "azurerm" {
  features {}
}

# Define the number of VMs based on the current workspace
locals {
  vm_count = terraform.workspace == "test" ? 3 : terraform.workspace == "dev" ? 2 : 0
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources-${terraform.workspace}"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet-${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  count               = local.vm_count  # Create NICs based on the VM count
  name                = "example-nic-${terraform.workspace}-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  count               = local.vm_count  # Create VMs based on the VM count
  name                = "example-vm-${terraform.workspace}-${count.index}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"  # Use a secure password in production
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    caching        = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "vm_ids" {
  value = azurerm_linux_virtual_machine.example[*].id
}
