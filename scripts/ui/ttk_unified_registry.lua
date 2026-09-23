local Registry = setmetatable({}, { __mode = "k" })
local NativeRequests = setmetatable({}, { __mode = "k" })
local NativeSequences = setmetatable({}, { __mode = "k" })

local UnifiedRegistry = {}

local function GetNativeRequests(owner, create)
    if owner == nil then return nil end
    local requests = NativeRequests[owner]
    if requests == nil and create then
        requests = {}
        NativeRequests[owner] = requests
    end
    return requests
end

function UnifiedRegistry.Set(owner, screen)
    if owner ~= nil then
        Registry[owner] = screen
    end
end

function UnifiedRegistry.Get(owner)
    local screen = owner ~= nil and Registry[owner] or nil
    if screen ~= nil and screen.inst ~= nil and screen.inst.IsValid ~= nil and not screen.inst:IsValid() then
        UnifiedRegistry.CancelNative(owner, screen)
        Registry[owner] = nil
        return nil
    end
    return screen
end

function UnifiedRegistry.Clear(owner, screen)
    if owner ~= nil and (screen == nil or Registry[owner] == screen) then
        UnifiedRegistry.CancelNative(owner, screen)
        Registry[owner] = nil
    end
end

function UnifiedRegistry.BeginNative(owner, screen, prefab)
    if owner == nil or screen == nil or prefab == nil then return false end
    local requests = GetNativeRequests(owner, true)
    local unresolved = requests[prefab]
    if unresolved ~= nil then
        unresolved.queued_screen = screen
        return false, unresolved.request_id
    end
    local request_id = (NativeSequences[owner] or 0) + 1
    NativeSequences[owner] = request_id
    requests[prefab] = {
        screen = screen,
        state = "pending",
        request_id = request_id,
    }
    return true, request_id
end

function UnifiedRegistry.ResolveNative(owner, screen, prefab)
    local requests = GetNativeRequests(owner, false)
    local request = requests ~= nil and requests[prefab] or nil
    if request == nil or request.state == "pending" and request.screen ~= screen then return false end
    local queued_screen = request.queued_screen
    requests[prefab] = nil
    return true, queued_screen
end

function UnifiedRegistry.CancelNative(owner, screen)
    local requests = GetNativeRequests(owner, false)
    if requests == nil then return false end
    local cancelled = false
    for _, request in pairs(requests) do
        if request.state == "pending" and (screen == nil or request.screen == screen) then
            request.state = "cancelled"
            cancelled = true
        end
        if screen == nil or request.queued_screen == screen then request.queued_screen = nil end
    end
    return cancelled
end

function UnifiedRegistry.ConsumeCancelledNative(owner, prefab)
    local requests = GetNativeRequests(owner, false)
    local request = requests ~= nil and requests[prefab] or nil
    if request == nil then return false end
    if request.state ~= "cancelled" then return false end
    requests[prefab] = nil
    return true
end

function UnifiedRegistry.FailNative(owner, prefab, request_id)
    local requests = GetNativeRequests(owner, false)
    local request = requests ~= nil and requests[prefab] or nil
    if request == nil or request.request_id ~= request_id then return false end
    local target_screen = request.queued_screen or request.screen
    requests[prefab] = nil
    return true, target_screen
end

return UnifiedRegistry
