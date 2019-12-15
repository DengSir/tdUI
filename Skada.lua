-- Skada.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/14/2019, 5:49:37 PM

if not Skada then
    return
end

local function OnShow(self)
    self:ClearAllPoints()
    self:SetParent(ChatFrame7)
    self:rawSetPoint('TOPLEFT', 0, -self.button:GetHeight())
    self:rawSetPoint('BOTTOMRIGHT', 0, -4)
    self.isResizing = true
    self.resizebutton:GetScript('OnMouseUp')(self.resizebutton)
end

local Skada_CreateWindow = Skada.CreateWindow

function Skada:CreateWindow(name, db, display)
    local window = Skada_CreateWindow(self, name, db, display)
    if name == 'Skada' then
        window.bargroup:HookScript('OnShow', OnShow)
        window.bargroup.rawSetPoint = window.bargroup.SetPoint
        window.bargroup.SetPoint = nop
        OnShow(window.bargroup)
    end
    return window
end
