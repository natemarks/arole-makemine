variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami_owner" {
  type = string
}

variable "role_name" {
  type = string
  default = "makemine"
}


source "amazon-ebs" "ubuntu" {
  ami_name                    = "run-ansible-test-arole-${var.role_name}-ubuntu"
  # use force_deregister and force_delete-snapshot to overwrite the AMI
  instance_type               = "t2.micro"
  region                      = "us-east-1"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  source_ami_filter {
    filters     = {
      name                = "ansible-test-arole-${var.role_name}-ubuntu"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["${var.ami_owner}"]
  }
  ssh_username                = "ubuntu"
  ssh_interface               = "public_ip"
  associate_public_ip_address = true
  skip_create_ami = true

}

build {
  name = "ansible-test-arole-makemine"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source = "./upload"

    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/ansible",
      "sudo mv /tmp/upload /opt/ansible/${var.role_name}",
      "ls /opt/ansible/${var.role_name}"
    ]
  }

  provisioner "shell" {
    inline = [
      "/usr/local/bin/ansible-playbook /opt/ansible/makemine/playbook/local_test.yml",
      "sudo PATH=\"/usr/local/bin:$PATH\" python3 -m pytest -v /opt/ansible/makemine/test"
    ]
  }
}
