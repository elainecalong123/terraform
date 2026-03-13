# 1. VPC Definition
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.environment}-vpc" }
}

# 2. Public Subnets (For ALBs and NAT Gateway)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.environment}-public-${count.index}" }
}

# 3. Private Subnets (For ECS, RDS, and Redis)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = var.availability_zones[count.index]

  tags = { Name = "${var.environment}-private-${count.index}" }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# 5. NAT Gateway (Allows ECS tasks to pull images from ECR safely)
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Placed in the first public AZ
}

# 6. Routing
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 7. EXPORT TO SSM (The "Bridge" to your Apps)
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/infra/${var.environment}/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "private_subnets" {
  name  = "/infra/${var.environment}/private_subnets"
  type  = "String"
  value = join(",", aws_subnet.private[*].id)
}

resource "aws_ssm_parameter" "public_subnets" {
  name  = "/infra/${var.environment}/public_subnets"
  type  = "String"
  value = join(",", aws_subnet.public[*].id)
}

resource "aws_route53_zone" "main" {
  name = var.domain_name # e.g., yourcompany.com
}

resource "aws_route53_zone" "main" {
  name = var.domain_name # e.g., yourcompany.com
}

# Save the Zone ID to SSM so the Apps can "Discover" it
resource "aws_ssm_parameter" "zone_id" {
  name  = "/infra/${var.environment}/zone_id"
  type  = "String"
  value = aws_route53_zone.main.zone_id
}