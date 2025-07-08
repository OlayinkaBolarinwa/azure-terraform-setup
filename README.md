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

Later, this could be split into modules or separate files, but keeping everything in one file helped during the learning phase.



---


