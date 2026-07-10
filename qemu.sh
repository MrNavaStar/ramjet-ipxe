#!/usr/bin/env bash
set -euo pipefail

# Chain boot script from a local instance of ramjet
ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
cat > qemu.ipxe <<EOF
#!ipxe
:start
chain --replace http://${ip}:11722/v1/idle ||
sleep 5
goto start
EOF

qemu-system-x86_64 \
  -m 1024 \
  -netdev user,id=n1,tftp=$(pwd),bootfile=qemu.ipxe \
  -device virtio-net-pci,netdev=n1 \
  -kernel out/bin/ipxe.lkrn

rm qemu.ipxe