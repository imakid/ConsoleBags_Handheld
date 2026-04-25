# ConsoleBags Handheld Mode

为ROG Ally X等掌机设备优化ConsoleBags的UI尺寸。

## 功能特性

- **4种预设模式**：标准(PC) / 掌机(ROG Ally X推荐) / 超大(远距离) / 自定义
- **6个可调尺寸**：行高、图标、分类栏、头部、窗口、字体
- **实时预览**：开启自动应用后，拖动滑块即时生效
- **GUI配置界面**：无需编辑代码，游戏内可调
- **零侵入**：不修改ConsoleBags任何文件

## 依赖

- [ConsoleBags](https://www.curseforge.com/wow/addons/consolebags) - 必须先安装
- WoW 11.0+ (The War Within)

## 安装方法

### 方法一：WoWUp 自动安装
在WoWUp中搜索 "ConsoleBags Handheld" 并安装

### 方法二：手动安装
1. 下载最新Release的zip文件
2. 解压到 `World of Warcraft/_retail_/Interface/AddOns/`
3. 重新启动游戏或重载界面

## 使用方法

### 命令
- `/handheld` 或 `/hh` - 打开配置界面
- `/handheld apply` - 立即应用当前配置
- `/handheld preset handheld` - 切换到掌机模式
- `/handheld status` - 查看当前配置

### 配置界面
游戏中按 `Esc` → 选项 → 插件 → ConsoleBags Handheld

## 预设模式说明

| 模式 | 物品行高 | 图标 | 分类栏 | 窗口尺寸 | 适合场景 |
|------|---------|------|---------|----------|---------|
| normal | 28px | 32px | 32px | 600×436 | PC默认 |
| handheld | 56px | 56px | 48px | 850×650 | ROG Ally X推荐 |
| big | 64px | 64px | 56px | 950×750 | 远距离/躺着玩 |
| custom | 自定义 | 自定义 | 自定义 | 自定义 | 手动调整 |

## 掌机操作说明

- **肩键切换分类** (R1/L1): 分类栏高度可独立调节，默认48px更适合手指点击
- **左操纳运动** (L3): 开启鼠标模式后可拖动窗口
- **右操纳运动** (R3): 增大窗口/详情面板

## 版本历史

### v1.0.1
- 修复: 移除重复的 Enable() 调用
- 修复: 更新为新版设置界面API (WoW 11.0+)
- 改进: 增加防御性空值检查

### v1.0.0
- 初始发布
- 支持4种预设模式
- 支持6个可调尺寸
- 支持实时预览

## 授权协议

MIT License - 自由使用和分发

## 感谢

- [ConsoleBags](https://www.curseforge.com/wow/addons/consolebags) - 优秀的手柄优化背包插件
