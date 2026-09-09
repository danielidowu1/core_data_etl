#!/bin/bash

# ==============================================================================
# Script Name: setup_cron.sh
# Description: Automates scheduling the etl_pipeline.sh script to run daily
#              at 12:00 AM (midnight) via Linux crontab.
# ==============================================================================

set -e

# Automatically resolve the absolute path of the directory where this script lives
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETL_SCRIPT="$PROJECT_DIR/etl_pipeline.sh"
LOG_FILE="$PROJECT_DIR/etl.log"

# Ensure the ETL pipeline script is executable
if [ -f "$ETL_SCRIPT" ]; then
    chmod +x "$ETL_SCRIPT"
else
    echo "Error: $ETL_SCRIPT not found! Make sure etl_pipeline.sh is in $PROJECT_DIR."
    exit 1
fi

# Define the cron schedule expression (00:00 / 12:00 AM every day)
# Syntax: Minute Hour DayOfMonth Month DayOfWeek Command
CRON_SCHEDULE="0 0 * * * /bin/bash \"$ETL_SCRIPT\" >> \"$LOG_FILE\" 2>&1"

echo "Configuring daily cron job for CoreDataEngineers pipeline..."

# Export current user crontab to a temporary file (suppress exit error if empty)
crontab -l 2>/dev/null > current_cron || true

# Check if the pipeline is already scheduled to avoid duplicate crontab entries
if grep -Fq "$ETL_SCRIPT" current_cron; then
    echo "Updating existing cron schedule..."
    sed -i "\|$ETL_SCRIPT|d" current_cron
fi

# Append the new job schedule
echo "$CRON_SCHEDULE" >> current_cron

# Install the updated crontab
crontab current_cron

# Clean up temporary file
rm -f current_cron

echo "SUCCESS: Cron job configured!"
echo "Schedule: Daily at 12:00 AM"
echo "Execution Log: $LOG_FILE"