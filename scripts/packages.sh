#!/bin/bash
set -euo pipefail

#删除feeds中的插件
rm -rf feeds/packages/lang/golang

#克隆依赖插件
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang


#克隆的源码放在small文件夹
mkdir package/small
pushd package/small

# luci-theme-aurora
[ -e luci-theme-aurora ] || git clone -b master --depth 1 https://github.com/eamonxg/luci-theme-aurora.git

# luci-app-nft-timecontrol
[ -e luci-theme-timecontrol ] || git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-timecontrol.git

popd

echo "packages executed successfully!"
