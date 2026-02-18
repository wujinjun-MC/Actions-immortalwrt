#!/bin/bash
set -euo pipefail

echo "04-cleanup-and-update-for-compile-again.sh start"

touch ./.env
export SHARED_ENV=$(realpath ./.env)
. "$SHARED_ENV"

#deprecated, directly exit 1
echo "deprecated, directly exit 1"
exit 1

cd "$OPENWRT_PATH"

git fetch && git reset --hard origin/main-nss
cd "$GITHUB_WORKSPACE"
cp "$CONFIG_FILE" "$OPENWRT_PATH/.config"
#make defconfig

# { Install Feeds(安装feeds) }
cd "$OPENWRT_PATH"

    # 添加small-package https://github.com/kenzok8/small-package
echo >> feeds.conf.default
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default

    # 添加istoreos界面 https://github.com/linkease/nas-packages-luci
echo >> feeds.conf.default
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default

./scripts/feeds update -a
git clone --depth 1 "https://github.com/sbwml/openwrt_pkgs.git" package/new/custom
mv package/new/custom/luci-app-netspeedtest  package/new || true
mv package/new/custom/speedtest-cli package/new || true
rm -rf package/new/custom
./scripts/feeds install -a

# { Load Custom Configuration(加载自定义配置) }
cd "$GITHUB_WORKSPACE"
[ -e files ] && mv files "$OPENWRT_PATH/files"
[ -e "$CONFIG_FILE" ] && mv "$CONFIG_FILE" "$OPENWRT_PATH/.config"
chmod +x "$DIY_SCRIPT"
cd "$OPENWRT_PATH"
"$GITHUB_WORKSPACE/$DIY_SCRIPT"

# { Load Custom Overwrite(加载自定义覆写) }
chmod +x "$GITHUB_WORKSPACE/overwrite/overwrite-after-feeds-download.sh"
"$GITHUB_WORKSPACE/overwrite/overwrite-after-feeds-download.sh"

# { Load Custom Patch(加载自定义修补) }
chmod +x $GITHUB_WORKSPACE/patch/patch-after-feeds-download.sh
$GITHUB_WORKSPACE/patch/patch-after-feeds-download.sh

echo "04-cleanup-and-update-for-compile-again.sh success"
