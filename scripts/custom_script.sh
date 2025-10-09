#!/bin/bash

# 修改固件版本号为编译日期
sed -i "s/^VERSION:=.*/VERSION:=${NEW_VERSION}/" include/version.mk
sed -i "s/^DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='${NEW_VERSION}'/" package/base-files/files/etc/openwrt_release
sed -i "s/^DISTRIB_REVISION='.*'/DISTRIB_REVISION='R${CURRENT_DATE}'/" package/base-files/files/etc/openwrt_release
