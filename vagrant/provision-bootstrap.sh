#!/usr/bin/env bash

echo "Installing Ansible..."
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y ansible

ansible-galaxy install -r /ansible/requirements.yml
