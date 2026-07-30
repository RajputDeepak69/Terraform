provider "aws" {
    region = "us-east-1"
    alias = "east-wala"
}

provider "aws" {
    alias = "west-wala"
    region = "us-west-1"
}

resource "aws_instance" "demo" {
    provider = aws.west-wala
    ami = "fhwfhwhoi"
    instance_type = "t2.micro"
    subnet_id = "2rywrwufhweuf"
    key_name = "project"
    tags = {
        name = "demo"
    }
}