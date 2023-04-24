#!/bin/bash

# --- Duplicacy backup script. Assumes that duplicacy is in the PATH. ---
# --- Requires LVM thin volumes                                       ---

# --- REPOSITORIES,LOCATIONS,VOLUMES have to match           ---
# --- Even if all the backed up locations are on the same LV ---

# Functions
info () { echo -e "\e[32m[INFO]\e[0m ${1}" ; }
warn () { echo -e "\e[33m[WARN]\e[0m ${1}" ; }
error () { echo -e "\e[31m[INFO]\e[0m ${1}" ; }

# Duplicacy config
BASE_FOLDER="/opt/duplicacy/data"         # Base folder for all data used by script
REPO_FOLDER="${BASE_FOLDER}/repositories" # Folder for storing repository data (what normally is stored in .duplicacy)
MOUNT_FOLDER="${BASE_FOLDER}/mounts"      # Folder where snapshots will be mounted
THREADS=4                                 # Number of threads to use

STORAGE_NAME="google-drive"               # Name of the storage used
STORAGE="gcd://duplicacy"                 # URL of the storage used
GCD_TOKEN="${BASE_FOLDER}/gcd-token.json" # Path to Google Drive token

# Repositories and locations
REPOSITORIES=("ampere-etc" "ampere-root" "ampere-home") # Names of the repositories
LOCATIONS=("etc/" "root/" "home/")                      # Folder inside the volume to back up (empty to back up root of the volume)

# Drive configuration
SNAP_PREFIX=duplicacy-
VOLUMES=("ocivolume/root" "ocivolume/root" "ocivolume/root")

info "Ensuring that base directories are created"
mkdir -p "$REPO_FOLDER"
mkdir -p "$MOUNT_FOLDER"

# Backup all repositories
for (( i=0; i<${#REPOSITORIES[@]}; i++ )); do
	### Set variables
	REPO="${REPOSITORIES[${i}]}"       # Repo name
        REPO_PATH="${REPO_FOLDER}/${REPO}" # Path to repository data

        MOUNT="${MOUNT_FOLDER}/${REPO}"               # Mount point for the snapshot
	BACKUP_PATH="${MOUNT}/${LOCATIONS[${i}]}"     # Path to back up
        VOLUME="${VOLUMES[${i}]}"                     # Volume on which the backup is performed
	VOL_GROUP="$(dirname $VOLUME)"                # Volume group of that volume
	SNAPSHOT="${VOL_GROUP}/${SNAP_PREFIX}${REPO}" # Snapshot name (with VG)


	### Backup
	info "Backing up repository ${REPO}"

	info "Creating a snapshot"
	lvcreate --snapshot --name "$SNAPSHOT" "$VOLUME"

	info "Mounting the snapshot"
	mkdir -p "$MOUNT"
	lvchange -ay -Ky "$SNAPSHOT"
	mount -o nouuid,ro "/dev/${SNAPSHOT}" "$MOUNT"

	info "Checking if the repo is initialized"
        if [[ ! -d "$REPO_PATH" ]]; then
		info "Initializing the repository"
		warn "Please wait, the token path will be passed automatically!"
		(sleep 5; echo "$GCD_TOKEN") | duplicacy init -pref-dir "$REPO_PATH" -repository "$BACKUP_PATH" -storage-name "$STORAGE_NAME" "$REPO" "$STORAGE"
        fi

	info "Starting the actual backup"
	echo -n "$REPO_PATH" > .duplicacy
	warn "Please wait, the token path will be passed automatically!"
	(sleep 5; echo "$GCD_TOKEN") | duplicacy backup -threads "$THREADS"

	info "Unmounting the snapshot"
	umount "/dev/${SNAPSHOT}"
	info "Removing the mount point"
	rmdir "$MOUNT"
	info "Removing the snapshot"
	lvremove -y "/dev/${SNAPSHOT}"
done
