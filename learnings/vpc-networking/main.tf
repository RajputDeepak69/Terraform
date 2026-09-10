resource aws_vpc "my-vpc" {
  cidr_block = var.CIDR
}
resource aws_subnet "subnet1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}
resource aws_subnet "subnet2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}
resource aws_internet_gateway "igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "igw-for-project"
  }
}
resource aws_route_table "rt1" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Rout-Table-1"
  }
}
resource aws_route_table_association "sub1-association" {
  route_table_id = aws_route_table.rt1.id
  subnet_id = aws_subnet.subnet1.id
}
resource aws_route_table_association "sub2-association" {
  route_table_id = aws_route_table.rt1.id
  subnet_id = aws_subnet.subnet2.id
}
resource aws_security_group "sg" {
  name = "project-sg"
  vpc_id = aws_vpc.my-vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.CIDRs
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.CIDRs
  }
}