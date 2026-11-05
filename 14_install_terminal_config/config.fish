# ==============================================================================
# CONFIGURATION FISH
# ==============================================================================

# --- Node.js via NVM (indispensable pour node, npm, pnpm et turbo) ---
# NVM est une fonction Bash : Fish ne charge pas ~/.bashrc. On utilise "bass"
# (installé via fisher) pour sourcer nvm.sh, puis on active la version par défaut.
set -gx NVM_DIR ~/.nvm

function nvm --description "NVM via bass"
    bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
end

if test -f $NVM_DIR/nvm.sh
    bass source $NVM_DIR/nvm.sh ';' nvm use default --silent
end

# --- Chargement des alias et fonctions ---
source ~/.config/fish/aliases.fish

# --- Auto-start Zellij (désactivé : décommentez pour l'activer) ---
# if status is-interactive
#     and not set -q ZELLIJ
#     zellij --layout dev
# end

# Raccourci rapide pour relancer manuellement le layout
alias dev-start="zellij --layout dev"

# --- Prompt simple (sans information Git) ---
function fish_prompt
    set -l user (set_color cyan)$USER(set_color normal)
    set -l host (set_color green)(prompt_hostname)(set_color normal)
    set -l cwd (set_color yellow)(prompt_pwd)(set_color normal)
    echo -n "$user@$host $cwd> "
end
