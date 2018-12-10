#! /bin/sh

# install necessary packages
sudo yum install -y\
    epel-release\
    gtk2-engines\
    gtk-murrine-engine\
    gtk-xfce-engine\
    gtk3\
    paper-icon-theme
    # goa

sudo yum groupinstall "X window System" -y
sudo yum groupinstall xfce -y

# check if xfce4 config directory exist. 
xfce_DIR=/home/"$USER"/.config/xfce4
mkdir -p $xfce_DIR

function runoveroldconf {
    rm -rf $xfce_DIR/*
    yes | cp -rf ./* $xfce_DIR
}

function keepoldconf {
    yes | cp -rf ./* $xfce_DIR
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

