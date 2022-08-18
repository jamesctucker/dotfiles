#!/bin/sh
echo "---------------------------------------------------------"
echo "$(tput setaf 2) Artemis: Hello there, explorer. I am powering up and will begin configuration checks momentarily.$(tput sgr 0)"
echo "---------------------------------------------------------"

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
    echo "$(tput setaf 3)Artemis: Installing Homebrew. Homebrew requires osx command lines tools, please download xcode first$(tput sgr 0)"
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
    # "tmux"
    # "neovim"
    # "ripgrep"
    # "fzf"
    # "z"
    "yarn"
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