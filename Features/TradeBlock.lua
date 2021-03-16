-- TradeBlock.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/25/2021, 12:55:30 PM
--
---@type ns
local ns = select(2, ...)

local function IsMyFriend()
    local name = UnitName('npc')
    local realm = GetRealmName()

    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if name == info.name then
            return true
        end
    end

    for i = 1, BNGetNumFriends() do
        local client, isOnline = select(7, BNGetFriendInfo(i))
        if isOnline and client == BNET_CLIENT_WOW then
            for j = 1, BNGetNumFriendGameAccounts(i) do
                local _, characterName, client, realmName, _, faction, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
                      wowProjectID = BNGetFriendGameAccountInfo(i, j)

                if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and realmName == realm and name ==
                    characterName then
                    return true
                end
            end
        end
    end
end

ns.event('TRADE_SHOW', function()
    if GetCVarBool('blockTrades') then
        print('Blocked')
        return
    end
    local unit = 'npc'

    if UnitInRaid(unit) or UnitInParty(unit) or UnitIsInMyGuild(unit) or UnitIsUnit(unit, 'target') then
        return
    end

    local level = UnitLevel(unit)
    if level > 1 then
        return
    end

    if IsMyFriend() then
        return true
    end

    CloseTrade()
end)
