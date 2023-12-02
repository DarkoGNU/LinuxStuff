#!/bin/bash

RUNNING_MSG="MySQL Server is running"
STARTED_MSG="MySQL Server has been started."

systemctl status mysqld --no-pager > /dev/null
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
	logger -p info "$RUNNING_MSG"
elif [ $EXIT_CODE -gt 0 ]; then
	systemctl start mysqld
	logger -p warn "$STARTED_MSG"
	echo "$STARTED_MSG" | mail -s "$STARTED_MSG" root
fi
