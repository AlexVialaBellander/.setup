SYSTEM=$(uname -s)

echo "Running setup"

if [ "$SYSTEM" == "Linux" ]
then 
	echo "Updating system"
	eval sudo apt-get update
	
	echo "Installing curl"
	eval sudo apt install curl

	echo "Installing git"
	eval sudo apt install git

	echo "Installing brew requirements"
	eval sudo apt-get install build-essential procps curl file git

	echo "Installing homebrew"
	eval NONINTERACTIVE=1 
	eval curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh >> homebrew_install.sh
	eval bash homebrew_install.sh

	echo "Installing wget"
	eval sudo apt install wget

	echo "Installing oh my zsh"
	eval sudo apt-get install zsh
elif [ "$SYSTEM" == "Darwin" ]
then 
	echo "Installing xcode"
	eval xcode-select --install

	echo "Installing homebrew"
	eval NONINTERACTIVE=1 
	eval /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo "Installing curl"
	eval brew install curl

	echo "Installing git"
	eval brew install git

	echo "Installing wget"
	eval brew install wget

	echo "Installing oh my zsh"
	eval brew install zsh
else 
	echo "System not supported"
	exit 1
fi

# comment out since unsure if works on both Linux and Mac
#echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/alexandervialabellander/.profile
#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/alexandervialabellander/.profile
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing zsh-autosuggestions"
eval git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing Python"
eval brew install python
export PATH=$PATH:/opt/homebrew/opt/python@3.10/libexec/bin

echo "Enter your email:"
read email

echo "Cloning setup repo"
eval git clone https://github.com/AlexVialaBellander/.setup ~/.setup && make -C ~/.setup

echo "generating ssh key for github"
eval ssh-keygen -t ed25519 -C $email -f ~/.ssh/github
echo "public key:"
eval cat ~/.ssh/github.pub
echo "paste and create here: https://github.com/settings/ssh/new"

echo "press any key to continue"
read _

echo "Enabling ssh key for github"
eval "$(ssh-agent -s)"
eval ssh-add ~/.ssh/github
eval ssh -T git@github.com

echo "Importing gitconfig"
eval ln -Fis "${PWD}/development/gitconfig" "${HOME}/.gitconfig"
eval grep -q '/zshrc' "${HOME}/.zshrc" 2> /dev/null || \
echo "source '${PWD}/development/zshrc'" >> "${HOME}/.zshrc"

echo "Installing miniconda"
CONDA_INSTALL_PATH=""

if [ "$SYSTEM" == "Darwin" ]
then CONDA_INSTALL_PATH="Miniconda3-latest-MacOSX-arm64.sh"
elif ["$SYSTEM" == "Linux"]
then CONDA_INSTALL_PATH="Miniconda3-latest-Linux-x86_64.sh"
fi

eval mkdir temp_installation
eval cd temp_installation
eval wget "https://repo.anaconda.com/miniconda/$CONDA_INSTALL_PATH"
eval bash $CONDA_INSTALL_PATH
eval cd ..
eval rm -rf temp_installation
eval ~/miniconda3/bin/conda init bash
eval ~/miniconda3/bin/conda init zsh
