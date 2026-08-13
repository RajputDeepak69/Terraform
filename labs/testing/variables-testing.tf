provider "aws" {
    region = "us-east-1"
    alias = "east-wala"
}

provider "aws" {
    alias = "west-wala"
    region = "us-west-1"
}

# checking out input and output variables ... 👍

variable "subnet-id" {
    description = "this one for subnet id"
    type = string
    default = "my-subnet-id-000"
}
variable "ami-id" {
    type = string
    default = "ami-02b64aa047cb5edf5"
}
resource "aws_instance" "test-vm" {
    provider = aws.east-wala
    ami = var.ami-id
    instance_type = "t2.micro"
    subnet_id = var.subnet-id
    key_name = "key"
    tags = {
        Name = "test-vm"
    }
}

output "instance-id" {
    value = aws_instance.test-vm.id
}