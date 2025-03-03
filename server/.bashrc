[ -z "$PS1" ] && return
# 対話型ではない接続の場合は、以降を読み込まない

if [ -f /etc/bashrc ];then
    . /etc/bashrc
fi

alias v='vim'
alias l='ls -AFlihrt --color=auto'
alias ll='ls -AFlihrt --color=auto'
alias tree="pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"
alias rm='rm -i'
alias rmf='confirm rm -rf'
alias re='exec $SHELL -l'
alias q='exit'

function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function warn() {
    printf "\e[32m[\e[33mWARN\e[32m] \e[34m$1\e[m\n"
}
function error() {
    printf "\e[32m[\e[31mERROR\e[32m] \e[34m$1\e[m\n"
}

function confirm() {
    CMD=$@
    if [ -n "$ZSH_VERSION" ]; then
        read "input?Are you sure? (y/n):"
    else
        read -p "Are you sure? (y/n):" input
    fi
    if [ "$input" = "y" ]; then
        eval $CMD
    else
        info "cancel"
    fi
}

info 'Welcome to neras-sta.com'

