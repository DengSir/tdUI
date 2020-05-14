-- WeakAuras.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 3/2/2020, 8:43:24 PM

---@type ns
local ns = select(2, ...)

ns.addon('WeakAuras', function()
    local ipairs = ipairs

    local GetActionInfo = GetActionInfo
    local GetItemInfo = GetItemInfo
    local GetMacroInfo = GetMacroInfo
    local GetMacroItem = GetMacroItem
    local GetMacroSpell = GetMacroSpell
    local GetSpellInfo = GetSpellInfo

    local BUTTONS = {}
    do
        for _, bar in ipairs{
            'ActionButton', 'MultiBarBottomLeftButton', 'MultiBarBottomRightButton', 'MultiBarLeftButton',
            'MultiBarRightButton',
        } do
            for i = 1, 12 do
                tinsert(BUTTONS, _G[bar .. i])
            end
        end
    end

    WeakAuras.FindSpellAction = function(spellName)
        for i, button in ipairs(BUTTONS) do
            local actionType, id = GetActionInfo(button.action)
            if actionType == 'spell' then
                if GetSpellInfo(id) == spellName then
                    return button
                end
            elseif actionType == 'macro' then
                local macroSpellId = GetMacroSpell(id)
                if GetSpellInfo(macroSpellId) == spellName then
                    return button
                end
            end
        end
    end

    WeakAuras.FindItemAction = function(itemName)
        for i, button in ipairs(BUTTONS) do
            local actionType, id = GetActionInfo(button.action)
            if actionType == 'item' then
                if GetItemInfo(id) == itemName then
                    return button
                end
            elseif actionType == 'macro' then
                if GetMacroItem(id) == itemName then
                    return button
                end
            end
        end
    end

    WeakAuras.FindMacroAction = function(macroName)
        for i, button in ipairs(BUTTONS) do
            local actionType, id = GetActionInfo(button.action)
            if actionType == 'macro' and GetMacroInfo(id) == macroName then
                return button
            end
        end
    end
end)
