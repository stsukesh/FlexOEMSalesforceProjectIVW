#!/usr/bin/env bash

set -e

ORG_ALIAS="salesforceMain"
BRANCH="main"

echo "Checking out $BRANCH and pulling latest changes..."
git checkout $BRANCH
git pull origin $BRANCH

echo "Retrieving metadata from Salesforce org ($ORG_ALIAS) using package.xml..."
sf project retrieve start \
  --manifest manifest/package.xml \
  --target-org $ORG_ALIAS \
  --wait 10

echo "Retrieve complete."
echo "Review changes with:"
echo "  git status"
echo "  git diff"

