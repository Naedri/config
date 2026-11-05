#!/bin/bash

# ==============================================================================
# Script : 14_install_terminal_init.sh
# Description : Initialise le dossier compagnon 14_install_terminal_config/
#               avec les fichiers de configuration vides, prêts à être remplis.
# Usage      : ./14_install_terminal_init.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/14_install_terminal_config"

# ------------------------------------------------------------------------------
# 1. CRÉATION DU DOSSIER
# ------------------------------------------------------------------------------
if [ -d "$CONFIG_DIR" ]; then
    echo "-> Le dossier existe déjà : $CONFIG_DIR"
else
    echo "-> Création du dossier : $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# ------------------------------------------------------------------------------
# 2. CRÉATION DES FICHIERS VIDES (IDEMPOTENTE)
# ------------------------------------------------------------------------------
# Les fichiers ne sont jamais écrasés s'ils existent déjà.
FILES=(
    "config.fish"
    "aliases.fish"
    "zellij-config.kdl"
    "zellij-layout-dev.kdl"
)

for f in "${FILES[@]}"; do
    FILEPATH="${CONFIG_DIR}/${f}"
    if [ -f "$FILEPATH" ]; then
        echo "-> ${f} : déjà présent, non modifié."
    else
        touch "$FILEPATH"
        echo "-> ${f} : créé (vide)."
    fi
done

# ------------------------------------------------------------------------------
# EXIT
# ------------------------------------------------------------------------------
echo ""
echo "======================================================="
echo "Initialisation terminée."
echo "Structure créée dans : $CONFIG_DIR"
echo ""
echo "Prochaine étape : remplissez les fichiers avec votre contenu,"
echo "puis exécutez 14_install_terminal.sh pour les déployer."
echo "======================================================="
