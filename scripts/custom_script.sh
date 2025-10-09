#!/bin/bash

# 获取当前北京时间
CURRENT_DATE=$(TZ=Asia/Shanghai date +%Y%m%d)
NEW_VERSION="LEDE R${CURRENT_DATE}"

# 修改固件版本号为编译日期
sed -i "s/^VERSION:=.*/VERSION:=${NEW_VERSION}/" include/version.mk
sed -i "s/^DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='${NEW_VERSION}'/" package/base-files/files/etc/openwrt_release
sed -i "s/^DISTRIB_REVISION='.*'/DISTRIB_REVISION='R${CURRENT_DATE}'/" package/base-files/files/etc/openwrt_release


# 提取 CPU 型号（取第一行有效信息）
cpu_model=$(cat /proc/cpuinfo | grep -m1 'model name' | cut -d: -f2 | sed -e 's/^[ \t]*//')
# 提取 CPU 主频（单位 MHz，取第一核心的主频）
cpu_freq=$(cat /proc/cpuinfo | grep -m1 'cpu MHz' | cut -d: -f2 | sed -e 's/^[ \t]*//' | awk '{printf "%.0fMHz", $1}')

# 提取 CPU 核心数
cpu_cores=$(cat /proc/cpuinfo | grep -c '^processor')
# 组合成目标主机型号字符串（例如："Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz 1600MHz 4核"）
new_model="${cpu_model} ${cpu_freq} ${cpu_cores}核"
# 替换原型号为 CPU 信息（注意保留其他字段）
sed -i "s/\"model\": {\"name\": \".*\"}/\"model\": {\"name\": \"${new_model}\"}/g" /etc/board.json
