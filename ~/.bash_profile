###### Meta
# Enable (O)DOH via local proxy
# https://gist.github.com/soderlind/6a440cd3c8e017444097cf2c89cc301d
# 1.
# $ brew install cloudflare/cloudflare/cloudflared
# 2.
# $ mkdir -p /usr/local/etc/cloudflared
# $ cat <<EOF >> /usr/local/etc/cloudflared/config.yaml
# proxy-dns: true
# proxy-dns-upstream:
#   - https://1.1.1.1/dns-query
#   - https://1.0.0.1/dns-query
# EOF
# 3.
# $ sudo cloudflared service install
# 5. Change DNS settings to use 127.0.0.1

# Disable dock auto hide/appear animation
# defaults write com.apple.dock autohide-time-modifier -int 0
# defaults write com.apple.Dock autohide-delay -float 0
# killall Dock

# Disable "try safari" notifications ... srsly bapple ...
# defaults write com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched -bool YES
# defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2050-01-01T00:00:00Z
# defaults write com.apple.coreservices.uiagent CSUILastOSVersionWhereSafariRecommendationWasMade -float 11.99

# Disable "make safari default browser" notification
# defaults write com.apple.Safari DefaultBrowserDateOfLastPrompt -date '2050-01-01T00:00:00Z'
# defaults write com.apple.Safari DefaultBrowserPromptingState -int 2

# Press and hold behavior
# defaults write -g ApplePressAndHoldEnabled 0

# No margins for tiled windows
# defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Why is this is so hidden!? Bapples ...
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
# killall Finder

# Disable Apple Music starting when pressing play on keyboard
# ... but apparently disables it from working at all :(
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

# Terminal theme and font
# Belafonte night: https://github.com/lysyi3m/macos-terminal-themes/blob/master/schemes/Belafonte%20Night.terminal
# Font: Inconsolata 18pt
# Line height: 1.451


