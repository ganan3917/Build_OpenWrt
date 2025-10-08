#!/bin/bash
# 功能：替换固件中所有固定版本号 R25.8.8 为编译当天的日期（R年.月.日）
# 使用方法：在 LEDE 源码根目录执行

# 检查是否在 LEDE 源码目录（通过 Makefile 判断）
if [ ! -f "Makefile" ]; then
    echo "错误：请在 LEDE 源码根目录执行此脚本"
    exit 1
fi

# 获取编译当天的日期（格式：年.月.日，例如 2025.10.11）
BUILD_DATE=$(date +%Y.%m.%d)
NEW_VERSION="R$BUILD_DATE"
OLD_VERSION="R25.8.8"

echo "开始替换固件版本：$OLD_VERSION -> $NEW_VERSION"

# 1. 替换核心版本配置文件（/etc/openwrt_release）
RELEASE_FILE="package/base-files/files/etc/openwrt_release"
if [ -f "$RELEASE_FILE" ]; then
    sed -i "s/$OLD_VERSION/$NEW_VERSION/g" "$RELEASE_FILE"
    # 强制设置版本描述格式
    sed -i "s/^DISTRIB_REVISION=.*/DISTRIB_REVISION='$NEW_VERSION'/" "$RELEASE_FILE"
    sed -i "s/^DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION='LEDE $NEW_VERSION'/" "$RELEASE_FILE"
    echo "已更新 $RELEASE_FILE"
else
    echo "警告：未找到 $RELEASE_FILE，跳过"
fi

# 2. 替换版本生成脚本（影响 /etc/os-release）
CONFIG_GENERATE="package/base-files/files/bin/config_generate"
if [ -f "$CONFIG_GENERATE" ]; then
    sed -i "s/$OLD_VERSION/$NEW_VERSION/g" "$CONFIG_GENERATE"
    # 确保生成的 /etc/os-release 版本正确
    sed -i "s/echo \"VERSION='.*'\"/echo \"VERSION='$NEW_VERSION'\"/" "$CONFIG_GENERATE"
    sed -i "s/echo \"PRETTY_NAME='.*'\"/echo \"PRETTY_NAME='LEDE $NEW_VERSION'\"/" "$CONFIG_GENERATE"
    echo "已更新 $CONFIG_GENERATE"
else
    echo "警告：未找到 $CONFIG_GENERATE，跳过"
fi

# 3. 替换 LuCI 网页界面中显示的版本（覆盖所有相关页面）
echo "替换 LuCI 界面中的版本信息..."
find feeds/luci/ -type f \( -name "*.htm" -o -name "*.lua" -o -name "*.js" \) -exec \
    sed -i "s/$OLD_VERSION/$NEW_VERSION/g" {} +

# 4. 替换其他可能包含硬编码版本的文件（Makefile、配置等）
find . -type f \( -name "Makefile" -o -name "*.conf" -o -name "*.sh" \) -exec \
    sed -i "s/$OLD_VERSION/$NEW_VERSION/g" {} +

echo "版本替换完成，新固件版本：$NEW_VERSION"