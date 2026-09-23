local Registry = require("ui/ttk_unified_registry")

local UnifiedOpen = {}

function UnifiedOpen.Open(owner, tab_id, options)
    owner = owner or ThePlayer
    if owner == nil or TheFrontEnd == nil then return nil end

    local current = Registry.Get(owner)
    if current ~= nil then
        current:SelectTab(tab_id or "character")
        return current
    end

    local active = TheFrontEnd:GetActiveScreen()
    if active ~= nil and active ~= owner.HUD then return nil end

    local summary_lock = require("utils/hh_summary_lock")
    if summary_lock.IsOpen(owner) then summary_lock.Close(owner) end

    options = options or {}
    local factory = options.screen_factory or function(player, initial_tab)
        local Screen = require("screens/ttk_unified_screen")
        return Screen(player, { initial_tab = initial_tab })
    end
    local screen = factory(owner, tab_id or "character")
    if screen == nil then return nil end
    TheFrontEnd:PushScreen(screen)
    Registry.Set(owner, screen)
    return screen
end

function UnifiedOpen.Toggle(owner, tab_id, options)
    owner = owner or ThePlayer
    local current = Registry.Get(owner)
    if current ~= nil then
        current:Close()
        return nil
    end
    return UnifiedOpen.Open(owner, tab_id, options)
end

return UnifiedOpen
