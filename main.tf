resource "aws_vpc" "mainvpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "dna"
  }
}

resource "aws_subnet" "mainvpc_pub_subnet" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dna-public"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub_rt"
  }
}

resource "aws_route_table_association" "pub_rta" {
  subnet_id      = aws_subnet.mainvpc_pub_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "dna"
  }
}

resource "aws_subnet" "mainvpc_pri_subnet" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dna-private"
  }
}

resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.pri_natgw.id
  }

  tags = {
    Name = "pri_rt"
  }
}

resource "aws_route_table_association" "pri_rta" {
  subnet_id      = aws_subnet.mainvpc_pri_subnet.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "pri_natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.mainvpc_pub_subnet.id

  tags = {
    Name = "dna-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
