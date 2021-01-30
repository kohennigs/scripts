#!/bin/bash
# FHEM
# docker: user pi hardcoded

clear
echo "*********************************************************"
echo "* pi_install.sh installs my (koh s) raspberry Pi s      *"
echo "*********************************************************"
echo " " 
echo " WAIT! prerequirements " 
echo " " 
echo "  - ssh-key(s) copied to this mashine? "
echo "       1. ssh-keygen -t rsa -b 4096"
echo "       2. ssh-copy-id -i ~/path_to_keyfil user@server"
echo " " 

# ask for confirmation of prereq. 
# no ssy key present might become a problem ;-) 
read -r -p "1) run script? [Y/n] " inputStart


case $inputStart in
        [yY][eE][sS]|[yY])

        # shall wie install Cups and Samsung ML1915 driver?
        read -r -p "2) Install CUPS? [Y/n]" inputCUPS
        read -r -p "2) Install Docker? [Y/n]" inputDocker
        line="----------------------------> "
        gitfolder="koh-git"

        echo "$line updating repository data"
        sudo apt-get -y update 
        sudo apt-get -y upgrade

        echo "$line installing aptitude"
        sudo apt-get install aptitude -y

        echo "$line installing tools"
        sudo aptitude install vim screen git zsh unattended-upgrades -y

        echo "$line system setup"
        # set timezome to europe / berlin
        sudo timedatectl set-timezone Europe/Berlin
        ## set system lang to de DE
        sudo sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/g' /etc/locale.gen
        sudo locale-gen
        sudo update-locale LANG=de_DE.UTF-8 LC_MESSAGES=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8
        #sudo sed -i 's/LC_ALL="C"/LC_ALL=de_DE.UTF-8/g' /etc/environment
        #sudo echo "LANG=de_DE.UTF-8" >> /etc/environment
        echo ""

        echo "$line ssh setup"
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        sudo service ssh restart

        echo "$line git setup"
        set the one and only editor 
        git config --global core.editor vim
        git config --global user.name "Kai Hennigs"
        git config --global user.email "koh@ngopi.de"
        git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
        git config --global alias.ll = "log --graph --pretty=format:'%Cred%h%Creset - %C(bold blue)<%an> %C(yellow)%d%Creset %s %Cgreen(%cr) %Creset' --abbrev-commit"

        echo "$line clone dotfiles from github"
        cd ~
        mkdir $gitfolder
        cd $gitfolder
        git clone https://github.com/kohennigs/dotfiles.git -q

        echo "$line bash setup "
        rm -f ~/.bash_aliases
        ln -s ~/$gitfolder/dotfiles/.aliases /.bash_aliases
        ln -s ~/$gitfolder/dotfiles/.screenrc /.screenrc
        source ~/.bashrc

        echo "$line zsh setup"
        if [ -f ~./zshrc ] ; then 
                rm ~/.zshrc
        fi

        ln -s ~/$gitfolder/dotfiles/.zshrc ~/.zshrc
        mkdir -p ~/.cache/zsh
        sudo usermod --shell /usr/bin/zsh pi

        echo "$line adding autosuggestion to zsh" 
        rm -rf ~/.zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

        echo "$line fzf setup"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf -q && ~/.fzf/install --all >> /dev/null


        echo "$line vim setup"
        rm -f ~/.vimrc
        rm -rf ~/.vim
        mkdir -p ~/.vim/plugged
        mkdir -p ~/.vim/vim_sessions
        
        echo "let work = 0" > ~/.vimrc
        echo "source ~/$gitfolder/dotfiles/.vimrc" >> ~/.vimrc

        case $inputCUPS in
                [yY][eE][sS]|[yY])
                        echo "Installing CUPS (and splix driver)"
                        # cups instal
                        sudo aptitude install cups printer-driver-splix  -y
                        # allow administrtion via network
                        sudo cupsctl --remote-admin
                        # allow printer sharing
                        sudo cupsctl --share-printers
                        # allow administrtion via any computer
                        sudo cupsctl --remote-any
                        # add user pi to cups admins
                        sudo usermod -aG lpadmin pi
                        # samsung printer driver
                        #sudo aptitude install  printer-driver-splix
                        # restart cups
                        sudo systemctl restart cups
                        ;;
                *)
                        echo "OK. No CUPS"
#                        exit 1
                        ;;
        esac

        case $inputDocker in
                [yY][eE][sS]|[yY])
                        echo "Installing Docker"
                        curl -fsSL https://get.docker.com -o get-docker.sh
                        sudo sh get-docker.sh
                        sudo usermod -aG docker pi
                        echo "Docker installed. You shall reconnect user"
                        ;;
                *)
                        echo "OK. No Docker"
#                        exit 1
                        ;;
        esac


        echo "********************************"
        echo "*    YOU SHALL REBOOT!         *"
        echo "********************************"

;;

# inputStart = n(o),..
[nN][oO]|[nN])
        echo "stopped. Have a nice day!"
        exit 1
        ;;
*)
        echo "Invalid inputStart..."
        exit 1
        ;;
esac


