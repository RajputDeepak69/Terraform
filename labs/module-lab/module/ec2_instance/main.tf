resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/20"
}
resource "aws_subnet" "subnet1"{
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.0.0/22"
}

resource aws_instance "web-vm" {
    ami = var.ami-id
    instance_type = var.instance_type
    subnet_id = aws_subnet.subnet1.id
    key_name = "project"
    tags = {
        Name = "web-vm"
        env = "testing"
    }
}
