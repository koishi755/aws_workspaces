# Configure the AWS Provider
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
  access_key = "my_access_key"
  secret_key = "my_secret_key"
}

# infomation vpc
variable "vpc1" {
  default = {
    name = "vpc1"
    cidr_block = "10.0.0.0/16"
    route_table = "test_route"
    subnets = {
      subnet1 = {
        name = "subnet1"
        availability_zone = "ap-northeast-1a"
        cidr_block = "10.0.0.0/24"
        route_table = "test_route"
      }
      subnet2 = {
        name = "subnet2"
        availability_zone = "ap-northeast-1c"
        cidr_block = "10.0.1.0/24"
        route_table = "test_route"
      }
    }
  }
}

# create vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc1.cidr_block
  tags = {
    Name = var.vpc1.name
  }
}

# create subnet
resource "aws_subnet" "vpc1-subnets" {
  for_each = var.vpc1.subnets
  cidr_block = lookup(each.value, "cidr_block")
  availability_zone = lookup(each.value, "availability_zone")
  tags = {
    Name = lookup(each.value, "name")
  }
  vpc_id = aws_vpc.main.id
}

# create route table
resource "aws_route_table" "test_route" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "test_route"
  }
}

# add route table
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.test_route.id
}

# add route table 
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.vpc1-subnets["subnet1"].id
  route_table_id = aws_route_table.test_route.id
}

# Create SimpleAD
resource "aws_directory_service_directory" "simpleAD" {
  name     = "corp.notexample.com"
  password = "SuperSecretPassw0rd"
  size     = "Small"

  vpc_settings {
    vpc_id     = aws_vpc.main.id
    subnet_ids = [aws_subnet.vpc1-subnets["subnet1"].id, aws_subnet.vpc1-subnets["subnet2"].id]
  }

  tags = {
    Name = "testad"
  }
}

# register simpleAD
resource "aws_workspaces_directory" "example" {
  directory_id = aws_directory_service_directory.simpleAD.id
  subnet_ids = [
    aws_subnet.vpc1-subnets["subnet1"].id,
    aws_subnet.vpc1-subnets["subnet2"].id
  ]
  tags = {
    Name = "test"
  }
}

#
data "aws_workspaces_bundle" "value_windows_10" {
  bundle_id = "wsb-bh8rsxt14" # Value with Windows 10 (English)
}

# create workspaces
resource "aws_workspaces_workspace" "example" {
  directory_id = aws_workspaces_directory.example.id
  bundle_id    = data.aws_workspaces_bundle.value_windows_10.id
  user_name    = "Administrator"

  # root_volume_encryption_enabled = true
  # user_volume_encryption_enabled = true
  # volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                         = "POWER"
    # user_volume_size_gib                      = 10
    # root_volume_size_gib                      = 80
    # running_mode                              = "AUTO_STOP"
    # running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Name = "testWork"
  }
}