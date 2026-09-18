terraform {
  required_version = ">= 1.15.5"

  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7.0"
    }

    outscale = {
      source  = "outscale/outscale"
      version = "1.5.0"
    }

    # Optional random provider if generating initial temporary passwords
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}
