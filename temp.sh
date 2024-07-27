#!/bin/bash

set -e  # Stop on error

SYSTEM=$(uname -s)
TEMPDIR="temp"
LOGFILE="setup.log"

divider() {
    printf '=%.0s' {1..40}
    printf '\n'
}

# Helper function for installing packages
install_package() {
    if ! brew list $1 &>/dev/null; then
        echo "■ Installing $1" | tee -a $LOGFILE
        brew install $1
    else
        echo "$1 is already installed ✅" | tee -a $LOGFILE
    fi
}

# Helper function for brew cask installations
install_cask_package() {
    if ! brew list $1 &>/dev/null; then
        echo "■ Installing $1" | tee -a $LOGFILE
        brew install --cask $1
    else
        echo "$1 is already installed ✅" | tee -a $LOGFILE
    fi
}

##############################################################

divider | tee -a $LOGFILE
echo "Running setup" | tee -a $LOGFILE
mkdir -p $TEMPDIR
echo "Temporary directory created at $TEMPDIR" | tee -a $LOGFILE
divider | tee -a $LOGFILE

echo "■ Installing xcode" | tee -a $LOGFILE
xcode-select --install || true  # Continue if already installed

NONINTERACTIVE=1
if ! command -v brew &>/dev/null; then
    echo "■ Installing homebrew" | tee -a $LOGFILE
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > $TEMPDIR/homebrew_install.sh
    sh $TEMPDIR/homebrew_install.sh
else
    echo "Homebrew is already installed ✅" | tee -a $LOGFILE
fi

install_package curl
install_package git
install_package wget
install_package zsh

echo "■ Installing zsh-autosuggestions" | tee -a $LOGFILE
ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    echo "zsh-autosuggestions directory already exists. Checking for updates..." | tee -a $LOGFILE
    pushd "$ZSH_AUTOSUGGESTIONS_DIR"
    git pull
    popd
else
    echo "Cloning zsh-autosuggestions..." | tee -a $LOGFILE
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
fi

divider | tee -a $LOGFILE

echo "Cloning setup repo" | tee -a $LOGFILE
if [ ! -d ~/.setup ]; then
    git clone https://github.com/AlexVialaBellander/.setup ~/.setup && make -C ~/.setup
else
    echo "Setup repo is already cloned" | tee -a $LOGFILE
fi

divider | tee -a $LOGFILE

echo "Generating ssh key for GitHub" | tee -a $LOGFILE
if [ ! -f ~/.ssh/github ]; then
    echo "Enter your email:" | tee -a $LOGFILE
    read email
    ssh-keygen -t ed25519 -C $email -f ~/.ssh/github
    echo "Public key:" | tee -a $LOGFILE
    cat ~/.ssh/github.pub | tee -a $LOGFILE
    echo "Paste and create here: https://github.com/settings/ssh/new" | tee -a $LOGFILE
    echo "Press any key to continue" | tee -a $LOGFILE
    read _
    echo "Enabling ssh key for GitHub" | tee -a $LOGFILE
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github
    ssh -T git@github.com
else
    echo "SSH key for GitHub already exists" | tee -a $LOGFILE
fi

divider | tee -a $LOGFILE

echo "Importing gitconfig" | tee -a $LOGFILE
GITCONFIG_TARGET="${HOME}/.gitconfig"
GITCONFIG_SOURCE="${PWD}/development/gitconfig"

# Check if .gitconfig already exists and is not a symlink
if [ -f "$GITCONFIG_TARGET" ] && [ ! -L "$GITCONFIG_TARGET" ]; then
    echo "Existing .gitconfig found. Checking for differences..." | tee -a $LOGFILE
    git diff --no-index -- "$GITCONFIG_TARGET" "$GITCONFIG_SOURCE" | tee -a $LOGFILE

    # Ask user if they want to overwrite the existing .gitconfig
    echo "Do you want to replace the existing .gitconfig with the new version? (yes/no):"
    read user_input

    if [[ $user_input == "yes" ]]; then
        # Backup existing .gitconfig
        echo "Backing up existing .gitconfig" | tee -a $LOGFILE
        cp "$GITCONFIG_TARGET" "${GITCONFIG_TARGET}.bak"

        # Replace .gitconfig with the new one
        ln -fis "$GITCONFIG_SOURCE" "$GITCONFIG_TARGET"
        echo ".gitconfig has been replaced and backed up as .gitconfig.bak" | tee -a $LOGFILE
    else
        echo "Operation cancelled by the user." | tee -a $LOGFILE
    fi
elif [ -L "$GITCONFIG_TARGET" ]; then
    # Handle the case where .gitconfig is a symlink
    if [ "$(readlink -- "$GITCONFIG_TARGET")" != "$GITCONFIG_SOURCE" ]; then
        echo "Existing symlink for .gitconfig does not point to the target. Updating symlink..." | tee -a $LOGFILE
        ln -fis "$GITCONFIG_SOURCE" "$GITCONFIG_TARGET"
        echo ".gitconfig symlink updated" | tee -a $LOGFILE
    else
        echo ".gitconfig already correctly linked" | tee -a $LOGFILE
    fi
else
    # No .gitconfig exists, create a new symlink
    ln -fis "$GITCONFIG_SOURCE" "$GITCONFIG_TARGET"
    echo ".gitconfig linked to $GITCONFIG_SOURCE" | tee -a $LOGFILE
fi

# Manage .zshrc updates
divider | tee -a $LOGFILE
echo "■ Sourcing pre-defined zshrc" | tee -a $LOGFILE
ZSHRC_LINE="source '${PWD}/development/zshrc'"
if ! grep -Fxq "$ZSHRC_LINE" "$HOME/.zshrc" 2>/dev/null; then
    echo "$ZSHRC_LINE" >> "$HOME/.zshrc"
    echo "Added zshrc source line to .zshrc" | tee -a $LOGFILE
else
    echo "zshrc source line already in .zshrc" | tee -a $LOGFILE
fi

divider | tee -a $LOGFILE

install_cask_package miniconda
# CONDA_INSTALL_PATH=""
# if [ "$SYSTEM" == "Darwin" ]
# then CONDA_INSTALL_PATH="Miniconda3-latest-MacOSX-arm64.sh"
# elif [ "$SYSTEM" == "Linux" ]
# then CONDA_INSTALL_PATH="Miniconda3-latest-Linux-x86_64.sh"
# fi
# wget -P $TEMPDIR/ "https://repo.anaconda.com/miniconda/$CONDA_INSTALL_PATH"
# bash $TEMPDIR/$CONDA_INSTALL_PATH

divider | tee -a $LOGFILE

rm -rf $TEMPDIR
echo "Temporary files cleaned up" | tee -a $LOGFILE

divider | tee -a $LOGFILE
echo "✨ Setup complete 🦄" | tee -a $LOGFILE
echo "\n\n"
