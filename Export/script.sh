#!/bin/bash

# --- HyperTag Export Cleanup and Packaging Script ---

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Define the base directory for the export operations.
BASE_DIR="/home/Logan/Documents/Godot Projects/HyperTag/Export"

# Define the final destination directory for all packaged files.
FINAL_DIR="$BASE_DIR/FinalFiles"

# Define the directories to be zipped and then emptied.
BUILD_DIRECTORIES=("LinuxBuild" "WebBuild" "WindowsBuild")
SOURCE_DIRECTORY="Source"

echo "Starting export cleanup and packaging in: $BASE_DIR"
echo "----------------------------------------------------"

# 1. Check if the base directory and final destination directory exist.
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Base directory $BASE_DIR does not exist. Aborting."
    exit 1
fi

if [ ! -d "$FINAL_DIR" ]; then
    echo "Error: Final destination directory $FINAL_DIR does not exist. Aborting."
    echo "(Please ensure this folder is created before running the script.)"
    exit 1
fi

# Change to the base directory to make relative zipping easier
cd "$BASE_DIR"

# 2. Loop through the build directories, create zip files, empty originals, and move zips
for DIR in "${BUILD_DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        ZIP_FILE="$DIR.zip"
        echo "--> Creating $ZIP_FILE from $DIR..."
        
        # -r: recurse into directories, -q: quiet mode
        # The zip file is created in BASE_DIR.
        zip -rq "$ZIP_FILE" "$DIR"
        
        # Check if the zip was created successfully
        if [ -f "$ZIP_FILE" ]; then
            echo "    Zip successful. Emptying original directory $DIR..."
            # Remove all contents (files and subfolders) inside $DIR, keeping $DIR itself.
            rm -rf "$DIR"/*

            echo "    Moving $ZIP_FILE to $FINAL_DIR..."
            mv "$ZIP_FILE" "$FINAL_DIR/"
        else
            echo "    Warning: Failed to create $ZIP_FILE. Skipping folder operations for $DIR."
        fi
    else
        echo "    Warning: Directory $DIR not found. Skipping."
    fi
done

echo ""
echo "----------------------------------------------------"

# 3. Rename and move the Source zip file
if [ -d "$SOURCE_DIRECTORY" ]; then
    echo "--> Processing contents of $SOURCE_DIRECTORY..."

    # Find the single zip file in the Source directory
    SOURCE_ZIP_PATH=$(find "$SOURCE_DIRECTORY" -maxdepth 1 -type f -name "*.zip" | head -n 1)

    if [ -n "$SOURCE_ZIP_PATH" ]; then
        TARGET_ZIP_NAME="Source.zip"
        echo "    Found and renaming '$SOURCE_ZIP_PATH' to '$TARGET_ZIP_NAME'..."
        
        # Move and rename the file in one step to the final directory
        mv "$SOURCE_ZIP_PATH" "$FINAL_DIR/$TARGET_ZIP_NAME"
        
        # NOTE: The Source directory is intentionally NOT deleted, as requested.
        echo "    Source directory contents moved. Leaving $SOURCE_DIRECTORY empty."
    else
        echo "    Warning: No single .zip file found in $SOURCE_DIRECTORY or directory is empty. Skipping move."
    fi
else
    echo "    Warning: Source directory $SOURCE_DIRECTORY not found. Skipping rename/move."
fi

echo "----------------------------------------------------"
echo "Script finished successfully! All final files are in $FINAL_DIR"