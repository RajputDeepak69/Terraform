provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "testing" {
    ami = "ami-0b5f627205de80196"
    instance_type = "t3.micro"
    subnet_id = "subnet-0a68775a7f6e9fa5e"
}