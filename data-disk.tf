resource "azurerm_managed_disk" "disk" {
    name = "mydatadisk"
    location = azurerm_linux_virtual_machine.example.location
    resource_group_name = azurerm_resource_group.example.name
    storage_account_type = "Standard_LRS"
    create_option = "Empty"
    disk_size_gb = 50
  
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattch" {
    managed_disk_id = azurerm_managed_disk.disk.id
    virtual_machine_id = azurerm_linux_virtual_machine.example.id
    lun = 10
    caching = "ReadWrite"
}
