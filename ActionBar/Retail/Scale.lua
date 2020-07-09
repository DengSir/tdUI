-- Scale.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/25/2020, 3:59:38 PM

local ns = select(2, ...)

local UpdateScale = ns.nocombated(function()
    local screenWidth = UIParent:GetWidth()
    local barScale = 1
    local barWidth = MainMenuBar:GetWidth()
    local barMargin = MAIN_MENU_BAR_MARGIN or 75
    local bagsWidth = MicroButtonAndBagsBar:GetWidth()
    local contentsWidth = barWidth + bagsWidth
    if contentsWidth > screenWidth then
        barScale = screenWidth / contentsWidth
        barWidth = barWidth * barScale
        bagsWidth = bagsWidth * barScale
        barMargin = barMargin * barScale
    end
    MainMenuBar:SetScale(barScale)
    MainMenuBar:ClearAllPoints()
    -- if there's no overlap with between action bar and bag bar while it's in the center, use center anchor
    local roomLeft = screenWidth - barWidth - barMargin * 2
    if roomLeft >= bagsWidth * 2 then
        MainMenuBar:SetPoint('BOTTOM', UIParent, 0, 0)
    else
        local xOffset = 0
        -- if both bars can fit without overlap, move the action bar to the left
        -- otherwise sacrifice the art for more room
        if roomLeft >= bagsWidth then
            xOffset = roomLeft - bagsWidth + barMargin
        else
            xOffset = math.max((roomLeft - bagsWidth) / 2 + barMargin, 0)
        end

        if ns.profile.actionbar.micro.position == 'LEFT' then
            MainMenuBar:SetPoint('BOTTOMRIGHT', UIParent, -xOffset / barScale, 0)
        else
            MainMenuBar:SetPoint('BOTTOMLEFT', UIParent, xOffset / barScale, 0)
        end
    end
end)

ns.event('DISPLAY_SIZE_CHANGED', UpdateScale)
ns.event('UI_SCALE_CHANGED', UpdateScale)
ns.config('actionbar.micro.position', UpdateScale)
ns.login(UpdateScale)