###### Healthchecks
(
    set -euo pipefail

    warn () {
        echo -e '\033[7;31m⟡ Warning ⟡  '$@'\033[0m'
    }

    inform () {
        echo -e '\033[7;37m'$@'\033[0m'
    }

    check_bash_version () {
        # Make sure we're running on a recent version of bash
        if (( ${BASH_VERSION%%.*} < 5 )); then
            warn "Outdated bash version (5 > ${BASH_VERSION})"
        else
            inform "Bash version OK: ${BASH_VERSION}"
        fi
    }

    # check_bash_version

    check_required_homebrew_packages () {
        local required=(
            ansible
            coreutils
            curl
            bash
            'bash-completion@2'
            direnv
            findutils
            fzf
            gh
            git
            htop
            jq
            openssh
            pre-commit
            pyenv
            pyenv-virtualenv
            terminal-notifier
            tree
            vim
            wget
        )
        local installed=( $(brew list -1 --formula) )
        local missing=(
            $(
                comm -13 \
                    <(printf '%s\n' "${installed[@]}" | LC_ALL=C sort) \
                    <(printf '%s\n' "${required[@]}" | LC_ALL=C sort)
            )
        )
        local num_missing=${#missing[@]}

        if (( num_missing > 0 )); then
            warn "Missing $num_missing dependencies: ${missing[@]}"
        else
            inform "Homebrew dependencies OK"
        fi
    }

    # check_required_homebrew_packages
)


###### Activate Homebrew, on ARM
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi


###### Environment

# Prevent Homebrew from fucking with my privacy
export HOMEBREW_NO_ANALYTICS=1

# Homebrew path
export PATH="$PATH:/usr/local/bin"
export PATH="/usr/local/sbin:$PATH"


# Prefer Homebrew curl
export PATH="/usr/local/opt/curl/bin:$PATH"

# OpenSSL compiler flags
export LDFLAGS="$LDFLAGS -L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="$LDFLAGS -I/usr/local/opt/openssl@1.1/include"

# Fix vim starting X11
export DISPLAY=

# GPG bad default
export GPG_TTY=$(tty)

# Customize prompts
__pyenv_version () {
    pyenv version | cut -f1 -d' '
}
__python_version () {
    python --version 2>&1 | cut -f2 -d' '
}
export PROMPT_DIRTRIM=2
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PS1='\[\e[2m\]\d \t\n($(__pyenv_version)) \w \[\e[m\]\n\[\e[0;91m\]⦿ \[\e[m\] '
export MYSQL_PS1="\u@\h/\d [\D]\n💾 "

# Fix weird output from sudo
export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL=

# Make ansible not use cowsay
export ANSIBLE_NOCOWS=1

# Make docker not suggest using Snyk
export DOCKER_SCAN_SUGGEST=false
export DOCKER_CLI_HINTS=false

# Please put the gun down, pip.
export PIP_REQUIRE_VIRTUALENV=true


###### Secret local stuffs
source ~/.bash_secret_stuff


###### Aliases
alias ll="ls -laGh"
alias resetdns="sudo pkill mDNSResponder"
alias md5sum='md5 -r'
alias grep='grep --color'
alias kcat='docker run --net=host -it --rm edenhill/kcat:1.7.0'


###### Start SSH agent and add private key
eval "$(ssh-agent -s)" > /dev/null
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2> /dev/null


###### Misc helpers
# Move contents of dir to current dir
level_up () {
    (
        set -euo pipefail
        local temp_name="_$1_temp"
        mv "$1" "$temp_name"
        mv "$temp_name/{,.}*" .
        rmdir "$temp_name"
    )
}

# Source file if it exists
maybe_source () {
    [[ -r "$1" ]] && source "$1"
}

cp_to_usb () {
    exit 1
    local usb_volume='/Volumes/SD U M/'
    local source=$1
    echo "Copying $source to $usb_volume$source recursively."
    mkdir -p "$usb_volume$source"
    cp -R -L "$source" "$usb_volume$source"
    say -v Daniel "Copy is done"
}


###### Bash completion
# Install with `brew install bash-completion`
maybe_source "$(brew --prefix)/etc/profile.d/bash_completion.sh"


###### Git
# Bash completion
maybe_source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
maybe_source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"

git-close () {
    # Atomically push a feature branch on to a remote integration branch and
    # delete its remote equivalent.
    (
        set -euo pipefail
        local origin=$1
        local source_branch=$2
        local target_branch=${3:-master}
        git push "$origin" --atomic "$source_branch":"$target_branch" :"$source_branch"
    )
}

git-touched-files () {
    # List all files touched by given commit or ref or HEAD if not given.
    (
        set -euo pipefail
        local ref=${1:-HEAD}
        git diff-tree --no-commit-id --name-only -r "$ref"
    )
}

git-readd () {
    # Interactively add changes in all files touched by the latest commit, or
    # in any reference passed as a single argument (commit or branch).
    (
        set -euo pipefail
        local ref=${1:-HEAD}
        gxargs -a <(git-touched-files) git add -p --
    )
}

git-fix () {
    # Interactively add changes to files touched in the commit using git-readd,
    # and then make a fixup commit pointing at the given reference, or HEAD.
    (
        set -euo pipefail
        local ref=${1:-HEAD}
        git-readd "$ref"
        git commit --fixup="$ref" --edit
    )
}

git-flog () {
    # Interactively pick a commit from the history of the given reference, or
    # HEAD.
    (
        set -euo pipefail
        local ref=${1:-HEAD}
        git log --color=always --decorate --oneline "$ref" \
            | fzf --ansi --reverse \
            | awk '{ print $1 }'
    )
}

charm-conflict () {
    (
        set -euo pipefail
        git diff --name-only --diff-filter=U \
            | xargs ~/Library/Application\ Support/JetBrains/Toolbox/scripts/pycharm
    )
}


# Aliases
alias gs='git status'
alias gl='git log --oneline -15 --graph'
alias gap='git add --patch'
alias gcp='git checkout --patch'
alias gm='git commit -m'
alias grf='git-readd $(git-flog)'
alias gff='git-fix $(git-flog)'
alias pro='gh pr view --web'
alias prc='gh pr create --web'


###### Profile sync
__synced_files=(
    '~/.bash_profile'
    '~/.vimrc'
    '~/.git_global_exclude'
    '~/.gitconfig'
    '~/.ssh/config'
    '~/.ideavimrc'
    '~/.inputrc'
    '~/.pyenv/version'
)
__syncdir=~/.syncdir

profileaddall () {
    (
        # Copy and add all watched files
        set -euo pipefail
        cd "$__syncdir"
        for file in "${__synced_files[@]}"; do
            local local_path="${file/#\~/$HOME}"
            local repo_path="${__syncdir}/${file}"
            mkdir -p "${repo_path%/*}"
            cp "$local_path" "$repo_path"
            git add "$repo_path"
        done
    )
}

profilepush () {
    profileaddall
    (
        # Commit changes and push to remote
        set -euo pipefail
        cd "$__syncdir"
        git commit -m "${1:-autoupdate}"
        git push origin master
    )
}

profilepull () {
    (
        # Pull changes from remote
        set -euo pipefail
        cd "$__syncdir"
        git pull --rebase --autostash
        for file in "${__synced_files[@]}"; do
            local local_path="${file/#\~/$HOME}"
            local repo_path="${__syncdir}/${file}"
            mkdir -p "${local_path%/*}"
            cp "$repo_path" "$local_path"
        done
    )
}

profilediff () {
    profileaddall
    (
        set -euo pipefail
        cd "$__syncdir"
        git diff --cached
    )
}


###### Spotify
spotify () {
    osascript -e 'tell application "Spotify" to activate'
    sleep 5
    osascript -e 'tell application "Spotify" to set shuffling to true'
    local fav='spotify:user:bananatrapp:playlist:4a6RQIxSGXZVvXy6ckDeL5'
    osascript -e "tell application \"Spotify\" to play track \"$fav\""
}


###### pyenv
# Related: https://twitter.com/agestam/status/1397308917504430086
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

mkvirtualenv () {
    (
        set -euo pipefail
        local name="${PWD##*/}"
        pyenv virtualenv "${1:-3.13.1}" "$name"
        echo "$name" > .python-version
        cd .
        python3 -m pip install --upgrade pip setuptools wheel
    )
}


###### Goose
alias goose='uvx --from=git-goose goose'


###### Rust/cargo
maybe_source "$HOME/.cargo/env"


###### direnv
eval "$(direnv hook bash)"
