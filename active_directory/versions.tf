terraform {
  required_version = ">= 1.14.6"

  required_providers {
    ad = {
      source  = "hashicorp/ad"
      version = ">= 0.5.0"
    }
  }
}
