#! /bin/sh

CONVERT=$(which convert)

usage() {
	cat << EOF
Usage: $0 <source>
	source: source image file (must be a valid file)
Outputs a "icon.ico" file
EOF
}

run() {
	local source=$1
	echo $source
	${CONVERT} $source -define icon:auto-resize=64,32,16 icon.ico
}

if [ "$#" != "1" ]; then
	usage
	exit
fi

if [ ! -f "$1" ]; then
	usage
	exit
fi

if [ -z "$CONVERT" ]; then
	echo "It seems you do not have imagemagick..."
	echo "Aborting Win app icon creation."
	exit
fi

run $1
