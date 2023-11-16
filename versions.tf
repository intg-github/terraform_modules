terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.71.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.18.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "=3.74.1"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "=3.2.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.3.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "=0.9.1"
    }
  }
}
