echo "Running setup"

echo "Updating system"
eval sudo apt-get update

echo "Installing curl"
eval sudo apt install curl

echo "Installing git"
eval sudo apt install git

echo "Installing homebrew"
echo | eval /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null

echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/alexandervialabellander/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/alexandervialabellander/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing wget"
eval sudo apt install wget

echo "Installing oh my zsh"
eval sudo apt-get install zsh

echo "Installing zsh-autosuggestions"
eval git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing Python"
eval brew install python
export PATH=$PATH:/opt/homebrew/opt/python@3.10/libexec/bin

echo "Installing Anaconda"
eval brew install --cask anaconda

echo "Enter your email:"
read email

echo "Cloning setup repo"
eval git clone https://github.com/AlexVialaBellander/.setup ~/.setup && make -C ~/.setup

echo "generating ssh key for github"
eval ssh-keygen -t ed25519 -C $email -f ~/.ssh/github
eval pbcopy < ~/.ssh/github.pub
echo "public key saved to clipboard"
echo "paste and create here: https://github.com/settings/ssh/new"

echo "press any key to continue"
read _
