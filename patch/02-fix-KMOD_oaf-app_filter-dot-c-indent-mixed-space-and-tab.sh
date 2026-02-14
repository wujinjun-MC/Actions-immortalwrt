#!/bin/bash
expand -i -t 4 "$OPENWRT_PATH/feeds/smpackage/oaf/src/app_filter.c" > "$OPENWRT_PATH/feeds/smpackage/oaf/src/app_filter.c.2"
cp "$OPENWRT_PATH/feeds/smpackage/oaf/src/app_filter.c.2" "$OPENWRT_PATH/feeds/smpackage/oaf/src/app_filter.c"
