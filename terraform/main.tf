data "aws_ami" "latestLinuxAMI" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2" {
  ami                     = data.aws_ami.latestLinuxAMI.id
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.this.id
  iam_instance_profile    = "LabInstanceProfile"
  security_groups         = [aws_security_group.docker_sg.id]
  key_name                = "docker"
}


resource "aws_ecr_repository" "database" {
  name = "database"
}

resource "aws_ecr_repository" "application" {
  name = "application"
}