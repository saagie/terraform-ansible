#!/bin/bash

mkdir -p /root/.ssh
echo "Host *" > /root/.ssh/config
echo "  ForwardAgent yes" >> /root/.ssh/config
echo "  StrictHostKeyChecking no" >> /root/.ssh/config
eval $(ssh-agent)
echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >> /etc/bashrc
echo "export SSH_AGENT_PID=${SSH_AGENT_PID}" >> /etc/bashrc

exec "$@"