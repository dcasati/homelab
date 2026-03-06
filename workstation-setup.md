# Workstation Setup Manifest
# ==========================
# System: WSL2 Ubuntu 24.04 (WIN-THINK24)
# User: dcasati
# X11 Server: X410
# Window Manager: i3wm
# Last updated: 2026-03-04

# ─────────────────────────────────────────────
# 1. TOOLS — ~/bin (no sudo required)
# ─────────────────────────────────────────────

## kubectl — Kubernetes CLI
# Version: v1.35.2
# Install:
#   curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#   chmod +x kubectl && mv kubectl ~/bin/

## helm — Kubernetes package manager
# Version: v3.20.0
# Install:
#   curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=~/bin USE_SUDO=false bash

## k9s — Kubernetes TUI
# Version: v0.50.18
# Install:
#   curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz -C ~/bin k9s

## viu — Terminal image viewer (supports Kitty graphics protocol)
# Version: 1.6.1
# Install:
#   curl -fsSL https://github.com/atanunq/viu/releases/latest/download/viu-x86_64-unknown-linux-musl -o ~/bin/viu && chmod +x ~/bin/viu

## yazi — Terminal file manager
# Version: 26.1.22
# Install:
#   curl -fsSL https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip -o /tmp/yazi.zip
#   unzip -o /tmp/yazi.zip -d /tmp/yazi
#   cp /tmp/yazi/yazi-x86_64-unknown-linux-musl/yazi ~/bin/yazi && chmod +x ~/bin/yazi

## kitty wrapper — WSL2 software rendering wrapper
# Location: ~/bin/kitty (wraps /usr/bin/kitty)
# Contents:
#   #!/bin/bash
#   export LIBGL_ALWAYS_SOFTWARE=1
#   export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
#   export GALLIUM_DRIVER=llvmpipe
#   export KITTY_ENABLE_WAYLAND=0
#   export GIO_USE_VFS=local
#   export GTK_USE_PORTAL=0
#   exec /usr/bin/kitty "$@"

# ─────────────────────────────────────────────
# 2. TOOLS — apt packages (sudo required)
# ─────────────────────────────────────────────

## i3wm + ecosystem
# sudo apt-get install -y i3 rofi flameshot py3status i3status fonts-dejavu fonts-hack python3-i3ipc
# Versions: i3 4.23 | rofi 1.7.5 | flameshot 12.1.0 | py3status 3.54 | i3status 2.14

## kitty — GPU-accelerated terminal with image protocol
# sudo apt-get install -y kitty
# Version: 0.32.2

## microsoft-edge — Browser
# curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
# sudo apt-get update && sudo apt-get install -y microsoft-edge-stable
# Version: 145.0.3800.82

## azure-cli
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Version: 2.84.0

## Other apt tools
# sudo apt-get install -y jq fzf unzip direnv
# jq 1.7 | fzf 0.44.1 | direnv (for .envrc auto-loading)

## Hack Nerd Font — required for yazi icons
# Install:
#   mkdir -p ~/.local/share/fonts
#   curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip -o /tmp/Hack.zip
#   unzip -o /tmp/Hack.zip -d ~/.local/share/fonts/
#   fc-cache -fv ~/.local/share/fonts/
#   rm /tmp/Hack.zip

# ─────────────────────────────────────────────
# 3. BASHRC ADDITIONS (~/.bashrc)
# ─────────────────────────────────────────────

# eval "$(direnv hook bash)"
# export PATH="$HOME/bin:$PATH"
# export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
# k=kubectl
# export DISPLAY=$(grep -m1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0
# export LIBGL_ALWAYS_SOFTWARE=1
# export GSK_RENDERER=cairo
# export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
# export GALLIUM_DRIVER=llvmpipe
# source /usr/share/doc/fzf/examples/key-bindings.bash
# source <(kubectl completion bash)
# source ~/.kubectl_fzf.bash

# ─────────────────────────────────────────────
# 4. SSH CONFIG (~/.ssh/config)
# ─────────────────────────────────────────────

