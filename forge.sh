#!/bin/bash
function info() {
    printf "\e[32m[\e[34mINFO\e[32m] \e[34m$1\e[m\n"
}
function warn() {
    printf "\e[32m[\e[33mWARN\e[32m] \e[34m$1\e[m\n"
}
function error() {
    printf "\e[32m[\e[31mERROR\e[32m] \e[34m$1\e[m\n"
}

# git gh は入っている想定
if ! type gum > /dev/null 2>&1; then
    brew install gum
fi
if ! type jq > /dev/null 2>&1; then
    brew install jq
fi
if ! type genact > /dev/null 2>&1; then
    brew install genact
fi

# ======================================================

# fetch and exec shell on private repository
# いったんファイル保存して実行しないと、for文中で一時停止とかしなさそう
function exec-remote-sh() {
    gh api \
        -H "Accept: application/vnd.github.raw" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/serna37/easy-provi/contents/$1?ref=main" \
        > ._forge_tmp.sh
    sh ._forge_tmp.sh && \rm ._forge_tmp.sh
}
function spin() {
    gum spin --title "$1" -- "${@:2}"
}

if [ "$1" = "gen" ]; then
    printf "\e[34m\n"
    echo "   ___ ";
    echo "  / __) ";
    echo " | |__   ___    ____   ____   ____       ____   ____  ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )     / _  | / _  )|  _ \ ";
    echo " | |   | |_| || |    ( ( | |( (/ /     ( ( | |( (/ / | | | | ";
    echo " |_|    \___/ |_|     \_|| | \____)     \_|| | \____)|_| |_| ";
    echo "                     (_____|           (_____| ";
    printf "\e[m\n"
    spin 'initiating...' sleep 0.5
    info '======================'
    info 'Assembly Line Protocol'
    info '======================'
    genact -s 10 --exit-after-modules 1 -m botnet
    genact -s 10 --exit-after-modules 1 -m bruteforce
    info 'start: gen-repository'
    exec-remote-sh 'local/gen.sh'
    exit 0
fi

