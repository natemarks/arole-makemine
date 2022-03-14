variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  ami_name                    = "ansible-test-arole-makemine-ubuntu"
  # use force_deregister and force_delete-snapshot to overwrite the AMI
  force_deregister            = true
  force_delete_snapshot       = true
  instance_type               = "t2.micro"
  region                      = "us-east-1"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  source_ami_filter {
    filters     = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username                = "ubuntu"
  ssh_interface               = "public_ip"
  associate_public_ip_address = true
}

build {
  name = "ansible-test-arole-makemine"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "file" {
    source = "./scripts"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "./files"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = ["bash /tmp/scripts/install_desktop_gui/ubuntu-20.04/install_ubuntu_desktop.sh"]
  }
  provisioner "shell" {
    inline = ["bash /tmp/scripts/install_ansible_prereqs/ubuntu-20.04/install_ansible_prereqs.sh"]
  }
  provisioner "shell" {
    inline = ["bash /tmp/scripts/create_test_user/ubuntu-20.04/create_test_user.sh"]
  }
}
