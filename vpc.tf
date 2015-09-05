resource "aws_vpc" "central_vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "central_vpc"
    id-tag = "central_vpc"
  }
}

resource "aws_internet_gateway" "central_vpc" {
  vpc_id = "${aws_vpc.central_vpc.id}"
}
