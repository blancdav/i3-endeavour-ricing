#!/usr/bin/env bash
set -e

echo "🚀 Installation post-install complète : i3 + Polybar + PulseAudio + Rofi + VMs + Desktop Clock + Animations + CMatrix + Kairu + Weather + i3lock-fancy + Fonts harmonisées"

# ------------------------------
# Dépendances principales
# ------------------------------
sudo pacman -S --noconfirm git curl wget unzip \
  zsh neovim fastfetch xava htop fzf ripgrep bat fd \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-iosevka-nerd \
  alacritty thunderbird vlc mpv timeshift \
  obsidian stremio rofi lsd helix qemu virt-manager dnsmasq vde2 bridge-utils openbsd-netcat \
  xautolock cmatrix feh jq pulseaudio pulseaudio-alsa pulseaudio-bluetooth pavucontrol \
  imagemagick i3lock colorlock

sudo systemctl enable --now libvirtd pulseaudio

# ------------------------------
# Supprimer PipeWire
# ------------------------------
sudo pacman -Rns --noconfirm pipewire pipewire-pulse wireplumber || true

# ------------------------------
# AUR helper si pas installé
# ------------------------------
if ! command -v yay &>/dev/null; then
  sudo pacman -S --noconfirm base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd ~
fi

# ------------------------------
# AUR packages
# ------------------------------
yay -S --noconfirm picom-git \
  catppuccin-gtk-theme-mocha \
  catppuccin-cursors-mocha papirus-icon-theme \
  brave-bin tor-browser discord code-bin polybar \
  autotiling zsh-theme-powerlevel10k baca \
  catppuccin-rofi-theme-git lf desktop-clock-widget kairu \
  polybar-pulseaudio-control-git \
  i3lock-fancy-git

# ------------------------------
# Dossiers de config
# ------------------------------
mkdir -p ~/.config/{i3,polybar,picom,nvim,yazi,fastfetch,xava,htop,alacritty,Code,thunderbird,rofi,desktop-clock-widget,i3lock-fancy}
mkdir -p ~/.local/bin

# ==============================
# i3 config avec fonts harmonisées et verrouillage écran
# ==============================
cat > ~/.config/i3/config << 'EOF'
set $mod Mod4
font pango:JetBrains Mono Nerd Font 11

# Palette Catppuccin Frappe
set $blue      #8caaee
set $green     #a6d189
set $red       #e78284
set $base      #303446
set $mantle    #292c3c
set $subtext1  #b5bfe2
set $text      #c6d0f5

client.focused          $blue $blue $text $base
client.focused_inactive $mantle $mantle $subtext1 $base
client.unfocused        $mantle $mantle $subtext1 $base
client.urgent           $red $red $base $text

# Workspaces minimalistes et VMs
set $ws1 ""
set $ws2 ""
set $ws3 ""
set $ws4 ""
set $ws5 ""
set $ws6 ""
set $ws7 ""
set $ws8 ""
set $ws9 "⏱️"
set $ws10 ""
set $ws11 ""
set $ws12 "kairu"
set $ws_k "k: "
set $ws_w "w: "

# Assign apps to workspaces
assign [class="Alacritty"] $ws1
assign [class="Neovim"] $ws1
assign [class="Helix"] $ws1
assign [class="Lf"] $ws1
assign [class="Brave-browser"] $ws2
assign [class="Tor Browser"] $ws2
assign [class="Thunar"] $ws3
assign [class="Code"] $ws4
assign [class="VirtualBox Manager"] $ws5
assign [class="virt-manager"] $ws5
assign [class="discord"] $ws6
assign [class="Obsidian"] $ws7
assign [class="Vlc"] $ws8
assign [class="stremio"] $ws8
assign [class="mpv"] $ws8
assign [class="Timeshift"] $ws9
assign [class="Thunderbird"] $ws10
assign [class="baca"] $ws11
assign [class="yazi"] $ws11
assign [class="fastfetch"] $ws11
assign [class="xava"] $ws11
assign [class="htop"] $ws11
assign [class="Kairu"] $ws12

