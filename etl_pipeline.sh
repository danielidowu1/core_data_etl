#!/bin/bash

# Stop immediately if any command fails
set -e

# Automatically resolve the root directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# =====================================================================
# 1. LOAD ENVIRONMENT VARIABLES
# =====================================================================
if [ -f .env ]; then
    source .env
else
    echo "❌ Error: .env file not found in $SCRIPT_DIR!"
    exit 1
fi

if [ -z "$data_url" ]; then
    echo "❌ Error: \$data_url is not defined inside .env!"
    exit 1
fi

# =====================================================================
# 2. ENSURE DIRECTORIES EXIST
# =====================================================================
mkdir -p raw Transformed Gold json_and_CSV

# =====================================================================
# 3. EXTRACT
# =====================================================================
echo "Starting download..."
curl -sSL -o ./raw/raw_data.csv "$data_url"

if [ -s ./raw/raw_data.csv ]; then
    echo "Step 1 complete! File saved in the raw folder."
else
    echo "❌ Error: Download failed or file is empty."
    exit 1
fi

# =====================================================================
# 4. TRANSFORM
# =====================================================================
echo "Transforming data..."

awk -F',' '
BEGIN { FS=","; OFS="," }
NR==1 {
    for (i=1; i<=NF; i++) {
        gsub(/\r/, "", $i);
        if (tolower($i) == "year") c1=i;
        if ($i == "Value") c2=i;
        if ($i == "Units") c3=i;
        if ($i == "Variable_code") c4=i;
    }
    print "year", "Value", "Units", "variable_code";
    next;
}
{
    gsub(/\r/, "", $0);
    print $c1, $c2, $c3, $c4;
}
' ./raw/raw_data.csv > ./Transformed/2023_year_finance.csv

echo "Step 2 complete! File saved in Transformed folder."

# =====================================================================
# 5. LOAD
# =====================================================================
echo "Loading to Gold..."
cp ./Transformed/2023_year_finance.csv ./Gold/

echo "Step 3 complete! File loaded to Gold folder."