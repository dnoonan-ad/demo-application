data "aws_availability_zones" "available" {}

locals {
  name   = "data-app"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "app"
  container_port = 80

  tags = {
    Name    = local.name
    Example = local.name
  }
}