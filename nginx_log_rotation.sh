#!/bin/bash

# Nginx Log Rotation and Cleanup Script
# Purpose: Compress log files older than 7 days and delete compressed files older than 15 days
# Author: Admin
# Date: 2025-12-11

LOG_DIR="/var/log/nginx"
COMPRESS_AGE_DAYS=7
DELETE_AGE_DAYS=15
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file for script execution
SCRIPT_LOG="/var/log/nginx_rotation.log"

# Function to log messages
log_message() {
    echo "[${TIMESTAMP}] $1" | tee -a "${SCRIPT_LOG}"
}

# Check if nginx log directory exists
if [ ! -d "${LOG_DIR}" ]; then
    log_message "${RED}ERROR: Directory ${LOG_DIR} does not exist${NC}"
    exit 1
fi

log_message "${GREEN}Starting Nginx log rotation and cleanup process${NC}"

# Step 1: Compress log files older than 7 days
log_message "${YELLOW}Step 1: Compressing log files older than ${COMPRESS_AGE_DAYS} days${NC}"

find "${LOG_DIR}" -type f -name "*.log" -mtime +${COMPRESS_AGE_DAYS} ! -name "*.gz" | while read -r logfile; do
    if [ -f "${logfile}" ]; then
        log_message "Compressing: ${logfile}"
        gzip -v "${logfile}" >> "${SCRIPT_LOG}" 2>&1
        if [ $? -eq 0 ]; then
            log_message "${GREEN}Successfully compressed: ${logfile}.gz${NC}"
        else
            log_message "${RED}Failed to compress: ${logfile}${NC}"
        fi
    fi
done

# Step 2: Delete compressed files older than 15 days
log_message "${YELLOW}Step 2: Deleting compressed files older than ${DELETE_AGE_DAYS} days${NC}"

find "${LOG_DIR}" -type f -name "*.gz" -mtime +${DELETE_AGE_DAYS} | while read -r compfile; do
    if [ -f "${compfile}" ]; then
        log_message "Deleting: ${compfile}"
        rm -f "${compfile}"
        if [ $? -eq 0 ]; then
            log_message "${GREEN}Successfully deleted: ${compfile}${NC}"
        else
            log_message "${RED}Failed to delete: ${compfile}${NC}"
        fi
    fi
done

log_message "${GREEN}Nginx log rotation and cleanup process completed${NC}"
log_message "================================"

exit 0
