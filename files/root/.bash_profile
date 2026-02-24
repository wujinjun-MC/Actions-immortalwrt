if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.inputrc ]
then
    bind -f ~/.inputrc
fi

#export HISTCONTROL=ignoreboth #ignoredups:ignorespace
#shopt -s histappend
export HISTSIZE=10000000
export HISTFILESIZE=20000000
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
stty -ixon

if [ $(id -u) = 0 ]
then
    export GIT_CLONE_DIR="/opt/git"
else
    export GIT_CLONE_DIR=~/git
fi
export GPG_TTY=$(tty)
mkdir -p "$GIT_CLONE_DIR"
