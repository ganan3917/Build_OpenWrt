#!/bin/bash

# 获取当前北京时间（格式：YYYYMMDD）
CURRENT_DATE=$(TZ=Asia/Shanghai date +%Y%m%d)
# 定义新版本号
NEW_VERSION="LEDE R${CURRENT_DATE}"

# 修改固件版本号为编译日期
sed -i "s/^VERSION:=.*/VERSION:=${NEW_VERSION}/" include/version.mk
sed -i "s/^DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='${NEW_VERSION}'/" package/base-files/files/etc/openwrt_release
sed -i "s/^DISTRIB_REVISION='.*'/DISTRIB_REVISION='R${CURRENT_DATE}'/" package/base-files/files/etc/openwrt_release



# 设置时区为Asia/Shanghai  
sed -i "s/option timezone '.*/option timezone 'Asia\/Shanghai'/" /etc/config/system  
# 禁用UTC时间  
sed -i "s/option utc '.*/option utc '0'/" /etc/config/system  
# 设置时间格式（若已有time_format行则替换，无则添加）  
sed -i "s/option time_format '.*/option time_format '%Y-%m-%d %H:%M:%S'/" /etc/config/system  
sed -i "/config system 'system'/a option time_format '%Y-%m-%d %H:%M:%S'" /etc/config/system  
# 配置国内NTP服务器（替换默认服务器）  
sed -i "s/list server '.*'//g" /etc/config/system  # 清空原有服务器  
sed -i "/config timeserver 'ntp'/a list server 'ntp.aliyun.com'" /etc/config/system  
sed -i "/config timeserver 'ntp'/a list server 'time1.cloud.tencent.com'" /etc/config/system  
