provider "aws" {
  region     = "us-east-1"
  access_key = "aws_access_key"
  secret_key = "aws_secret_key"
}

# VPCs

resource "aws_vpc" "mgt-vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Management VPC"
  }
}

resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Production VPC"
  }
}

resource "aws_vpc" "dev-vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Development VPC"
  }
}


# Subnets (Management)

#Private

resource "aws_subnet" "mgt-private-az1" {
  vpc_id = "${aws_vpc.mgt-vpc.id}"
  cidr_block = "192.168.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Mgt-Private-AZ1"
  }
}

resource "aws_subnet" "mgt-private-az2" {
  vpc_id = "${aws_vpc.mgt-vpc.id}"
  cidr_block = "192.168.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Mgt-Private-AZ2"
  }
}

#Public

resource "aws_subnet" "mgt-public-az1" {
  vpc_id = "${aws_vpc.mgt-vpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Mgt-Public-AZ1"
  }
}

resource "aws_subnet" "mgt-public-az2" {
  vpc_id = "${aws_vpc.mgt-vpc.id}"
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Mgt-Public-AZ2"
  }
}

# Subnets (Production)

#Private

resource "aws_subnet" "prod-private-az1" {
  vpc_id = "${aws_vpc.prod-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod-Private-AZ1"
  }
}

resource "aws_subnet" "prod-private-az2" {
  vpc_id = "${aws_vpc.prod-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Prod-Private-AZ2"
  }
}

# Subnets (Development)

#Private

resource "aws_subnet" "dev-private-az1" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Dev-Private-AZ1"
  }
}

resource "aws_subnet" "dev-private-az2" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Dev-Private-AZ2"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.mgt-vpc.id}"
  tags = {
    Name = "igw"
  }
}

 #Transit Gateway 
resource "aws_ec2_transit_gateway" "tgw" {
  tags = {
    Name = "tgw"
  }
}

#Transit Gateway RT
resource "aws_ec2_transit_gateway_route_table" "tgw-app-rt" {   
transit_gateway_id = aws_ec2_transit_gateway.tgw.id  
}

#Transit Gateway Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attach-mgt-vpc" {
  subnet_ids         = [aws_subnet.mgt-private-az1.id, aws_subnet.mgt-private-az2.id] 
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.mgt-vpc.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attach-prod-vpc" {
  subnet_ids         = [aws_subnet.prod-private-az1.id, aws_subnet.prod-private-az2.id] 
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.prod-vpc.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attach-dev-vpc" {
  subnet_ids         = [aws_subnet.dev-private-az1.id, aws_subnet.dev-private-az2.id] 
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.dev-vpc.id
}

# Elastic IP 
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}


# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.mgt-public-az1.*.id, 0)

  tags = {
    Name  = "nat"
  }
}

# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "mgt-private-rt" {
  vpc_id = aws_vpc.mgt-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat.id
  }

  tags = {
    Name  = "private-route-table"
  }
}

#Private RT Route Association
resource "aws_route_table_association" "private-az1" {
  subnet_id      = aws_subnet.mgt-private-az1.id
  route_table_id = aws_route_table.mgt-private-rt.id
}

resource "aws_route_table_association" "private-az2" {
  subnet_id      = aws_subnet.mgt-private-az2.id
  route_table_id = aws_route_table.mgt-private-rt.id
}

/*# Routes from Private RT
resource "aws_route" "private-route1" {
  route_table_id         = aws_route_table.mgt-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
*/

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "mgt-public-rt" {
  vpc_id = aws_vpc.mgt-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  route {
    cidr_block = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name        = "public-route-table"
  }
}

#Public RT Route Association
resource "aws_route_table_association" "public-az1" {
  subnet_id      = aws_subnet.mgt-public-az1.id
  route_table_id = aws_route_table.mgt-public-rt.id
}

resource "aws_route_table_association" "public-az2" {
  subnet_id      = aws_subnet.mgt-public-az2.id
  route_table_id = aws_route_table.mgt-public-rt.id
}

/*# Routes from Public RT
resource "aws_route" "public-route1" {
  route_table_id         = aws_route_table.mgt-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "public-route2" {
  route_table_id         = aws_route_table.mgt-public-rt.id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "public-route3" {
  route_table_id         = aws_route_table.mgt-public-rt.id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}
*/
