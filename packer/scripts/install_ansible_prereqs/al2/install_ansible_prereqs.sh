#!/usr/bin/env bash

set -Eeuoxv pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

setup_colors

# script logic here
cat << EOF > /tmp/global_usr_local_bin.sh
# /etc/profiles.d/global_usr_local_bin.sh
#  globally update path to include /usr/local/bin
export PATH="/usr/local/bin:$PATH"
EOF
sudo mv /tmp/global_usr_local_bin.sh /etc/profile.d
sudo chmod 644 /etc/profile.d/global_usr_local_bin.sh
export PATH="/usr/local/bin:$PATH"
# python2 will be the default for amazon linux 2, but we'll add the python3 binary
# ansible  is installed in the default python2  site path
msg "${GREEN}Installing python3 and ansible2${NOFORMAT}"
sleep 10
sudo amazon-linux-extras install python3.8

# these pip install commnad occaasionally fail with dependency  errors. re-running
# the packer build seems to solve it, but perhaaps aa better instance type or waiting/timing might wif the problem
sleep 5
sudo ln -s /usr/bin/python3.8 /usr/bin/python3
sudo python3 -m pip install --upgrade pip setuptools
sleep 5
sudo python3 -m pip install ansible pytest pytest-testinfra molecule awscli boto3 json-logging PyYAML
msg "${GREEN}Verify installed modules${NOFORMAT}"
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
sudo chown -R ec2-user:root /ansible

# install ansible aws collection

# because we use ansible fro amazon-linux-extras, we have to provide required
# packaages to the system-wide python2  site

sudo yum install -y python-pip
# boto3 and botocore have to be in the python2 site for the ansible
# amazon.aws collection
sudo /usr/bin/python -m pip install boto3 botocore

ansible-galaxy collection install amazon.aws