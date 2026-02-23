#!/bin/bash
set -euo pipefail
mv "$OPENWRT_PATH/staging_dir/hostpkg/bin"/python3{,-bak}
