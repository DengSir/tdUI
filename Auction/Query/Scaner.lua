-- Scaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:35:54 AM
--
---@type ns
local ns = select(2, ...)

---@class Scaner
local Scaner = ns.class()
ns.Auction.Scaner = Scaner

function Scaner:Threshold()
    if debugprofilestop() > 16 then
        debugprofilestart()
        return true
    end
end

function Scaner:Continue()
    debugprofilestart()
    return self:OnContinue()
end

function Scaner:Done()
    self:OnDone()
    self:Fire('OnDone')
end

function Scaner:Next()
end

function Scaner:OnStart()
end

function Scaner:OnResponse()
end

function Scaner:OnContinue()
end

function Scaner:OnDone()
end

function Scaner:PreQuery()
end
