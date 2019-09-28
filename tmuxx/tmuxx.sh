#!/bin/bash

# Create custom tmux session for work (25Sprout)
#
# Author: haw


# Variables declaration
_session_name='25Sprout'

# Check session existence
tmux ls | cut -d : -f 1 | grep 25Sprout > /dev/null
if [[ "${?}" -eq 0 ]]; then
    echo "Session name: ${_session_name} exists"
    exit 1
fi


# Create tmux session
tmux new -s "${_session_name}" -n 'cur' -d

tmux new-window -t "${_session_name}:1" -n 'l1'  
tmux new-window -t "${_session_name}:2" -n 'l2'  
tmux new-window -t "${_session_name}:3" -n 'l3'  
tmux new-window -t "${_session_name}:4" -n 'l4'  
tmux new-window -t "${_session_name}:5" -n 'l5'  
tmux new-window -t "${_session_name}:6" -n 'l6'  
tmux new-window -t "${_session_name}:7" -n 'l7'  
tmux new-window -t "${_session_name}:9" -n 'ryzen'  

tmux select-window -t "${_session_name}:0"
tmux a -t "${_session_name}"