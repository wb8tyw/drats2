#!/bin/bash
# setup_dev.sh -> Run via: . ./setup_dev.sh

# 1. Clear previous session state and grab lowercase short hostname
unset PYTHONPATH
unset DRATS_DEV_HOME
SHORT_HOST=$(hostname -s | tr '[:upper:]' '[:lower:]')

echo "[INFO] Initializing / Resuming environment for host: [${SHORT_HOST}]"

# 2. Establish monorepo base locations
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_LOCAL_DIR="${REPO_ROOT}/local/${SHORT_HOST}"
DEV_LIBS="${DEV_LOCAL_DIR}/libs"
DEV_HOME="${DEV_LOCAL_DIR}/home"

# 3. Auto-heal folders if a Windows update or sleep cycle cleared them
mkdir -p "${DEV_LIBS}" "${DEV_HOME}"

# 4. Delegate package deployment directly to the Linux dispatcher script
if [ -f "${REPO_ROOT}/install_linux.sh" ]; then
    echo "[SETUP] Invoking Linux installation dispatcher..."
    "${REPO_ROOT}/install_linux.sh" "dev"
else
    echo "[WARNING] install_linux.sh was not found at repository root."
fi

# 5. Automatically ensure application scripts are executable
if [ -d "${REPO_ROOT}/apps" ]; then
    echo "[SETUP] Verifying executable permissions across apps directory..."
    find "${REPO_ROOT}/apps" -type f -name "*.py" -exec chmod +x {} +
fi

# 6. Build dynamic PYTHONPATH tracking arrays for runtime execution
PATHS_TO_INJECT=()

# Inject internal monorepo shared library directories
if [ -d "${REPO_ROOT}/libs" ]; then
    for lib in "${REPO_ROOT}/libs"/*; do
        if [ -d "$lib" ]; then
            # Cleanly support BOTH flat layouts and nested src/ monorepo layouts
            if [ -d "${lib}/src" ]; then
                PATHS_TO_INJECT+=("${lib}/src")
            else
                PATHS_TO_INJECT+=("$lib")
            fi
        fi
    done
fi

# Inject host-isolated PyPI development libraries and the repo root itself
PATHS_TO_INJECT+=("${DEV_LIBS}")
PATHS_TO_INJECT+=("${REPO_ROOT}")

# 7. Live Parent Shell Variable Export Configuration
export DRATS_DEV_HOME="${DEV_HOME}"

RAW_PATHS=$(IFS=:; echo "${PATHS_TO_INJECT[*]}")
export PYTHONPATH="${RAW_PATHS}"

echo "[READY] Environment variables bound. Ready to manually run tests."
echo "   -> Active PYTHONPATH: ${PYTHONPATH}"
echo "   -> Run apps:          ./apps/drats_kivy/src/drats_kivy/hello_world_kivy.py"
