#!/bin/bash
# 1. overwrite-01-nginx-disable-https nginx默认使用http
echo "Applying overwrite-01-nginx-disable-https ( nginx默认使用http )"
echo ">> Copy $GITHUB_WORKSPACE/overwrite/01-nginx-disable-https to $OPENWRT_PATH/feeds/packages/net/nginx-util/files/nginx.config"
cp "$GITHUB_WORKSPACE/overwrite/01-nginx-disable-https" "$OPENWRT_PATH/feeds/packages/net/nginx-util/files/nginx.config"
