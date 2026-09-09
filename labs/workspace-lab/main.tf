variable "ami-id" {
  
}
variable "instance-type" {
  
}
variable "subnet-id" {
    
}
module "instances" {
    source = "./modules/instances"
    ami-id = var.ami-id
    instance-type = var.instance-type
    subnet-id = var.subnet-id
}