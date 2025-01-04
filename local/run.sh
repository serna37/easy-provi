#!/bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}

# Dockerエンジン
# FIXME OrbStackの使用を前提としています。
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
# FIXME ポート番号はお好きなものに変更いただけます
BACKEND_PORT_NUM=8080
FRONTEND_PORT_NUM=3000
OPEN_URLS=()

info '起動対象を選択してください(複数)'
TARGETS=$(git ls-files | grep Dockerfile | gum choose --no-limit)

for v in ${TARGETS[@]}; do
    if [ "$v" = "back/Dockerfile" ]; then
        info 'バックエンド起動'
        spin 'docker build' docker build -t ${CONTAINER_NAME}:latest ./back
        spin 'docker run' docker run \
            --name $CONTAINER_NAME \
            -d \
            -p ${BACKEND_PORT_NUM}:8080 \
            -v ./back/app:/app \
            ${CONTAINER_NAME}:latest
        OPEN_URLS+=("http://localhost:${BACKEND_PORT_NUM}/docs")
        OPEN_URLS+=("http://localhost:${BACKEND_PORT_NUM}/redoc")
    fi
    if [ "$v" = "front/Dockerfile" ]; then
        info 'フロント起動'
        spin 'docker build' docker build -t ${FRONT_CONTAINER_NAME}:latest ./front
        spin 'docker run' docker run \
            --name ${FRONT_CONTAINER_NAME} \
            -d \
            -p ${FRONTEND_PORT_NUM}:3000 \
            -v ./front:/work \
            ${FRONT_CONTAINER_NAME}:latest
        OPEN_URLS+=("http://localhost:${FRONTEND_PORT_NUM}")
    fi
    if [ "$v" = "Dockerfile" ]; then
        info '現在位置のDockerfileを起動します'
        info 'forgeコマンドが前提とするフォルダ構成でないため、注意してください'
        if ! gum confirm; then
            continue
        fi
        NAME=$(gum input --prompt='>> コンテナ名: ')
        spin 'docker build' docker build -t ${NAME}:latest .
        info 'ポートフォワードしますか?'
        if gum confirm; then
            HOST_PORT=$(gum input --prompt='>> ホストポート番号: ')
            CONT_PORT=$(gum input --prompt='>> コンテナポート番号: ')
            PORT_FWD="-p ${HOST_PORT}:${CONT_PORT}"
        fi
        info 'バインドマウントしますか？'
        if gum confirm; then
            info 'ホスト側は相対パス記述でないと、ボリュームマウントになります'
            info 'optionを記述してください(複数可)'
            BIND_MNT=$(gum input --prompt='>> ' --value="-v ./app:/app")
        fi
        spin 'docker run' docker run \
            --name ${NAME} \
            -d \
            $PORT_FWD \
            $BIND_MNT \
            ${NAME}:latest
        OPEN_URLS+=("http://localhost:${HOST_PORT}")
    fi
done

if [ "$(uname -s)" = "Darwin" ]; then
    for v in ${OPEN_URLS[@]}; do
        open -a '/Applications/Google Chrome.app' $v
    done
fi

info 'DONE.'

