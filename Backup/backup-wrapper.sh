#!/bin/bash

# Crontab example:
# 0 3 * * * /opt/duplicacy/data/backup-wrapper.sh

# The script itself:
/bin/bash --login -c '/opt/duplicacy/data/backup.sh &> "/opt/duplicacy/data/logs/backup-$(date +%Y-%m-%d-%H-%M).log"'
