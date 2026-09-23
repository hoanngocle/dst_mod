-- Run only in the disposable offline cluster created by run_ttk_solo_smoke.py.
local ok, problem = pcall(function()
    assert(TheWorld.ismastersim)
    assert(TheWorld.components.hh_world, "Solo world component missing")
    assert(TheWorld.components.dungeon_manager, "Dungeon manager missing")
    local arena = false
    for _, id in ipairs(TheWorld.topology.ids) do
        if id == "SoloLeveling:DungeonArena" then arena = true end
    end
    assert(arena, "Solo arena topology missing")
    assert(MOD_RPC.hh_rpc and CLIENT_MOD_RPC.hh_rpc, "Solo RPC missing")

    if rawget(_G, "TTK_SOLO_RELOAD") then
        local chest
        for _, ent in pairs(Ents) do
            if ent.prefab == "treasurechest" and ent.components.container then
                local item = ent.components.container:GetItemInSlot(1)
                if item and item.prefab == "hh_daogam" then chest = ent; break end
            end
        end
        assert(chest, "Saved chest missing")
        local solo = chest.components.container:GetItemInSlot(1)
        local ttk = chest.components.container:GetItemInSlot(2)
        assert(solo and solo.prefab == "hh_daogam", "Solo item did not reload")
        assert(solo.components.wb_strengthen.level == 3, "Solo strengthen level lost")
        assert(ttk and ttk.prefab == "ttk_lingshi1" and ttk.components.stackable:StackSize() == 7,
            "TuTienKy item state lost")
        print("TTK_SOLO_RELOAD_PASS")
        return
    end

    local portal = TheSim:FindFirstEntityWithTag("multiplayer_portal")
    local x, y, z = portal.Transform:GetWorldPosition()
    local chest = assert(SpawnPrefab("treasurechest"))
    chest.Transform:SetPosition(x + 6, y, z)
    if not chest.components.named then chest:AddComponent("named") end
    chest.components.named:SetName("TTK_SOLO_PERSISTENCE")
    local sword = assert(SpawnPrefab("hh_daogam"))
    assert(sword.components.wb_strengthen, "Solo weapon enhancement missing")
    sword.components.wb_strengthen:SetLevel(3)
    chest.components.container:GiveItem(sword, 1)
    local stone = assert(SpawnPrefab("ttk_lingshi1"))
    stone.components.stackable:SetStackSize(7)
    chest.components.container:GiveItem(stone, 2)
    for _, name in ipairs({"hh_lo_ren", "hh_hac_nguyet_ho", "hh_daogam2", "ttk_lucnguyenkiemdong", "ttk_hhlmz"}) do
        local ent = assert(SpawnPrefab(name), name)
        ent:Remove()
    end

    local player = assert(SpawnPrefab("wilson"))
    player.Transform:SetPosition(x, y, z)
    for _, name in ipairs({"hh_player", "hh_leveling", "hh_mana", "hh_shadow_manager", "hh_daily_quest"}) do
        assert(player.components[name], "Player component missing: " .. name)
    end
    assert(player.components.inventory.maxslots == 45, "TuTienKy inventory was replaced")
    player.components.hh_leveling.level = 7
    player.components.hh_leveling.exp = 23
    local saved = player:GetSaveRecord()
    player:Remove()
    local restored = assert(SpawnSaveRecord(saved))
    assert(restored.components.hh_leveling.level == 7 and restored.components.hh_leveling.exp == 23,
        "Player Solo progression lost in save-record roundtrip")
    restored:Remove()
    print("TTK_SOLO_CREATE_PASS")
end)
if not ok then print("TTK_SOLO_FAIL", tostring(problem)) end
