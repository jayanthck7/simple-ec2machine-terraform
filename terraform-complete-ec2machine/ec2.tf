## we are configuring key pair	

resource aws_key_pair my_key {
  key_name   = "terra-key"
  public_key = file("terra-key.pub)"
}

####VPC

resource aws_default_vpc default {
  tags = {
    Name = "Default VPC"
  }
}

###security group

resource aws_security_group sgp {
  name = "auto_sg"
  vpc_id  = aws_default_vpc.default.id  ###interpolation concept

##inbound rules ingress
 ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    from_port   = 80
    protocol = "tcp"
    to_port     = 80
  }

ingress {
 cidr_blocks  = ["0.0.0.0/0"]
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
 }

##outbound rules 
  egress {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol = "-1" ## for all ports
  to_port     = 0


###main part ec2 instance creation

resource "aws_instance" "my_instance" {
   key_name = aws_key_pair.my_key.key_name  
   security_groups = [aws_security_group.sgp.name]
   instance_type = "t2.micro"
   ami = "ami-0b6c6ebed2801a5cb"
   
## storage 
 root_block_device {
   volume_size = 10
   volume_type = "gp3"

 tags = {
    name = "my-ec2"
    }
}
 
