variable "hostname_prefix" {
  description = "Your prefix to hostname, end it with a dash"
  default     = ""
  type        = string
}

variable "auth_token" {
  description = "Your Packet API token"
  default     = "TOKEN"
  type        = string
}

variable "project_id" {
  description = "Your Packet project ID"
  default     = "PROJECT_ID"
  type        = string
}

variable "facility" {
  description = "The facility in which the bare metal server will be provisioned."
  default     = "ewr1"
  type        = string
}

variable "plan" {
  description = "The server type that you want to provision"
  default     = "t1.small.x86"
  type        = string
}

variable "amount" {
  description = "Amount of servers to be deployed"
  default     = 2
  type        = number
}

variable "esxi_update_filename" {
  description = "The specific update version that your servers will be updated to. Note that the Packet portal and API will still show ESXi 6.5 as the OS but this script adds a tag with the update filename specified below. You can check all ESXi update versions/filenames here: https://esxi-patches.v-front.de/ESXi-6.7.0.html"
  default     = "ESXi-6.7.0-20191104001-standard"
  type        = string
}
