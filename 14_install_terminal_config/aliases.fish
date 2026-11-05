# ==============================================================================
# FONCTIONS AVANCÉES (acceptant des arguments)
# ==============================================================================

# Copie le contenu exact d'un fichier dans le presse-papiers (Ctrl+V)
function copyfile
    set -l f $argv[1]
    if test -f "$f"
        xclip -selection clipboard < "$f"
        echo "Success: Content of '$f' copied to clipboard!"
    else
        echo "Error: File '$f' does not exist."
    end
end

# Extrait automatiquement toute archive compressée selon son extension
function extract
    set -l f $argv[1]
    if test -f "$f"
        switch "$f"
            case '*.tar.bz2'
                tar xjf "$f"
            case '*.tar.gz'
                tar xzf "$f"
            case '*.bz2'
                bunzip2 "$f"
            case '*.rar'
                unrar x "$f"
            case '*.gz'
                gunzip "$f"
            case '*.tar'
                tar xf "$f"
            case '*.tbz2'
                tar xjf "$f"
            case '*.tgz'
                tar xzf "$f"
            case '*.zip'
                unzip "$f"
            case '*.Z'
                uncompress "$f"
            case '*.7z'
                7z x "$f"
            case '*'
                echo "'$f' cannot be extracted via extract()"
        end
    else
        echo "'$f' is not a valid file"
    end
end

# ==============================================================================
# RACCOURCIS GIT
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
# RACCOURCIS DOCKER
# ==============================================================================
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimages='docker images'
alias dprune='docker system prune -a --volumes -f' # Danger: nettoie toutes les données inutilisées

# docker stop $(docker ps -a -q) : converti en fonction (substitution Bash incompatible)
function dstopall
    docker stop (docker ps -aq)
end

# ==============================================================================
# ALIAS GÉNÉRAUX & FILETS DE SÉCURITÉ
# ==============================================================================
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation rapide
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='cd ~'

# Liste de répertoires améliorée
alias ls='ls --color=auto'
alias ll='ls -la'
alias l='ls -l'

# Maintenance Ubuntu
alias update='sudo apt update; and sudo apt upgrade -y'

# Raccourcis pratiques
alias c='clear'
alias myip='curl ifconfig.me; echo'

# $(...) et ${PATH//:/\n} sont des syntaxes Bash : converti en fonction
function path
    printf '%s\n' $PATH
end

alias copyx='xclip -selection clipboard'
