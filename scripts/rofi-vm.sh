#!/bin/bash
options="  Kali\n  Windows11"
chosen=$(echo -e "$options" | rofi -dmenu -i -p "▶ VM")
case $chosen in
    "  Kali")
        i3-msg "workspace k: "
        ~/.local/bin/start-vm.sh
        ;;
    "  Windows11")
        i3-msg "workspace w: "
        qemu-system-x86_64 -enable-kvm -m 8192 -smp 4 -cpu host \
          -drive file="$HOME/VMs/windows11.qcow2",format=qcow2 -display gtk,gl=on
        ;;
esac
