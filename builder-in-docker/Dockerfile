# 使用 Ubuntu latest 作为基础镜像
FROM ubuntu:latest

# 环境变量设置
ARG DEBIAN_FRONTEND=noninteractive

# 设置镜像
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
RUN sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true

RUN apt-get update
RUN apt -yqq install adduser 
RUN adduser ubuntu || echo "Skip adduser"

# 安装基础编译依赖
RUN apt-get full-upgrade -y && apt-get install -yqq sudo curl
RUN bash -c 'bash <(curl -sL https://build-scripts.immortalwrt.org/init_build_environment.sh)'
RUN sudo -E apt -yqq install ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
RUN sudo -E apt -yqq install dos2unix libfuse-dev ccache mkisofs ncdu btop colorized-logs expect safe-rm 
RUN apt -yqq autoremove --purge && apt -yqq autoclean && apt -yqq clean
RUN rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Shanghai
ENV REPO_URL_BUILDER=https://github.com/wujinjun-MC/Actions-immortalwrt
ENV REPO_URL=https://github.com/immortalwrt/immortalwrt
ENV REPO_BRANCH=openwrt-25.12
ENV PLATFORM_FILE=configs/Target-X86.txt
ENV CONFIG_FILE=configs/Packages.txt
ENV CONFIG_5G=configs/Packages-5G.txt
ENV CONFIG_WUJINJUN=configs/Packages-wujinjun.txt
ENV CONFIG_WUJINJUN_LARGER=configs/Packages-wujinjun-larger.txt
ENV CONFIG_WUJINJUN_OTHERS=configs/Others-wujinjun.txt
ENV SETTINGS_SH=scripts/init-settings.sh
ENV PACKAGES_SH=scripts/packages.sh
ENV INSTALL5G_SH=scripts/install-5G.sh
ENV CLASH_CORE_SH=scripts/preset-clash-core-amd64.sh
ENV RUST_SH=scripts/rust.sh
ENV CUSTOM_SH=scripts/custom-wujinjun-1.sh
ENV CLASH_KERNEL=amd64

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN adduser ubuntu sudo
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 创建非 root 用户 (OpenWrt 严禁使用 root 编译)
USER ubuntu
WORKDIR /home/ubuntu

STOPSIGNAL SIGKILL

# 进入shell，开始自定义
CMD ["/bin/bash"]
