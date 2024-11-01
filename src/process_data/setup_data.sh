#!/bin/bash

# Exit on error
set -e

# Store the project root directory (assuming script is in src/process_data/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DATA_DIR="${PROJECT_ROOT}/data"
VENV_DIR="${PROJECT_ROOT}/.venv"
BIOGUIDE_ZIP="${DATA_DIR}/BioguideProfiles.zip"
BIOGUIDE_DIR="${DATA_DIR}/BioguideProfiles"

echo "Setting up data processing environment..."

# Create and activate virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Install requirements
echo "Installing requirements..."
pip install -r "${PROJECT_ROOT}/requirements.txt"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Download and process data
echo "Downloading Bioguide data..."
if [ ! -f "$BIOGUIDE_ZIP" ]; then
    curl -L "https://bioguide.congress.gov/bioguide/data/BioguideProfiles.zip" -o "$BIOGUIDE_ZIP"
fi

echo "Extracting Bioguide data..."
unzip -o "$BIOGUIDE_ZIP" -d "$DATA_DIR"

echo "Removing zip file..."
rm "$BIOGUIDE_ZIP"

echo "Running data processing scripts..."
# Change to process_data directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Run the Python script
python merge_and_clean_congress_jsons.py

# Run the Jupyter notebook
echo "Converting and running Jupyter notebook..."
jupyter nbconvert --to python read_jsons_to_df.ipynb --stdout | python

echo "Cleaning up..."
rm -rf "$BIOGUIDE_DIR"

echo "Data processing complete!"