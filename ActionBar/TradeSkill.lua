-- TradeSkill.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/11/2020, 11:28:12 AM

---@type ns
local ns = select(2, ...)

local LibRecipes = LibStub('LibRecipes-1.0')

local GetActionInfo = GetActionInfo
local GetItemIcon = GetItemIcon

ns.securehook('ActionButton_Update', function(button)
    local type, id = GetActionInfo(button.action)
    if type == 'spell' then
        local _, itemId = LibRecipes:GetSpellInfo(id)
        if itemId then
            button.icon:SetTexture(GetItemIcon(itemId))
        end
    end
end)
