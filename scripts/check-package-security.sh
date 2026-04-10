#!/bin/bash

# Check if a package is in the Shai Hulud 2.0 compromised list
# Usage: ./scripts/check-package-security.sh <package-name>

PACKAGE_NAME=$1
COMPROMISED_LIST_URL="https://raw.githubusercontent.com/DataDog/indicators-of-compromise/main/shai-hulud-2.0/consolidated_iocs.csv"
TEMP_FILE="/tmp/compromised_packages_check.csv"

if [ -z "$PACKAGE_NAME" ]; then
  echo "Usage: $0 <package-name>"
  exit 1
fi

echo "Checking package: $PACKAGE_NAME"
curl -s "$COMPROMISED_LIST_URL" -o "$TEMP_FILE"

if [ ! -f "$TEMP_FILE" ]; then
  echo "ERROR: Failed to download compromised packages list"
  exit 1
fi

if grep -q "^$PACKAGE_NAME," "$TEMP_FILE"; then
  echo "WARNING: Package '$PACKAGE_NAME' is COMPROMISED!"
  grep "^$PACKAGE_NAME," "$TEMP_FILE"
  echo "DO NOT INSTALL this package!"
  exit 1
else
  echo "SUCCESS: Package '$PACKAGE_NAME' is NOT in the compromised list"
  echo "Still verify: dep count < 5, known maintainer, < 2000 LOC auditable, no C bindings."
  exit 0
fi
