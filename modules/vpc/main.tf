# modules/vpc/main.tf

# VPC #テストコードを入れる
resource "aws_vpc" "aws_study_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aws-study-vpc"
  }
}

# パブリックサブネット　#テストコードを入れる
resource "aws_subnet" "MyPublicSubnet1" {
  vpc_id                  = aws_vpc.aws_study_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "MyPublicSubnet1"
  }
}

resource "aws_subnet" "MyPublicSubnet2" {
  vpc_id                  = aws_vpc.aws_study_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  
  tags = {
    Name = "MyPublicSubnet2"
  }
}

# プライベートサブネット
resource "aws_subnet" "PrivateSubnet1" {
  vpc_id            = aws_vpc.aws_study_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id            = aws_vpc.aws_study_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "PrivateSubnet2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "aws_study_igw" {
  vpc_id = aws_vpc.aws_study_vpc.id

  tags = {
    Name = "aws-study-igw"
  }
}

# パブリックルートテーブル
resource "aws_route_table" "MyPublicRouteTable" {
  vpc_id = aws_vpc.aws_study_vpc.id

  tags = {
    Name = "MyPublicRouteTable"
  }
}

# プライベートルートテーブル
resource "aws_route_table" "MyPrivateRouteTable" {
  vpc_id = aws_vpc.aws_study_vpc.id

  tags = {
    Name = "MyPrivateRouteTable"
  }
}

# パブリックルート
resource "aws_route" "MyPublicRoute" {
  route_table_id         = aws_route_table.MyPublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_study_igw.id
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "MyPublicSubnet1RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPublicSubnet1.id
  route_table_id = aws_route_table.MyPublicRouteTable.id
}

resource "aws_route_table_association" "MyPublicSubnet2RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPublicSubnet2.id
  route_table_id = aws_route_table.MyPublicRouteTable.id
}

resource "aws_route_table_association" "PrivateSubnet1RouteTableAssociation" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.MyPrivateRouteTable.id
}

resource "aws_route_table_association" "PrivateSubnet2RouteTableAssociation" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.MyPrivateRouteTable.id
}
