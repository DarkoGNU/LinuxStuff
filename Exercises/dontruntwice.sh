#!/bin/bash

FILENAME=$(basename "$0")
INSTANCES="$(ps axco command | grep $FILENAME | grep -v grep --count)"
INSTANCES=$(( $INSTANCES - 1 ))

if [ $INSTANCES -gt 1 ]; then
	logger -p warn "This script is currently running ($INSTANCES instances) - exiting... - PID $BASHPID"
	exit 1
fi

if mkdir /run/lock/dontruntwice; then
	logger -p info "This script won't run in parallel! - PID $BASHPID"
	trap 'rm -rf /run/lock/dontruntwice' EXIT
else
	logger -p warn "Locking failed - this script might be running in parallel! - PID $BASHPID"
	exit 1
fi

sleep 115

logger -p info "This script is stopping now - PID $BASHPID"
