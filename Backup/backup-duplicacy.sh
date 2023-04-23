#!/bin/bash

# --- Duplicacy backup script. Assumes that duplicacy is in the PATH. ---
# --- Also assumes that everything is on / partition                  ---

# --- REPOSITORIES,LOCATIONS,VOLUMES have to match ---

# Duplicacy config
REPO_FOLDER="/root/duplicacy/repositories"

# Repositories and locations
REPOSITORIES=("ampere-home" "ampere-etc" "ampere-root")
LOCATIONS=("/home" "/etc" "/root")

# Drive configuration
SNAP_PREFIX=duplicacy-
VOLUMES=("ocivolume/root" "ocivolume/root" "ocivolume/root")

for (( i=0; i<${#REPOSITORIES[@]}; i++ )); do
        # Make a snapshot
        echo lvcreate -s --name "${SNAP_PREFIX}/${REPOSITORIES[${i}]}" ""
done
