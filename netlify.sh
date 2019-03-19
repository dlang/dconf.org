#!/usr/bin/env bash
# A small script to build dconf.org and allows previewing PRs with netlify

set -euox pipefail

DMD_VERSION="2.085.0"
BUILD_DIR="build"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"

. "$(curl -fsSL --retry 5 --retry-max-time 120 --connect-timeout 5 --speed-time 30 --speed-limit 1024 https://dlang.org/install.sh | bash -s install "dmd-${DMD_VERSION}" --activate)"

make
