-- BoomTime.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/14/2021, 6:16:05 PM
--
---@type ns
local ns = select(2, ...)

local INSTANCE_RESET_FAILED_P = gsub(INSTANCE_RESET_FAILED, '%%s', '(.+)')
local INSTANCE_RESET_SUCCESS_P = gsub(INSTANCE_RESET_SUCCESS, '%%s', '(.+)')

local MACRO_NAME = '_BoomTime'
local MACRO_ICON = 132319

local BOOM_TIMES_PRE_DAY = 30
local BOOM_TIMES_PRE_HOUR = 5

local BoomTime = {}

function BoomTime:OnLoad()
    self:Read()
    self:Clean(true)

    ns.event('CHAT_MSG_SYSTEM', function(msg)
        if msg:find(INSTANCE_RESET_FAILED_P) or msg:find(INSTANCE_RESET_SUCCESS_P) then
            self:OnReset()
        elseif msg == RESET_FAILED_NOTIFY then
            self.resetAtOutInstance = true
        end
    end)

    ns.event('ZONE_CHANGED_NEW_AREA', function()
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == 'party' or instanceType == 'raid') then
            if self.resetAtOutInstance then
                self.resetAtOutInstance = nil
                self:OnReset()
            end
        end
    end)
end

function BoomTime:Save()
    print('Save')
    local sb = {}
    for i = 1, BOOM_TIMES_PRE_DAY do
        if self.times[i] then
            if i == 1 then
                sb[i] = self.times[i]
            else
                sb[i] = self.times[i] - self.times[i - 1]
            end
        end
    end

    local body = table.concat(sb, ',')
    local index = GetMacroIndexByName(MACRO_NAME)
    if GetMacroBody(index) == body then
        return
    end
    if not index or index == 0 then
        CreateMacro(MACRO_NAME, MACRO_ICON, body, true)
    else
        EditMacro(index, MACRO_NAME, MACRO_ICON, body)
    end
end

BoomTime.Save = ns.nocombated(BoomTime.Save)

function BoomTime:Read()
    local times = {}
    local timesMap = {}

    local function FillMap(times)
        if not times then
            return
        end
        for i, v in ipairs(times) do
            timesMap[v] = true
        end
    end

    local index = GetMacroIndexByName(MACRO_NAME)
    if index and index ~= 0 then
        local body = GetMacroBody(index)
        if body then
            local macroTimes = {}
            for i, v in ipairs({strsplit(',', body)}) do
                if i == 1 then
                    macroTimes[i] = tonumber(v)
                else
                    macroTimes[i] = macroTimes[i - 1] + tonumber(v)
                end
            end

            FillMap(macroTimes)
        end
    end

    FillMap(TDDB_UI_BOOMTIME)

    for time in pairs(timesMap) do
        tinsert(times, time)
    end
    sort(times)

    TDDB_UI_BOOMTIME = times

    self.times = times
end

function BoomTime:CheckTimer()
    if next(self.times) then
        if not self.timer then
            self.timer = ns.timer(1, function()
                return self:Clean()
            end)
        end
    else
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
    end
end

function BoomTime:OnReset()
    tinsert(self.times, time() + 86400)
    self.changed = true
    self:CheckTimer()
end

function BoomTime:Clean(force)
    local now = time()
    for i = #self.times, 1, -1 do
        if self.times[i] < now then
            tremove(self.times, i)
            self.changed = true
        end
    end

    if force or self.changed then
        self.changed = nil
        self:Save()
        self:UpdateView()
        self:CheckTimer()
    end
end

function BoomTime:UpdateView()
    self.view = {}

    for v in self:Iterate() do
        tinsert(self.view, v)
    end
end

