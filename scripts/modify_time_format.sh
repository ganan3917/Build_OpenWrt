#!/bin/bash
# 功能：修改 LEDE 本地时间显示格式为 "年-月-日 时:分:秒"
# 使用方法：在 LEDE 源码根目录执行

# 检查是否在 LEDE 源码目录
if [ ! -f "Makefile" ]; then
    echo "错误：请在 LEDE 源码根目录执行此脚本"
    exit 1
fi

echo "开始修改本地时间格式为 '年-月-日 时:分:秒'"

# 1. 修改 LuCI 状态页初始时间格式（Lua 模板）
# 文件路径：feeds/luci/modules/luci-base/luasrc/view/admin_status/index.htm
LUCI_STATUS_HTM="feeds/luci/modules/luci-base/luasrc/view/admin_status/index.htm"
if [ -f "$LUCI_STATUS_HTM" ]; then
    # 替换 os.date() 为指定格式（%Y-%m-%d %H:%M:%S）
    sed -i "s/os.date()/os.date(\"%Y-%m-%d %H:%M:%S\")/g" "$LUCI_STATUS_HTM"
    echo "已修改 $LUCI_STATUS_HTM"
else
    echo "警告：未找到 $LUCI_STATUS_HTM，跳过"
fi

# 2. 修改 LuCI 动态时间刷新逻辑（JavaScript）
# 文件路径：feeds/luci/modules/luci-base/htdocs/luci-static/resources/overview.js
OVERVIEW_JS="feeds/luci/modules/luci-base/htdocs/luci-static/resources/overview.js"
if [ -f "$OVERVIEW_JS" ]; then
    # 替换原时间格式化函数（toLocaleString()）为自定义格式
    sed -i '/function updateLocalTime() {/,/}/c\function updateLocalTime() {\n    var now = new Date();\n    var elem = document.getElementById(\'localtime\');\n    var year = now.getFullYear();\n    var month = (now.getMonth() + 1).toString().padStart(2, \'0\');\n    var day = now.getDate().toString().padStart(2, \'0\');\n    var hours = now.getHours().toString().padStart(2, \'0\');\n    var minutes = now.getMinutes().toString().padStart(2, \'0\');\n    var seconds = now.getSeconds().toString().padStart(2, \'0\');\n    elem.innerText = year + \'-\' + month + \'-\' + day + \' \' + hours + \':\' + minutes + \':\' + seconds;\n}' "$OVERVIEW_JS"
    echo "已修改 $OVERVIEW_JS"
else
    echo "警告：未找到 $OVERVIEW_JS，跳过"
fi

# 3. 修改系统日志或其他页面的时间格式（如系统日志页面）
# 文件路径：feeds/luci/modules/luci-base/luasrc/helper.lua（日志时间格式化）
HELPER_LUA="feeds/luci/modules/luci-base/luasrc/helper.lua"
if [ -f "$HELPER_LUA" ]; then
    # 替换日志时间格式为 "%Y-%m-%d %H:%M:%S"
    sed -i "s/os.date(\"%c\", t)/os.date(\"%Y-%m-%d %H:%M:%S\", t)/g" "$HELPER_LUA"
    echo "已修改 $HELPER_LUA"
else
    echo "警告：未找到 $HELPER_LUA，跳过"
fi

echo "本地时间格式修改完成"