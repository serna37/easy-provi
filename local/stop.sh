#!/bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}

# Dockerエンジン
CNT=$(ps aux | grep -c OrbStack)
if [ $CNT -eq 1 ]; then
    APP_LIST=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)')
    if [[ ! $APP_LIST =~ "OrbStack" ]]; then
        info "START OrbStack"
        open -g /Applications/OrbStack.app
    fi
    open -g /Applications/OrbStack.app
    sleep 1
    genact -s 10 --exit-after-modules 1 -m botnet
    genact -s 10 --exit-after-modules 1 -m bruteforce
fi

cd $(git rev-parse --show-toplevel)
REPOSITORY_NAME=$(basename -s .git `git remote get-url origin`)
CONTAINER_NAME=$(echo $REPOSITORY_NAME | tr -d '-' | tr [A-Z] [a-z])
FRONT_CONTAINER_NAME=${CONTAINER_NAME}-front

info 'コンテナ名と一致しないイメージは削除できません'
info '停止/削除対象を選択してください(複数)'
TARGETS=$(gum choose --no-limit $CONTAINER_NAME $FRONT_CONTAINER_NAME)
info 'その他のコンテナも停止しますか？'
if gum confirm; then
    MORE=$(docker ps -a --format '{{.Names}}')
    ADDITIONAL=$(gum choose --no-limit $MORE)
    for v in ${ADDITIONAL[@]}; do
        TARGETS+=($v)
    done
fi

for v in ${TARGETS[@]}; do
    spin "docker stop: $v" docker stop $(docker ps -aq -f name=$v)
    spin "docker rm: $v" docker rm $(docker ps -aq -f name=$v)
    spin "docker rmi: $v" docker rmi $(docker images $v -q)
    #kill $(lsof -t -i :${FRONTEND_PORT_NUM})
done

info 'DONE.'

