#!/bin/bash

# ==============================================================================
# Script : 14_install_terminal.sh
# Description : Automatisation de l'environnement de dev (Fish, Zellij, FZF, NVM)
# Compatibilité : Ubuntu & Kubuntu (Détecte GNOME Terminal et Konsole)
#
# ARCHITECTURE : les fichiers de configuration ne sont plus intégrés dans ce
# script (heredocs). Ils sont stockés dans le dossier compagnon
# "14_install_terminal_config" et copiés tels quels. Avantages :
#   - le script reste lisible et court ;
#   - les fichiers de config sont éditables et versionnables indépendamment ;
#   - aucune collision de délimiteurs heredoc.
#
# Structure attendue (dossier voisin du script) :
#   14_install_terminal_config/
#     ├── config.fish
#     ├── aliases.fish
#     ├── zellij-config.kdl
#     └── zellij-layout-dev.kdl
# ==============================================================================

set -euo pipefail

echo "=== Début de l'installation de l'environnement terminal ==="

# ------------------------------------------------------------------------------
# 0. LOCALISATION DU DOSSIER DE CONFIGURATION
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="${SCRIPT_DIR}/14_install_terminal_config"

if [ ! -d "$CONFIG_SRC" ]; then
    echo "ERREUR : dossier de configuration introuvable : $CONFIG_SRC"
    echo "        Placez 14_install_terminal_config/ à côté de 14_install_terminal.sh"
    exit 1
fi

# Vérification de la présence de tous les fichiers avant de commencer
REQUIRED_FILES=(
    "config.fish"
    "aliases.fish"
    "zellij-config.kdl"
    "zellij-layout-dev.kdl"
)
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${CONFIG_SRC}/${f}" ]; then
        echo "ERREUR : fichier manquant : ${CONFIG_SRC}/${f}"
        exit 1
    fi
done
echo "[0/9] Fichiers de configuration localisés dans : $CONFIG_SRC"

# ------------------------------------------------------------------------------
# 1. GESTION PROPRE DES DOSSIERS ET IDEMPOTENCE
# ------------------------------------------------------------------------------
echo "[1/9] Création des répertoires de configuration..."
mkdir -p ~/.config/fish
mkdir -p ~/.config/zellij/layouts
mkdir -p ~/.local/share/fonts

# ------------------------------------------------------------------------------
# 2. VÉRIFICATION DES PRÉREQUIS
# ------------------------------------------------------------------------------
echo "[2/9] Vérification des prérequis (curl, wget, git, unzip)..."
for pkg in curl wget git unzip; do
    if ! command -v $pkg &> /dev/null; then
        echo "-> Installation de $pkg..."
        sudo apt update && sudo apt install -y $pkg
    fi
done

# ------------------------------------------------------------------------------
# 3. AJOUT DU PPA FISH & INSTALLATION
# ------------------------------------------------------------------------------
echo "[3/9] Installation de Fish Shell..."
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
echo "[4/9] Installation de Zellij..."
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
echo "[5/9] Installation de FZF et Fisher..."
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

# Installation de "bass" : pont permettant d'exécuter des scripts Bash (nvm.sh)
# depuis Fish. Indispensable pour retrouver node / npm / pnpm / turbo.
echo "-> Installation de bass (pont Fish -> Bash pour NVM)..."
fish -c "fisher install edc/bass"

# ------------------------------------------------------------------------------
# 6. TÉLÉCHARGEMENT DES NERD FONTS (FiraMono & Ubuntu Mono)
# ------------------------------------------------------------------------------
echo "[6/9] Téléchargement et installation des polices Nerd Fonts..."

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
# 7. DÉPLOIEMENT DES FICHIERS DE CONFIGURATION EXTERNES
# ------------------------------------------------------------------------------
echo "[7/9] Déploiement des fichiers de configuration..."

install_file() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        echo "ERREUR : fichier source manquant : $src"
        exit 1
    fi
    cp -v "$src" "$dst"
}

