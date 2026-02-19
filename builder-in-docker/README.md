## 在Docker中编译

1. 如果使用Btrfs，请关闭当前文件夹的写时复制 (CoW) 避免占用快照空间 `sudo chattr -R +C .`
2. 进入此目录: `cd builder-in-docker/`
3. 创建镜像: `docker build -t immortalwrt-builder .`
4. 创建和进入容器: `docker run -it --name openwrt-build --network host -v ../:/home/ubuntu immortalwrt-builder:latest`
    - 如需退出时自动删除容器 (记得复制编译产物): `docker run -it --rm --name openwrt-build --network host -v ../:/home/ubuntu immortalwrt-builder:latest bash -l`
5. 在容器内:
    1. 准备环境: `bash builder-in-docker/scripts/01-prepare-env.sh`
    2. 更改配置: `bash builder-in-docker/scripts/02-menuconfig.sh`
    3. 编译: `cd ~/openwrt/ ; make clean ; cd ; time bash builder-in-docker/scripts/03-compile.sh`
    4. 清除准备下次编译 (deprecated: 建议重新 `git clone`): `bash builder-in-docker/scripts/04-cleanup-and-update-for-compile-again.sh`
6. 快速停止容器: `docker stop -t 0 openwrt-build`

快速脚本示例 (适合copy-paste):

```bash
# In your machine
chattr -R +C .
cd builder-in-docker/
docker build -t immortalwrt-builder .
docker run -it --name openwrt-build --network host -v ../:/home/ubuntu immortalwrt-builder:latest bash -l
# In container
bash builder-in-docker/scripts/01-prepare-env.sh
bash builder-in-docker/scripts/02-menuconfig.sh
cd ~/openwrt/ ; make clean ; cd ; time bash builder-in-docker/scripts/03-compile.sh
bash builder-in-docker/scripts/04-cleanup-and-update-for-compile-again.sh
```

代理加速下载:
```bash
# 需要创建容器时 "--network host"
# 在容器内执行命令前
export http_proxy=http://127.0.0.1:7897
export https_proxy=$http_proxy
```

避免跳过`make download`: 删除 `openwrt/flags-downloaded-packages`

强制单线程编译: 容器内 `export force_single_thread=1`

自动修复插件版本号不合法: `export FIX_VERSION_INVALID=true` (在 [01-prepare-env](./scripts/01-prepare-env.sh) 默认开启 如需关闭注释掉两行)

注意:

1. 避免在路径中出现空格、中文等特殊字符，否则部分PATH会出错
    - WSL用户: 修改配置 `sudo nano /etc/wsl.conf` 然后重启WSL
        ```toml
        [interop]
        appendWindowsPath = false
        ```
