#!/usr/bin/env bash
sudo useradd -m -d /home/testansible -s /bin/bash -g sudo testansible
echo "testansible:testansible" | sudo chpasswd