# --- Zellij : configuration principale ---
install_file "${CONFIG_SRC}/zellij-config.kdl" ~/.config/zellij/config.kdl

# --- Zellij : layout dev à 4 panneaux ---
# NOTE : ajustez la valeur de "cwd" dans zellij-layout-dev.kdl
install_file "${CONFIG_SRC}/zellij-layout-dev.kdl" ~/.config/zellij/layouts/dev.kdl

# --- Fish : configuration principale ---
install_file "${CONFIG_SRC}/config.fish" ~/.config/fish/config.fish

# --- Fish : alias et fonctions ---
install_file "${CONFIG_SRC}/aliases.fish" ~/.config/fish/aliases.fish

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
#     cat << 'HISTEOF' >> ~/.config/fish/config.fish
#
# # Partage de l'historique en temps réel entre les panneaux Zellij
# function vcs_preexec --on-event fish_preexec
#     history save
# end
# function vcs_postexec --on-event fish_postexec
#     history merge
# end
# HISTEOF
# fi

# ------------------------------------------------------------------------------
# 8. VÉRIFICATION DE L'ENVIRONNEMENT NODE (NVM / corepack / turbo)
# ------------------------------------------------------------------------------
echo "[8/9] Vérification de l'environnement Node.js sous Fish..."

if [ -f ~/.nvm/nvm.sh ]; then
    # Vérifie que node est accessible depuis Fish ; sinon, la config sera à revoir.
    if ! fish -c "command -v node" &> /dev/null; then
        echo "-> ATTENTION : node n'est pas accessible depuis Fish."
        echo "   Vérifiez qu'une version par défaut existe :"
        echo "   bash -c 'source ~/.nvm/nvm.sh && nvm alias default <version>'"
    else
        echo "-> node est accessible depuis Fish : $(fish -c 'node -v')"
    fi

    # Réinstalle les shims corepack (pnpm) et vérifie turbo si nécessaire.
    echo "-> Activation de corepack (fournit pnpm)..."
    fish -c "nvm use default --silent; corepack enable" || echo "   (corepack déjà actif ou échec non bloquant)"

    if ! fish -c "command -v turbo" &> /dev/null; then
        echo "-> turbo absent : réinstallation globale..."
        fish -c "npm i -g tsx turbo" || echo "   (réinstallez manuellement : npm i -g tsx turbo)"
    fi
else
    echo "-> NVM (~/.nvm) introuvable : installez NVM puis relancez ce script."
    echo "   Voir : https://github.com/nvm-sh/nvm"
fi

# ------------------------------------------------------------------------------
# 9. CHANGEMENT DU SHELL PAR DÉFAUT & ACTION
# ------------------------------------------------------------------------------
echo "[9/9] Définition de Fish comme Shell par défaut..."
FISH_PATH=$(command -v fish)

# Vérification que Fish figure dans /etc/shells, sinon chsh refusera le changement
if ! grep -q "^${FISH_PATH}$" /etc/shells; then
    echo "-> Attention : $FISH_PATH est absent de /etc/shells."
    echo "   Ajout de Fish à /etc/shells (nécessite sudo)..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

if [ "$SHELL" != "$FISH_PATH" ]; then
    # chsh sans sudo : la commande demande le mot de passe utilisateur
    if ! chsh -s "$FISH_PATH"; then
        echo "-> Échec du changement de shell. Vérifiez que $FISH_PATH est valide."
    else
        echo "Le shell par défaut a été modifié vers Fish."
    fi
else
    echo "-> Fish est déjà le shell par défaut."
fi

# ------------------------------------------------------------------------------
# EXIT
# ------------------------------------------------------------------------------
echo ""
echo "======================================================="
echo "Installation terminée avec succès !"
echo "Pour appliquer les changements globaux (comme le shell par défaut),"
echo "Veuillez fermer votre session système ou redémarrer votre machine."
echo "======================================================="
