#!/bin/bash

# --- Duplicacy backup script. Assumes that duplicacy is in the PATH. ---
# --- Also assumes that everything is on / partition                  ---
# --- Requires LVM thin volumes                                       ---

# --- REPOSITORIES,LOCATIONS,VOLUMES have to match           ---
# --- Even if all the backed up locations are on the same LV ---

# Duplicacy config
BASE_FOLDER="/opt/duplicacy/data"         # Base folder for all data used by script
REPO_FOLDER="${BASE_FOLDER}/repositories" # Folder for storing repository data (what normally is stored in .duplicacy)
MOUNT_FOLDER="${BASE_FOLDER}/mounts"      # Folder where snapshots will be mounted
INIT_FOLDER="${BASE_FOLDER}/initialized"  # Folder where information whether repositories are already analyzed is stored

# Repositories and locations
REPOSITORIES=("ampere-home") # "ampere-etc" "ampere-root")
LOCATIONS=("/home" "/etc" "/root")

# Drive configuration
SNAP_PREFIX=duplicacy-
VOLUMES=("ocivolume/root" "ocivolume/root" "ocivolume/root")

# Ensure that all repositories are initialized
for (( i=0; i<${#REPOSITORIES[@]}; i++ )); do
	REPO="${REPOSITORIES[${i}]}"
	if [[ ! -f  ]]; then

	fi
done

# Backup all repositories
for (( i=0; i<${#REPOSITORIES[@]}; i++ )); do
	# Set variables
        MOUNT="${MOUNT_FOLDER}/${REPOSITORIES[${i}]}"               # Mount point for the snapshot
        VOLUME="${VOLUMES[${i}]}"                                   # Volume on which the backup is performed
	VOL_GROUP="$(dirname $VOLUME)"                              # Volume group of that volume
	SNAPSHOT="${VOL_GROUP}/${SNAP_PREFIX}${REPOSITORIES[${i}]}" # Snapshot name (with VG)

	# Make a snapshot
	echo lvcreate --snapshot --name "$SNAPSHOT" "$VOLUME"

	# Mount the snapshot
	echo mkdir -p "$MOUNT"
	echo lvchange -ay -Ky "$SNAPSHOT"
	echo mount -o nouuid,ro "/dev/${SNAPSHOT}" "$MOUNT"

	# Unmount the snapshot
	echo umount "/dev/${SNAPSHOT}"
	# Remove the mount point
	echo rmdir "$MOUNT"
	# Remove the snapshot
	echo lvremove -y "/dev/${SNAPSHOT}"
done
