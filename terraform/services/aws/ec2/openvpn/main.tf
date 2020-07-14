variable "domain" { type = string }
variable "openvpn_amis" { type = map }
variable "region" { type = string }
variable "subnet_id" { type = string }
variable "vpc_security_group_ids" { type = list(string) }
variable "zone_id" { type = string }

# KEYS
######
module "ec2-key-bastion" {
  source = "../../../../modules/aws/ec2/keys"
  name = "bastion"
}

resource "aws_instance" "openvpn" {
  ami = var.openvpn_amis[var.region]
  instance_type = "t2.medium"
  key_name = module.ec2-key-bastion.name
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = "${terraform.workspace}-openvpn"
  }
}

module "subdomain" {
    source = "../../../../modules/aws/r53/record"
    domain = var.domain
    dns = aws_instance.openvpn.public_dns
    service = "vpn"
    zone_id = var.zone_id
}