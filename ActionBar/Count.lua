-- Count.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 2:22:49 PM

---@type ns
local ns = select(2, ...)

local LibClassicSpellActionCount = LibStub('LibClassicSpellActionCount-1.0')

local IsConsumableAction = IsConsumableAction
local IsItemAction = IsItemAction
local IsStackableAction = IsStackableAction

ns.securehook('ActionButton_UpdateCount', function(button)
    local action = button.action
    if not IsItemAction(action) and (IsConsumableAction(action) or IsStackableAction(action)) then
        local count = LibClassicSpellActionCount:GetActionCount(action)
        if count > (button.maxDisplayCount or 9999) then
            button.Count:SetText('*')
        else
            button.Count:SetText(count)
        end
    end
end)