# Host elserverloco
#     HostName 172.16.5.184
#     User ubuntu
#
# Host microk8s
#     HostName 172.16.5.185
#     User dcasati
#
# Host unifi
#     HostName 172.16.5.186
#     User dcasati
#
# Host haos
#     HostName 172.16.5.148
#     User root

# ─────────────────────────────────────────────
# 5. CONFIG FILES
# ─────────────────────────────────────────────

## i3 config — ~/.config/i3/config
# Source: https://raw.githubusercontent.com/dcasati/dotfiles/refs/heads/master/i3/config
# Modifications:
#   - Terminal changed to: kitty --single-instance
#   - Added startup: exec --no-startup-id kitty --single-instance --start-as minimized

## Kitty config — ~/.config/kitty/kitty.conf
# Key settings:
#   font_family Hack Nerd Font Mono, font_size 11.0
#   hide_window_decorations yes
#   disable_ligatures always
#   repaint_delay 2, input_delay 0, sync_to_monitor no
#   cursor_blink_interval 0
#   detect_urls no
#   mouse_hide_wait -1
#   single_instance yes
#   scrollback_lines 2000
#   allow_hyperlinks yes

## k9s config — ~/.config/k9s/config.yaml
# Key settings:
#   ui.skin: amber

## k9s skin — ~/.config/k9s/skins/amber.yaml
# Old-school amber-on-black terminal theme (#FFB000 on #000000)

## Cluster config — ~/clusters/elserverloco/
# .envrc: export KUBECONFIG=$(pwd)/kubeconfig
# kubeconfig: MicroK8s cluster at 172.16.5.185:16443

# ─────────────────────────────────────────────
# 5b. GO + KUBECTL-FZF
# ─────────────────────────────────────────────

## Go — required for building kubectl-fzf
# Version: 1.23.6
# Install:
#   curl -fsSL https://go.dev/dl/go1.23.6.linux-amd64.tar.gz -o /tmp/go.tar.gz
#   sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz
#   export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin  # also in .bashrc

## kubectl-fzf — blazing-fast kubectl completion with fzf
# Binaries: ~/go/bin/kubectl-fzf-completion, ~/go/bin/kubectl-fzf-server
# Bash integration: ~/.kubectl_fzf.bash
# Cache dir: /tmp/kubectl_fzf_cache/
# Install:
#   go install github.com/bonnefoa/kubectl-fzf/v3/cmd/kubectl-fzf-completion@main
#   go install github.com/bonnefoa/kubectl-fzf/v3/cmd/kubectl-fzf-server@main
#   wget -q https://raw.githubusercontent.com/bonnefoa/kubectl-fzf/main/shell/kubectl_fzf.bash -O ~/.kubectl_fzf.bash
# Ref: https://lafabrique.ai/blog/blazing-fast-kubectl-completion/
#      https://github.com/bonnefoa/kubectl-fzf

## kubectl-fzf-server systemd service — ~/.config/systemd/user/kubectl-fzf-server.service
# [Unit]
# Description=kubectl-fzf cache server
# After=network.target
# [Service]
# Type=simple
# ExecStart=%h/go/bin/kubectl-fzf-server
# Restart=on-failure
# RestartSec=10
# Environment=KUBECONFIG=%h/clusters/elserverloco/kubeconfig
# [Install]
# WantedBy=default.target
#
# Enable & start:
#   systemctl --user daemon-reload
#   systemctl --user enable --now kubectl-fzf-server.service

