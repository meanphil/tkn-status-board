#!/usr/local/bin/bash

export LANG=en_NZ.UTF-8

export EDITOR=vim
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

export SSH_ENV="$HOME/.ssh/environment"


# WB: startx if it isn't already running
XPID=`/usr/bin/pgrep xinit`

if [ -n "$XPID" ]; then
  echo "X is already running"
else
  god -c ~/status-board/god.conf
  sleep 2
  echo "POWER ON" | nc -N localhost 4684
  startx -- -nocursor
  logout
fi
