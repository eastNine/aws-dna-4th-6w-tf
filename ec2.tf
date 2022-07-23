resource "aws_key_pair" "ec2_key" {
  key_name   = "dna"
  public_key = ""
}


data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "proxy" {
  name        = "proxy"
  vpc_id      = aws_vpc.mainvpc.id
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
  }
  
  ingress {
      from_port = 3128
      to_port = 3128
      protocol = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "proxy"
  }
}

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.large"
  
  key_name = aws_key_pair.ec2_key.id
  subnet_id = aws_subnet.mainvpc_pri_subnet.id
  vpc_security_group_ids = [
    aws_security_group.proxy.id
  ]

  tags = {
    Name = "proxy"
  }
}

data "aws_ami" "windows" {
  most_recent = true     
  filter {
       name   = "name"
       values = ["Windows_Server-2019-English-Full-Base-*"]  
  }     
  filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }
  owners = ["801119661308"] # Canonical
}

resource "aws_security_group" "windows" {
  name        = "windows"
  vpc_id      = aws_vpc.mainvpc.id
  
  ingress {
      from_port = 3389
      to_port = 3389
      protocol = "tcp"
      cidr_blocks      = [var.your_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "windows"
  }
}

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = "m5.large"
  
  key_name = aws_key_pair.ec2_key.id
  subnet_id = aws_subnet.mainvpc_pub_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.windows.id
  ]

  tags = {
    Name = "windows"
  }
}
