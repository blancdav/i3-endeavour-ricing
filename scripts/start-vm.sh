#!/bin/bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 2 \
  -cpu host \
  -drive file="$HOME/VMs/kali.qcow2",format=qcow2 \
  -display gtk,gl=on \
  -device virtio-net,netdev=n0 \
  -netdev user,id=n0 \
  -boot c
