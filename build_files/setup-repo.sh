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

# Enable the Terra repository
dnf install -y --nogpgcheck --repofrompath \
    'terra,https://repos.fyralabs.com/terra$releasever' terra-release

# Setup VSCode repository
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e \
    "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
    | tee /etc/yum.repos.d/vscode.repo > /dev/null
