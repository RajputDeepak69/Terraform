module "ec2_instance" {
    source = "./module/ec2_instance" 
    ami-id = var.ami-id
    instance_type = var.instance_type
}