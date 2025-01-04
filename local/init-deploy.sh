#!bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}
info 'forge init-deploy'
if ! gum confirm; then
    info 'cancel.'
    exit
fi

cd $(git rev-parse --show-toplevel)
REPOSITORY_NAME=$(basename -s .git `git remote get-url origin`)

info 'バックエンドコンテナをデプロイしますか？'
NO_BACKEND=$(gum choose --header='deploy backend?' 'yes' 'no-backend')
# FIXME あなたのサーバへssh接続する記述になります
ssh USERNAME@xxxx.com "sh ~/git/forge/init-deploy.sh $REPOSITORY_NAME $NO_BACKEND"

