<img width="768" src="https://github.com/openwrt/openwrt/blob/main/include/logo.png"/>

## 优化后的OpenWRT编译 for x86(-64) - from my `openwrt-ci`

1. ~~修改默认管理地址~~
2. actions过程 (部分灵感来源于[旧项目](https://github.com/wujinjun-MC/openwrt-ci))
   1. 支持远程调试和修改配置 `make menuconfig` (当前支持 Cpolar ，可设置两个 token 负载均衡，建议使用[此 Tampermonkey 脚本](https://greasyfork.org/scripts/564723)以加快操作)
   2. 将更多硬盘空间用于编译
   3. 直接进入单线程模式，并上传编译日志到 artifact ，便于排查错误
   4. 编译开始前上传配置 `.config` 到 artifact
   5. (远程)自动进入工作目录、一键 menuconfig
   6. release 防覆盖
   7. 兼容 opkg 模式
3. 添加软件包/源
   1. [nas-packages-luci](https://github.com/linkease/nas-packages-luci): iStoreOS风格主页、快速配置、应用商店、...
   2. AdGuard Home
   3. Tailscale (community)
   4. [small-package](https://github.com/kenzok8/small-package): 更多软件包
4. 自定义overwrite
   1. [01-nginx-disable-https](./overwrite/01-nginx-disable-https) nginx默认使用http
   2. 
5. 自定义patch
   1. [01-fix-version-invalid](./patch/01-fix-version-invalid.py*) 修复旧软件包 `ERROR: info field 'version' has invalid value: package version is invalid` 问题
   2. 
6. release信息:
   1. 显示编译时所使用的commit (包括源码和本仓库的)
   2. 自定义发布信息 (Release notes): 需要远程连接后，在源码目录创建 `custom_release_notes.txt`
7. 解决了部分常见问题
   1. `ip-full` 和 `ip-tiny` 冲突 - 禁用 `ip-tiny`
   2. 修复UPnP - 默认打开libupnp
   3. 关闭 `luci-app-oaf` 避免编译 KMOD_oaf (有bug无法编译) (依赖 by appfilter)
   4. 自动编译缺失的 `ccache` 工具链 (即使已经安装 `ccache` 也不行，必须使用官方源码编译到指定目录)
8. (Todo) 根据actions过程创建Dockerfile和所需的一键脚本，方便本地编译

### 已测试通过 更多查看 `openwrt-ci`

注: 部分固件无法直接刷入，会导致重启循环。需要先刷入底包(上游)，然后使用系统更新 `sysupgrade` 刷入

- x86: 

### 无法使用 更多查看 `openwrt-ci`

- x86: 
    1. `ERROR: info field 'version' has invalid value: package version is invalid` (可能因为OpenWRT官方从OPKG换成apk,部分软件包未适配，请耐心等待) (如果急需这些软件包，需要在新增actions run时开启 `fix_version_invalid` / 本地Docker编译时设置 `FIX_VERSION_INVALID=true` 。将会使用overwrite遍历修复版本号(可能会导致其他正常软件包的版本号被修改))
    2. 内核不兼容
    3. 源码有bug
    4. 冲突
      1. `luci-app-eqos` and `eqos-3` (无中生包? config 里面根本没有):
        ```
        ERROR: luci-app-eqos-26.042.32073~dd800de: trying to overwrite etc/config/eqos owned by eqos-3.
        ERROR: luci-app-eqos-26.042.32073~dd800de: trying to overwrite etc/hotplug.d/iface/10-eqos owned by eqos-3.
        ERROR: luci-app-eqos-26.042.32073~dd800de: trying to overwrite etc/init.d/eqos owned by eqos-3.
        ERROR: luci-app-eqos-26.042.32073~dd800de: trying to overwrite usr/sbin/eqos owned by eqos-3.
        ```
    5. 看起来编译成功，实际刷入后用不了 (参见 [已测试通过](#已测试通过) 的测试状态)
    6. 迷惑行为
    7. 缺失依赖
    8. 工具链兼容性 (一般发生在停更的软件包)
    9. 可能需要更改编译时生成的配置/脚本 (但make过程中不可能实现)
    10. 导致编译时间过长 / Github Actions 超时
        1. 需要Node.js
    11. 体积太大，可能无法刷入
        1. Docker。除了本身，需要docker的软件包如下 (部分)
    12. 文件错误
        1. trojan-plus
            ```
             make[3] -C feeds/smpackage/trojan-plus compile
            CMake Deprecation Warning at CMakeLists.txt:23 (cmake_minimum_required):
              Compatibility with CMake < 3.10 will be removed from a future version of
              CMake.
            
              Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
              to tell CMake that the project requires at least <min> but has been updated
              to work with policies introduced by <max> or earlier.
            
            
            Cloning into '/workdir/openwrt/build_dir/target-x86_64_musl/trojan-plus-10.0.3/external/GSL'...
            Note: switching to '0f6dbc9'.
            
            You are in 'detached HEAD' state. You can look around, make experimental
            changes and commit them, and you can discard any commits you make in this
            state without impacting any branches by switching back to a branch.
            
            If you want to create a new branch to retain commits you create, you may
            do so (now or later) by using -c with the switch command. Example:
            
              git switch -c <new-branch-name>
            
            Or undo this operation with:
            
              git switch -
            
            Turn off this advice by setting config variable advice.detachedHead to false
            
            HEAD is now at 0f6dbc9 Merge pull request #892 from JordanMaples/dev/jomaples/gsl3.1.0
            CMake Warning (dev) at CMakeLists.txt:199 (find_package):
              Policy CMP0167 is not set: The FindBoost module is removed.  Run "cmake
              --help-policy CMP0167" for policy details.  Use the cmake_policy command to
              set the policy and suppress this warning.
            
            This warning is for project developers.  Use -Wno-dev to suppress it.
            
            CMake Warning at /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:1443 (message):
              New Boost version may have incorrect or missing dependencies and imported
              targets
            Call Stack (most recent call first):
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:1568 (_Boost_COMPONENT_DEPENDENCIES)
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:2180 (_Boost_MISSING_DEPENDENCIES)
              CMakeLists.txt:199 (find_package)
            
            
            CMake Warning at /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:1443 (message):
              New Boost version may have incorrect or missing dependencies and imported
              targets
            Call Stack (most recent call first):
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:1568 (_Boost_COMPONENT_DEPENDENCIES)
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:2180 (_Boost_MISSING_DEPENDENCIES)
              CMakeLists.txt:199 (find_package)
            
            
            CMake Error at /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindPackageHandleStandardArgs.cmake:290 (message):
              Could NOT find Boost (missing: system) (found suitable version "1.89.0",
              minimum required is "1.66.0")
            Call Stack (most recent call first):
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindPackageHandleStandardArgs.cmake:654 (_FPHSA_FAILURE_MESSAGE)
              /workdir/openwrt/staging_dir/host/share/cmake-4.2/Modules/FindBoost.cmake:2438 (find_package_handle_standard_args)
              CMakeLists.txt:199 (find_package)
            
            
            make[3]: *** [Makefile:66: /workdir/openwrt/build_dir/target-x86_64_musl/trojan-plus-10.0.3/.configured_68b329da9893e34099c7d8ad5cb9c940] Error 1
                ERROR: package/feeds/smpackage/trojan-plus failed to build.
            ```
    13. 未知


### 建议

1. `make menuconfig`
   1. 勾选软件包时，先选择 `luci` ，再选择其他
   2. 已经添加软件源，部分软件包应该在某处，但是页面上找不到?
      1. 按下 `/` 搜索软件包
      2. 留意 `Depends on: ` 部分，确保条件已满足
      3. 查看 `Location:` ，获取软件包的具体路径
   3. 记录自己开启/关闭的功能，因为关闭功能时不会自动取消依赖项
      1. 先打开一次 `make menuconfig` ，不更改任何选项，保存并退出
      2. 备份好原始全量 `.config`
      3. 开始勾选软件包，可以 `Save` 然后对比文件变化。记得记录打开/关闭了什么
      4. 之后需要关闭软件包时，建议恢复原始 `.config` ，然后重新打开其他软件包

### Q&A

1. 更新系统 (sysupgrade) 后， SSH 可连接，但是 luci (管理页面) 打不开?
   - 输入 `service` 命令查看服务状态，可能是 HTTP 服务器没有运行，可以手动启用和启动
   - 多见于 `make menuconfig` 时切换是否选择 nginx 。如果启用过 nginx 但后来编译不含 nginx ， uhttpd 并不会自动恢复启用，请自行设置启用和启动。
2. 添加了不兼容的主题，导致 luci 报错进不去?
   - 用 nano 或 vi 修改 `/etc/config/luci` ，修改一行为 `option mediaurlbase '/luci-static/argon'` 再刷新页面

## 原README ↓

```markdown
## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/main/LICENSE) © [**P3TERX**](https://p3terx.com)   
[**作者源仓库 Actions-OpenWrt**](https://github.com/P3TERX/Actions-OpenWrt)

# 仅供学习、查阅资料使用。
**目前采用overlay分区编译，非必要 不要编译太多插件，我都想使用 精简版配置文件**<br>
.github/workflows_  工作流文件（自动化编译最主要的文件），如果无法编译可以看描述文件内容自己更改<br>
configs_____________ 配置文件夹（主要修改这个），Target-* 修改平台型号。Packages-* 是插件编译。<br>
files/etc____________ 固件内置配置文件夹，用于覆盖使用（一般不会改，我只是用来预先放smartdns配置文件）<br>
patches_____________我自己放的补丁文件夹，现在基本用不上了（天灵大佬已经把问题解决）<br>
scripts______________ 脚本文件夹，添加 插件克隆 和 实现想要的操作<br>

目前openwrt-25.12分支还存在编译时间过长的问题，部分平台先不切换
## ip地址：192.168.8.1<br>
**运行编译时间：周一 Allwinner、周二 mt7621、周三 Rockchip、周四 mtk_filogic、周五 X86-64**<br>
smartdns（海外端口6553）<br>Openclash已下载好clash?内核<br>

![packages-l](doc/Packages-L.png)<br>
![argon2](doc/argon3.png)<br>

## 如何使用呢？<br>

**X86** 平台：应该不用教了吧，写在U盘也行，硬盘也行。<br>

**Allwinner、Rockchip** 平台：能插内存卡的可以写内存卡，emmc的就自己找官方工具写入<br>

**mt7621** 应该也不难，先刷好不死然后刷 -factory.bin 后面再刷 -squashfs-sysupgrade.bin 就可以<br>

**MTK-filogic** 平台最麻烦<br>
先科普一下（*建议参考其他教程刷！需要按顺序刷入！*）<br>
**-gpt.bin** 有些存储空间比较大的机型会有这个文件，不多（*有的话第一次也要刷* ）<br>
**-preloader.bin** 是 **bl2** （op官方需要..所以第一次刷必须！）<br>
**-bl31-uboot.fip** 是 **uboot** （不刷你也刷不了这个固件！）*后续想刷回lede的固件可以用ttl先把这个刷了，Uboot就改它需要的文件名..就是 -fip.bin 文件改 -bl31-uboot.fip文件..*<br>
**-recovery.itb** 这是uboot自动识别刷入的 第一个初始固件（这里推荐使用天灵大佬的初始固件，下面网址），刷了以后开机进去的时候会提示让你刷 -squashfs-sysupgrade.itb 结尾的固件（这个就可以刷本仓库编译出来带 squashfs 的固件）<br>

[ImortalWrt Firmware Selector](https://firmware-selector.immortalwrt.org/)
这是天灵大佬的自动生成固件网站<br>

例如我的设备CMCC RAX3000M nand版本
![IFS](doc/IFS.png)
如果你本来是有192.168.1.1后台的uboot了（能刷lede固件的）如何切换到这个固件呢？<br>
192.168.1.1/bl2.html<br>
192.168.1.1/uboot.html<br>
根据上面提示自己领悟..完毕。<br>
<br>
**English** | [中文](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

# Actions-OpenWrt

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)

A template for building OpenWrt with GitHub Actions


## Credits

- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cowtransfer](https://cowtransfer.com)
- [WeTransfer](https://wetransfer.com/)
- [Mikubill/transfer](https://github.com/Mikubill/transfer)
- [actions/upload-artifact](https://github.com/actions/upload-artifact)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [Mattraks/delete-workflow-runs](https://github.com/Mattraks/delete-workflow-runs)
- [dev-drprasad/delete-older-releases](https://github.com/dev-drprasad/delete-older-releases)
- [peter-evans/repository-dispatch](https://github.com/peter-evans/repository-dispatch)

#### Related Repositories（部分代码灵感来源，感谢~）

- [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI)
- [smallprogram/OpenWrtAction](https://github.com/smallprogram/OpenWrtAction)
- [zzcabc/OpenWrt_Action](https://github.com/zzcabc/OpenWrt_Action)
- [WYC-2020/Actions-OpenWrt](https://github.com/WYC-2020/Actions-OpenWrt)
- [mingxiaoyu/R1-Plus-LTS](https://github.com/mingxiaoyu/R1-Plus-LTS)
- [SuLingGG/OpenWrt-Rpi](https://github.com/SuLingGG/OpenWrt-Rpi)

```

## Others

...
