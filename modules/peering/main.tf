# 1. Requester side (Singapore)
resource "aws_vpc_peering_connection" "this" {
  provider      = aws.primary
  vpc_id        = var.primary_vpc_id
  peer_vpc_id   = var.dr_vpc_id
  peer_region   = var.dr_region
  auto_accept   = false

  tags = {
    Name = "${var.env}-peering-sg-to-syd"
  }
}

# 2. Accepter side (Sydney)
resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.dr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = {
    Name = "${var.env}-peering-syd-to-sg"
  }
}

# 3. Route from Singapore to Sydney
resource "aws_route" "sg_to_syd" {
  provider                  = aws.primary
  count                     = length(var.primary_route_table_ids)
  route_table_id            = var.primary_route_table_ids[count.index]
  destination_cidr_block    = var.dr_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# 4. Route from Sydney to Singapore
resource "aws_route" "syd_to_sg" {
  provider                  = aws.dr
  count                     = length(var.dr_route_table_ids)
  route_table_id            = var.dr_route_table_ids[count.index]
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}