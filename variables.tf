variable "vm_name" {
  type = string
  default = "test"
}

variable "vm_namespace" {
  type = string
  default = "test"
}

variable "image_name" {
  type = string
  default = "test"
}

variable "image_url" {
  type = string
  default = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
}

variable "image_size" {
  type = string
  default = "10Gi"
}

variable "machine_size" {
  type = string
  default = "4Gi"
}
