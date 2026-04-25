-- ConsoleBags Handheld Mode
-- ROG Ally X 优化伴侣插件
-- 使用Hook方式，不修改原插件任何文件

local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- 创建插件
local CBHandheld = AceAddon:NewAddon(addonName, "AceConsole-3.0")
addon.core = CBHandheld

-- 默认配置
local defaults = {
    profile = {
        preset = "handheld",  -- normal, handheld, big, custom
        sizes = {
            listItemHeight = 56,      -- 物品行高
            iconSize = 56,            -- 图标大小
            filterBarHeight = 48,     -- 肩键分类栏高度
            headerHeight = 48,        -- 头部高度
            footerHeight = 48,        -- 底部高度
            windowWidth = 850,        -- 窗口宽度
            windowHeight = 650,       -- 窗口高度
            fontSize = 16,            -- 字体大小
        },
        autoApply = true,             -- 是否自动应用
    }
}

-- 预设配置
local presets = {
    normal = {
        listItemHeight = 28,
        iconSize = 32,
        filterBarHeight = 32,
        headerHeight = 32,
        footerHeight = 32,
        windowWidth = 600,
        windowHeight = 436,
        fontSize = 12,
    },
    handheld = {
        listItemHeight = 56,
        iconSize = 56,
        filterBarHeight = 48,
        headerHeight = 48,
        footerHeight = 48,
        windowWidth = 850,
        windowHeight = 650,
        fontSize = 16,
    },
    big = {
        listItemHeight = 64,
        iconSize = 64,
        filterBarHeight = 56,
        headerHeight = 56,
        footerHeight = 56,
        windowWidth = 950,
        windowHeight = 750,
        fontSize = 18,
    },
}

-- 检查ConsoleBags是否加载
function CBHandheld:CheckConsoleBags()
    local cb = AceAddon:GetAddon("ConsoleBags", true)
    if not cb then
        self:Print("|cffff0000错误：未检测到ConsoleBags插件！")
        self:Print("|cffff0000本插件需要ConsoleBags作为依赖")
        return false
    end
    return true
end

-- 获取ConsoleBags模块
function CBHandheld:GetCBModules()
    local cb = AceAddon:GetAddon("ConsoleBags")
    return {
        addon = cb,
        session = cb:GetModule("Session"),
        database = cb:GetModule("Database"),
        view = cb:GetModule("View"),
    }
end

-- 应用配置到ConsoleBags
function CBHandheld:ApplyConfig()
    if not self:CheckConsoleBags() then return end
    
    local modules = self:GetCBModules()
    local db = self.db.profile
    local sizes = db.sizes
    
    -- 修改Session设置 (防御性检查)
    if modules.session and modules.session.Settings then
        local settings = modules.session.Settings
        if settings.Defaults then
            if settings.Defaults.Sections then
                settings.Defaults.Sections.ListItemHeight = sizes.listItemHeight
                settings.Defaults.Sections.Header = sizes.headerHeight
                settings.Defaults.Sections.Filters = sizes.filterBarHeight
                settings.Defaults.Sections.Footer = sizes.footerHeight
            end
            if settings.Defaults.Columns then
                settings.Defaults.Columns.Icon = sizes.iconSize
                settings.Defaults.Columns.Name = math.max(320, sizes.iconSize * 7)
            end
        end
    end
    
    -- 修改数据库默认值 (防御性检查)
    if modules.database and modules.database.internal and modules.database.internal.global then
        local cbdb = modules.database.internal.global
        if cbdb.InventoryFrame then
            if cbdb.InventoryFrame.Size then
                cbdb.InventoryFrame.Size.X = sizes.windowWidth
                cbdb.InventoryFrame.Size.Y = sizes.windowHeight
            end
            cbdb.InventoryFrame.ItemHeight = sizes.listItemHeight
        end
        if cbdb.BankFrame then
            if cbdb.BankFrame.Size then
                cbdb.BankFrame.Size.X = sizes.windowWidth
                cbdb.BankFrame.Size.Y = sizes.windowHeight
            end
            cbdb.BankFrame.ItemHeight = sizes.listItemHeight
        end
        if cbdb.Font then
            cbdb.Font.Size = sizes.fontSize
        end
    end
    
    -- 更新现有窗口
    self:UpdateExistingWindows()
    
    self:Print(string.format("|cff00ff00配置已应用：%s模式", db.preset))
end

