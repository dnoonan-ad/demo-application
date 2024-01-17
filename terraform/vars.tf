variable "api_image" {
  type    = string
  default = "<RATES_IMAGE_ADDRESS>"
}

variable "db_image" {
  type    = string
  default = "<DB_IMAGE_ADDRESS>"
}

variable "cpu_arch" { # This was becasue i built the images on a mac
  type = string
  default = "ARM64"
}