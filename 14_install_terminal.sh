#!/bin/bash

# ==============================================================================
# Script : 14_install_terminal.sh
# Description : Automatisation de l'environnement de dev (Fish, Zellij, FZF)
# Compatibilité : Ubuntu & Kubuntu (Détecte GNOME Terminal et Konsole)
# ==============================================================================

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0;37m' # Pas de couleur

echo -e "${BLUE}=== Début de l'installation de l'environnement terminal ===${NC}"

# ------------------------------------------------------------------------------
# 1. GESTION PROPRE DES DOSSIERS ET IDEMPOTENCE
# ------------------------------------------------------------------------------
echo -e "${GREEN}[1/8] Création des répertoires de configuration...${NC}"
mkdir -p ~/.config/fish
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.local/share/fonts

# ------------------------------------------------------------------------------
# 2. VÉRIFICATION DES PRÉREQUIS
# ------------------------------------------------------------------------------
echo -e "${GREEN}[2/8] Vérification des prérequis (curl, wget, git)...${NC}"
for pkg in curl wget git unzip; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "${YELLOW}-> Installation de $pkg...${NC}"
        sudo apt update && sudo apt install -y $pkg
    fi
done

# ------------------------------------------------------------------------------
# 3. AJOUT DU PPA FISH & INSTALLATION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[3/8] Installation de Fish Shell...${NC}"
if ! command -v fish &> /dev/null; then
    sudo add-apt-repository ppa:fish-shell/release-3 -y
    sudo apt update
    sudo apt install -y fish
else
    echo "-> Fish Shell est déjà installé."
fi

