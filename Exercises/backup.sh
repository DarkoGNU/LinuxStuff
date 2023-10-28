#!/bin/bash

info () { echo "First argument: directory to backup, second argument (optional) - compression algorithm (gzip, bzip2, xz)"; }

move () {
	case "$1" in
	*.*) mv "$1" "${1%.*}_$(date --reference "$1" +%Y%m%dT%H%M).${1##*.}";;
	*) mv "$1" "${1}_$(date --reference "$1" +%Y%m%dT%H%M)";;
	esac
}
export -f move

DIR="$1"
ALGO="$2"
BACKUP_DIR="/Ćwiczenia/backup"

# Ensure BACKUP_DIR is created
mkdir -p "$BACKUP_DIR"

# Check if BACKUP_DIR exists
if [ ! -d "$BACKUP_DIR" ]; then
	echo "$BACKUP_DIR does not exist"
	exit 1
fi

# Check if first argument (directory) is not empty
if [ -z "$DIR" ]; then
	echo "First argument is required"
	info
	exit 1
fi

# Check if the directory exists
if [ ! -d "$DIR" ]; then
	echo "First argument has to be a directory"
	info
	exit 1
fi

# No compression algorithm - use gzip
if [ -z "$ALGO" ]; then
	ALGO="gzip"
	echo "Using default (gzip) compression algorithm"
fi

# Backup files
cp -a "$DIR" "$BACKUP_DIR"

TARGET_DIR="${BACKUP_DIR}/$(basename ${DIR})"

# Compress
if [ "$ALGO" == "gzip" ]; then
	gzip -r "$TARGET_DIR"
elif [ "$ALGO" == "bzip2" ]; then
	find "$TARGET_DIR" -type f -not -name \*.bz2 -exec bzip2 \{\} \;
elif [ "$ALGO" == "xz" ]; then
	find "$TARGET_DIR" -type f -not -name \*.xz -exec xz \{\} \;
else
	echo "Compression algorithm $ALGO is not supported"
	exit 1
fi

# Rename
find "$TARGET_DIR" -depth -exec bash -c 'move {}' \;

echo "Backed up $DIR"
