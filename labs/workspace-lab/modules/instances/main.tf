variable "ami-id" {
    description = "ami id for my instances...."
}
variable "instance-type" {
    description = "instance type for instances .."
} 
variable "subnet-id" {
    description = "subnet id for instance ..."
}

resource "aws_instance" "server" {
    ami = var.ami-id
    instance_type = var.instance-type
    subnet_id = var.subnet-id
    tags = {
        Name = "Test"
        Environment = "Dev"
    }
}