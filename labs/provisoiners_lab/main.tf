resource "aws_key_pair" "key-pair" {
  key_name = "project-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_subnet" "my-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my-igw"  {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "sub-rt-association" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id = aws_subnet.my-subnet.id
}

resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.my-vpc.id
  ingress {
    description = "for ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "for application serving "
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "for external internet access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-sg"
    Environment = "project"
  }
}  

resource "aws_instance" "project-server" {
  ami = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my-subnet.id
  key_name = aws_key_pair.key-pair.key_name
  vpc_security_group_ids = [aws_security_group.my-sg.id]

  connection {
    host = self.public_ip
    private_key = file("~/.ssh/id_rsa")
    type = "ssh"
    port = "22"
    user = "ubuntu"
  }

  provisioner "file" {
    source = "app.py"
    destination = "~/app.py"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt update -y",
      "sudo apt install -y python3-pip",
      "sudo apt install -y python3-venv",
      "python3 -m venv my-env",
      "source my-enc/bin/activate",
      "pip install flask",
      "python app.py"
     ]
  }


}
