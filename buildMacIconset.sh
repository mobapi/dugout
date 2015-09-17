#! /bin/sh

SIZES="64 128 256 512 1024"
DIRECTORY=icon.iconset

SIPS=$(which sips)
ICONUTIL=$(which iconutil)

usage() {
	cat << EOF
Usage: $0 <source>
	source: 1024 x 1024 source image file (must be a valid file)
Outputs a "icon.icns" file including 64x64 to 1024x1024 icons
EOF
}

run() {
	local source=$1
	echo $source
	rm -rf ${DIRECTORY}
	mkdir ${DIRECTORY}
	for size in $SIZES; do
		$SIPS -z $size $size "$source" --out ${DIRECTORY}/icon_${size}x${size}.png
		$SIPS -z $size $size "$source" --out ${DIRECTORY}/icon_$(($size/2))x$(($size/2))@2x.png
	done
	$ICONUTIL -c icns ${DIRECTORY}
	rm -rf ${DIRECTORY}
}

if [ "$#" != "1" ]; then
	usage
	exit
fi

if [ ! -f "$1" ]; then
	usage
	exit
fi

if [ -z "$SIPS" -o -z "$ICONUTIL" ]; then
	echo "It seems you do not have sips nor iconutil, maybe you are not on a Mac..."
	echo "Aborting Mac app icon creation."
	exit
fi

run $1
