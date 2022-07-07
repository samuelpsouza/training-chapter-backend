terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

provider "oci" {
  region              = var.region
  auth                = var.auth_method
  config_file_profile = var.config_file_profile
}

resource "oci_identity_compartment" "compartment-chapter-backend" {
    compartment_id = var.compartment_id
    description = "Compartment to play with k8s"
    name = "compartment-chapter-backend"
}

resource "oci_core_vcn" "internal" {
  dns_label       = "internal"
  cidr_block      = "192.168.1.0/24"
  compartment_id = var.compartment_id
  display_name    = "k8s internal VCN"
}