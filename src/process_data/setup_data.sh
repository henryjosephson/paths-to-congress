#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROCESSED_DIR="${PROJECT_ROOT}/data/processed"
PROCESSED_FILE="${PROCESSED_DIR}/processed-bios.json"
DOWNLOAD_URL="https://drive.usercontent.google.com/download?id=1oBKjHDWkscpAJUrrh1NVi4CbboyD8lvq&export=download"

echo "Creating directory structure..."
mkdir -p "${PROCESSED_DIR}"

if [ -f "$PROCESSED_FILE" ]; then
    echo "File already exists at $PROCESSED_FILE"
    exit 0
fi

read -p "Would you like to download the processed file directly? (yes/no): " choice

if [[ $choice =~ ^[Yy].*$ ]]; then
    echo "Downloading processed file..."
    curl -L "$DOWNLOAD_URL" -o "$PROCESSED_FILE" || {
        echo "Download failed"
        echo "Error details:"
        echo "Target directory: ${PROCESSED_DIR}"
        echo "Target file: ${PROCESSED_FILE}"
        echo "Please ensure you have write permissions to this location"
        exit 1
    }

    if [ -f "$PROCESSED_FILE" ]; then
        echo "Download completed successfully"
        exit 0
    else
        echo "Download verification failed"
        exit 1
    fi
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DATA_DIR="${PROJECT_ROOT}/data/raw"
VENV_DIR="${PROJECT_ROOT}/.venv"
BIOGUIDE_ZIP="${DATA_DIR}/BioguideProfiles.zip"
BIOGUIDE_DIR="${DATA_DIR}/BioguideProfiles"

echo "Setting up data processing environment..."

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

source "${VENV_DIR}/bin/activate"

echo "Installing requirements..."
pip install -r "${PROJECT_ROOT}/requirements.txt"

mkdir -p "$DATA_DIR"

echo "Downloading Bioguide data..."
if [ ! -f "$BIOGUIDE_ZIP" ]; then
    curl -L "https://bioguide.congress.gov/bioguide/data/BioguideProfiles.zip" -o "$BIOGUIDE_ZIP"
fi

echo "Extracting Bioguide data..."
unzip -o "$BIOGUIDE_ZIP" -d "$DATA_DIR"

echo "Removing zip file..."
rm "$BIOGUIDE_ZIP"

echo "Running data processing scripts..."
cd "$(dirname "${BASH_SOURCE[0]}")"

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