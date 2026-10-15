#!/bin/bash

# ==============================================================================
# ADVANCED FUNCTIONS (Accepting arguments)
# ==============================================================================

# Copy the exact content of a file directly into your system clipboard (Ctrl+V)
copyfile() {
    if [ -f "$1" ]; then
        cat "$1" | xclip -selection clipboard
        echo "Success: Content of '$1' copied to clipboard!"
    else
        echo "Error: File '$1' does not exist."
    fi
}

# Extract any compressed archive automatically based on its extension
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ==============================================================================
# GIT SHORTCUTS
# ==============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# ==============================================================================
# DOCKER SHORTCUTS
# ==============================================================================
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimages='docker images'
alias dstopall='docker stop $(docker ps -a -q)'
alias dprune='docker system prune -a --volumes -f' # Danger: Cleans up all unused data

# ==============================================================================
# GENERAL ALIASES & SAFETY NETS
# ==============================================================================

# Safety prompts: Ask before deleting or overwriting files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='cd ~'

# Enhanced directory listing (Colorized and detailed)
alias ls='ls --color=auto'
alias ll='ls -la'
alias l='ls -l'

# Quick Ubuntu system maintenance
alias update='sudo apt update && sudo apt upgrade -y'

# Handy shortcuts
alias c='clear'                     # Quickly clears the terminal screen
alias myip='curl ifconfig.me; echo'  # Displays your public IP address
alias path='echo -e ${PATH//:/\\n}'  # Prints a clean, readable list of your PATH directories
