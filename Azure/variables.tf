variable "azure_client_id" {}
variable "client_certificate_path" {}
variable "client_certificate_password" {}
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}
variable "location" {}
variable "storageAcct" {}

variable "prefix" { default = "cz-image-generator" }
variable "my-ip" {}
variable "username" {}
variable "password" {}
variable "cidr" { default = "10.0.0.0/16" }

variable "subnets" {
  type = map(any)
  default = {
    "s0" = "10.0.0.0/24"
    "s1" = "10.0.1.0/24"
  }
}

variable "ips" {
  type = map(any)
  default = {
    "ltm-mgmt"   = "10.0.0.4",
    "ltm-ext"    = "10.0.1.4",
    "ubuntu-ext" = "10.0.1.5"
  }
}

variable "pips" {
  type = list(string)
  default = [
    "ltm-mgmt",
    "ltm-ext",
    "ubuntu-ext"
  ]
}

variable "ltm-instance-type" { default = "Standard_DS4_v2" }
variable "ubuntu-instance-type" { default = "Standard_D16_v3" }

variable "DO-URL" { default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.25.0/f5-declarative-onboarding-1.25.0-7.noarch.rpm" }
variable "AS3-URL" { default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.21.0/f5-appsvcs-3.21.0-4.noarch.rpm" }
variable "TS-URL" { default = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.13.0/f5-telemetry-1.13.0-2.noarch.rpm" }
variable "CF-URL" { default = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.4.0/f5-cloud-failover-1.4.0-0.noarch.rpm" }
variable "libs-dir" { default = "/config/cloud/azure/node-modules" }
variable "onboard-log" { default = "/var/log/startup-script.log" }
variable "mgmt-gw" { default = "10.0.0.1" }

variable "default_vm_tags" {
  type = map(any)
  default = {
    Owner = "christopher.zhang@f5.com"
  }
}


