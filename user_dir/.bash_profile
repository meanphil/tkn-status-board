#!/usr/local/bin/bash

export LANG=en_NZ.UTF-8

export EDITOR=vim
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

export SSH_ENV="$HOME/.ssh/environment"

XPID=`/usr/bin/pgrep xinit`

if [ -n "$XPID" ] || [[ $(tty) != /dev/tty1 ]]; then
  echo "X is already running, or not main tty"
else
  god -c ~/status-board/god.conf
  sleep 2
  ~/status-board/aquos/power.sh on
  startx -- -nocursor
  logout
fi