function BoomTime:Iterate()
    return coroutine.wrap(function()
        local group = {}
        local fiveLockCount = 0
        local fiveLockLast

        for i = 1, BOOM_TIMES_PRE_DAY do
            local t = self.times[i]
            if t then
                if not next(group) or (t - group[#group].time < 18 * 60 and t - group[1].time < 60 * 60) then
                    tinsert(group, {index = i, time = t})
                else
                    coroutine.yield(group)
                    group = {}

                    tinsert(group, {index = i, time = t})
                end
            else
                if next(group) and group[1].time then
                    coroutine.yield(group)
                    group = {}
                end
                tinsert(group, {index = i})
            end
        end

        if next(group) then
            coroutine.yield(group)
        end
    end)
end

--- UI

local UI = CreateFrame('Frame', nil, UIParent)

function UI:OnLoad()
    self.lines = {}

    local WIDTH = 200

    UI:SetSize(WIDTH, 30)
    UI:SetPoint('CENTER')

    local Button = CreateFrame('Button', nil, UI)

    local TitleFold = Button:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    TitleFold:SetPoint('RIGHT', Button, 'LEFT', -5, 0)
    TitleFold:SetText('爆本计时')

    local Body = CreateFrame('Frame', nil, UI)
    Body:SetPoint('TOPLEFT', 0, -30)
    Body:SetPoint('TOPRIGHT', 0, -30)
    Body:Hide()

    local Header = CreateFrame('Frame', nil, Body)
    Header:SetPoint('TOPLEFT', UI)
    Header:SetSize(WIDTH, 30)

    local Title = Header:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    Title:SetPoint('LEFT')
    Title:SetText('爆本计时')

    Button:SetScript('OnClick', function()
        Body:SetShown(not Body:IsShown())
    end)

    local function Layout()
        return self:Layout()
    end

    Body:SetScript('OnShow', Layout)
    Body:SetScript('OnHide', Layout)
    Body:SetScript('OnSizeChanged', ns.spawned(Layout))

    Body:SetScript('OnUpdate', function(f, elasped)
        f.timer = (f.timer or 0) - elasped
        if f.timer < 0 then
            f.timer = 1
            self:Update()
        end
    end)

    self.Body = Body
    self.Header = Header
    self.Button = Button
    self.TitleFold = TitleFold
end

function UI:GetLine(i)
    if not self.lines[i] then
        local line = CreateFrame('Frame', nil, self.Body)
        if i == 1 then
            line:SetPoint('TOPLEFT', self.Body, 'TOPLEFT')
            line:SetPoint('TOPRIGHT', self.Body, 'TOPRIGHT')
        else
            line:SetPoint('TOPLEFT', self:GetLine(i - 1), 'BOTTOMLEFT')
            line:SetPoint('TOPRIGHT', self:GetLine(i - 1), 'BOTTOMRIGHT')
        end

        local textLeft = line:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        textLeft:SetPoint('TOPLEFT')
        textLeft:SetText('重置倒计时' .. i)

        local textRight = line:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        textRight:SetPoint('TOPRIGHT')

        line:SetHeight(textLeft:GetStringHeight())

        line.textLeft = textLeft
        line.textRight = textRight

        if i % 2 == 0 then
            local bg = line:CreateTexture(nil, 'BACKGROUND')
            bg:SetAllPoints(true)
            bg:SetColorTexture(1, 1, 1, 0.1)
        end

        self.lines[i] = line
    end
    return self.lines[i]
end

function UI:Update()
    local now = time()
    local fiveLockCount = 0
    local fiveLockFirst
    local totalHeight = 0

    local function t2s(s)
        local hour = floor(s / 3600)
        s = s - hour * 3600
        local minute = floor(s / 60)
        s = s - minute * 60
        local second = s

        if hour == 0 then
            return format('%02d:%02d', minute, second)
        end

        return format('%02d:%02d:%02d', hour, minute, second)
    end

    for i, node in ipairs(BoomTime.view) do
        local line = self:GetLine(i)

        for i, v in ipairs(node) do
            if fiveLockCount < 5 and v.time and v.time - now > 23 * 3600 then
                fiveLockCount = fiveLockCount + 1

                if not fiveLockFirst then
                    fiveLockFirst = v.time - 23 * 3600
                end
            end
        end

        if #node == 1 then
            line.textLeft:SetFormattedText('倒计时 |cffffffff%d|r', node[1].index)
        else
            line.textLeft:SetFormattedText('倒计时 |cffffffff%d-%d|r |cff00ffff(%d)|r', node[1].index,
                                           node[#node].index, #node)
        end

        if node[1].time then
            if #node == 1 then
                line.textRight:SetFormattedText('|cffff0000%s|r', t2s(node[1].time - now))
            else
                line.textRight:SetFormattedText('|cffff0000%s|r |cffffffff(+%s)|r', t2s(node[1].time - now),
                                                t2s(node[#node].time - node[1].time))
            end
        elseif fiveLockCount >= 5 then
            line.textRight:SetFormattedText('|cffffd100%s|r', t2s(fiveLockFirst - now))
        else
            line.textRight:SetFormattedText('|cff00ff00可用|r')
        end

        local height = max(line.textLeft:GetStringHeight(), line.textRight:GetStringHeight())
        line:SetHeight(height)
        line:Show()
        totalHeight = totalHeight + height
    end

    for i = #BoomTime.view + 1, BOOM_TIMES_PRE_DAY do
        if self.lines[i] then
            self.lines[i]:Hide()
        end
    end

    -- for i = 1, BOOM_TIMES_PRE_DAY do
    --     local line = self:GetLine(i)
    --     local label = line.textRight

    --     if BoomTime.times[i] then
    --         if BoomTime.times[i] - now > 23 * 3600 then
    --             fiveLockCount = fiveLockCount + 1

    --             if not fiveLockFirst then
    --                 fiveLockFirst = BoomTime.times[i] - 23 * 3600
    --             end
    --         end

    --         label:SetText(date('|cffff0000%H:%M:%S|r', BoomTime.times[i] - now + 57600 - 24))

    --     elseif fiveLockCount >= BOOM_TIMES_PRE_HOUR then
    --         label:SetText(date('|cffffd100%H:%M:%S|r', fiveLockFirst - now + 57600 - 24));
    --     else
    --         label:SetText('|cff00ff00可用|r');
    --     end

    --     local height = max(line.textLeft:GetStringHeight(), line.textRight:GetStringHeight())
    --     line:SetHeight(height)

    --     totalHeight = totalHeight + height
    -- end

    self.Body:SetHeight(totalHeight)
end

function UI:Layout()
    local height = 30

    if self.Body:IsShown() then
        height = height + self.Body:GetHeight()

        self.TitleFold:Hide()
        self.Button:Unfold()
    else
        self.TitleFold:Show()
        self.Button:Fold()
    end

    self:SetHeight(height)
end

ns.login(function()
    BoomTime:OnLoad()
    UI:OnLoad()

    ns.WatchManager:Register(UI, 4, { --
        minimizeButton = UI.Button,
        header = UI.Header,
        marginLeft = 0,
        marginRight = 20,
    })

    local C = ns.profile.watch

    local function UpdateWidth()
        UI:SetWidth(C.frame.width - 20)
    end

    ns.config('watch.frame.width', UpdateWidth)
    UpdateWidth()
end)
