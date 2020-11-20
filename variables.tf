variable "env" {
  type    = string
  default = "dev"
}

locals {
  common_tags = {
    module  = "gitian_setup"
    creator = "terraform"
    env     = var.env
  }
}
locals {
  ubuntu20_04 = {
    us-east-1 = "ami-0885b1f6bd170450c"
    us-east-2 = "ami-0a91cd140a1fc148a"
    us-west-1 = "ami-00831fc7c1e3ddc60"
    us-west-2 = "ami-07dd19a7900a1f049"
    # Add your region / ami here 
  }
}

locals {
  instance_options = {
    t3medium = {
      cores   = "2"
      memory  = "3"
    }
    c4xlarge = {
      cores   = "4"
      memory  = "6"
    }
    c42xlarge = {
      cores   = "8"
      memory  = "13"
    }
    c44xlarge = {
      cores   = "16"
      memory  = "26"
    }
    # used for -j and -m options with build process representing cpu (cores) and memory (GBs) to use per instance size
  }
}


variable "cidr_block_ssh_access_rule" {
  type    = string
  default = "0.0.0.0/0"
}
variable "vpc_id" {
  type = string
}

variable "service_name" {
  default = "gitian"
}
variable "subnet_id" {
  type = string
}
variable "ssh_key_name" {
  type = string
}

# use this for vpn / jump box sg or other service
variable "sg_for_access_id" { 
  type    = string
  default = ""
}

variable "region" {
  type = string
}


variable use_docker {
  default = true
  type    = bool
}

variable "instance_size" {
  type    = string
  default = "t3.medium"
}

variable "docker_fingerprint" {
  type    = string
  default = "0EBFCD88"
}
variable "gpg_signer" {
  type    = string
  default = "DEFAULT_NAME"
}
variable "bitcoin_version" {
  type    = string
  default = "0.20.1"
}

variable "az_letter" {
  type    = string
  default = "a"
}