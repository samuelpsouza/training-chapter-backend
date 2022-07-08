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

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.root_compartment_id
}

resource "oci_identity_compartment" "compartment_cb" {
  compartment_id = var.root_compartment_id
  description    = "Compartment to play with k8s"
  name           = "compartment_cb"
  enable_delete  = true
}

resource "oci_core_vcn" "internal" {
  dns_label      = "internal"
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.compartment_cb.id
  display_name   = "k8s internal VCN"
}

resource "oci_core_subnet" "internal_subnet_1" {
  vcn_id                     = oci_core_vcn.internal.id
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = oci_identity_compartment.compartment_cb.id
  display_name               = "Dev subnet 1"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "subnet1"
}

resource "oci_core_subnet" "internal_subnet_2" {
  vcn_id         = oci_core_vcn.internal.id
  cidr_block     = "10.0.0.0/24"
  compartment_id = oci_identity_compartment.compartment_cb.id
  display_name   = "Dev subnet 2"
  dns_label      = "subnet2"
}

resource "oci_core_instance" "amd_instance" {
  count = 2

  compartment_id      = oci_identity_compartment.compartment_cb.id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "amd_instance_${count.index}"

  shape = "VM.Standard.E4.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaayuhnfqdtn6h4dbzsbdbuvsdx2rfw2qif42de6ruaogia4svbdthq"
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = false
    subnet_id = oci_core_subnet.internal_subnet_1.id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_key_path)
  }

  preserve_boot_volume = false
}
resource "oci_core_instance" "arm_instance" {
  count = 2

  compartment_id      = oci_identity_compartment.compartment_cb.id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "arm_instance_${count.index}"

  shape = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaarouditficgq7lhq2wi7nkt3hcpiu6mq4xwgyq6oabjpy7cnqlj5a"
    source_type = "image"
  }

  create_vnic_details {
    assign_public_ip = false
    subnet_id = oci_core_subnet.internal_subnet_2.id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_key_path)
  }

  preserve_boot_volume = false
}
