#!/bin/bash
function info() {
    # FIXME あなたのサーバホスト名にしてください
    printf "(xxxx.com) \e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
REPOSITORY_NAME=$1
NO_BACKEND=$2

info "1. $REPOSITORY_NAMEをclone developブランチで作業"
if [ ! -d ~/git/$REPOSITORY_NAME ]; then
    # FIXME あなたのユーザ名にしてください
    git clone -b develop https://github.com/XXX/$REPOSITORY_NAME.git ~/git/$REPOSITORY_NAME > /dev/null
else
    info 'すでにclone済み'
fi
cd ~/git/$REPOSITORY_NAME

info '2. フロント資材を配置'
mkdir -p /var/www/html/$REPOSITORY_NAME
cp -R front/* /var/www/html/$REPOSITORY_NAME
\rm /var/www/html/$REPOSITORY_NAME/Dockerfile

if [ "$NO_BACKEND" = "no-backend" ]; then
    info 'バックエンドのデプロイなし'
    # FIXME デプロイ後に処理をしたい場合はここに記述してください
    info 'DONE.'
    exit
fi

info '3. バックエンドコンテナをビルド'
CONTAINER_NAME=$(echo $REPOSITORY_NAME | tr -d '-' | tr [A-Z] [a-z])
CHK=$(docker images $CONTAINER_NAME -q)
if [ "$CHK" != "" ]; then
    echo 'イメージ名がすでに存在します'
    echo '処理を終了します'
    exit
fi
docker build -t ${CONTAINER_NAME}:latest ./back  > /dev/null

info '4. 未使用ポートを取得'
UNUSED_PORT=8080
# コンテナがホストへフォワードしているポートの最大数値
CONTAINER_USING_PORT_MAX=$(docker ps -a --format '{{.Ports}}' | sed -n 's/.*:\([0-9]*\)->.*/\1/p' | sort -nr | head -n1)
if [ "$CONTAINER_USING_PORT_MAX" != "" ]; then
    UNUSED_PORT=$((CONTAINER_USING_PORT_MAX + 1))
fi
# ホストがLISTENしていないポートである保証
until ! lsof -i :${UNUSED_PORT} > /dev/null 2>&1; do
    UNUSED_PORT=$((UNUSED_PORT + 1))
done

info '5. バックエンドコンテナを起動'
CHK=$(docker ps -aq -f name=$CONTAINER_NAME)
if [ "$CHK" != "" ]; then
    echo 'コンテナ名がすでに存在します'
    echo '処理を終了します'
    exit
fi
# FIXME docker-composeで起動したい場合、ここの記述をdocker-compose up -dなどに変更してください
docker run \
    --name $CONTAINER_NAME \
    -d \
    -p ${UNUSED_PORT}:8080 \
    -v ./back/app:/app \
    --network SOME \ # FIXME 作成済みのdockerネットワーク名
    ${CONTAINER_NAME}:latest > /dev/null

info '6. リバースプロキシを追加'
# FIXME apache前提の記述になります
sudo sh -c "cat << EOF >> /etc/httpd/conf/httpd.conf
<Location /$REPOSITORY_NAME/api>
  ProxyPass http://localhost:${UNUSED_PORT}
  ProxyPassReverse http://localhost:${UNUSED_PORT}
</Location>
EOF
"
# FIXME httpのみのため、websocketプロトコルが必要な場合は別途処理の追加をしてください

info '!! WebSocketを用いる場合、別途wsプロトコルでのリバプロ追加が必要です !!'
sleep 2

info '7. デーモン再起動'
sudo systemctl restart httpd

# FIXME デプロイ後に処理をしたい場合はここに記述してください

info 'DONE.'

