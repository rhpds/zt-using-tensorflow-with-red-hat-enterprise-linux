#!/bin/bash

subscription-manager config --rhsm.manage_repos=1
subscription-manager register --activationkey=${ACTIVATION_KEY} --org=12451665 --force

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "setting password" >> /root/post-run.log
echo redhat | passwd --stdin rhel

echo "trashing GCP repos" >> /root/post-run.log
mv /etc/yum.repos.d/google-cloud.repo /root


#set up tmux so it has to restart itself whenever the system reboots

#step 1: make a script
tee ~/startup-tmux.sh << EOF
TMUX='' tmux new-session -d -s 'rhel-session' > /dev/null 2>&1
tmux set -g pane-border-status top
tmux setw -g pane-border-format ' #{pane_index} #{pane_current_command}'
tmux set -g mouse on
tmux set mouse on
tmux unbind -n MouseDown3Pane
EOF

#step 2: make it executable
chmod +x ~/startup-tmux.sh
#step 3: use cron to execute 
echo "@reboot ~/startup-tmux.sh" | crontab -

#step 4: start tmux for the lab
~/startup-tmux.sh

echo "DONE" >> /root/post-run.log
