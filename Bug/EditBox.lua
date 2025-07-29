-- EditBox.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/28/2025, 11:59:35 AM
--
local hooked = {}

local function FixEditBox(f)
    if not f or hooked[f] then
        return
    end
    if not f.Left or not f.Right or not f.Middle then
        return
    end

    if f.Left:GetAtlas() or f.Left:GetTexture() then
        return
    end

    f.Left:SetTexture([[interface\common\commonsearch]])
    f.Left:SetTexCoord(0.88671875, 0.94921875, 0.0078125, 0.3203125)

    f.Right:SetTexture([[interface\common\commonsearch]])
    f.Right:SetTexCoord(0.00390625, 0.06640625, 0.3359375, 0.6484375)

    f.Middle:SetTexture([[interface\common\commonsearch]])
    f.Middle:SetTexCoord(0.00390625, 0.87890625, 0.0078125, 0.3203125)

    hooked[f] = true
end

do
    local f
    while true do
        f = EnumerateFrames(f)
        if not f then
            break
        end

        if f:IsObjectType('EditBox') then
            FixEditBox(f)
        end
    end
end

local mt = getmetatable(ChatFrame1EditBox).__index

hooksecurefunc(mt, 'HighlightText', FixEditBox)
hooksecurefunc(mt, 'SetTextInsets', FixEditBox)