# Workspace shortcuts
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
bindsym $mod+9 workspace $ws9
bindsym $mod+0 workspace $ws10
bindsym $mod+Shift+0 workspace $ws11
bindsym $mod+Shift+k workspace $ws12
bindsym $mod+k workspace $ws_k
bindsym $mod+w workspace $ws_w

# Remove native i3 bar
bar { status_command echo "Polybar replaces me" mode hide }

# Autostart apps
exec_always --no-startup-id picom --config ~/.config/picom/picom.conf
exec_always --no-startup-id autotiling
exec_always --no-startup-id ~/.config/polybar/launch.sh
exec_always --no-startup-id desktop-clock-widget --css ~/.config/desktop-clock-widget/style.css --position center --size 200

# CMatrix écran de veille après 10 min
exec_always --no-startup-id xautolock -time 10 -locker "cmatrix -C green -b" -detectsleep &

# Keybindings
bindsym $mod+Return exec alacritty
bindsym $mod+d exec rofi -show drun -theme ~/.config/rofi/catppuccin.rasi
bindsym $mod+n exec alacritty -e nvim
bindsym $mod+e exec alacritty -e yazi
bindsym $mod+t exec thunderbird
bindsym $mod+b exec baca
bindsym $mod+Shift+u exec kairu
bindsym $mod+v exec --no-startup-id ~/.local/bin/start-vm.sh
bindsym $mod+Shift+v exec --no-startup-id ~/.local/bin/rofi-vm.sh

# i3lock-fancy
bindsym $mod+Shift+l exec --no-startup-id ~/.config/i3lock-fancy/catppuccin.sh
EOF

# ==============================
# Script i3lock-fancy Catppuccin
# ==============================
cat > ~/.config/i3lock-fancy/catppuccin.sh << 'EOF'
#!/bin/bash
BG="#292c3c"
FG="#c6d0f5"
ACCENT="#8caaee"
i3lock-fancy -t blur -b "$BG" -f "$FG" -a "$ACCENT"
EOF
chmod +x ~/.config/i3lock-fancy/catppuccin.sh

# ==============================
# Picom animations
# ==============================
cat > ~/.config/picom/picom.conf << 'EOF'
backend = "glx"
vsync = true
corner-radius = 10
round-borders = 8
shadow = true
shadow-radius = 12
shadow-offset-x = -6
shadow-offset-y = -6
shadow-opacity = 0.3
fading = true
fade-delta = 8
fade-in-step = 0.03
fade-out-step = 0.03
animation-window-move = true
animation-stopping-step = 0.03
animation-open-window = true
animation-close-window = true
mark-wmwin-focused = true
detect-rounded-corners = true
EOF

# ==============================
# Polybar config avec PulseAudio, Weather
# ==============================
cat > ~/.config/polybar/config << 'EOF'
[colors]
background = #303446
foreground = #c6d0f5
primary = #8caaee
kali = #a6d189
windows = #89b4fa
alert = #e78284

[bar/top]
width = 100%
height = 28
background = ${colors.background}
foreground = ${colors.foreground}
modules-left = i3
modules-center =
modules-right = pulseaudio weather date
monitor = primary
override-redirect = true
tray-position = none
bottom = false

[module/i3]
type = internal/i3
label-focused = %name%
label-focused-background = ${primary}
label-focused-foreground = ${background}
label-unfocused =
label-urgent = %name%
label-urgent-foreground = ${alert}

[module/pulseaudio]
type = custom/script
exec = polybar-pulseaudio-control
interval = 2
label-volume = " %volume%%"
label-muted = "婢"
click-left = pactl set-sink-mute @DEFAULT_SINK@ toggle
click-right = pavucontrol

[module/weather]
type = custom/script
exec = ~/.local/bin/polybar-weather.sh
interval = 600
label = %output%
EOF

cat > ~/.config/polybar/launch.sh << 'EOF'
#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar top &
EOF
