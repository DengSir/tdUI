-- ComboBox.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/31/2020, 11:22:31 AM
--
---@type ns
local ns = select(2, ...)

local ComboBox = ns.class('Frame')
ns.ComboBox = ComboBox

local function ButtonOnClick(button)
    local parent = button:GetParent()
    ToggleDropDownMenu(1, nil, parent, nil, nil, nil, parent.menuList)
    PlaySound(856)
end

function ComboBox:Constructor()
    self:SetScript('OnShow', nil)
    self.Button:SetScript('OnClick', ButtonOnClick)
end

function ComboBox:SetMenuList(list)
    local function OnClick(_, value)
        self.selectedValue = value
        self:Refresh()
        self:Fire('OnValueChanged', value)
    end

    local function Checked(button)
        return self.selectedValue == button.arg1
    end

    local menuList = {}
    for i, v in ipairs(list) do
        menuList[i] = {text = v.text, arg1 = v.value, func = OnClick, checked = Checked}
    end

    UIDropDownMenu_Initialize(self, EasyMenu_Initialize, nil, nil, menuList)
end

function ComboBox:Refresh()
    for i, v in ipairs(self.menuList) do
        if v.arg1 == self.selectedValue then
            self.Text:SetText(v.text)
            break
        end
    end
end

function ComboBox:SetValue(value)
    self.selectedName = nil
    self.selectedID = nil
    self.selectedValue = value
    self:Refresh()
end

ComboBox.GetValue = UIDropDownMenu_GetSelectedValue

function ns.combobox(obj, menuList, callback)
    ComboBox:Bind(obj)

    if menuList then
        obj:SetMenuList(menuList)
    end
    if callback then
        obj:SetCallback('OnValueChanged', function(_, value)
            return callback(value)
        end)
    end
end
