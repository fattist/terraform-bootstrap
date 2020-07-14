variable "name" {}

resource "aws_key_pair" "key" {
  key_name = "${terraform.workspace}-${var.name}"
  public_key = file("${path.cwd}/../secrets/terraform/keys/bastion/openvpn_${terraform.workspace}.pub")
}

# OUTPUT
output "name" {
  value = "${aws_key_pair.key.key_name}"
}
