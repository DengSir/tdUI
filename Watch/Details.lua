---@type ns
local ns = select(2, ...)


ns.addonlogin('Details', function()
    local Details = _G.Details

    Details:ReabrirTodasInstancias()

    local instance = Details:GetInstance(1)
    if not instance then
        return
    end

    ns.WatchManager:Register(instance.baseframe, 2, {     --
        header = instance.baseframe.titleBar,
        marginLeft = 5,
        marginRight = 10,
        marginBottom = 5,
        marginTop = 20,
    })

    instance:ChangeSkin("Forced Square")
    instance:LockInstance(true)
end)
