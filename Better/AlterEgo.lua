-- AlterEgo.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/21/2026, 11:52:05 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('AlterEgo', function()

    local LiqUI = LibStub('LiqUI-1.0', true)
    if not LiqUI then
        return
    end

    local positions = {}

    local function OnShow(window)
        local pos = positions[window]
        if not pos then
            return
        end
        window:ClearAllPoints()
        window:SetPoint(SafeUnpack(pos))
    end

    local function HookPosition(window, ...)
        positions[window] = SafePack(...)
        window:HookScript('OnShow', OnShow)
    end

    local function UpdateWindowClampInsets(window)
        local width = window:GetWidth()
        local height = window:GetHeight()
        window:SetClampRectInsets(0, width, 0, height)
    end

    local function HookSize(frame)
        frame:SetScript('OnSizeChanged', UpdateWindowClampInsets)
    end

    -- local font, _, fontFlags = ChatFontNormal:GetFont()
    -- local _, fontHeight = GameFontHighlightSmall:GetFont()

    local function SetText(label, text)
        text = text:gsub('%[', ''):gsub('%]', '')
        getmetatable(label).__index.SetText(label, text)
    end

    local function SetupEquipmentCell(row)
        -- row.label:SetFont(font, fontHeight, fontFlags)
        row.label:SetFontObject(ChatFontNormal)
        row.label.SetFontObject = nop
        row.label.SetText = SetText
    end

    local equipmentCellMetatable = {
        __newindex = function(o, k, v)
            rawset(o, k, v)
            if k == 2 then
                SetupEquipmentCell(v)
            end
        end,
    }

    local equipmentRowMetatable = {
        __newindex = function(o, k, v)
            rawset(o, k, v)
            setmetatable(v.cells, equipmentCellMetatable)
        end,
    }

    ns.hook(LiqUI, 'NewElement', function(orig, lib, elementType, options)
        -- print(options, options.name)

        if elementType == 'Table' and options.name == 'AlterEgoEquipment' then
            local columns = options.columns
            columns[1].width = 50
            columns[2].width = 220
            columns[3].width = 50
            columns[4].width = 80
            -- columns[5]
        end

        ---@type Frame
        local instance = orig(lib, elementType, options)
        local name = instance:GetName()
        if name == 'LiqUIWindowAlterEgoEquipment' then
            HookPosition(instance, 'TOPLEFT', 'LiqUIWindowAlterEgoMain', 'TOPRIGHT', 1, 0)
        elseif name == 'LiqUIWindowAlterEgoAffixes' then
            HookPosition(instance, 'BOTTOMLEFT', 'LiqUIWindowAlterEgoMain', 'BOTTOMRIGHT', 1, 0)
        end
        if elementType == 'Window' then
            HookSize(instance)
        end
        if name == 'LiqUITableAlterEgoEquipment' then
            setmetatable(instance.rowFrames, equipmentRowMetatable)
        end
        return instance
    end)
end)
