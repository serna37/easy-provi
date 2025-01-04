#!/bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}
info 'forge gen: Assembly Line Protocol initiation.'
if ! gum confirm; then
    info 'cancel.'
    exit
fi

info 'リポジトリ作成、デプロイ(optional)を開始します。'
info '元となるテンプレートリポジトリを選択してください'
TEMPLATE_REPO=$(gh repo ls --json name --json isTemplate --json isArchived | jq -r '.[] | select(.isTemplate == true and .isArchived == false) | .name' | gum choose)

NEW_NAME=TestRepository
info 'リポジトリ名を指定してください'
REPOSITORY_NAME=$(gum input --prompt='❯ ' --header='Repository name' --value="$NEW_NAME")
info 'リポジトリ説明を入力してください'
REPOSITPRY_DESCRIPTION=$(gum input --prompt='❯ ' --header='Repository description' --placeholder='to notice salary.')
# FIXME お好きなホームページを入力
HOMEPAGE_URL="https://github.com/xxx"

# FIXME お好きなフォルダ位置にしてください
cd ~/git
spin 'Creating repository...' gh repo create \
    $REPOSITORY_NAME \
    --private \
    # FIXME あなたのユーザ名を入力
    --template XXX/$TEMPLATE_REPO \
    --description "$REPOSITPRY_DESCRIPTION" \
    --homepage "$HOMEPAGE_URL" \
    --clone
info "リポジトリを作成、クローンしました: ~/git/$REPOSITORY_NAME"
cd $REPOSITORY_NAME

info 'トピックを入力してください'
TOPICS=$(gum input --prompt='❯ ' --header='Input topics split by space' --placeholder='vim python js')
for v in ${TOPICS[@]}; do
    spin "Adding topic $v ..." gh repo edit --add-topic $v
done
info "トピックを追加しました: $TOPICS"

# FIXME お好きなブランチ構成にしてください
spin 'switch to a new branch develop' git checkout -b develop
spin 'regist develop to origin' git push -u origin develop
spin 'regist develop to default branch' gh repo edit --default-branch develop
spin 'delete main branch on origin' git push --delete origin main
spin 'delete main branch on local' git branch -D main
info 'ブランチdevelopをデフォルトに設定しました'
info 'develop -> release -> master の3ブランチを使用してください'

# FIXME templateリポジトリのreplace.shを起動できます
# テンプレート作成後に文字列置換などをしたいshellがあれば登録できます
if [ -f "replace.sh" ]; then
    sh replace.sh $REPOSITORY_NAME
    \rm replace.sh
    spin 'staging' git add --all
    spin 'commit' git commit -m 'forge gen'
    spin 'push replaced template' git push
    info 'テンプレートのリポジトリ名を置換しました'
fi

info '今すぐサーバにデプロイしますか？'
IS_DEPLOY=$(gum choose --header='deploy now?' 'yes' 'no')
if [ "$IS_DEPLOY" = "yes" ]; then
    info 'バックエンドコンテナをデプロイしますか？'
    NO_BACKEND=$(gum choose --header='deploy backend?' 'yes' 'no-backend')
    # FIXME あなたのサーバへssh接続する記述になります
    ssh USERNAME@xxxx.com "sh ~/git/forge/init-deploy.sh $REPOSITORY_NAME $NO_BACKEND"
fi

info '全てのシーケンスが完了しました。'
info 'GitHub ActionsでCI/CDを用いる場合など、別途シークレット登録が必要です。'
info "サンプル"
info "gh secret set PASS_WORD --body 'xxxxxx'"

spin 'gh browse' gh browse

