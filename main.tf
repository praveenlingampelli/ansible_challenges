resource "aws_instance" "jenkins-controller" {
  ami           = "ami-0d92749d46e71c34c"
  instance_type = "t2.micro"
  key_name = "ansible"
  associate_public_ip_address = true
  tags = {
    Name = "jenkins-controller"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-17-amazon-corretto-devel
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
              sudo yum install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              sudo systemctl status jenkins
              EOF
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "c8" {
  ami           = "ami-0d92749d46e71c34c"  // Amazon Linux AMI ID
  instance_type = "t2.micro"
  key_name = "ansible"
  user_data     = <<-EOF
                 #!/bin/bash
                 sudo hostnamectl set-hostname c8.local
                 EOF
  tags = {
    Name = "c8.local"
  }
}
resource "aws_instance" "u21" {
  ami           = "ami-0a7cf821b91bcccbc"  // Ubuntu 21.04 AMI ID
  instance_type = "t2.micro"
  key_name = "ansible"
  user_data     = <<-EOF
                 #!/bin/bash
                 sudo hostnamectl set-hostname u21.local
                 EOF
  tags = {
    Name = "u21.local"
  }
}
data "template_file" "ansible_inventory" {
  template = <<-EOT
    [frontend]
    ${aws_instance.c8.private_ip}
    [backend]
    ${aws_instance.u21.private_ip}
  EOT
}
resource "local_file" "ansible_inventory" {
    filename = "inventory.yml"
    content= data.template_file.ansible_inventory.rendered
  }