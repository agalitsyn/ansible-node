#@IgnoreInspection BashAddShebang
export EDITOR=vim

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS --group-directories-first -p -CAFh';
alias l='ls -lAh $LS_OPTIONS --group-directories-first';
alias ll='ls -lah $LS_OPTIONS --group-directories-first'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias grep='grep --color=auto'

export PS1="\[$(tput setaf 1)\]\u@\h:\w $ \[$(tput sgr0)\]"

alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"
