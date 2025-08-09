#!/bin/bash

set -ouex pipefail

# Enable COPR repository
dnf -y copr enable atim/starship
dnf -y copr enable atim/bottom
dnf -y copr enable harryjph/fonts

# Enable the RPM Fusion repositories
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Setup VSCode repository
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# Remove packages that are not needed in the final image
dnf remove -y \
    gnome-tour \
    gnome-initial-setup \
    gnome-system-monitor \
    gnome-shell-extension-apps-menu \
    gnome-shell-extension-launch-new-instance \
    gnome-shell-extension-places-menu \
    gnome-shell-extension-window-list \
    gnome-classic-session \
    fedora-third-party \
    fedora-flathub-remote \
    fedora-workstation-repositories

# Install packages that are needed in the final image
dnf install -y \
    flatpak \
    dnf-plugins-core \
    fish \
    gitui \
    bat \
    mpv \
    starship \
    bottom \
    fastfetch \
    code \
    docker \
    docker-compose \
    gnome-tweaks \
    gnome-shell-extension-appindicator \
    helix \
    discord

# Enable Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Configure system
# grep -E '^docker:' /usr/lib/group | tee -a /etc/group
# usermod --shell /usr/bin/fish $USER
# usermod -aG docker $USER

# Enable a System Unit File
systemctl enable docker

# Setup system font
dnf install -y \
    google-noto-sans-fonts \
    jetbrains-mono-nerd-fonts

# Disable repository so they don't end up enabled on the final image:
dnf remove -y \
    rpmfusion-free-release \
    rpmfusion-nonfree-release
dnf -y copr disable atim/starship
dnf -y copr disable atim/bottom
dnf -y copr disable harryjph/fonts
rm /etc/yum.repos.d/vscode.repo

# Install GNOME extensions
# gnome-extensions install \
# https://extensions.gnome.org/extension-data/nightthemeswitcherromainvigier.fr.v79.shell-extension.zip
