###### Meta
# Disable dock auto hide/appear animation
# defaults write com.apple.dock autohide-time-modifier -int 0
# defaults write com.apple.Dock autohide-delay -float 0
# killall Dock

# Terminal theme and font
# Belafonte night: https://github.com/lysyi3m/macos-terminal-themes/blob/master/schemes/Belafonte%20Night.terminal
# Font: Inconsolata 18pt
# Line height: 1.4


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

    check_bash_version

    check_required_homebrew_packages () {
        local required=(
            bash
            bash-completion
            git
            htop
            jq
            pyenv
            pyenv-virtualenv
            tree
            vim
            wget
        )
        local installed=( $(brew list -1) )
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

    check_required_homebrew_packages
)


###### Environment
# Prevent Homebrew from fucking with my privacy
export HOMEBREW_NO_ANALYTICS=1
# Homebrew path
export PATH=$PATH:/usr/local/bin
# OpenSSL compiler flags
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
# Fix vim starting X11
export DISPLAY=
# GPG bad default
export GPG_TTY=$(tty)
# Customize prompts
export PROMPT_DIRTRIM=2
export PS1='\[\e[2m\]\d \t \w \[\e[m\]\n\[\e[0;91m\]⦿ \[\e[m\] '
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


###### Secret local stuffs
source ~/.bash_secret_stuff


###### Aliases
alias m="python manage.py"
alias ms="m shell"
alias ll="ls -laGh"
alias resetdns="sudo pkill mDNSResponder"
alias md5sum='md5 -r'
# Dokku
alias dokku='$HOME/.dokku/contrib/dokku_client.sh'


###### Misc helpers
# Move contents of dir to current dir
level_up () {
    local temp_name="_$1_temp"
    mv "$1" "$temp_name"
    mv "$temp_name/{,.}*" .
    rmdir "$temp_name"
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
maybe_source '/usr/local/etc/profile.d/bash_completion.sh'


###### Git
alias gs='git status'
alias gl='git log --pretty=oneline -25 --decorate --graph'
alias gap='git add -p'
alias gm='git commit -m'
# Interactively add changes to files changed in HEAD
alias gap-head='git diff-tree --no-commit-id --name-only -r HEAD | xargs git add -p'

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


###### Profile sync
__synced_files=(
    '~/.bash_profile'
    '~/.vimrc'
    '~/.git_global_exclude'
    '~/.gitconfig'
    '~/.docker/config.json'
    '~/.ssh/config'
    '~/.ideavimrc'
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
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

mkvirtualenv () {
    (
        set -euo pipefail
        local name="${PWD##*/}"
        pyenv virtualenv "${1:-3.8.2}" "$name"
        echo "$name" > .python-version
        cd .
        python3 -m pip install --upgrade pip setuptools wheel pip-tools
    )
}