-- 更新现有窗口
function CBHandheld:UpdateExistingWindows()
    local modules = self:GetCBModules()
    
    if modules.addon and modules.addon.bags then
        -- 更新背包窗口
        if modules.addon.bags.Inventory then
            local inv = modules.addon.bags.Inventory
            if inv.UpdateGUI then
                inv:UpdateGUI()
            end
        end
        -- 更新银行窗口
        if modules.addon.bags.Bank then
            local bank = modules.addon.bags.Bank
            if bank.UpdateGUI then
                bank:UpdateGUI()
            end
        end
    end
end

-- 应用预设
function CBHandheld:ApplyPreset(presetName)
    if not presets[presetName] then
        self:Print("|cffff0000无效的预设：" .. tostring(presetName))
        return
    end
    
    -- 复制预设值到配置
    for key, value in pairs(presets[presetName]) do
        self.db.profile.sizes[key] = value
    end
    self.db.profile.preset = presetName
    
    -- 如果是自定义模式，保留当前值
    if presetName == "custom" then
        self:Print("|cff00ff00已切换到自定义模式 - 保留当前设置")
    else
        self:Print(string.format("|cff00ff00已应用%s预设", presetName))
    end
    
    -- 应用配置
    self:ApplyConfig()
end

-- 创建配置界面
function CBHandheld:CreateConfig()
    local options = {
        name = "ConsoleBags 掌机模式",
        type = "group",
        args = {
            desc = {
                type = "description",
                name = "为ROG Ally X等掌机设备优化ConsoleBags的UI尺寸\n",
                fontSize = "medium",
                order = 0,
            },
            preset = {
                type = "select",
                name = "预设方案",
                desc = "选择预设的UI尺寸方案",
                values = {
                    normal = "标准模式 (PC默认)",
                    handheld = "掌机模式 (ROG Ally X推荐)",
                    big = "超大模式 (远距离/躺着玩)",
                    custom = "自定义 (手动调整)",
                },
                get = function() return self.db.profile.preset end,
                set = function(_, value)
                    self.db.profile.preset = value
                    self:ApplyPreset(value)
                end,
                order = 1,
            },
            applyBtn = {
                type = "execute",
                name = "立即应用",
                desc = "将当前配置应用到ConsoleBags",
                func = function() self:ApplyConfig() end,
                order = 2,
            },
            sizesHeader = {
                type = "header",
                name = "尺寸设置 (自定义模式下可调)",
                order = 10,
            },
            listItemHeight = {
                type = "range",
                name = "物品行高",
                desc = "每行物品的高度",
                min = 28,
                max = 80,
                step = 2,
                get = function() return self.db.profile.sizes.listItemHeight end,
                set = function(_, value)
                    self.db.profile.sizes.listItemHeight = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    -- 实时预览
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 11,
            },
            iconSize = {
                type = "range",
                name = "图标大小",
                desc = "物品图标的尺寸",
                min = 32,
                max = 80,
                step = 2,
                get = function() return self.db.profile.sizes.iconSize end,
                set = function(_, value)
                    self.db.profile.sizes.iconSize = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 12,
            },
            filterBarHeight = {
                type = "range",
                name = "分类栏高度",
                desc = "肩键切换的物品类型栏高度 (R1/L1切换)",
                min = 32,
                max = 80,
                step = 2,
                get = function() return self.db.profile.sizes.filterBarHeight end,
                set = function(_, value)
                    self.db.profile.sizes.filterBarHeight = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 13,
            },
            headerHeight = {
                type = "range",
                name = "头部高度",
                desc = "顶部标题栏的高度",
                min = 32,
                max = 80,
                step = 2,
                get = function() return self.db.profile.sizes.headerHeight end,
                set = function(_, value)
                    self.db.profile.sizes.headerHeight = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 14,
            },
            windowHeader = {
                type = "header",
                name = "窗口设置",
                order = 20,
            },
            windowWidth = {
                type = "range",
                name = "窗口宽度",
                desc = "背包和银行窗口的宽度",
                min = 600,
                max = 1200,
                step = 10,
                get = function() return self.db.profile.sizes.windowWidth end,
                set = function(_, value)
                    self.db.profile.sizes.windowWidth = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 21,
            },
            windowHeight = {
                type = "range",
                name = "窗口高度",
                desc = "背包和银行窗口的高度",
                min = 400,
                max = 900,
                step = 10,
                get = function() return self.db.profile.sizes.windowHeight end,
                set = function(_, value)
                    self.db.profile.sizes.windowHeight = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 22,
            },
            fontSize = {
                type = "range",
                name = "字体大小",
                desc = "文字字体的大小",
                min = 12,
                max = 24,
                step = 1,
                get = function() return self.db.profile.sizes.fontSize end,
                set = function(_, value)
                    self.db.profile.sizes.fontSize = value
                    if self.db.profile.preset ~= "custom" then
                        self.db.profile.preset = "custom"
                    end
                    if self.db.profile.autoApply then
                        self:ApplyConfig()
                    end
                end,
                order = 23,
            },
            optionsHeader = {
                type = "header",
                name = "选项",
                order = 30,
            },
            autoApply = {
                type = "toggle",
                name = "自动应用",
                desc = "调整滑块时是否立即应用改动（否则需点击立即应用按钮）",
                get = function() return self.db.profile.autoApply end,
                set = function(_, value) self.db.profile.autoApply = value end,
                order = 31,
            },
            status = {
                type = "description",
                name = function()
                    local sizes = self.db.profile.sizes
                    return string.format(
                        "\n|cff00ff00当前配置:|r\n" ..
                        "  物品行高: %dpx\n" ..
                        "  图标大小: %dpx\n" ..
                        "  分类栏高度: %dpx\n" ..
                        "  窗口尺寸: %dx%d\n" ..
                        "  字体大小: %dpx",
                        sizes.listItemHeight,
                        sizes.iconSize,
                        sizes.filterBarHeight,
                        sizes.windowWidth,
                        sizes.windowHeight,
                        sizes.fontSize
                    )
                end,
                order = 40,
            },
        },
    }
    
    AceConfig:RegisterOptionsTable("CBHandheld", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("CBHandheld", "ConsoleBags Handheld")
end

-- 初始化
function CBHandheld:OnInitialize()
    -- 初始化数据库
    self.db = AceDB:New("CBHandheldDB", defaults, true)
    
    -- 创建配置界面
    self:CreateConfig()
    
    -- 注册聊天命令
    self:RegisterChatCommand("handheld", "ChatCommand")
    self:RegisterChatCommand("hh", "ChatCommand")
    
    self:Print("|cff00ff00ConsoleBags Handheld Mode 已加载")
    self:Print("输入 |cffffff00/handheld|r 打开配置界面")
end

-- 启用时
function CBHandheld:OnEnable()
    -- 延迟等待ConsoleBags完全加载
    C_Timer.After(1, function()
        if not self:CheckConsoleBags() then return end
        
        -- 如果设置了自动应用，则应用当前预设
        if self.db.profile.autoApply then
            self:ApplyPreset(self.db.profile.preset)
        end
    end)
end

-- 聊天命令处理
function CBHandheld:ChatCommand(input)
    if not input or input:trim() == "" then
        -- 打开配置界面
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory(self.optionsFrame)
        else
            -- 兼容旧版本
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end
        return
    end
    
    local command, rest = input:match("^(%S*)%s*(.-)$")
    command = command:lower()
    
    if command == "apply" then
        self:ApplyConfig()
    elseif command == "preset" and rest ~= "" then
        self:ApplyPreset(rest:lower())
    elseif command == "status" then
        local sizes = self.db.profile.sizes
        self:Print("当前配置:")
        self:Print(string.format("  模式: %s", self.db.profile.preset))
        self:Print(string.format("  物品行高: %dpx", sizes.listItemHeight))
        self:Print(string.format("  分类栏高度: %dpx", sizes.filterBarHeight))
        self:Print(string.format("  窗口: %dx%d", sizes.windowWidth, sizes.windowHeight))
    else
        self:Print("用法:")
        self:Print("  /handheld - 打开配置界面")
        self:Print("  /handheld apply - 应用当前配置")
        self:Print("  /handheld preset [normal/handheld/big] - 切换预设")
        self:Print("  /handheld status - 查看状态")
    end
end

--#region 装备等级显示在图标上

-- 装等显示配置
CBHandheld.ItemLevelConfig = {
    Enabled = true,           -- 是否启用
    ShowOnIcon = true,        -- 显示在图标上(而非单独列)
    FontSize = 12,            -- 字体大小
    Position = "BOTTOMRIGHT", -- 位置
    ColorByQuality = true,    -- 根据品质着色
}

-- 创建装等文本框
function CBHandheld:CreateItemLevelText(parent)
    local itemLevelFrame = CreateFrame('Frame', nil, parent)
    itemLevelFrame:SetSize(30, 14)
    itemLevelFrame:SetFrameLevel(parent:GetFrameLevel() + 5)
    
    -- 背景遮罩（提高可读性）
    local bg = itemLevelFrame:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.6)
    itemLevelFrame.bg = bg
    
    -- 文本
    local text = itemLevelFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalTiny')
    text:SetAllPoints()
    text:SetJustifyH('CENTER')
    text:SetJustifyV('MIDDLE')
    text:SetFont('Fonts\\FRIZQT__.TTF', self.ItemLevelConfig.FontSize, 'OUTLINE')
    itemLevelFrame.text = text
    
    itemLevelFrame:Hide()
    return itemLevelFrame