if [ "$1" = "init-deploy" ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___                                  _         _                 _                _ ";
    echo "  / __)                                (_)       (_) _             | |              | | ";
    echo " | |__   ___    ____   ____   ____      _  ____   _ | |_   ___   _ | |  ____  ____  | |  ___   _   _ ";
    echo " |  __) / _ \  / ___) / _  | / _  )    | ||  _ \ | ||  _) (___) / || | / _  )|  _ \ | | / _ \ | | | | ";
    echo " | |   | |_| || |    ( ( | |( (/ /     | || | | || || |__      ( (_| |( (/ / | | | || || |_| || |_| | ";
    echo " |_|    \___/ |_|     \_|| | \____)    |_||_| |_||_| \___)      \____| \____)| ||_/ |_| \___/  \__  | ";
    echo "                     (_____|                                                 |_|              (____/ ";
    printf "\e[m\n"
    exec-remote-sh 'local/init-deploy.sh'
    exit 0
fi

if [ "$1" = "run" ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___ ";
    echo "  / __) ";
    echo " | |__   ___    ____   ____   ____       ____  _   _  ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )     / ___)| | | ||  _ \ ";
    echo " | |   | |_| || |    ( ( | |( (/ /     | |    | |_| || | | | ";
    echo " |_|    \___/ |_|     \_|| | \____)    |_|     \____||_| |_| ";
    echo "                     (_____| ";
    printf "\e[m\n"
    exec-remote-sh 'local/run.sh'
    exit 0
fi

if [ $# -eq 0 ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___                             ";
    echo "  / __)                            ";
    echo " | |__   ___    ____   ____   ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )";
    echo " | |   | |_| || |    ( ( | |( (/ / ";
    echo " |_|    \___/ |_|     \_|| | \____)";
    echo "                     (_____| ";
    printf "\e[m\n"
    cd $(git rev-parse --show-toplevel)
    # FIXME Pythonが不用であれば、仮想環境起動は不用
    spin 'Python venv activation' python -m venv venv
    . venv/bin/activate
    REQ=$(git ls-files | grep -m 1 requirements.txt)
    if [ "$REQ" != "" ]; then
        spin 'pip install requirements' pip install -r $REQ
    fi
    # FIXME vimかつcoc.nvimの前提となっています
    vim -c "CocCommand explorer --no-focus --width 30"
fi

if [ "$1" = "test" ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___ ";
    echo "  / __)                                 _                  _ ";
    echo " | |__   ___    ____   ____   ____     | |_    ____   ___ | |_ ";
    echo " |  __) / _ \  / ___) / _  | / _  )    |  _)  / _  ) /___)|  _) ";
    echo " | |   | |_| || |    ( ( | |( (/ /     | |__ ( (/ / |___ || |__ ";
    echo " |_|    \___/ |_|     \_|| | \____)     \___) \____)(___/  \___) ";
    echo "                     (_____| ";
    printf "\e[m\n"
    cd $(git rev-parse --show-toplevel)
    # FIXME Pythonが不用であれば、仮想環境起動は不用
    spin 'Python venv activation' python -m venv venv
    . venv/bin/activate
    REQ=$(git ls-files | grep -m 1 requirements.txt)
    if [ "$REQ" != "" ]; then
        spin 'pip install requirements' pip install -r $REQ
    fi
    # FIXME pytestでないならば別途テストコマンドを記述してください
    pytest -v \
        --cov=src \
        --cov-report=term-missing \
        --cov-report=html \
        && open -a "Google Chrome" htmlcov/index.html
    exit 0
fi

if [ "$1" = "stop" ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___ ";
    echo "  / __)                                       _ ";
    echo " | |__   ___    ____   ____   ____       ___ | |_    ___   ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )     /___)|  _)  / _ \ |  _ \ ";
    echo " | |   | |_| || |    ( ( | |( (/ /     |___ || |__ | |_| || | | | ";
    echo " |_|    \___/ |_|     \_|| | \____)    (___/  \___) \___/ | ||_/ ";
    echo "                     (_____|                              |_| ";
    printf "\e[m\n"
    exec-remote-sh 'local/stop.sh'
    exit 0
fi

if [ "$1" = "release" ]; then
    if ! git -C "$(pwd)" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "not a git repository"
        exit
    fi
    printf "\e[34m\n"
    echo "   ___                                                _ ";
    echo "  / __)                                              | | ";
    echo " | |__   ___    ____   ____   ____       ____   ____ | |  ____   ____   ___   ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )     / ___) / _  )| | / _  ) / _  | /___) / _  ) ";
    echo " | |   | |_| || |    ( ( | |( (/ /     | |    ( (/ / | |( (/ / ( ( | ||___ |( (/ / ";
    echo " |_|    \___/ |_|     \_|| | \____)    |_|     \____)|_| \____) \_||_|(___/  \____) ";
    echo "                     (_____| ";
    printf "\e[m\n"
    exec-remote-sh 'local/release.sh'
    exit 0
fi

# not public
#curl -fsSLo /usr/local/bin/forge --create-dirs https://raw.githubusercontent.com/serna37/easy-provi/main/forge.sh
if [ "$1" = "upgrade" ]; then
    # 自身を更新するため、変なエラーがでがち
    printf "\e[34m\n"
    echo "   ___                                                                         _ ";
    echo "  / __)                                                                       | | ";
    echo " | |__   ___    ____   ____   ____      _   _  ____    ____   ____   ____   _ | |  ____ ";
    echo " |  __) / _ \  / ___) / _  | / _  )    | | | ||  _ \  / _  | / ___) / _  | / || | / _  ) ";
    echo " | |   | |_| || |    ( ( | |( (/ /     | |_| || | | |( ( | || |    ( ( | |( (_| |( (/ / ";
    echo " |_|    \___/ |_|     \_|| | \____)     \____|| ||_/  \_|| ||_|     \_||_| \____| \____) ";
    echo "                     (_____|                  |_|    (_____| ";
    printf "\e[m\n"
    if [ -e /usr/local/bin/forge ]; then
        chmod +xw /usr/local/bin/forge
    fi
    spin '' gh api \
        -H "Accept: application/vnd.github.raw" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/serna37/easy-provi/contents/forge.sh?ref=main" \
        > /usr/local/bin/forge
    chmod +xw /usr/local/bin/forge
    exit 0
fi

if [ "$1" = "-h" ]; then
cat << "EOF"
Usage: forge [option]

Development commands. Need serna37/dotfiles and gh auth.

Options:
    {no arg}    Start venv & vim
    gen         Generate repository and init-deploy
    init-deploy initial deploy on server
    run         Run containers on local
    test        Test pytest & coverage
    stop        Stop containers on local
    release     develop -> release -> master
    upgrade     Upgrade forge
    -h          Show this help
EOF
exit 0
fi

info 'no action'

