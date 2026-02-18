#!/bin/bash
set -euo pipefail

rm -rf package/luci/applications/luci-app-lucky

# Lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky

# AdGuard Home
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# Tailscale (community)
git clone --depth=1 https://github.com/tokisaki-galaxy/luci-app-tailscale-community package/luci-app-tailscale-community
