output "instance-public-ip" {
    value = aws_instance.web-vm.public_ip
}