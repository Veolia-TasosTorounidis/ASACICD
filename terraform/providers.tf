terraform {
  required_version = ">= 0.14.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "iot-dev-rg-coreTerraformState"
    storage_account_name = "iotdevstrgterraform"
    container_name       = "terraform-state"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}