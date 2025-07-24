#!/usr/bin/env bash

# BAX IDE Custom Build Script
# This script sets BAX-specific overrides and sources the original build script

# BAX-specific overrides
export APP_NAME="BAX"
export BINARY_NAME="bax"
export ORG_NAME="BAX"
export ASSETS_REPOSITORY="Erg69/BAX-IDE"
export GH_REPO_PATH="Erg69/BAX-IDE"

# Source the original build script with all arguments
source ./dev/build.sh "$@" 