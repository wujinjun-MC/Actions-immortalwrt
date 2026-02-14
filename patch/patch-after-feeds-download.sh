#!/bin/bash
# 1. patch-01-fix-version-invalid 修复插件版本号不合法
if [ "$FIX_VERSION_INVALID"x = "true"x ]; then
    echo '$FIX_VERSION_INVALID'"=true, applying patch-01-fix-version-invalid ( 修复插件版本号不合法 )"
    echo ">> Execute $GITHUB_WORKSPACE/patch/01-fix-version-invalid.py"
    python3 "$GITHUB_WORKSPACE/patch/01-fix-version-invalid.py" --apply --dirs  "$OPENWRT_PATH/feeds/smpackage/" "$OPENWRT_PATH/feeds/nas_luci/"
fi

# 2. patch-02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab 修复 oaf 内核模块 缩进混用空格和TAB
echo "Applying patch-02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab ( 修复 oaf 内核模块 缩进混用空格和TAB )"
echo ">> Execute $GITHUB_WORKSPACE/patch/02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab.sh"
bash "$GITHUB_WORKSPACE/patch/02-fix-KMOD_oaf-app_filter-dot-c-indent-mixed-space-and-tab.sh"
