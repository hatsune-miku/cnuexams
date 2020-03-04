# System-wide .bashrc file for interactive bash(1) shells.
if [ -z "$PS1" ]; then
   return
fi

# PS1='\h:\W \u\$ '
# Make bash check its window size after a process completes
shopt -s checkwinsize

[ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM"


export PS1='\n 🍭 \[\e[01;32m\]\u@miku\e[00m\]:\[\e[01;34m\]\w\[\e[00m\] ~ \e[36m\]\^O^/ \e[30;36m\]\d \t\e[00;00m\]\n $ '

