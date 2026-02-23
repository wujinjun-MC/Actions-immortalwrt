#!/bin/bash
set -euo pipefail

cd "$OPENWRT_PATH"

# 1. patch-01-fix-version-invalid 修复插件版本号不合法
if [[ -v "FIX_VERSION_INVALID" ]]; then
    echo '$FIX_VERSION_INVALID'"=true, applying patch-01-fix-version-invalid ( 修复插件版本号不合法 )"
    echo ">> Execute $GITHUB_WORKSPACE/patch/01-fix-version-invalid.py"
    python3 "$GITHUB_WORKSPACE/patch/01-fix-version-invalid.py" --apply --dirs "$OPENWRT_PATH/feeds/smpackage/" "$OPENWRT_PATH/feeds/jell/" "$OPENWRT_PATH/feeds/nas_luci/"
fi

# 2. patch-02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab 修复 oaf 内核模块 缩进混用空格和TAB
echo "Applying patch-02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab ( 修复 oaf 内核模块 缩进混用空格和TAB )"
echo ">> Execute $GITHUB_WORKSPACE/patch/02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab.sh"
bash "$GITHUB_WORKSPACE/patch/02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab.sh" || echo "修复失败，可能错误已被修复"

# 3. patch-03-fix-BIOS-Boot-Partition-is-under-1MiB 修复 BIOS Boot 分区缺少空间
echo "Applying patch-03-fix-BIOS-Boot-Partition-is-under-1MiB ( 修复 BIOS Boot 分区缺少空间 )"
echo ">> patch target/linux/x86/image/Makefile $GITHUB_WORKSPACE/patch/03-fix-BIOS-Boot-Partition-is-under-1MiB.patch"
patch target/linux/x86/image/Makefile "$GITHUB_WORKSPACE/patch/03-fix-BIOS-Boot-Partition-is-under-1MiB.patch"

# 4. patch-04-fix-qBittorrent-Enhanced-Edition-include-fortify-unistd_dot_h-include_next 修复 qBittorrent-Enhanced-Edition 调用 fortify 的 unistd.d 时因为 “#include_next" 而失败
echo "Applying patch-04-fix-qBittorrent-Enhanced-Edition-include-fortify-unistd_dot_h-include_next ( 修复 qBittorrent-Enhanced-Edition 调用 fortify 的 unistd.d 时因为 \"#include_next\" 而失败 )"
echo ">> patch feeds/packages/net/qBittorrent-Enhanced-Edition/Makefile $GITHUB_WORKSPACE/patch/04-fix-qBittorrent-Enhanced-Edition-include-fortify-unistd_dot_h-include_next.patch"
patch feeds/packages/net/qBittorrent-Enhanced-Edition/Makefile "$GITHUB_WORKSPACE/patch/04-fix-qBittorrent-Enhanced-Edition-include-fortify-unistd_dot_h-include_next.patch" || echo "patch 失败，可能错误已被修复"

# 5. patch-05-fix-shadowsocks-libev-failed-due-to-python3-no-module-asciidoc 修复 shadowsocks-libev 因为自带工具链中 python3 没有 asciidoc 模块而失败 ( 可选 )
#echo "Applying patch-05-fix-shadowsocks-libev-failed-due-to-python3-no-module-asciidoc ( 修复 shadowsocks-libev 因为自带工具链中 python3 没有 asciidoc 模块而失败 ) ( 可选 )"
#echo ">> Execute $GITHUB_WORKSPACE/patch/05-fix-shadowsocks-libev-failed-due-to-python3-no-module-asciidoc.sh"
#bash "$GITHUB_WORKSPACE/patch/05-fix-shadowsocks-libev-failed-due-to-python3-no-module-asciidoc.sh" || echo "执行失败，可能错误已被修复 / 已经执行过了"
