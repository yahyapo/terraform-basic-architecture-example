

resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.central_vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "${var.availability_zone}"
}


resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.central_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.central_vpc.id}"
  }

}

resource "aws_route_table_association" "association" {
  subnet_id = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
    name = "terraform_example"
    description = "Used in the terraform"

    # SSH access from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.central_vpc.id}"
}


resource "aws_elb" "web" {
  name = "terraform-example-elb"

  subnets = ["${aws_subnet.subnet.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  # The instance is registered automatically
  instances = ["${aws_instance.web.id}"]
}


resource "aws_instance" "web" {

  ami = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type = "t2.micro"
  availability_zone = "${var.availability_zone}"
  subnet_id = "${aws_subnet.subnet.id}"
  associate_public_ip_address = true

  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
        "sudo yum -y install nginx",
        "sudo service nginx start"
    ]
    connection {
      # The default username for our AMI
      user = "ec2-user"

      # The path to your keyfile
      key_file = "${var.key_path}"
    }
  }
}
