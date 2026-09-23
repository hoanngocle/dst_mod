local M = {}
local TIMER = "ttk_llt_spirit"

function M.Clear(inst)
    if inst._ttk_skin_task ~= nil then inst._ttk_skin_task:Cancel(); inst._ttk_skin_task = nil end
    if inst.components.timer ~= nil then inst.components.timer:StopTimer(TIMER) end
    if inst._ttk_skin_spirit ~= nil and inst._ttk_skin_spirit:IsValid() then
        inst._ttk_skin_spirit:Remove()
    end
    inst._ttk_skin_spirit = nil
    if inst._ttk_skin_cosmetic ~= nil and inst._ttk_skin_cosmetic:IsValid() then
        inst._ttk_skin_cosmetic:Remove()
    end
    inst._ttk_skin_cosmetic = nil
end

local function Schedule(inst)
    if not inst.components.timer:TimerExists(TIMER) then
        inst.components.timer:StartTimer(TIMER, math.random(110, 120))
    end
end

function M.Apply(inst, skin)
    M.Clear(inst)
    if string.find(skin or "", "_skins_hyys$", 1) ~= nil then
        local fx = SpawnPrefab("ttk_skin_hyys_fx")
        if fx ~= nil then
            fx.entity:SetParent(inst.entity)
            inst._ttk_skin_cosmetic = fx
        end
        return
    end
    if skin ~= "ttk_dbg_skins_llt" then return end
    if inst.components.timer == nil then inst:AddComponent("timer") end
    if not inst._ttk_skin_listening then
        inst._ttk_skin_listening = true
        inst:ListenForEvent("timerdone", function(_, data)
            if data.name ~= TIMER or inst.AnimState:GetBuild() ~= "xd_dbg_skins_llt" then return end
            -- Nearby shelves share a window, matching the source's visual throttle.
            local x, y, z = inst.Transform:GetWorldPosition()
            for _, shelf in ipairs(TheSim:FindEntities(x, y, z, 20, {"ttk_dbg"})) do
                if shelf.AnimState:GetBuild() == "xd_dbg_skins_llt" and shelf.components.timer ~= nil then
                    shelf.components.timer:StopTimer(TIMER)
                    Schedule(shelf)
                end
            end
            Schedule(inst)
            if inst:IsAsleep() then return end
            local offset = FindWalkableOffset(inst:GetPosition(), math.random() * TWOPI, math.random(3, 5), 8, true)
            if offset == nil then return end
            local pet = SpawnPrefab("ttk_skin_spirit")
            if pet ~= nil then
                if inst._ttk_skin_spirit ~= nil and inst._ttk_skin_spirit:IsValid() then inst._ttk_skin_spirit:Remove() end
                pet.Transform:SetPosition(x + offset.x, y, z + offset.z)
                pet.components.knownlocations:RememberLocation("home", pet:GetPosition())
                inst._ttk_skin_spirit = pet
                pet:ListenForEvent("onremove", function() pet:Remove() end, inst)
            end
        end)
    end
    -- A deferred task lets the saved timer component load first.
    if inst._ttk_skin_task ~= nil then inst._ttk_skin_task:Cancel() end
    inst._ttk_skin_task = inst:DoTaskInTime(0, function()
        inst._ttk_skin_task = nil
        if inst.AnimState:GetBuild() == "xd_dbg_skins_llt" then Schedule(inst) end
    end)
end

return M
