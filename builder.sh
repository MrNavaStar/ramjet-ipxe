#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
	echo
	cat <<EOF
#----------------------------------------------------------#
# To use this script, pass a config and a list of make     #
# targets as args. They can be added to the command array  #
# inside the docker-compose.yml file. See the README for   #
# more info.                                               #
#----------------------------------------------------------#
EOF
	echo
	exit 1
fi

CONFIG="$1"
shift
if [[ ! -d "config/$CONFIG" ]]; then
	echo "Could not find config directory /build/ipxe/src/config/$CONFIG"
	exit 1
fi

# TODO: More sanity checks on the config directory?

TARGETS=()
while [[ $# -gt 0 ]]; do
	TARGETS+=("$1")
	shift
done

# If there is an embed script with the named config, use it
if [[ -f "config/$CONFIG/embed.ipxe" ]]; then
	EMBED="config/$CONFIG/embed.ipxe"
else
	EMBED=""
fi

for target in "${TARGETS[@]}"; do
	buildopts=("CONFIG=$CONFIG")
	if [[ -n "$EMBED" ]]; then
		buildopts+=("EMBED=$EMBED")
	fi
	if [[ "$target" =~ ^bin-arm32-efi/.*$ ]]; then
		buildopts+=("CROSS_COMPILE=arm-linux-gnueabi-" "ARCH=arm32")
	elif [[ "$target" =~ ^bin-arm64-efi/.*$ ]]; then
		buildopts+=("CROSS_COMPILE=aarch64-linux-gnu-" "ARCH=arm64")
	fi

	echo "make ${buildopts[@]} $target"
	make -j$(nproc) "${buildopts[@]}" "$target"
done

echo
echo "Build finished successfully!"

echo
echo "Copying build artifacts:"
for bin in "${TARGETS[@]}"; do
	mkdir -p "$(dirname "/out/$bin")"
	cp -v "$bin" "/out/$bin"
done

echo
echo "Building tarball:"
tar czvf /out/ipxe-bundle.tar.gz "${TARGETS[@]}"
