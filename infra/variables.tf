variable "root_compartment_id" {
  description = "OCID from your tenancy page"
  type        = string
}

variable "region" {
  description = "Region where you have OCI tenancy"
  type        = string
  default     = "us-ashburn-1"
}

variable "auth_method" {
  description = "Define what method of authentication will be used"
  type        = string
  default     = "SecurityToken"
}

variable "config_file_profile" {
  description = "Config profile created"
  type        = string
  default     = "DEFAULT"
}

variable "ssh_key_path" {
  description = "SSH key file path"
  type        = string
}
