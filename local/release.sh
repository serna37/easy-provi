#!/bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}
info "Start release."
if ! gum confirm; then
    info "cancel."
    exit
fi

cd $(git rev-parse --show-toplevel)
info '更新するバージョン情報を選択してください'
UPDATE_TARGET=$(gum choose --height 5 --cursor="❯ " --header="Update Version" "major" "minor" "patch")
info 'リリースノートを記入してください'
gum write > ~/___tmp.release_note.txt

# FIXME ブランチ構成がdevelop、release、masterの前提です
# developは初期作成しているが
# release, masterは未作成の可能性もある
info '1. developをpull'
spin 'checkout develop' git checkout develop
spin 'pull develop' git pull

info '2. タグを更新'
spin 'fetch tags' git pull --tags
LATEST_TAG=$(git rev-list --tags --max-count=1)
if [ "$LATEST_TAG" != "" ]; then
    LATEST_TAG=$(git describe --tags $LATEST_TAG || echo 'v0.0.0')
else
    LATEST_TAG='v0.0.0'
fi
info "current tag: $LATEST_TAG"
VERSION_NUMS=($(echo "$LATEST_TAG" | sed 's/^v//' | tr '.' ' '))
MAJOR=${VERSION_NUMS[0]}
MINOR=${VERSION_NUMS[1]}
PATCH=${VERSION_NUMS[2]}
NEW_MAJOR=0
NEW_MINOR=0
NEW_PATCH=0
if [ "$UPDATE_TARGET" = "major" ]; then
    NEW_MAJOR=$((MAJOR + 1))
elif [ "$UPDATE_TARGET" = "minor" ]; then
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$((MINOR + 1))
elif [ "$UPDATE_TARGET" = "patch" ]; then
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$MINOR
    NEW_PATCH=$((PATCH + 1))
fi
NEW_TAG=v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}
info "new tag: $NEW_TAG"

sed -i '' "s/v${MAJOR}.${MINOR}.${PATCH}/v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}/g" README.md
spin 'staging' git add README.md
spin 'commit README update' git commit -m "update tag badge $NEW_TAG"
spin 'push README update' git push
info 'READMEを更新しました'

ch_mg() {
    BASE_BRANCH=$1
    TARGET_BRANCH=$2
    CHK=$(git branch -r | grep -c $TARGET_BRANCH)
    if [ $CHK -eq 0 ]; then
        spin "checkout $TARGET_BRANCH" git checkout -b $TARGET_BRANCH
        spin "merge $BASE_BRANCH -> $TARGET_BRANCH" git merge $BASE_BRANCH -m "forge release"
        spin "regist & push $TARGET_BRANCH" git push -u origin $TARGET_BRANCH
    else
        spin "checkout $TARGET_BRANCH" git checkout $TARGET_BRANCH
        spin "pull $TARGET_BRANCH" git pull
        spin "merge $BASE_BRANCH -> $TARGET_BRANCH" git merge $BASE_BRANCH -m "forge release"
        spin "push $TARGET_BRANCH" git push
    fi
}

info '3. マージ develop -> release'
ch_mg develop release

info '4. マージ release -> master'
ch_mg release master

info '5. タグ作成とリリース'
spin "create tag: $NEW_TAG" git tag $NEW_TAG
spin 'push tag' git push --tags
spin 'release' gh release create $NEW_TAG -n "$(cat ~/___tmp.release_note.txt)" -t $NEW_TAG
\rm ~/___tmp.release_note.txt

spin 'checkout develop' git checkout develop
info 'DONE.'

