-- ThreatClassic2.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/1/2020, 1:03:21 PM

---@type ns
local ns = select(2, ...)

ns.addonlogin('ThreatClassic2', function()
    local UpdateFrame

    do -- remove options
        local options = LibStub('AceConfigRegistry-3.0'):GetOptionsTable('ThreatClassic2', 'dialog', 'Inject-1.0')
        local function remove(...)
            local options = options
            local n = select('#', ...)
            for i = 1, n do
                local key = select(i, ...)

                if not options.args then
                    break
                end
                if i < n then
                    options = options.args[key]
                else
                    options.args[key] = nil
                end
            end
        end

        UpdateFrame = options.args.appearance.args.reset.func
        setfenv(UpdateFrame, {self = {db = {}}})

        remove('appearance', 'frame', 'locked')
        remove('appearance', 'frame', 'strata')
        remove('appearance', 'frame', 'headerShow')
        remove('appearance', 'frame', 'framePosition')
        remove('appearance', 'frame', 'scale')
        remove('appearance', 'frame', 'frameColors')
        remove('appearance', 'bar')
        remove('appearance', 'font')
        remove('appearance', 'reset')
    end

    local db = (function()
        local AceDB = LibStub('AceDB-3.0')
        for db in pairs(AceDB.db_registry) do
            if db.sv == ThreatClassic2DB then
                return db
            end
        end
    end)()

    ---@type Frame
    local Window = ThreatClassic2BarFrame

    ns.WatchManager:Register(Window, 3, { --
        header = Window.header,
        marginLeft = 7,
        marginRight = 12,
        marginTop = 32,
        marginBottom = 5,
    })

    local function UpdateConfig()
        local C = TDDB_UI.Watch
        local OC = db.profile

        OC.frame.headerShow = true
        OC.frame.scale = 1
        OC.frame.width = C.frame.width - 21
        OC.frame.height = (C.bar.height + C.bar.spacing - 1) * 5
        OC.frame.locked = true
        OC.frame.color = {0, 0, 0, 0}
        OC.frame.position = {'TOPRIGHT'}

        OC.bar.count = 5
        OC.bar.padding = C.bar.spacing
        OC.bar.texture = C.bar.texture
        OC.bar.height = C.bar.height

        OC.font.name = C.bar.font
        OC.font.size = C.bar.fontSize
        OC.font.style = C.bar.fontFlag

        UpdateFrame()
        ns.WatchManager:Refresh()
    end

    do
        local function HookFontString(fontString)
            fontString.origSetPoint = fontString.SetPoint
            fontString.SetPoint = function(fontString, point, relativeTo, ...)
                local parent = fontString:GetParent()
                return fontString:origSetPoint(point, relativeTo == parent and parent:GetParent() or relativeTo, ...)
            end
        end

        local function SetupBar(bar)
            local backdrop = bar.backdrop

            backdrop:ClearAllPoints()
            backdrop:SetParent(bar:GetParent())
            backdrop:SetBackdrop(nil)

            bar:ClearAllPoints()
            bar:SetParent(backdrop)
            bar:SetHeight(8)
            bar:SetPoint('BOTTOMLEFT', backdrop, 'BOTTOMLEFT')
            bar:SetPoint('BOTTOMRIGHT', backdrop, 'BOTTOMRIGHT')

            HookFontString(bar.name)
            HookFontString(bar.perc)
            HookFontString(bar.val)

            bar.bg:SetVertexColor(0, 0, 0, 0.3)
            bar.bg.SetVertexColor = nop

            bar.SetSize = function(_, width, height)
                return backdrop:SetSize(width, height)
            end

            bar.SetPoint = function(_, ...)
                return backdrop:SetPoint(...)
            end
        end

        local function SetupHeader(header)
            -- ns.WatchManager:SetupHeaderFrame(Window, header)

            header:SetStatusBarTexture('')
            header:EnableMouse(false)
            header:SetScript('OnMouseUp', nil)

            header.backdrop:Hide()
            header.text:SetFont(GameFontNormal:GetFont())
            header.text:SetTextColor(1, 0.82, 0)

            header.SetStatusBarTexture = nop
            header.text.SetFont = nop
            header.text.SetVertexColor = nop
        end

        local function SetupWindow(window)
            window.resize:Hide()
            window.resize.Show = nop
        end

        SetupWindow(Window)
        SetupHeader(Window.header)

        for _, bar in ipairs{Window:GetChildren()} do
            if bar ~= Window.header and bar:GetObjectType() == 'StatusBar' then
                SetupBar(bar)
            end
        end
    end

    ns.config({'Watch', 'frame', 'width'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'height'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'spacing'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'font'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'fontSize'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'fontFlag'}, UpdateConfig)
    ns.config({'Watch', 'bar', 'texture'}, UpdateConfig)

    UpdateConfig()
end)
