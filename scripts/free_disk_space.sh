#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# The Azure provided machines typically have the following disk allocation:
# Total space: 85GB
# Allocated: 67 GB
# Free: 17 GB
# This script frees up 28 GB of disk space by deleting unneeded packages and 
# large directories.
# The Flink end to end tests download and generate more than 17 GB of files,
# causing unpredictable behavior and build failures.
#
echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

echo "清单100个最大的包"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
df -h
echo "移除大的包裹"
sudo apt-get -y purge firefox
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '^llvm-.*'
sudo apt-get remove -y 'php.*'
sudo apt-get remove -y '^mongodb-.*'
sudo apt-get remove -y '^mysql-.*'
sudo apt-get remove -y azure-cli google-cloud-sdk hhvm google-chrome-stable firefox powershell mono-devel google-cloud-cli google-cloud-cli-anthoscli 
# 自动清理依赖+缓存
sudo apt-get autoremove --purge -y
sudo apt-get autoclean
sudo apt-get clean
df -h
echo "删除大目录"
echo "-- .Net"
sudo rm -rf /usr/share/dotnet/
echo "-- graalvm"
sudo rm -rf /usr/local/graalvm/
echo "-- .ghcup"
sudo rm -rf /usr/local/.ghcup/
echo "-- powershell"
sudo rm -rf /usr/local/share/powershell
echo "-- chromium"
sudo rm -rf /usr/local/share/chromium
echo "-- Android"
sudo rm -rf /usr/local/lib/android
echo "-- Node"
sudo rm -rf /usr/local/lib/node_modules
echo "-- Dotnet"
sudo rm -rf /usr/share/dotnet
echo "-- Haskell"
sudo rm -rf /opt/ghc
echo "-- Boost"
sudo rm -rf /usr/local/share/boost
echo "-- CodeQL"
sudo rm -rf /opt/hostedtoolcache/CodeQL
# 清理 Docker
docker system prune -af --volumes
# 删除 GitHub Actions 工具缓存
sudo rm -rf /opt/hostedtoolcache
