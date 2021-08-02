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

# Keep a reasonably long history.
export HISTSIZE=50000000

# Keep even more history lines inside the file, so we can still look up
# previous commands without needlessly cluttering the current shell's history.
export HISTFILESIZE=$HISTSIZE;

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoredups

# Keep track of the time the commands were executed.
# The xterm colour escapes require special care when piping; e.g. "| less -R".
# timestamps for bash history. www.debian-administration.org/users/rossen/weblog/1
export HISTTIMEFORMAT="${FG_BLUE}${FONT_BOLD}%Y/%m/%d %H:%M:%S${FONT_RESET}  ";

# Make some commands not show up in history
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"
