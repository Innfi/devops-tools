#!/bin/sh
ansible-playbook -i ./inventory -u ec2-user ./docker_pull.yaml
