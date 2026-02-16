# Terraform AWS EC2 Setup
# This configuration:
# - Uploads SSH public key to AWS
# - Uses default VPC
# - Creates Security Group (HTTP + SSH)
# - Launches EC2 instance
############################
# 1️⃣ Key Pair Configuration

resource "aws_key_pair" "my_key" {
  key_name   = "terra-key"

  # Reads public key file from local machine
  # Make sure terra-key.pub exists in this directory
  public_key = file("../terra-key.pub")
}

# 2️⃣ Use Default VPC
############################

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default-VPC"
  }
}

############################
# 3️⃣ Security Group

resource "aws_security_group" "sgp" {
  name   = "auto_sg"
  vpc_id = aws_default_vpc.default.id

  # Allow HTTP (Port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (Port 22) from anywhere
  # ⚠️ In real projects, restrict to your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "auto_sg"
  }
}

############################
# 4️⃣ EC2 Instance Creation

resource "aws_instance" "my_instance" {

  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"

  # Attach uploaded key pair
  key_name = aws_key_pair.my_key.key_name

  # Attach security group
  vpc_security_group_ids = [aws_security_group.sgp.id]

  # Root storage configuration
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "my-ec2"
  }
}
