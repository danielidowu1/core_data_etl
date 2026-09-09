#!/bin/bash

# ==============================================================================
# Script Name: move_files.sh
# Description: Moves all .csv and .json files from a source directory into
#              the target directory named json_and_CSV.
# ==============================================================================

set -e

# Define target directory
TARGET_DIR="JSON_and_CSV"

# Define source directory (defaults to current directory if not passed as an argument)
SOURCE_DIR="${1:-.}"

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

echo "Scanning '$SOURCE_DIR' for CSV and JSON files..."

# Enable nullglob so the loop handles cases where no matching files exist
shopt -s nullglob
files=("$SOURCE_DIR"/*.csv "$SOURCE_DIR"/*.json)
shopt -u nullglob

# Check if any matching files were found
if [ ${#files[@]} -eq 0 ]; then
    echo "No CSV or JSON files found in '$SOURCE_DIR'."
    exit 0
fi

# Loop through each matched file and move it to json_and_CSV
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        
        # Prevent moving files that are already inside target folders
        if [ "$SOURCE_DIR" = "." ] && [ "$filename" = "2023_year_finance.csv" ]; then
            continue
        fi

        mv "$file" "$TARGET_DIR/"
        echo "Moved: $filename -> $TARGET_DIR/"
    fi
done

echo "SUCCESS: File transfer complete."