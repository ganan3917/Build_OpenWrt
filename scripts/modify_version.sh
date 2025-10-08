#!/bin/bash
# 功能：修改 LEDE 系统中 CPU 信息的显示格式（型号@主频 核心线程）
# 需在 LEDE 源码根目录执行

# 进入 LEDE 源码根目录（若脚本在其他路径执行，需修改此路径）
LEDESRC_DIR=$(pwd)
if [ ! -f "$LEDESRC_DIR/Makefile" ]; then
  echo "错误：未在 LEDE 源码目录执行，请进入源码根目录后运行此脚本"
  exit 1
fi

echo "开始修改 CPU 信息显示格式..."

# 1. 修改系统型号配置（/bin/config_generate）
# 原逻辑：显示 /proc/cpuinfo 中的 model 字段
# 新逻辑：提取 CPU 型号、主频、核心数、线程数，格式为 "型号@主频 核心数C线程数T"
CONFIG_GENERATE="$LEDESRC_DIR/package/base-files/files/bin/config_generate"
if [ -f "$CONFIG_GENERATE" ]; then
  # 删除原型号设置行，插入新逻辑
  sed -i '/uci_set system.@system\[0\].model/d' "$CONFIG_GENERATE"
  
  # 新增 CPU 信息提取逻辑
  cat >> "$CONFIG_GENERATE" << 'EOF'
# 提取 CPU 信息并格式化显示
cpu_model=$(grep -m1 '^model name' /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' -e 's/ @ /@/')  # 型号（去除空格，替换" @ "为"@"）
cpu_freq=$(grep -m1 '^cpu MHz' /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' | awk '{printf "%.2fGHz", $1/1000}')  # 主频（转换为GHz）
cpu_cores=$(grep -c '^processor' /proc/cpuinfo)  # 线程数（processor 计数）
cpu_physical_cores=$(grep -c '^core id' /proc/cpuinfo | awk '{print $1+1}')  # 物理核心数（core id 去重计数）
uci_set system.@system[0].model="${cpu_model}@${cpu_freq} ${cpu_physical_cores}C${cpu_cores}T"
EOF
  echo "修改 $CONFIG_GENERATE 成功"
else
  echo "警告：未找到 $CONFIG_GENERATE，跳过此文件"
fi

# 2. 修改 LuCI 状态页显示（若存在 autocore 插件的系统信息页面）
AUTOCORE_INDEX="$LEDESRC_DIR/package/lean/autocore/files/generic/index.htm"
if [ -f "$AUTOCORE_INDEX" ]; then
  # 替换 LuCI 页面中 CPU 型号的显示逻辑
  sed -i 's/<%=luci.sys.exec("grep .*model.* /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' | head -n1")%>/<%=luci.sys.exec("grep -m1 '^model name' /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' -e 's/ @ /@/'")%>@<%=luci.sys.exec("grep -m1 '^cpu MHz' /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' | awk '{printf \"%.2fGHz\", $1/1000}'")%> <%=luci.sys.exec("grep -c '^core id' /proc/cpuinfo | awk '{print $1+1}'")%>C<%=luci.sys.exec("grep -c '^processor' /proc/cpuinfo")%>T/g' "$AUTOCORE_INDEX"
  echo "修改 $AUTOCORE_INDEX 成功"
else
  echo "警告：未找到 $AUTOCORE_INDEX，跳过此文件（可能未安装 autocore 插件）"
fi

echo "CPU 信息显示格式修改完成"