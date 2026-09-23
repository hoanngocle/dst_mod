-- Run via the dedicated-server console in an isolated test world.
TheWorld:DoTaskInTime(2, function()
    local ok, err = pcall(function()
        local prizes = require("ttk_slot_prizes")
        local total, checked = 0, {}
        for _, group in pairs(prizes.groups) do
            for _, bundle in ipairs(group.bundles) do
                total = total + 1
                for _, item in ipairs(bundle.items) do
                    assert(Prefabs[item.prefab], "Missing reward: "..item.prefab)
                    if not checked[item.prefab] then
                        local entity = assert(SpawnPrefab(item.prefab), item.prefab)
                        checked[item.prefab] = entity.components.equippable ~= nil
                            and entity.components.stackable == nil and entity.components.health == nil
                        entity:Remove()
                    end
                    if checked[item.prefab] then assert(item.count == 1, "Duplicate equipment: "..item.prefab) end
                end
            end
        end
        assert(total == 104)
        local bosses = require("ttk_slot_bosses")
        local champion = assert(SpawnPrefab("alterguardian_phase3"))
        bosses.Prepare(champion, champion:GetPosition())
        assert(champion.components.ttk_slot_spawned:OnSave().add_component_if_missing)
        champion.sg.sg.states.death.events.animover.fn(champion)
        assert(not champion:IsValid(), "Summoned champion must not spawn its endgame orb")
        local recipe = assert(AllRecipes.ttk_choujiangji)
        for _, ingredient in ipairs(recipe.ingredients) do assert(Prefabs[ingredient.type], ingredient.type) end
        local placer = assert(SpawnPrefab("ttk_choujiangji_placer")); placer:Remove()
        local machine = assert(SpawnPrefab("ttk_choujiangji"))
        local sx, sy, sz = TheWorld.components.playerspawner:GetAnySpawnPoint()
        if sx ~= nil then machine.Transform:SetPosition(sx, sy, sz) end
        local trader = machine.components.trader
        for _, name in ipairs({"ttk_lingshi1", "ttk_lingshi3", "ttk_lingshi4"}) do
            local wrong = SpawnPrefab(name)
            assert(not trader:AcceptGift(nil, wrong, 1))
            assert(wrong:IsValid()); wrong:Remove()
        end
        local coin = SpawnPrefab("ttk_lingshi2")
        coin.components.stackable:SetStackSize(10)
        assert(trader:AcceptGift(nil, coin, 10))
        assert(coin.components.stackable:StackSize() == 9, "Must charge one even if count=10")
        assert(not trader:AcceptGift(nil, coin, 9), "Must lock while spinning")
        assert(coin.components.stackable:StackSize() == 9)
        assert(machine.components.ttk_slotmachine:OnSave() ~= nil)
        assert(not machine.components.workable:CanBeWorked())
        coin:Remove()
        machine:DoTaskInTime(30, function()
            local passed, message = pcall(function()
                assert(not machine.components.ttk_slotmachine.busy,
                    "Animation did not finish paying: "..machine.sg.currentstate.name.." asleep="..tostring(machine:IsAsleep()))
                assert(machine.components.workable:CanBeWorked())
                assert(machine.sg.currentstate.name == "idle")
                machine:Remove()
            end)
            print(passed and "TTK_SLOT_SMOKE_PASS" or "TTK_SLOT_SMOKE_FAIL", message or "104 bundles; real trader cost; animation and payout; boss handling")
        end)
        print("TTK_SLOT_INITIAL_PASS")
    end)
    if not ok then print("TTK_SLOT_SMOKE_FAIL", err) end
end)