# ─────────────────────────────────────────────
# 6. QUICK SETUP SCRIPT
# ─────────────────────────────────────────────
# To replay this setup on a fresh WSL2 Ubuntu 24.04 instance, run:
#
#   # 1. Create ~/bin
#   mkdir -p ~/bin
#
#   # 2. Install apt packages
#   sudo apt-get update
#   sudo apt-get install -y i3 rofi flameshot py3status i3status kitty \
#     fonts-dejavu fonts-hack python3-i3ipc jq fzf unzip direnv
#
#   # 3. Install Microsoft Edge
#   curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
#   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
#   sudo apt-get update && sudo apt-get install -y microsoft-edge-stable
#
#   # 4. Install Azure CLI
#   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
#
#   # 5. Install ~/bin tools
#   curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl ~/bin/
#   curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=~/bin USE_SUDO=false bash
#   curl -fsSL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz -C ~/bin k9s
#   curl -fsSL https://github.com/atanunq/viu/releases/latest/download/viu-x86_64-unknown-linux-musl -o ~/bin/viu && chmod +x ~/bin/viu
#   curl -fsSL https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip -o /tmp/yazi.zip && unzip -o /tmp/yazi.zip -d /tmp/yazi && cp /tmp/yazi/yazi-x86_64-unknown-linux-musl/yazi ~/bin/yazi && chmod +x ~/bin/yazi && rm -rf /tmp/yazi /tmp/yazi.zip
#
#   # 6. Apply i3 config
#   mkdir -p ~/.config/i3
#   curl -fsSL https://raw.githubusercontent.com/dcasati/dotfiles/refs/heads/master/i3/config -o ~/.config/i3/config
#   sed -i 's|exec i3-sensible-terminal|exec kitty --single-instance|' ~/.config/i3/config
#   echo 'exec --no-startup-id kitty --single-instance --start-as minimized' >> ~/.config/i3/config
#
#   # 7. Apply bashrc additions
#   cat >> ~/.bashrc << 'EOF'
#   eval "$(direnv hook bash)"
#   export PATH="$HOME/bin:$PATH"
#   k=kubectl
#   export DISPLAY=$(grep -m1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0
#   export LIBGL_ALWAYS_SOFTWARE=1
#   export GSK_RENDERER=cairo
#   export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
#   export GALLIUM_DRIVER=llvmpipe
#   source /usr/share/doc/fzf/examples/key-bindings.bash
#   EOF
#
#   # 8b. Install Hack Nerd Font
#   mkdir -p ~/.local/share/fonts
#   curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip -o /tmp/Hack.zip
#   unzip -o /tmp/Hack.zip -d ~/.local/share/fonts/ && fc-cache -fv ~/.local/share/fonts/ && rm /tmp/Hack.zip
#
#   # 8. Create kitty wrapper
#   cat > ~/bin/kitty << 'WRAPPER'
#   #!/bin/bash
#   export LIBGL_ALWAYS_SOFTWARE=1
#   export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
#   export GALLIUM_DRIVER=llvmpipe
#   export KITTY_ENABLE_WAYLAND=0
#   export GIO_USE_VFS=local
#   export GTK_USE_PORTAL=0
#   exec /usr/bin/kitty "$@"
#   WRAPPER
#   chmod +x ~/bin/kitty
#
#   # 9. Apply kitty, k9s configs (copy from this repo or recreate)
#   # See sections 5 above for contents
#
#   # 10. Install Go + kubectl-fzf
#   curl -fsSL https://go.dev/dl/go1.23.6.linux-amd64.tar.gz -o /tmp/go.tar.gz
#   sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz
#   export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
#   echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
#   go install github.com/bonnefoa/kubectl-fzf/v3/cmd/kubectl-fzf-completion@main
#   go install github.com/bonnefoa/kubectl-fzf/v3/cmd/kubectl-fzf-server@main
#   wget -q https://raw.githubusercontent.com/bonnefoa/kubectl-fzf/main/shell/kubectl_fzf.bash -O ~/.kubectl_fzf.bash
#   cat >> ~/.bashrc << 'EOF'
#   source <(kubectl completion bash)
#   source ~/.kubectl_fzf.bash
#   EOF
#
#   # 11. Create kubectl-fzf-server systemd user service
#   mkdir -p ~/.config/systemd/user
#   cat > ~/.config/systemd/user/kubectl-fzf-server.service << 'SVC'
#   [Unit]
#   Description=kubectl-fzf cache server
#   After=network.target
#   [Service]
#   Type=simple
#   ExecStart=%h/go/bin/kubectl-fzf-server
#   Restart=on-failure
#   RestartSec=10
#   Environment=KUBECONFIG=%h/clusters/elserverloco/kubeconfig
#   [Install]
#   WantedBy=default.target
#   SVC
#   systemctl --user daemon-reload
#   systemctl --user enable --now kubectl-fzf-server.service
