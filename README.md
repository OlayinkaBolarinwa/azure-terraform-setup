# Terraform Azure Project – Personal Build Log

This is my first Terraform setup for a basic Azure environment. It includes a virtual machine, networking, logging, and diagnostics. The purpose was to build everything from scratch using the AzureRM provider and learn how to manage infrastructure as code.

---

## What’s Included

- Resource Group  
- Virtual Network  
- Subnet  
- Network Security Group (NSG) with an inbound HTTP rule  
- Public IP (Static, Standard SKU)  
- Network Interface  
- Windows Virtual Machine (Windows Server 2019)  
- Log Analytics Workspace  
- Diagnostic Settings for the VM and NSG  

---

## Configuration Overview

Everything is written in one `main.tf` file. The virtual machine runs Windows Server 2019. The NSG allows HTTP traffic, and the public IP is configured as static. Tags are used to keep resources grouped under `environment = "dev"`.

---

## Error Encountered

When setting up diagnostic settings for the VM and NSG, I got this error:

Error: "enabled_logs": blocks of type "enabled_logs" are not expected here.
with azurerm_monitor_diagnostic_setting.project_vm_diagnostics



The same happened with `enabled_metric`.

This happened because the `enabled_logs` and `enabled_metric` blocks are no longer supported in the newer AzureRM provider version (`~> 3.117.1`).

---

## Fix

I changed this:


enabled_logs {
  category = "Administrative"
  enabled  = true
}


And this:

metric {
  category = "AllMetrics"
  enabled  = true
}



terraform init
terraform plan
terraform apply


Everything deployed successfully:

VM is running

NSG rules are working

Diagnostics are being sent to Log Analytics

No manual setup was needed in the Azure Portal


Notes:
Always check the official Terraform documentation when something doesn't work.

The syntax for diagnostic settings changes between provider versions.

Using log and metric is the correct format for newer versions.




---![Resource Group](https://github.com/user-attachments/assets/c5365a2e-bc43-4984-bf88-f6a27afc57c7)


![Virtual Network](https://github.com/user-attachments/assets/e77a0379-ac55-4093-9604-62cea4e09536)


![Subnet](https://github.com/user-attachments/assets/489ff5cd-9c93-4202-809b-a56c7967ecb4)


![Network Security Group (NSG)](https://github.com/user-attachments/assets/3c962cd7-7b3f-49c9-89c7-2e6d0b5451ff)


![Public IP](https://github.com/user-attachments/assets/e87937f9-cfc6-429e-8735-ae40950494bc)


![Network Interface](https://github.com/user-attachments/assets/2a09dc95-0089-46c0-b4c1-f6bb28ca7a97)


![Windows Virtual Machine](https://github.com/user-attachments/assets/5b7f39a7-1ee8-4f40-9d0b-8c0aeea3ee9f)


![Log Analytics Workspace](https://github.com/user-attachments/assets/1f6c1807-322e-45e6-ac49-32e07a87f5f3)


![VM Diagnostic Settings](https://github.com/user-attachments/assets/24f5b588-de43-4b6a-ad02-6173d2c70f3c)


![NSG Diagnostic Settings](https://github.com/user-attachments/assets/a9f4a5a9-ca72-416c-99d9-4db21628308e)


![Terraform Apply Output](https://github.com/user-attachments/assets/460d5538-9579-4eee-b21b-31ecabf01f1f)


