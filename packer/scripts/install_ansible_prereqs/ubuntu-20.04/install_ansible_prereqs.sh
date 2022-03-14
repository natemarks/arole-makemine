#!/usr/bin/env bash

set -Eeuoxv pipefail

sudo apt install -y python3 python3-pip git

sudo python3 -m pip install --upgrade pip setuptools
sudo python3 -m pip install ansible pytest pytest-testinfra molecule botocore boto3 json-logging PyYAML

sudo python3 -m pip list
sudo python3 -m site

# configure ansible to us the hosts (localhost) paths that the pacaker provisioner wants to use
# ansible-playbook ansible/build_azure_agent_ami.yml should work the same way the provisioner does
# ths is important for troubleshooting

# backup the default config files
sudo cp /etc/ansible/hosts /etc/ansible/hosts.orig || true
sudo cp /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.orig || true

# set the roles directory to match the provisioning staging dir: /ansible/roles
# set the default transport to local
sudo mkdir -p /etc/ansible
sudo cp /tmp/files/install_ansible_prereqs/al2/etc/ansible/ansible.cfg /etc/ansible
sudo chmod 644 /etc/ansible/ansible.cfg

# define a single host named 'localhost' wth the value 127.0.0.1
sudo cp /tmp/files/install_ansible_prereqs/al2/etc/ansible/hosts /etc/ansible
sudo chmod 644 /etc/ansible/hosts

sudo chown -R root:root /etc/ansible

# the provisioner will ise this path to upload the roles. create it and grant the permissions
# the provisioner will use
sudo mkdir /ansible
sudo chown -R ubuntu:root /ansible
