TheWorld:DoTaskInTime(3, function()
    local ok, err = pcall(function()
        local natural, workshops, old = 0, {}, 0
        for _, ent in pairs(Ents) do
            if ent:HasTag("ttk_spirit_mine") then
                if ent._ttk_crafted then old = old + 1 else natural = natural + 1 end
            end
            if ent.prefab == "ttk_spirit_workshop" then table.insert(workshops, ent) end
        end
        assert(natural == 24 and old == 0, "Natural mines changed or legacy mines not migrated")
        assert(AllRecipes.ttk_spirit_workshop, "Missing workshop recipe")
        for tier = 1, 3 do assert(AllRecipes["ttk_rock" .. tier] == nil, "Old mining recipe still exposed") end
        assert(#workshops >= 3, "Expected the three migrated workshops")
        for _, ent in ipairs(workshops) do
            assert(ent.components.workable == nil, "Workshop still uses mining")
            assert(ent:HasTag("pickable_harvest_str"))
            assert(not ent.components.pickable:CanBePicked(), "Saved cooldown lost")
            assert(ent.components.timer:GetTimeLeft("produce") > 0, "No saved production timer")
        end
        if rawget(_G, "TTK_WORKSHOP_RELOAD") then
            print("TTK_MINE_RELOAD_PASS", natural, #workshops)
            return
        end
        local placer = SpawnPrefab("ttk_spirit_workshop_placer")
        assert(placer); placer:Remove()
        local ent = workshops[#workshops]
        ent.Transform:SetPosition(22, 0, 0)
        assert(ent.AnimState:GetCurrentAnimationLength() > 0, "Compiled sprite animation missing")
        ent:PushEvent("onbuilt")
        assert(not ent.components.pickable:CanBePicked(), "Built workshop ready too early")
        assert(ent.components.timer:GetTimeLeft("produce") == 5 * TUNING.TOTAL_DAY_TIME, "Wrong initial duration")
        ent.components.timer:SetTimeLeft("produce", 1)
        ent:DoTaskInTime(2, function()
            local passed, problem = pcall(function()
                assert(ent.components.pickable:CanBePicked(), "Production did not finish")
                local success, loot = ent.components.pickable:Pick(ent)
                print("TTK_WORKSHOP_LOOT", tostring(success), loot and #loot)
                assert(success and #loot >= 22, "Too few harvest entities")
                local tiers = {}
                for _, item in ipairs(loot) do tiers[item.prefab] = (tiers[item.prefab] or 0) + 1 end
                print("TTK_WORKSHOP_TIERS", tiers.ttk_lingshi1, tiers.ttk_lingshi2, tiers.ttk_lingshi3)
                assert(tiers.ttk_lingshi1 == 20 and tiers.ttk_lingshi2 == 2, "Wrong tier yield")
                assert(tiers.cutstone == nil and tiers.boards == nil and tiers.purplegem == nil, "Harvest refunded recipe")
                assert((tiers.ttk_lingshi3 or 0) <= 1, "Too much upper-tier stone")
                assert(ent:IsValid() and not ent.components.pickable:CanBePicked())
                assert(not ent.components.pickable:Pick(ent), "Duplicate harvest")
                print("TTK_MINE_CREATE_PASS", natural, "three migrated; production, harvest and custom sprite verified")
            end)
            if not passed then print("TTK_MINE_FAIL", tostring(problem)) end
        end)
    end)
    if not ok then print("TTK_MINE_FAIL", tostring(err)) end
end)
