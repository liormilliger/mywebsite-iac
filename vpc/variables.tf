variable "vpc_name" {
  description = "Your vpc name"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone list"
  type        = list(string)
}

variable "az_name" {
  description = "Availability zone name list"
  type        = list(string)
}