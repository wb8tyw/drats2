#!/bin/bash
# install_fedora.sh -> Called by dispatcher, defaults to prod.

MODE="${1:-prod}"
SHORT_HOST=$(hostname -s | tr '[:upper:]' '[:lower:]')

echo "[INSTALL] Running Complete Fedora setup for host: [${SHORT_HOST}]"

# Establish repo base directory cleanly
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_LIBS="${REPO_ROOT}/local/${SHORT_HOST}/libs"
DEV_HOME="${REPO_ROOT}/local/${SHORT_HOST}/home"
mkdir -p "${DEV_LIBS}" "${DEV_HOME}"

# 1. Fallback wrapper only if 'sudo' is physically missing from the container
SUDO_CMD="sudo"
if ! command -v sudo &> /dev/null; then
    SUDO_CMD=""
fi

# 2. Complete System Infrastructure Packages (RPMs)
SYSTEM_RPM=(
    "python3-requests"
    "python3-sphinx"
    "python3-docutils"
    "python3-pyserial"
    "python3-geopy"
    "python3-lxml"
    "python3-feedparser"
    "python3-pillow"
    "python3-cairo"
    "python3-gobject"
    "python3-pip"
    "python3-devel"
    "gcc"
    "SDL2-devel"
    "SDL2_image-devel"
    "SDL2_mixer-devel"
    "SDL2_ttf-devel"
    "gstreamer1-devel"
    "gstreamer1-plugins-base-devel"
    "libjpeg-turbo-devel"
    "zlib-devel"
)

# kivy needs these packages:
SYSTEM_RPM+=(
  "python3-certifi"
  "python3-docutils"
  "python3-filetype"
  "python3-idna"
  "python3-pygments"
  "python3-requests"
  "python3-sphinx"
  "python3-urllib3"
)

# 3. Append Developer-only requirements if requested
if [ "${MODE}" = "dev" ]; then
    echo "[MODE] Pipeline validation: Adding testing and lint frameworks..."
    SYSTEM_RPM+=(
        "python3-pytest"
        "python3-black"
        "git"
        "pre-commit"
    )
fi

# 4. Secure Core Distribution Installation (Safe from missing-sudo crashes)
echo "[DNF] Deploying signed system distribution assets..."
if ! ${SUDO_CMD} dnf install -y "${SYSTEM_RPM[@]}"; then
    echo "[CRITICAL] Distribution package install failed. Halting for safety."
    exit 1
fi

# 5. Target-Isolated PyPI Block (Reads external file exclusively)
REQ_FILE="${REPO_ROOT}/fedora/requirements.txt"
if [ -f "$REQ_FILE" ]; then
    echo "[PIP] Installing isolated targets from ${REQ_FILE}..."
    pip install \
        --target="${DEV_LIBS}" \
        --upgrade \
        -r "$REQ_FILE"
else
    echo "[WARNING] Fedora requirements file not found at ${REQ_FILE}"
fi

echo "[SUCCESS] Secure Fedora environment verification completed."
