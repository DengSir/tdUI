-- Guild.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 6:01:08 PM

---@type ns
local ns = select(2, ...)

local ipairs, select = ipairs, select

local GetClassColor = GetClassColor
local GetGuildRosterInfo = GetGuildRosterInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GuildControlGetNumRanks = GuildControlGetNumRanks

local FriendsFrame = FriendsFrame

local Members = ns.GetButtons('GuildFrameButton%d', GUILDMEMBERS_TO_DISPLAY, 'Name', 'Class', 'Level', 'Zone')
local Status = ns.GetButtons('GuildFrameGuildStatusButton%d', GUILDMEMBERS_TO_DISPLAY, 'Name', 'Rank')

do
    local WIDTH = 8

    for _, button in ipairs(Members) do
        button.Name:SetWidth(button.Name:GetWidth() + WIDTH)
        button.Class:SetWidth(button.Class:GetWidth() - WIDTH)
    end

    WhoFrameColumn_SetWidth(GuildFrameColumnHeader1, GuildFrameColumnHeader1:GetWidth() + WIDTH)
    WhoFrameColumn_SetWidth(GuildFrameColumnHeader4, GuildFrameColumnHeader4:GetWidth() - WIDTH)
end

local function GetRankColor(rank)
    local max = GuildControlGetNumRanks()
    local value = rank / max
    local r, g, b

    if value > 0.5 then
        r = (1 - value) * 2
        g = 1
    else
        r = 1
        g = value * 2
    end
    b = 0
    return r, g, b
end

ns.securehook('GuildStatus_Update', function()
    if FriendsFrame.playerStatusFrame then
        local myZone = GetRealZoneText()

        for _, button in ipairs(Members) do
            local level, _, zone, _, _, online, _, class = select(4, GetGuildRosterInfo(button.guildIndex))
            if online then
                local r, g, b = GetClassColor(class)

                ns.SetTextColor(button.Name, r, g, b)
                ns.SetTextColor(button.Class, r, g, b)
                ns.SetTextColor(button.Level, GetQuestDifficultyColor(level))

                if zone == myZone then
                    ns.SetTextColor(button.Zone, 0, 1, 0)
                end
            end
        end

    else
        for _, button in ipairs(Status) do
            local rankIndex, level, _, zone, _, _, online, _, class = select(3, GetGuildRosterInfo(button.guildIndex))
            if online then
                ns.SetTextColor(button.Name, GetClassColor(class))
                ns.SetTextColor(button.Rank, GetRankColor(rankIndex))
            end
        end
    end
end)
