resource "aws_security_group" "docker_sg" {
  name        = "docker_security_group"
  description = "Security group for Docker Compose app"
  vpc_id      = data.aws_vpc.default.id

 ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 5001
    to_port          = 5001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 5002
    to_port          = 5002
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 5003
    to_port          = 5003
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
