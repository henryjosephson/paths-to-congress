#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROCESSED_FILE="${PROJECT_ROOT}/data/processed/processed-bios.json"
DOWNLOAD_URL="https://drive.usercontent.google.com/download?id=10LFUPXZ5GzMlsl_qjHeA5ByxGwJ2aIHE&export=download"

if [ -f "$PROCESSED_FILE" ]; then
    echo "File already exists at $PROCESSED_FILE"
    exit 0
fi

read -p "Would you like to download the processed file directly? (yes/no): " choice

if [[ $choice =~ ^[Yy].*$ ]]; then
    mkdir -p ../data/processed
    curl -L "$DOWNLOAD_URL" -o "$PROCESSED_FILE" || {
        echo "Download failed"
        exit 1
    }
    echo "Download completed successfully"
    exit 0
fi

DATA_DIR="${PROJECT_ROOT}/data/raw"
VENV_DIR="${PROJECT_ROOT}/.venv"
BIOGUIDE_ZIP="${DATA_DIR}/BioguideProfiles.zip"
BIOGUIDE_DIR="${DATA_DIR}/BioguideProfiles"

# Exit on error
set -e

# Store the project root directory (assuming script is in src/process_data/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DATA_DIR="${PROJECT_ROOT}/data/raw"
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

# Run the Python scripts
python 0_merge_and_clean_congress_jsons.py
python 1_add_helper_cols.py

echo ""
echo "Running Claude categorization... this took me around 4 minutes, but"
echo "it could theoretically take up to 24 hours, since it uses batch processing."
echo ""

# checks if .env file exists in project root and if ANTHROPIC_API_KEY exists in it.
# if the key is not found, prompt the user to enter it.

if [ ! -f "${PROJECT_ROOT}/.env" ]; then
    echo "Creating .env file..."
    touch "${PROJECT_ROOT}/.env"
    echo "Please enter your Anthropic API key:"
    read ANTHROPIC_API_KEY
    echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" >> "${PROJECT_ROOT}/.env"

# if .env file exists, check if ANTHROPIC_API_KEY exists in it.
# if it does not exist, prompt the user to enter it.
elif [ -z "$(grep ANTHROPIC_API_KEY ${PROJECT_ROOT}/.env)" ]; then
    echo "Please enter your Anthropic API key:"
    read ANTHROPIC_API_KEY
    echo "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}" >> "${PROJECT_ROOT}/.env"

python 2_claude_categorizes_congresspeople.py

echo "Cleaning up..."
rm -rf "$BIOGUIDE_DIR"
rm -rf "${PROJECT_ROOT}/__pycache__"
rm -f "${PROJECT_ROOT}/data/processed/temp-bios-for-claude.json"

echo "Data processing complete!"