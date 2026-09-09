#!/bin/bash

# Stop the script immediately if any step fails
set -e

# =====================================================================
# LOAD ENVIRONMENT VARIABLES
# =====================================================================
# This line reads your .env file and imports your $data_url variable
if [ -f .env ]; then
    source .env
else
    echo "❌ Error: .env file not found in the current directory!"
    exit 1
fi

# =====================================================================
# STEP 1: EXTRACT (Download the data using your variables)
# =====================================================================
echo "Starting download..."

# Your script reads the $data_url variable you set on your machine.
# It saves it into the 'raw' folder inside your. path.
curl -L -o ./raw/raw_data.csv "$data_url"

echo "Step 1 complete! File saved in the raw folder."


# =====================================================================
# STEP 2: TRANSFORM (Pick columns and save to your directory)
# =====================================================================
echo "Transforming data..."

# Write the clean column headers into your transformed directory path
echo "year,Value,Units,variable_code" > ./Transformed/2023_year_finance.csv

# SMART LOOKUP: awk finds column numbers by matching names on line 1, 
# then extracts those exact values from all lines underneath.
awk -F',' '
NR==1 {
    for(i=1; i<=NF; i++) {
        if($i=="year") c1=i;
        if($i=="Value") c2=i;
        if($i=="Units") c3=i;
        if($i=="Variable_code") c4=i;
    }
    next; # Skip printing the original header row
}
{
    # Print the values found under those matched names separated by commas
    print $c1","$c2","$c3","$c4
}' ./raw/raw_data.csv >> ./Transformed/2023_year_finance.csv

echo "Step 2 complete! Loaded safely into Transformed folder."

# =====================================================================
# STEP 3: LOAD (Copy to Gold folder using your directory variable)
# =====================================================================
echo "Loading to Gold..."

# Copy the file directly using your directory path variable
cp ./Transformed/2023_year_finance.csv ./Gold/

echo "Step 3 complete! File saved in the Gold folder."