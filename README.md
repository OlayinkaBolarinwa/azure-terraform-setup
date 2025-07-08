# Terraform Azure Project – Personal Build Log

Terraform Azure Project – Personal Build Log

This is my first Terraform setup in a simple Azure environment with a VM, networking, diagnostics, and logging. The goal was to build everything from scratch and get familiar with infrastructure-as-code using the AzureRM provider
What’s Included
Resource Group

Virtual Network

Subnet

Network Security Group (NSG) with inbound HTTP rule

Public IP (static)

Network Interface

Windows Virtual Machine

Log Analytics Workspace

Diagnostic Settings for both the VM and NSG


I wrote everything in one main.tf file. It includes all resources mentioned above. The VM is running Windows Server 2019, and the NSG is allowing HTTP traffic.

Public IP is set to static and standard SKU. Tags are applied to keep things organized under environment = "dev".

I hit this error while trying to set up diagnostic settings for the VM and NSG:
Error: "enabled_logs": blocks of type "enabled_logs" are not expected here.
with azurerm_monitor_diagnostic_setting.project_vm_diagnostics,


Same thing happened for enabled_metric.

This was super confusing at first because all examples I saw online still used enabled_logs, but it turns out that syntax is deprecated as of newer versions of the AzureRM provider (I’m using ~> 3.117.1).


Fix
To fix the diagnostic settings, I had to replace this:


enabled_logs {
  category = "Administrative"
  enabled  = true
}

With this:


log {
  category = "Administrative"
  enabled  = true
}


And this:


enabled_metric {
  category = "AllMetrics"
  enabled  = true
}


With:


metric {
  category = "AllMetrics"
  enabled  = true
}



Basically, just swap out enabled_logs → log and enabled_metric → metric. After making those changes for both the VM and NSG diagnostics, Terraform was happy again.


After the fix, everything deployed cleanly:

terraform init 

terraform plan 

terraform apply 

Got the VM running with a public IP, NSG rules applied, and diagnostics streaming to Log Analytics. No manual clicks in the portal — everything managed via Terraform.



Notes to Self
Always double-check the Terraform provider docs when something breaks. Stuff changes.

Diagnostic settings seem to break often between provider versions — use log and metric, not enabled_logs.

Might want to split this into modules or files later, but for testing and learning, keeping it in one file was easier to manage.
