#!/bin/bash

sudo pkill -9 -f flatpak
sudo pkill -9 -f bazaar
sudo pkill -9 -f flatpak-system-helper
sudo rm -f /var/lib/flatpak/.changed
sudo mkdir -p /etc/bazzite
echo "9" | sudo tee /etc/bazzite/flatpak_manager_version
mount | grep revokefs
flatpak repair --system
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update --appstreamflatpak
flatpak install flathub org.gnome.baobab -y