end

-- 初始化装等显示Hook
function CBHandheld:InitItemLevelOnIcon()
    if not self.ItemLevelConfig.Enabled then return end
    
    local cb = LibStub("AceAddon-3.0"):GetAddon("ConsoleBags", true)
    if not cb then return end
    
    local itemFrame = cb:GetModule("ItemFrame")
    if not itemFrame or not itemFrame.proto then return end
    
    -- 保存原始的Build函数引用
    local originalBuild = itemFrame.proto.Build
    local selfRef = self
    
    -- Hook Build函数
    itemFrame.proto.Build = function(itemFrameSelf, item, offset, parent)
        -- 调用原始函数
        originalBuild(itemFrameSelf, item, offset, parent)
        
        if not selfRef.ItemLevelConfig.Enabled then return end
        local config = selfRef.ItemLevelConfig
        
        local frame = itemFrameSelf.widget
        
        -- 创建或获取装等框
        if not frame.icon.itemLevel then
            frame.icon.itemLevel = selfRef:CreateItemLevelText(frame.icon)
        end
        
        local itemLevelFrame = frame.icon.itemLevel
        
        -- 检查是否是需要显示装等的物品类型
        local shouldShow = item.ilvl and item.ilvl > 0 and (
            item.type == Enum.ItemClass.Armor or 
            item.type == Enum.ItemClass.Weapon or
            item.category == Enum.ItemClass.Battlepet
        )
        
        if shouldShow then
            -- 设置位置
            itemLevelFrame:ClearAllPoints()
            local pos = config.Position
            if pos == "BOTTOMRIGHT" then
                itemLevelFrame:SetPoint('BOTTOMRIGHT', frame.icon, 'BOTTOMRIGHT', -1, 2)
            elseif pos == "BOTTOMLEFT" then
                itemLevelFrame:SetPoint('BOTTOMLEFT', frame.icon, 'BOTTOMLEFT', 1, 2)
            elseif pos == "TOPRIGHT" then
                itemLevelFrame:SetPoint('TOPRIGHT', frame.icon, 'TOPRIGHT', -1, -2)
            elseif pos == "TOPLEFT" then
                itemLevelFrame:SetPoint('TOPLEFT', frame.icon, 'TOPLEFT', 1, -2)
            end
            
            -- 设置文本
            itemLevelFrame.text:SetText(item.ilvl)
            
            -- 根据品质着色
            if config.ColorByQuality and C_Item and C_Item.GetItemQualityColor then
                local r, g, b = C_Item.GetItemQualityColor(item.quality or 0)
                itemLevelFrame.text:SetTextColor(r, g, b)
            else
                itemLevelFrame.text:SetTextColor(1, 1, 1)
            end
            
            -- 更新字体大小
            itemLevelFrame.text:SetFont('Fonts\\FRIZQT__.TTF', config.FontSize, 'OUTLINE')
            
            itemLevelFrame:Show()
        else
            itemLevelFrame:Hide()
        end
        
        -- 如果启用了图标显示，隐藏原始装等列
        if config.ShowOnIcon and frame.ilvlContainer then
            frame.ilvlContainer:Hide()
        elseif frame.ilvlContainer then
            frame.ilvlContainer:Show()
        end
    end
    
    self:Print("|cff00ff00装备等级图标显示已启用")
end

-- 切换装等显示模式
function CBHandheld:ToggleItemLevelDisplay()
    self.ItemLevelConfig.ShowOnIcon = not self.ItemLevelConfig.ShowOnIcon
    
    if self.ItemLevelConfig.ShowOnIcon then
        self:Print("|cff00ff00装等显示: 图标模式")
    else
        self:Print("|cff00ff00装等显示: 列模式")
    end
    
    -- 刷新背包界面
    local cb = LibStub("AceAddon-3.0"):GetAddon("ConsoleBags", true)
    if cb then
        local view = cb:GetModule("InventoryView")
        if view and view.Refresh then
            view:Refresh()
        end
    end
end

--#endregion

-- 在模块启用时初始化装等显示
local originalOnEnable = CBHandheld.OnEnable
CBHandheld.OnEnable = function(self)
    originalOnEnable(self)
    
    -- 延迟初始化装等显示
    C_Timer.After(2, function()
        self:InitItemLevelOnIcon()
    end)
end

