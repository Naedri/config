#!/bin/bash

# ==============================================================================
# Script : 14_install_terminal.sh
# Description : Automatisation de l'environnement de dev (Fish, Zellij, FZF)
# Compatibilité : Ubuntu & Kubuntu (Détecte GNOME Terminal et Konsole)
# ==============================================================================

set -euo pipefail

echo "=== Début de l'installation de l'environnement terminal ==="

# ------------------------------------------------------------------------------
# 1. GESTION PROPRE DES DOSSIERS ET IDEMPOTENCE
# ------------------------------------------------------------------------------
echo "[1/8] Création des répertoires de configuration..."
mkdir -p ~/.config/fish
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.local/share/fonts

# ------------------------------------------------------------------------------
# 2. VÉRIFICATION DES PRÉREQUIS
# ------------------------------------------------------------------------------
echo "[2/8] Vérification des prérequis (curl, wget, git, unzip)..."
for pkg in curl wget git unzip; do
    if ! command -v $pkg &> /dev/null; then
        echo "-> Installation de $pkg..."
        sudo apt update && sudo apt install -y $pkg
    fi
done

# ------------------------------------------------------------------------------
# 3. AJOUT DU PPA FISH & INSTALLATION
# ------------------------------------------------------------------------------
echo "[3/8] Installation de Fish Shell..."
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
echo "[4/8] Installation de Zellij..."
if ! command -v zellij &> /dev/null; then
    # Récupération de la dernière version stable via l'API GitHub
    ZELLIJ_LATEST=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    echo "-> Téléchargement de Zellij $ZELLIJ_LATEST..."
    wget -qO /tmp/zellij.tar.gz "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_LATEST}/zellij-x86_64-unknown-linux-musl.tar.gz" \
        || { echo "Échec du téléchargement de Zellij."; exit 1; }

    sudo tar -C /usr/local/bin -xzf /tmp/zellij.tar.gz zellij
    rm -f /tmp/zellij.tar.gz
    sudo chmod +x /usr/local/bin/zellij
else
    echo "-> Zellij est déjà installé."
fi

# ------------------------------------------------------------------------------
# 5. INTÉGRATION DE FZF (FUZZY FINDER) ET FISHER
# ------------------------------------------------------------------------------
echo "[5/8] Installation de FZF et Fisher..."
if ! command -v fzf &> /dev/null; then
    sudo apt install -y fzf
fi

# Installation de Fisher (Gestionnaire de paquets de Fish)
if [ ! -f ~/.config/fish/functions/fisher.fish ]; then
    echo "-> Installation de Fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fi

# Installation du plugin FZF dédié à Fish (pour un Ctrl+R parfait)
fish -c "fisher install PatrickF1/fzf.fish"

# ------------------------------------------------------------------------------
# 6. TÉLÉCHARGEMENT DES NERD FONTS (FiraMono & Ubuntu Mono)
# ------------------------------------------------------------------------------
echo "[6/8] Téléchargement et installation des polices Nerd Fonts..."

NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

# Téléchargement FiraMono Nerd Font
if ! ls ~/.local/share/fonts/FiraMonoNerdFont* &> /dev/null; then
    echo "-> Téléchargement de FiraMono..."
    wget -qO /tmp/FiraMono.zip "${NERD_FONTS_URL}/FiraMono.zip" \
        || { echo "Échec du téléchargement de FiraMono."; exit 1; }
    unzip -qo /tmp/FiraMono.zip -d ~/.local/share/fonts/
    rm -f /tmp/FiraMono.zip
fi

# Téléchargement Ubuntu Mono Nerd Font
if ! ls ~/.local/share/fonts/UbuntuMonoNerdFont* &> /dev/null; then
    echo "-> Téléchargement d'Ubuntu Mono..."
    wget -qO /tmp/Ubuntu.zip "${NERD_FONTS_URL}/UbuntuMono.zip" \
        || { echo "Échec du téléchargement d'Ubuntu Mono."; exit 1; }
    unzip -qo /tmp/Ubuntu.zip -d ~/.local/share/fonts/
    rm -f /tmp/Ubuntu.zip
fi

# Mise à jour du cache des polices du système
fc-cache -f ~/.local/share/fonts/

# Application de la police FiraMono par défaut selon l'environnement de bureau
if command -v konsole &> /dev/null; then
    echo "-> Configuration de FiraMono dans Konsole (Kubuntu)..."
    mkdir -p ~/.local/share/konsole
    if [ ! -f ~/.local/share/konsole/Profile\ 1.profile ]; then
        echo -e "[General]\nName=Profile 1\nParent=FALLBACK/\n\n[Appearance]\nFont=FiraMono Nerd Font,11,-1,5,50,0,0,0,0,0" > ~/.local/share/konsole/Profile\ 1.profile
    fi
elif command -v gsettings &> /dev/null && gsettings list-schemas | grep -q org.gnome.Terminal; then
    echo "-> Configuration de FiraMono dans GNOME Terminal (Ubuntu)..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/ font 'FiraMono Nerd Font 11'
else
    echo "-> Aucun terminal GNOME ou Konsole détecté, configuration de la police ignorée."
fi

# ------------------------------------------------------------------------------
# 7. ÉCRITURE DES FICHIERS DE CONFIGURATION (Idempotent)
# ------------------------------------------------------------------------------
echo "[7/8] Génération des fichiers de configuration..."

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
echo "[8/8] Définition de Fish comme Shell par défaut..."
FISH_PATH=$(command -v fish)
if [ "$SHELL" != "$FISH_PATH" ]; then
    sudo chsh -s "$FISH_PATH" "$USER"
    echo "Le shell par défaut a été modifié vers Fish."
else
    echo "-> Fish est déjà le shell par défaut."
fi

echo ""
echo "======================================================="
echo "Installation terminée avec succès !"
echo "Pour appliquer les changements globaux (comme le shell par défaut),"
echo "Veuillez fermer votre session système ou redémarrer votre machine."
echo "======================================================="
