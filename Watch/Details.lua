---@type ns
local ns = select(2, ...)


ns.addonlogin('Details_TWW', function()
    local Details = _G.Details

    Details:ReabrirTodasInstancias()

    local instance = Details:GetInstance(1)
    if not instance then
        return
    end

    ns.WatchManager:Register(instance.baseframe, 2, { --
        header = instance.baseframe.titleBar,
        marginLeft = 5,
        marginRight = 10,
        marginBottom = 5,
        marginTop = 40,
    })

    local function update()
        local c = math.min(instance.rows_showing, 5)
        local h = math.max(1, c * instance.row_height)
        instance.baseframe:SetHeight(h)
    end

    ns.hook(Details, 'RefreshMainWindow', function(orig, ...)
        if instance.baseframe:IsVisible() then
            orig(...)
            update()
        end
    end)

    instance.baseframe:SetWidth(260)
    instance:ChangeSkin("|cff8080ffThe War Within|r")
    instance:LockInstance(true)
end)
