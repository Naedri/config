#!/bin/bash

# ------------------------------------------------------------------------------
# TOOL
# ------------------------------------------------------------------------------
git config --global core.editor gnome-text-editor
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
git config --global diff.tool meld
git config --global difftool.prompt false
git config --global difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'

# ------------------------------------------------------------------------------
# REBASE & PUSH OPTIONS
# ------------------------------------------------------------------------------
git config --global rebase.autosquash true
git config --global push.autoSetupRemote true

# ------------------------------------------------------------------------------
# ALIAS
# ------------------------------------------------------------------------------
# Smart Interactive Rebase (Compatible with Ubuntu sh/dash)
git config --global alias.rba '!f() { case "$1" in *[!0-9]*|"") git rebase -i --autostash "$@" ;; *) git rebase -i --autostash HEAD~"$1" ;; esac; }; f'
git config --global alias.rbi '!f() { case "$1" in *[!0-9]*|"") git rebase -i "$@" ;; *) git rebase -i HEAD~"$1" ;; esac; }; f'
git config --global alias.rc "rebase --continue"
git config --global alias.ra "rebase --abort"

# Smart Soft Reset (Compatible with Ubuntu sh/dash)
git config --global alias.soft '!f() { case "$1" in *[!0-9]*|"") git reset --soft "$@" ;; *) git reset --soft HEAD~"$1" ;; esac; }; f'
git config --global alias.uncommit "reset --soft HEAD~1"

# Advanced Fixup Workflows
git config --global alias.cf '!f() { git commit --fixup "$1" && git rebase -i --autosquash "$1~1"; }; f'

# Logs and Utilities
git config --global alias.ignored '!git ls-files -v | grep "^[[:lower:]]"'
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

echo "Git configuration successfully updated!"
