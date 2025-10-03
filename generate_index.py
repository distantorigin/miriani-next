#!/usr/bin/env python3
"""
Generate index-v5.manifest automatically without MUSHclient
Recreates the functionality of the MUSHclient 'index' command
Matches the exact directories and file types from worlds/plugins/updater.xml
"""

import os
import json
import hashlib
from pathlib import Path

def get_file_md5(filepath):
    """Calculate MD5 hash of a file, normalizing line endings like the Lua version"""
    hash_md5 = hashlib.md5()
    with open(filepath, "rb") as f:
        content = f.read()
        # Normalize line endings (replace \r with \n like Lua version)
        content = content.replace(b'\r', b'\n')
        hash_md5.update(content)
    return hash_md5.hexdigest().upper()

def generate_manifest():
    """Generate the index-v5.manifest file using the same directories as updater.xml"""
    base_url = "https://raw.githubusercontent.com/distantorigin/Toastush/main"
    manifest = {}

    # Define the directories and extensions exactly as in updater.xml
    # These correspond to the update_dir table in lines 130-142
    update_directories = {
        ".": ".manifest",  # index-v5.manifest in root
        "worlds/plugins/": ".xml",  # toastush, channel_history, output_functions, updater
        "sounds/miriani/": ".ogg",
        "lua/miriani/scripts/": ".lua",
        "lua/miriani/": ".txt"
    }

    def process_directory(directory, extension):
        """Process files in a directory with the given extension"""
        if not os.path.exists(directory):
            return

        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith(extension):
                    filepath = os.path.join(root, file)
                    # Convert to forward slashes and normalize to lowercase like MUSHclient
                    relative_path = filepath.replace('\\', '/').lower()

                    try:
                        file_hash = get_file_md5(filepath)
                        file_url = f"{base_url}/{relative_path}"

                        manifest[relative_path] = {
                            "url": file_url,
                            "hash": file_hash,
                            "name": file
                        }

                        print(f"Added: {relative_path}")

                    except Exception as e:
                        print(f"Error processing {filepath}: {e}")

    # Process each directory type
    for directory, extension in update_directories.items():
        print(f"Processing {directory} for {extension} files...")
        process_directory(directory, extension)

    # Write the manifest file
    with open('index-v5.manifest', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, separators=(',', ':'), ensure_ascii=False)

    print(f"\nGenerated index-v5.manifest with {len(manifest)} entries")

if __name__ == '__main__':
    print("Generating index-v5.manifest...")
    generate_manifest()
    print("Done!")