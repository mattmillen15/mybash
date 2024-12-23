#!/usr/bin/env bash

#######################################################
# GENERAL CONFIGURATIONS
#######################################################

# History Configuration
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace
PROMPT_COMMAND='history -a'

# Auto-Adjust Terminal Size
shopt -s checkwinsize
shopt -s histappend

# Disable Terminal Bell
bind "set bell-style visible"

# Enable Enhanced Auto-Completion
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous On"

# Enable Spellcheck for Directories
shopt -s cdspell

# Enable Colors for ls and grep
export CLICOLOR=1
alias grep='grep --color=always'

# Default Editor
export EDITOR=nvim
export VISUAL=nvim

#######################################################
# FASTFETCH CONFIGURATION
#######################################################

# Run Fastfetch with custom configuration if installed
if command -v fastfetch &> /dev/null; then
    fastfetch --config ~/mykali/config.jsonc
fi

#######################################################
# STARSHIP PROMPT
#######################################################

# Ensure Starship is properly initialized
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    echo "⚠️  Starship is not installed. Run 'sudo apt install starship'."
fi

#######################################################
# ENHANCED DIRECTORY NAVIGATION
#######################################################

# Automatically list contents after cd
cd() {
    if [ -n "$1" ]; then
        builtin cd "$@" && ls -A --color=always
    else
        builtin cd ~ && ls -A --color=always
    fi
}

# Enable zoxide for smarter cd behavior
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
else
    echo "⚠️  zoxide is not installed. Run 'sudo apt install zoxide'."
fi

#######################################################
# TRASH FUNCTIONALITY
#######################################################

# Safe rm alias to move files to trash instead of deleting
if command -v trash &> /dev/null; then
    alias rm='trash'
    alias emptytrash='trash-empty'
    alias listtrash='trash-list'
else
    echo "⚠️  trash-cli is not installed. Run 'sudo apt install trash-cli' to enable safe deletion."
fi

#######################################################
# ALIASES
#######################################################

# Navigation Shortcuts
alias home='cd ~'
alias tools='cd ~/tools'
alias up='cd ..'
alias ..='cd ..'
alias ...='cd ../..'

# Networking Utilities
alias openports='netstat -tuln'

# Safety Aliases
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I --preserve-root'

# Utility Aliases
alias cls='clear'
alias myip='curl -s ifconfig.me'

# Quick Updates
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

# Enhanced ls Commands
alias la='ls -Alh'                # Show hidden files
alias ll='ls -Fls'                # Long listing format
alias lt='ls -ltrh'               # Sort by date
alias ldir="ls -l | grep '^d'"    # List directories only

#######################################################
# SPECIAL FUNCTIONS
#######################################################

# Extract Archives
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case "$archive" in
                *.tar.bz2) tar xvjf "$archive" ;;
                *.tar.gz) tar xvzf "$archive" ;;
                *.bz2) bunzip2 "$archive" ;;
                *.rar) rar x "$archive" ;;
                *.gz) gunzip "$archive" ;;
                *.tar) tar xvf "$archive" ;;
                *.tbz2) tar xvjf "$archive" ;;
                *.tgz) tar xvzf "$archive" ;;
                *.zip) unzip "$archive" ;;
                *.7z) 7z x "$archive" ;;
                *) echo "❌ Unknown archive type: '$archive'" ;;
            esac
        else
            echo "❌ '$archive' is not a valid file!"
        fi
    done
}

# Copy with Progress Bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Show External and Internal IP
myip() {
    echo -n "Internal IP: "
    hostname -I | awk '{print $1}'
    echo -n "External IP: "
    curl -s ifconfig.me
    echo ""
}


#######################################################
# PATH CONFIGURATIONS
#######################################################

# Ensure Tools Directory is in PATH
if [ -d "$HOME/tools" ]; then
    export PATH="$HOME/tools:$PATH"
fi

# Add local binaries to PATH
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"

#######################################################
# SOURCE GLOBAL FILES
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#######################################################
# FINALIZATION
#######################################################

# Display a friendly greeting
echo "✅ Environment Loaded. Happy Hacking!"
