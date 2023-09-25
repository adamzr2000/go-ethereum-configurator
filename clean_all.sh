#!/bin/bash

# Remove all directories named "nodeX"
for dir in node*; do
  if [ -d "$dir" ]; then
    echo "Removing directory: $dir"
    rm -rf "$dir"
  fi
done

# Remove all nodeX_start.sh files
for file in node*_start.sh; do
  if [ -f "$file" ]; then
    echo "Removing file: $file"
    rm -f "$file"
  fi
done

# Remove the "bootnode" directory if it exists
if [ -d "bootnode" ]; then
  echo "Removing directory: bootnode"
  rm -rf "bootnode"
fi

# Remove the "logs" directory if it exists
if [ -d "logs" ]; then
  echo "Removing directory: logs"
  rm -rf "logs"
fi

# Remove "bootnode_start.sh" file
echo "Removing file: bootnode_start.sh"
rm -f bootnode_start.sh

# Remove "genesis.json" file
echo "Removing file: genesis.json"
rm -f genesis.json

# Remove the ".env" file
echo "Removing file: .env"
rm -f .env

echo "Cleanup complete."

