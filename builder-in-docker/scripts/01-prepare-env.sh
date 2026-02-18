#!/bin/bash
set -euo pipefail

echo "01-prepare-env.sh start"

touch ./.env
export SHARED_ENV=$(realpath ./.env)
export FIX_VERSION_INVALID=true
echo "export FIX_VERSION_INVALID=true" >> "$SHARED_ENV"

# { Checkout, 克隆源码 }
[[ -v REPO_URL_BUILDER ]] || export REPO_URL_BUILDER="https://github.com/wujinjun-MC/openwrt-ci.git"
git clone --depth 1 -b "$REPO_BRANCH" "$REPO_URL" openwrt
export GITHUB_WORKSPACE="$(pwd)"
echo "export GITHUB_WORKSPACE=$(pwd)" >> "$SHARED_ENV"
cd openwrt
export OPENWRT_PATH="$(pwd)"
echo "export OPENWRT_PATH=$(pwd)" >> "$SHARED_ENV"

# { 安装 feeds }
cd "$OPENWRT_PATH"

    # 添加 small-package https://github.com/kenzok8/small-package
echo >> feeds.conf.default
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default

    # 添加 jell https://github.com/kenzok8/jell
echo >> feeds.conf.default
sed -i '$a src-git jell https://github.com/kenzok8/jell' feeds.conf.default

    # 添加 istoreos 界面 https://github.com/linkease/nas-packages-luci
echo >> feeds.conf.default
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

# { 导入补丁和配置 & 执行脚本 }
cd "$GITHUB_WORKSPACE"
[ -d files ] && cp -r files "$OPENWRT_PATH/files" || echo "files not found"
rm 
[ -f $PLATFORM_FILE ] && cat $PLATFORM_FILE >> "$OPENWRT_PATH/.config"
[ -f $CONFIG_FILE ] && cat $CONFIG_FILE >> "$OPENWRT_PATH/.config"
[ -f $CONFIG_5G ] && cat $CONFIG_5G >> "$OPENWRT_PATH/.config"
[ -f $CONFIG_WUJINJUN ] && cat $CONFIG_WUJINJUN >> "$OPENWRT_PATH/.config"
[ -f $CONFIG_WUJINJUN_OTHERS ] && cat $CONFIG_WUJINJUN_OTHERS >> "$OPENWRT_PATH/.config"
if [ "$USE_LARGER"x = "true"x ]; then
    [ -f $CONFIG_WUJINJUN_LARGER ] && cat $CONFIG_WUJINJUN_LARGER >> "$OPENWRT_PATH/.config"
fi
chmod +x $RUST_SH && $RUST_SH
cd "$$OPENWRT_PATH"
chmod +x $GITHUB_WORKSPACE/$SETTINGS_SH && $GITHUB_WORKSPACE/$SETTINGS_SH
chmod +x $GITHUB_WORKSPACE/$PACKAGES_SH && $GITHUB_WORKSPACE/$PACKAGES_SH
chmod +x $GITHUB_WORKSPACE/$INSTALL5G_SH && $GITHUB_WORKSPACE/$INSTALL5G_SH
chmod +x $GITHUB_WORKSPACE/$CLASH_CORE_SH && $GITHUB_WORKSPACE/$CLASH_CORE_SH
chmod +x $GITHUB_WORKSPACE/$CUSTOM_SH && $GITHUB_WORKSPACE/$CUSTOM_SH

chmod +x $GITHUB_WORKSPACE/overwrite/overwrite-after-feeds-download.sh
$GITHUB_WORKSPACE/overwrite/overwrite-after-feeds-download.sh
chmod +x $GITHUB_WORKSPACE/patch/patch-after-feeds-download.sh
$GITHUB_WORKSPACE/patch/patch-after-feeds-download.sh

echo "01-prepare-env.sh success"
