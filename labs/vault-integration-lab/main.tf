data "vault_kv_secret_v2" "tag-name" {
    mount = "secret"
    name = "aws/ec2"
}
resource "aws_instance" "server" {
    ami = "ami-0f094b852a615ea36"
    instance_type = "t3.micro"
    tags = {
        Name = data.vault_kv_secret_v2.tag-name.data["tag"]
        env = data.vault_kv_secret_v2.tag-name.data["env"]
    }
}