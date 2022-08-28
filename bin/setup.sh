#!/bin/sh

# Greeting from program
echo "---------------------------------------------------------"
echo "$(tput setaf 2) Artemis: Hello there, explorer. I am powering up and will begin configuration checks momentarily.$(tput sgr 0)"
echo "---------------------------------------------------------"

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

############################################
# Install xcode, homebrew, nvm, etc.       #
############################################

# install xcode developer tools
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing xcode developer tools.$(tput sgr 0)"
echo "---------------------------------------------------------"
xcode-select --install

# check if homebrew is installed, and install it if it's not
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Checking for Homebrew installation.$(tput sgr 0)"
echo "---------------------------------------------------------"
brew="/usr/local/bin/brew"
if [ -f "$brew" ]
then
    echo "---------------------------------------------------------"
    echo "$(tput setaf 2)Artemis: Homebrew is installed.$(tput sgr 0)"
    echo "---------------------------------------------------------"
else
    echo "---------------------------------------------------------"
    echo "$(tput setaf 3)Artemis: Installing Homebrew.$(tput sgr 0)"
    echo "---------------------------------------------------------"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# begin installing additional homebrew packages
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing system packages.$(tput sgr 0)"
echo "---------------------------------------------------------"

packages=(
    "git"
    "nvm"
    "yarn"
    "rcm"
)

for i in "${packages[@]}"
do
# check if package is installed
    echo "---------------------------------------------------------"
    echo "$(tput setaf 2)Artemis: Checking if $i is installed.$(tput sgr 0)"
    echo "---------------------------------------------------------"
    if brew list -1 | grep -q "^$i\$"; then
        echo "---------------------------------------------------------"
        echo "$(tput setaf 2)Artemis: $i is installed.$(tput sgr 0)"
        echo "---------------------------------------------------------"
    else
        echo "---------------------------------------------------------"
        echo "$(tput setaf 3)Artemis: $i is not installed. Installing $i.$(tput sgr 0)"
        echo "---------------------------------------------------------"
        brew install $i
        # if there is an installation error, exit the script
        if [ $? -ne 0 ]; then
            echo "---------------------------------------------------------"
            echo "$(tput setaf 1)Artemis: There was an error installing $i.$(tput sgr 0)"
            echo "---------------------------------------------------------"
            exit 1
        fi
    fi
done

# check if node is installed, if not install with nvm
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Checking if node is installed.$(tput sgr 0)"
echo "---------------------------------------------------------"
if [ -f "$(brew --prefix)/bin/node" ]
then
    echo "---------------------------------------------------------"
    echo "$(tput setaf 2)Artemis: Node is installed.$(tput sgr 0)"
    echo "---------------------------------------------------------"
else
    echo "---------------------------------------------------------"
    echo "$(tput setaf 3)Artemis: Node is not installed. Installing node.$(tput sgr 0)"
    echo "---------------------------------------------------------"
    nvm install node
    # if there is an installation error, exit the script
    if [ $? -ne 0 ]; then
        echo "---------------------------------------------------------"
        echo "$(tput setaf 1)Artemis: There was an error installing node.$(tput sgr 0)"
        echo "---------------------------------------------------------"
        exit 1
    fi
fi

# check if rvm is installed, and install it if it's not
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Checking for RVM installation.$(tput sgr 0)"
echo "---------------------------------------------------------"
rvm="/usr/local/rvm/bin/rvm"
if [ -f "$rvm" ]
then
    echo "---------------------------------------------------------"
    echo "$(tput setaf 2)Artemis: RVM is installed.$(tput sgr 0)"
    echo "---------------------------------------------------------"
else
    echo "---------------------------------------------------------"
    echo "$(tput setaf 3)Artemis: RVM is not installed. Installing RVM.$(tput sgr 0)"
    echo "---------------------------------------------------------"
    curl -sSL https://get.rvm.io | bash -s stable --ruby
fi

# Begin installing commonly used apps
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing your frequently used apps.$(tput sgr 0)"
echo "---------------------------------------------------------"

brew install --cask google-chrome
brew install --cask firefox
brew install --cask slack
brew install --cask visual-studio-code
# terminal emulator written in Rust
brew install --cask warp
# postgres explorer
brew install --cask postico
# docker 
brew install --cask docker
# markdown notes/second brain system
brew install --cask obsidian
# task management app
brew install --cask sunsama
# idea/thought inbox
brew install --cask todoist
# focus/distraction-blocking software (enable deep work)
brew install --cask focus

# install oh-my-zsh
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing oh-my-zsh.$(tput sgr 0)"
echo "---------------------------------------------------------"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install spaceship prompt
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing spaceship prompt.$(tput sgr 0)"
echo "---------------------------------------------------------"

git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# zsh plugins
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Installing zsh plugins.$(tput sgr 0)"
echo "---------------------------------------------------------"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# copy over dotfiles
echo "---------------------------------------------------------"
echo "$(tput setaf 2)Artemis: Copying over dotfiles.$(tput sgr 0)"
echo "---------------------------------------------------------"
env RCRC=$HOME/dotfiles/rcrc rcup
rcup