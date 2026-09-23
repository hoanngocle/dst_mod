-- Special lottery-boss handling adapted from the original Tu Tien machine.
local M = {}
function M.Prepare(inst, pos)
    if inst.components.health == nil then return end
    inst:AddComponent("ttk_slot_spawned")
    if inst.prefab == "klaus" then
        inst:SpawnDeer()
        inst.components.knownlocations:RememberLocation("spawnpoint", pos, false)
        if inst.components.spawnfader ~= nil then inst.components.spawnfader:FadeIn() end
    end
end

function M.Install(env)
    env.AddStategraphPostInit("alterguardian_phase3", function(sg)
        local death = sg.states.death
        local event = death ~= nil and death.events.animover or nil
        if event == nil then return end
        local original = event.fn
        event.fn = function(inst, ...)
            if inst.components.ttk_slot_spawned ~= nil then
                if inst.components.lootdropper ~= nil then
                    inst.components.lootdropper:SpawnLootPrefab("alterguardianhat")
                end
                inst:Remove()
                return
            end
            return original(inst, ...)
        end
    end)
    env.AddPrefabPostInit("minotaurchestspawner", function(inst)
        inst:DoTaskInTime(0, function()
            if inst.minotaur ~= nil and inst.minotaur.components.ttk_slot_spawned ~= nil then
                inst:Remove()
            end
        end)
    end)
end
return M