# ------------------------------------------------------------------------------
# 4. INSTALLATION DE ZELLIJ
# ------------------------------------------------------------------------------
echo -e "${GREEN}[4/8] Installation de Zellij...${NC}"
if ! command -v zellij &> /dev/null; then
    # Récupération de la dernière version stable via l'API GitHub
    ZELLIJ_LATEST=$(curl -s https://github.com | grep -oP '"tag_name": "\K[^"]+')
    echo "-> Téléchargement de Zellij $ZELLIJ_LATEST..."
    wget -qO /tmp/zellij.tar.gz "https://github.com{ZELLIJ_LATEST}/zellij-x86_64-unknown-linux-musl.tar.gz"
    
    sudo tar -C /usr/local/bin -xzf /tmp/zellij.tar.gz zellij
    rm /tmp/zellij.tar.gz
    sudo chmod +x /usr/local/bin/zellij
else
    echo "-> Zellij est déjà installé."
fi

# ------------------------------------------------------------------------------
# 5. INTÉGRATION DE FZF (FUZZY FINDER) ET FISHER
# ------------------------------------------------------------------------------
echo -e "${GREEN}[5/8] Installation de FZF et Fisher...${NC}"
if ! command -v fzf &> /dev/null; then
    sudo apt install -y fzf
fi

# Installation de Fisher (Gestionnaire de paquets de Fish)
if [ ! -f ~/.config/fish/functions/fisher.fish ]; then
    echo "-> Installation de Fisher..."
    fish -c "curl -sL https://githubusercontent.com | source && fisher install jorgebucaran/fisher"
fi

# Installation du plugin FZF dédié à Fish (pour un Ctrl+R parfait)
fish -c "fisher install PatrickF1/fzf.fish"

# ------------------------------------------------------------------------------
# 6. TÉLÉCHARGEMENT DES NERD FONTS (Oxygen Mono & Ubuntu Mono)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[6/8] Téléchargement et installation des polices Nerd Fonts...${NC}"

# Téléchargement Oxygen Mono Nerd Font
if [ ! -f ~/.local/share/fonts/OxygenMonoNerdFont-Regular.otf ]; then
    echo "-> Téléchargement d'Oxygen Mono..."
    wget -qO /tmp/Oxygen.zip https://github.com
    unzip -qo /tmp/Oxygen.zip -d ~/.local/share/fonts/
    rm /tmp/Oxygen.zip
fi

# Téléchargement Ubuntu Mono Nerd Font
if [ ! -f ~/.local/share/fonts/UbuntuMonoNerdFont-Regular.ttf ]; then
    echo "-> Téléchargement d'Ubuntu Mono..."
    wget -qO /tmp/Ubuntu.zip https://github.com
    unzip -qo /tmp/Ubuntu.zip -d ~/.local/share/fonts/
    rm /tmp/Ubuntu.zip
fi

# Mise à jour du cache des polices du système
fc-cache -f ~/.local/share/fonts/

# Application de la police Oxygen Mono par défaut selon l'environnement de bureau
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    echo "-> Configuration d'Oxygen Mono dans Konsole (Kubuntu)..."
    mkdir -p ~/.local/share/konsole
    if [ ! -f ~/.local/share/konsole/Profile\ 1.profile ]; then
        echo -e "[General]\nName=Profile 1\nParent=FALLBACK/\n\n[Appearance]\nFont=OxygenMono Nerd Font,11,-1,5,50,0,0,0,0,0" > ~/.local/share/konsole/Profile\ 1.profile
    fi
else
    echo "-> Configuration d'Oxygen Mono dans GNOME Terminal (Ubuntu)..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/ font 'OxygenMono Nerd Font 11'
fi

# ------------------------------------------------------------------------------
# 7. ÉCRITURE DES FICHIERS DE CONFIGURATION (Idempotent)
# ------------------------------------------------------------------------------
echo -e "${GREEN}[7/8] Génération des fichiers de configuration...${NC}"

# --- Configuration de Zellij (~/.config/zellij/config.kdl) ---
cat << 'EOF' > ~/.config/zellij/config.kdl
// Force Zellij à utiliser Fish comme shell par défaut à l'intérieur de ses panneaux
default_shell "fish"
theme "default"
EOF

# --- Configuration du Layout à 4 panneaux (~/.config/zellij/layouts/dev.kdl) ---
cat << 'EOF' > ~/.config/zellij/layouts/dev.kdl
layout {
    pane split_direction="vertical" {
        // Lance une commande spécifique dans Fish et laisse ouvert après
        pane command="fish" { args "-c" "npm run dev; exec fish" }
        pane command="fish" { args "-c" "docker compose up; exec fish" }
    }
    pane split_direction="horizontal" {
        pane command="fish" { args "-c" "git status; exec fish" }
        pane // Un terminal Fish vierge par défaut
    }
}
EOF

# --- Configuration de Fish (~/.config/fish/config.fish) ---
if ! grep -q "Auto-start Zellij" ~/.config/fish/config.fish 2>/dev/null; then
    cat << 'EOF' >> ~/.config/fish/config.fish

# --- Auto-start Zellij ---
# Lance Zellij automatiquement à l'ouverture du terminal
if status is-interactive
    and not set -q ZELLIJ
    zellij --layout dev
end

# Raccourci rapide pour relancer manuellement le layout
alias dev-start="zellij --layout dev"

EOF
fi

# ==============================================================================
# SECTION OPTIONNELLE : STARSHIP PROMPT (Laissez commenté pour activation manuelle)
# ==============================================================================
# echo "-> Installation optionnelle de Starship Prompt..."
# if ! command -v starship &> /dev/null; then
#     curl -sS https://starship.rs | sh -s -- -y
#     if ! grep -q "starship init fish" ~/.config/fish/config.fish; then
#         echo 'starship init fish | source' >> ~/.config/fish/config.fish
#     fi
# fi

# ==============================================================================
# SECTION OPTIONNELLE : HISTORIQUE PARTAGÉ TEMPS RÉEL (Laissez commenté)
# ==============================================================================
# if ! grep -q "history merge" ~/.config/fish/config.fish; then
#     cat << 'EOF' >> ~/.config/fish/config.fish
#
# # Partage de l'historique en temps réel entre les panneaux Zellij
# function vcs_preexec --on-event fish_preexec
#     history save
# end
# function vcs_postexec --on-event fish_postexec
#     history merge
# end
# EOF
# fi


# ------------------------------------------------------------------------------
# 8. CHANGEMENT DU SHELL PAR DÉFAUT & ACTION
# ------------------------------------------------------------------------------
echo -e "${GREEN}[8/8] Définition de Fish comme Shell par défaut...${NC}"
FISH_PATH=$(which fish)
if [ "$SHELL" != "$FISH_PATH" ]; then
    sudo chsh -s "$FISH_PATH" "$USER"
    echo -e "${YELLOW}Le shell par défaut a été modifié vers Fish.${NC}"
else
    echo "-> Fish est déjà le shell par défaut."
fi

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${GREEN}Installation terminée avec succès !${NC}"
echo -e "Pour appliquer les changements globaux (comme le shell par défaut),"
echo -e "${YELLOW}Veuillez fermer votre session système ou redémarrer votre machine.${NC}"
echo -e "=======================================================${NC}"
