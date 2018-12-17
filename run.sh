#! /bin/sh

# vscode install
install_vscode() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo yum install -y code
}

# adding nux repo to yum
enable_nux_repo() {
    # enable nux repo 
    echo "Enabling nux repo for Centos"
    rpm -q --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro 
    sudo yum -q -y install epel-release && rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
}

# guake
install_guake() {
    sudo yum install -y guake.x86_64
}

# just install all
install_all() {
    install_vscode
    enable_nux_repo
    install_guake
}

# input for yes/no/all
read_input_ynall() {
    install_rest() {
        local ENB_NUX_REPO=$'Would like to enable nux repository? [y/n] '
        local INST_GUAKE=$'Would like to install Guake? [y/n] '
        read_input_yn "$ENB_NUX_REPO" enable_nux_repo
        read_input_yn "$INST_GUAKE" install_guake
    }

    while true; do
        read -p "$1" yna
        case $yna in
            [Yy]* ) $2; break;;
            [Nn]* ) install_rest; break;;
            [all]* ) $3 ; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# input with yes/no
read_input_yn() {
    while true; do
        read -p "$1" yn
        case $yn in
            [Yy]* ) $2; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

INSTVSCODEMSG=$'Would like to install vscode as well?\nEnter [all] to install everything else [y/n] '
read_input_ynall "$INSTVSCODEMSG" install_vscode install_all

# install necessary packages
sudo yum install -y\
    epel-release\
    gtk2-engines\
    gtk-murrine-engine\
    gtk-xfce-engine\
    gtk3\
    paper-icon-theme\

sudo yum groupinstall "X window System" -y
sudo yum groupinstall xfce -y

# check if xfce4 config directory exist. 
XFCE_DIR=/home/"$USER"/.config/xfce4
mkdir -p $XFCE_DIR

function runoveroldconf {
    rm -rf $XFCE_DIR/*
    yes | cp -rf ./* $XFCE_DIR
}

function keepoldconf {
    yes | cp -rf ./* $XFCE_DIR
}

# ask if user wants to keep the old config
while true; do
    read -p "Do you wish to keep the old config?" yn
    case $yn in
        [Yy]* ) keepoldconf; break;;
        [Nn]* ) runoveroldconf exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


# change system conf and ask to restart X11
sudo systemctl isolate graphical.target

while true; do
    read -p "Do you wish to restart X11 now?" yn
    case $yn in
        [Yy]* ) sudo killall X; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

