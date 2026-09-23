-- Runs only in the disposable offline cluster created by
-- tools/run_phamnhan_boss_smoke.py. The test is intentionally server-only.
local phase = rawget(_G, "PHAM_NHAN_BOSS_SMOKE_PHASE") or "create"
local defs = require("ttk_boss_defs")

local function Trace(problem)
    return debug ~= nil and debug.traceback ~= nil and debug.traceback(problem, 2) or tostring(problem)
end

local failed = false
local function Fail(problem)
    if failed then return end
    failed = true
    print("PHAM_NHAN_BOSS_FAIL", phase, tostring(problem))
end

local function Check(condition, problem)
    if not condition then error(problem, 2) end
    return condition
end

local function CountPrefab(name)
    local count = 0
    for _, ent in pairs(Ents) do
        if ent.prefab == name and ent:IsValid() then count = count + 1 end
    end
    return count
end

local function FindPrefab(name)
    for _, ent in pairs(Ents) do
        if ent.prefab == name and ent:IsValid() then return ent end
    end
end

local function CountBlueprint(recipe)
    local count=0
    for _,ent in pairs(Ents) do
        if ent:IsValid() and ent.components.teacher and ent.components.teacher.recipe==recipe then count=count+1 end
    end
    return count
end

local function CountMain(key)
    local count = 0
    for _, ent in pairs(Ents) do
        if ent:IsValid() and ent._ttk_boss_main and not ent._ttk_boss_auxiliary
            and ent._ttk_boss_key == key and ent.components.health ~= nil
            and not ent.components.health:IsDead() then
            count = count + 1
        end
    end
    return count
end

local queue = {}
local cursor = 0
local function AddStep(delay, fn)
    queue[#queue + 1] = {delay = delay or 0, fn = fn}
end

local function RunNext()
    if failed then return end
    cursor = cursor + 1
    local row = queue[cursor]
    if row == nil then return end
    TheWorld:DoTaskInTime(row.delay, function()
        local ok, problem = xpcall(row.fn, Trace)
        if not ok then Fail(problem) else RunNext() end
    end)
end

local function SpawnPlayer(x, z)
    local player = Check(SpawnPrefab("wilson"), "could not spawn audit player")
    player.Transform:SetPosition(x, 0, z)
    Check(player.components.health ~= nil, "audit player health missing")
    player.components.health:SetInvincible(true)
    return player
end

local function AssertProgressRoundTrip(x, z)
    local player = SpawnPlayer(x, z)
    local progress = Check(player.components.ttk_bossprogress, "ttk_bossprogress missing from player")
    local base_health = player.components.health.maxhealth
    local base_hunger = player.components.hunger.max
    local base_sanity = player.components.sanity.max
    local base_mana = Check(player.components.hh_mana, "hh_mana missing from player"):GetMax()

    for _, key in ipairs(defs.order) do
        local def = defs.bosses[key]
        if def.food ~= nil then
            local food = Check(SpawnPrefab(def.food), "food prefab missing: " .. def.food)
            Check(food.components.edible ~= nil, "food is not edible: " .. def.food)
            Check(food.components.edible.healthvalue == 50, "wrong health restore: " .. def.food)
            Check(food.components.edible.hungervalue == 75, "wrong hunger restore: " .. def.food)
            Check(food.components.edible.sanityvalue == 50, "wrong sanity restore: " .. def.food)
            food:Remove()

            for index = 1, (defs.limit or 10) + 1 do
                local accepted, count = progress:Absorb(key)
                Check(accepted == (index <= (defs.limit or 10)), "wrong cap result: " .. key)
                Check(count == math.min(index, defs.limit or 10), "wrong food count: " .. key)
            end
            Check(progress:GetCount(key) == 10, "food count did not clamp: " .. key)
            local netvar = Check(player["ttk_bossprogress_" .. key], "food netvar missing: " .. key)
            Check(netvar:value() == 10, "food netvar cannot represent count 10: " .. key)
            Check(progress:GetEffectBonus(def.effect) == (def.effect_value or 1),
                "perk did not unlock exactly once: " .. key)
        end
    end

    Check(progress:GetEffectBonus("trueDamageNum") == 40, "40% armor-pierce bonus mismatch")
    Check(progress:GetEffectBonus("reduceAttackedDamage") == 0, "removed flat defense survived")
    Check(progress:GetEffectBonus("absorbDamage") == 20, "20% reduction pool bonus mismatch")
    local combat = Check(player.components.hh_player, "hh_player missing for percentage assertion")
    local target = Check(SpawnPrefab("hound"), "armor-pierce target missing")
    local function NoProc() return 100 end
    local _, pierce, metadata = combat:ResolvePrimaryHit(target, 200, nil, NoProc)
    Check(pierce == metadata.pierce_base * .4, "boss food Xuyen is not percentage of isolated base")
    combat:AddEffectValueByKey("trueDamageNum", 30)
    local _, capped, capped_metadata = combat:ResolvePrimaryHit(target, 200, nil, NoProc)
    Check(capped == capped_metadata.pierce_base * .4, "boss food plus equipment exceeded 40% Xuyen cap")
    combat:ReduceEffectValueByKey("trueDamageNum", 30)
    target:Remove()
    Check(player.components.health.maxhealth == base_health + 200, "health max recalculation mismatch")
    Check(player.components.hunger.max == base_hunger + 200, "hunger max recalculation mismatch")
    Check(player.components.sanity.max == base_sanity + 200, "sanity max recalculation mismatch")
    Check(player.components.hh_mana:GetMax() == base_mana + 200, "mana max recalculation mismatch")

    player.components.health:SetCurrentHealth(player.components.health.maxhealth)
    player.components.hunger:SetPercent(1)
    player.components.sanity:SetPercent(1)
    player.components.hh_mana.current = player.components.hh_mana:GetMax()
    player.components.hh_mana:Sync()

    local record = player:GetSaveRecord()
    player:Remove()
    local restored = Check(SpawnSaveRecord(record), "boss progress save-record restore failed")
    local loaded = Check(restored.components.ttk_bossprogress, "restored progress component missing")
    for _, key in ipairs(defs.order) do
        if defs.bosses[key].food ~= nil then
            Check(loaded:GetCount(key) == 10, "food count lost on save-record roundtrip: " .. key)
        end
    end
    return restored, base_health, base_mana
end

local function AssertSupportPrefabs(x, z)
    local names = {}
    for name in pairs(Prefabs) do
        if string.sub(name, 1, 9) == "ttk_boss_" then names[#names + 1] = name end
    end
    table.sort(names)
    Check(#names >= 20, "too few registered transitive boss prefabs: " .. tostring(#names))
    for index, name in ipairs(names) do
        print("PHAM_NHAN_BOSS_SUPPORT_TRY", name)
        local ent = Check(SpawnPrefab(name), "support prefab failed to spawn: " .. name)
        if ent:IsValid() and ent.Transform ~= nil then
            ent.Transform:SetPosition(x + 100 + index % 10, 0, z + 100 + math.floor(index / 10))
        end
        if ent:IsValid() then ent:Remove() end
    end
    print("PHAM_NHAN_BOSS_SUPPORT_PREFABS", #names)
end

local function GetRegistry()
    return Check(TheWorld.components.ttk_bossregistry, "world ttk_bossregistry missing")
end

local function PositionMainBosses(registry, x, z)
    local bosses = {}
    for index, key in ipairs(defs.order) do
        local row = Check(registry.entries[key], "registry entry missing: " .. key)
        local boss = row.entity
        Check(row.status == "alive" and boss ~= nil and boss:IsValid()
            and not boss.components.health:IsDead(), "boss not naturally seeded: "..key.." ("..row.status..")")
        -- Fight at the natural, spaced spawn sites; moving nine bosses together
        -- near the portal would trigger home leashes and invalidate summoning.
        print("PHAM_NHAN_BOSS_NATURAL", key)
        Check(boss.prefab == defs.bosses[key].prefab, "wrong main prefab: " .. key)
        Check(boss._ttk_boss_main and boss._ttk_boss_key == key, "main marker missing: " .. key)
        Check(not boss._ttk_boss_auxiliary, "main marked auxiliary: " .. key)
        Check(boss.components.health ~= nil, "boss health missing: " .. key)
        Check(boss.components.combat ~= nil, "boss combat missing: " .. key)
        Check(boss.components.locomotor ~= nil, "boss locomotor missing: " .. key)
        local original_health = boss.components.health.currenthealth
        boss.components.health:SetCurrentHealth(math.max(1, boss.components.health.maxhealth * 0.99))
        local save_record = boss:GetSaveRecord()
        Check(save_record.data ~= nil and save_record.data.health ~= nil
            and save_record.data.health.health ~= nil, "boss current health is not saved: " .. key)
        boss.components.health:SetCurrentHealth(original_health)
        Check(CountMain(key) == 1, "duplicate main boss after initial seed: " .. key)
        bosses[key] = boss
    end
    return bosses
end

local function BeginCombat(key, boss, player)
    print("PHAM_NHAN_BOSS_COMBAT", key)
    local def = defs.bosses[key]
    if def.unique then
        Check(boss.components.combat.target ~= player, "neutral boss targeted an approaching player: " .. key)
        boss.components.combat:GetAttacked(player, 1)
    else
        boss.components.combat:SetTarget(player)
    end
    boss:PushEvent("doattack", {target = player})
    if key == "baihu" then
        boss.sg:GoToState("skill_taunt")
    elseif key == "jfsn" then
        boss:PushEvent("spell", {target = player})
    elseif key == "qlch" then
        boss:PushEvent("spell1", {target = player})
    elseif key == "futu" then
        boss.sg:GoToState("skill1")
    elseif key == "spiderqueen" then
        boss.sg:GoToState("skill1")
    elseif key == "stalke_fuben" then
        boss:PushEvent("spell", {targets = {player}})
    end
end

local function KillBoss(key, boss)
    print("PHAM_NHAN_BOSS_KILL", key)
    local def = defs.bosses[key]
    local before_food = def.food ~= nil and CountPrefab(def.food) or 0
    local before_summon = def.summon ~= nil and CountPrefab(def.summon) or 0
    boss.components.health:SetInvincible(false)
    boss.components.health:Kill()
    return before_food, before_summon
end

local function BuildCreateQueue()
    local state = {}
    AddStep(6, function()
        Check(TheWorld.ismastersim, "boss smoke requires the master simulation")
        local portal = Check(TheSim:FindFirstEntityWithTag("multiplayer_portal"), "portal missing")
        local x, y, z = portal.Transform:GetWorldPosition()
        state.x, state.z = x, z
        state.registry = GetRegistry()
        Check(state.registry.ready, "registry did not finish load reconciliation")
        AssertSupportPrefabs(state.x, state.z)
        state.restored, state.base_health, state.base_mana = AssertProgressRoundTrip(state.x + 3, state.z + 3)
        local bag = Check(SpawnPrefab("ttk_boss_back_xh"), "Tien Ha backpack missing")
        bag.Transform:SetPosition(state.x + 5, 0, state.z + 5)
        Check(bag.components.container:GetNumSlots() == 18, "Tien Ha does not have 18 slots")
        Check(bag.components.stackable == nil, "Tien Ha bags must not stack")
        Check(bag.components.equippable.equipslot == EQUIPSLOTS.BACK, "Tien Ha uses wrong equip slot")
        Check(not bag.components.inventoryitem.cangoincontainer, "Tien Ha may be nested in containers")
        local wearer = SpawnPlayer(state.x + 5, state.z + 5)
        Check(wearer.components.inventory:Equip(bag), "Tien Ha could not be equipped")
        Check(wearer.components.inventory:GetOverflowContainer() == bag.components.container,
            "Tien Ha not registered as inventory overflow")
        for slot=1,18 do
            Check(bag.components.container:GiveItem(SpawnPrefab("twigs"),slot), "Tien Ha slot unavailable: "..slot)
        end
        local record = bag:GetSaveRecord()
        wearer.components.inventory:Unequip(EQUIPSLOTS.BACK)
        bag:Remove();wearer:Remove()
        local restored = Check(SpawnSaveRecord(record), "Tien Ha save failed to load")
        for slot=1,18 do
            local item = restored.components.container:GetItemInSlot(slot)
            Check(item and item.prefab == "twigs", "Tien Ha lost saved slot: "..slot)
        end
        restored:Remove()
        state.legacy_bag = SpawnPrefab("ttk_boss_back_xh")
        state.legacy_bag.Transform:SetPosition(state.x + 5, 0, state.z + 5)
        state.bags_before_split = CountPrefab("ttk_boss_back_xh")
        state.legacy_bag:SetPersistData({stackable={stack=3}})
        for _,colour in ipairs({"green","purple"}) do
            local seed = SpawnPrefab("ttk_boss_zcyseed")
            Check(seed.components.edible.healthvalue==5 and seed.components.edible.hungervalue==12
                and seed.components.edible.sanityvalue==2,"tree seed edible values incorrect")
            seed.components.stackable:SetStackSize(2)
            local original_random=math.random
            math.random=function(...) if select('#',...)==0 then return colour=="green" and .25 or .75 end;return original_random(...) end
            local ok,problem=pcall(seed.components.deployable.ondeploy,seed,Vector3(state.x+8,0,state.z+8),nil)
            math.random=original_random
            Check(ok,"seed deployment failed: "..tostring(problem))
            Check(seed.components.stackable:StackSize()==1,"planting did not consume exactly one seed")
            seed:Remove()
            local sapling=Check(FindPrefab("ttk_zuichunyan_"..colour.."_sapling"),"planted sapling missing")
            Check(sapling.components.timer:GetTimeLeft("grow")>950,"source sapling timer incorrect")
            local record=sapling:GetSaveRecord();sapling:Remove()
            sapling=Check(SpawnSaveRecord(record),"sapling save/load failed")
            Check(sapling.components.timer:TimerExists("grow"),"sapling growth timer lost on load")
            sapling:PushEvent("timerdone",{name="grow"})
            local tree=Check(FindPrefab("ttk_zuichunyan_"..colour),"sapling did not grow into tree")
            Check(tree.components.growable.stage==1,"sapling skipped small tree")
            tree.components.growable:SetStage(2)
            record=tree:GetSaveRecord();tree:Remove()
            tree=Check(SpawnSaveRecord(record),"tree save/load failed")
            Check(tree.components.growable.stage==2,"mature tree stage lost on load")
            local before_seed,before_log=CountPrefab("ttk_boss_zcyseed"),CountPrefab("log")
            tree.components.workable:Destroy(state.restored)
            Check(CountPrefab("ttk_boss_zcyseed")==before_seed+2,"mature tree did not drop two seeds")
            Check(CountPrefab("log")==before_log+3,"mature tree did not drop three logs")
            Check(tree:HasTag("stump"),"chopped tree did not leave stump")
            tree.components.workable:Destroy(state.restored)
            Check(CountPrefab("log")==before_log+4,"digging stump did not give one log")
        end
        print("PHAM_NHAN_SEED_TREE_PASS","plant both colours, save/load, grow, chop and dig")
        for _,recipe in ipairs({"ttk_zcmj","ttk_xshj"}) do
            local blueprint=Check(SpawnPrefab(recipe.."_blueprint"),"armor blueprint missing: "..recipe)
            Check(blueprint.components.teacher.recipe==recipe,"blueprint teaches wrong armor")
            local record=blueprint:GetSaveRecord();blueprint:Remove()
            blueprint=Check(SpawnSaveRecord(record),"blueprint save/load failed")
            Check(blueprint.components.teacher.recipe==recipe,"blueprint forgot recipe on load")
            local learner=SpawnPlayer(state.x+10,state.z+10)
            Check(not learner.components.builder:KnowsRecipe(recipe,true),"new player already knows boss armor")
            Check(blueprint.components.teacher:Teach(learner),"blueprint could not be learned")
            Check(learner.components.builder:KnowsRecipe(recipe,true),"blueprint did not unlock armor")
            record=learner:GetSaveRecord();learner:Remove()
            learner=Check(SpawnSaveRecord(record),"learned player save/load failed")
            Check(learner.components.builder:KnowsRecipe(recipe,true),"learned armor lost on save/load")
            learner:Remove()
        end
        print("PHAM_NHAN_BLUEPRINT_LEARN_PASS","both armor recipes locked, teachable and persistent")
    end)
    AddStep(0.2, function()
        Check(CountPrefab("ttk_boss_back_xh") == state.bags_before_split + 2,
            "legacy Tien Ha stack did not preserve three bags")
        print("PHAM_NHAN_BACKPACK_PASS", "18 slots, equip/overflow, save/load, legacy stack")
        Check(state.restored:IsValid(), "restored progress player disappeared")
        Check(state.restored.components.health.maxhealth == state.base_health + 200,
            "restored health max inflated")
        Check(state.restored.components.hh_mana:GetMax() == state.base_mana + 200,
            "restored mana max inflated")
        Check(state.restored.components.health.currenthealth == state.restored.components.health.maxhealth,
            "full health was clamped to the pre-food maximum on load")
        -- Native hunger/sanity updates can tick during the 0.2s deferred load.
        -- Permit less than one point of normal drain, not the 200-point cap loss.
        Check(math.abs(state.restored.components.hunger.current - state.restored.components.hunger.max) < 1,
            "loaded hunger mismatch: "..state.restored.components.hunger.current.."/"..state.restored.components.hunger.max)
        Check(math.abs(state.restored.components.sanity.current - state.restored.components.sanity.max) < 1,
            "loaded sanity mismatch: "..state.restored.components.sanity.current.."/"..state.restored.components.sanity.max)
        Check(state.restored.components.hh_mana.current == state.restored.components.hh_mana:GetMax(),
            "full mana was clamped to the pre-food maximum on load")
        state.restored:Remove()
        state.player = SpawnPlayer(state.x, state.z)
        state.bosses = PositionMainBosses(state.registry, state.x, state.z)

        local auxiliary = Check(SpawnPrefab("ttk_boss_deerclops_ziyun_aux"),
            "standalone deerclops auxiliary prefab missing")
        Check(auxiliary._ttk_boss_auxiliary, "deerclops helper lacks auxiliary marker")
        Check(not state.registry:Register("deerclops_ziyun", auxiliary),
            "auxiliary helper occupied a main registry slot")
        auxiliary:Remove()
    end)

    for _, key in ipairs(defs.order) do
        local current = key
        AddStep(0.2, function()
            local boss = Check(state.bosses[current], "boss disappeared before combat: " .. current)
            state.player.Transform:SetPosition(boss.Transform:GetWorldPosition())
            BeginCombat(current, boss, state.player)
        end)
        AddStep(3, function()
            local boss = Check(state.bosses[current], "boss disappeared while AI was ticking: " .. current)
            Check(boss:IsValid() and not boss.components.health:IsDead(), "boss died during AI tick: " .. current)
            if defs.bosses[current].unique then
                Check(boss.components.combat.target == state.player,
                    "neutral boss did not retaliate after attack: " .. current)
            end
            if current == "ziyunboss" then
                state.ziyun_l4_before = CountPrefab("ttk_lingshi4")
                boss.components.health:SetInvincible(false)
                boss.components.health:Kill()
            else
                if current=="qxdx" then
                    state.seed_before={}
                    for _,name in ipairs({"ttk_boss_zcyseed","ttk_lc_hsc_seed","ttk_lc_dms_seed","ttk_lc_qfx_seed","ttk_lc_cyh_seed","ttk_lc_lmg_seed","ttk_lc_yhh_seed"}) do
                        state.seed_before[name]=CountPrefab(name)
                    end
                end
                state["before_food_" .. current], state["before_summon_" .. current] = KillBoss(current, boss)
            end
        end)
        if current == "ziyunboss" then
            AddStep(5, function()
                local boss = state.bosses.ziyunboss
                Check(boss:IsValid() and boss.mode == 2, "Ziyun did not enter mode 2")
                Check(boss.mode2_pet ~= nil and boss.mode2_pet:IsValid(), "Ziyun mode-2 deer helper missing")
                Check(boss.mode2_pet._ttk_boss_auxiliary, "Ziyun mode-2 deer is not auxiliary")
                Check(state.registry.entries.ziyunboss.status == "alive",
                    "Ziyun phase transition incorrectly completed registry death")
                Check(CountPrefab("ttk_lingshi4") == state.ziyun_l4_before,
                    "Ziyun phase transition paid the unique reward early")
                Check(CountBlueprint("ttk_zcmj")==0,"Ziyun phase transition dropped armor blueprint early")
            end)
        else
            AddStep(5, function()
                local row = state.registry.entries[current]
                Check(row.status == "dead", "registry did not record final death: " .. current)
                local def = defs.bosses[current]
                if current=="futu" then
                    Check(CountBlueprint("ttk_xshj")==1,"Futu did not drop exactly one armor blueprint")
                    print("PHAM_NHAN_FUTU_BLUEPRINT_PASS")
                end
                if current=="qxdx" then
                    for name,before in pairs(state.seed_before) do
                        Check(CountPrefab(name)-before==(name=="ttk_boss_zcyseed" and 2 or 3),"fixed seed loot incorrect: "..name)
                    end
                    for _,suffix in ipairs({"cyfxd","lmsqd","dmhsd","qxdhd","yfsxd","pshsd","qjqsd","xynyd","hsphd","xttyd"}) do
                        Check(CountPrefab("ttk_boss_dy_"..suffix.."_5")==0,"retired random pill still drops")
                    end
                    print("PHAM_NHAN_FIXED_SEEDS_PASS","two tree seeds, three of each of six herb seeds, no random pills")
                end
                local retired = {baihu="ttk_boss_baihu_skin",jfsn="ttk_boss_fs",qlch="ttk_boss_qlr"}
                if retired[current] then
                    Check(CountPrefab(retired[current]) == 0,
                        "retired collectible still dropped: " .. current)
                end
                if def.food ~= nil then
                    Check(CountPrefab(def.food) - state["before_food_" .. current] == 1,
                        "final death did not drop exactly one food: " .. current)
                    Check(CountPrefab(def.summon) - state["before_summon_" .. current] == 1,
                        "final death did not drop exactly one summon: " .. current)
                end
            end)
            if current == "baihu" then
                AddStep(0.2, function()
                    local def = defs.bosses.baihu
                    local token = Check(FindPrefab(def.summon), "dropped Baihu summon token missing")
                    Check(state.player.components.inventory:GiveItem(token) ~= nil,
                        "could not put summon token in player inventory")
                    local ok, problem = state.registry:TrySummon("baihu", state.player, token)
                    Check(ok, "real summon transaction failed: " .. tostring(problem))
                    Check(not token:IsValid(), "successful summon did not consume exactly one token")
                    local summoned = state.registry.entries.baihu.entity
                    Check(summoned ~= nil and summoned:IsValid(), "summoned Baihu missing from registry")
                    state.bosses.baihu = summoned
                    summoned.components.combat:SetTarget(state.player)
                    summoned.components.health:SetInvincible(false)
                    summoned.components.health:Kill()
                end)
                AddStep(5, function()
                    Check(state.registry.entries.baihu.status == "dead",
                        "summoned Baihu final death was not recorded")
                end)
            end
        end
    end

    AddStep(1, function()
        local living = state.registry.entries.ziyunboss
        Check(living.status == "alive" and living.entity ~= nil and living.entity:IsValid(),
            "live Ziyun registry state missing before save")
        for _, key in ipairs(defs.order) do
            if key ~= "ziyunboss" then
                Check(state.registry.entries[key].status == "dead", "dead state missing before save: " .. key)
            end
        end
        TheWorld:PushEvent("ms_save")
    end)
    AddStep(5, function()
        print("PHAM_NHAN_BOSS_CREATE_PASS")
    end)
end

local function BuildReloadQueue()
    local state = {}
    AddStep(6, function()
        Check(TheWorld.ismastersim, "boss reload requires the master simulation")
        local helper=Check(SpawnPrefab("ttk_boss_ht"),"HT dependency regression failed")
        helper:Remove()
        print("PHAM_NHAN_BOSS_HT_ASSETS_PASS")
        state.registry = GetRegistry()
        Check(state.registry.ready, "registry did not reconcile after reload")
        for _, key in ipairs(defs.order) do
            local row = Check(state.registry.entries[key], "reloaded registry entry missing: " .. key)
            if key == "ziyunboss" then
                Check(row.status == "alive" and row.entity ~= nil and row.entity:IsValid(),
                    "live Ziyun link was not restored")
                Check(CountMain(key) == 1, "reload duplicated the live Ziyun boss")
                state.ziyun = row.entity
                Check(state.ziyun.mode == 2, "Ziyun mode 2 was not restored")
                Check(state.ziyun.mode2_pet ~= nil and state.ziyun.mode2_pet:IsValid(),
                    "Ziyun mode-2 helper was not restored")
            else
                Check(row.status == "dead", "dead boss changed state across reload: " .. key)
                Check(CountMain(key) == 0, "reload respawned a dead main boss: " .. key)
            end
        end
        state.ziyun.mode2_pet.components.health:SetInvincible(false)
        state.ziyun.mode2_pet.components.health:Kill()
    end)
    AddStep(3, function()
        Check(state.ziyun:IsValid() and state.ziyun.mode == 3, "Ziyun did not enter mode 3")
        Check(state.ziyun.mode3_pet ~= nil and state.ziyun.mode3_pet:IsValid(),
            "Ziyun mode-3 channeler missing")
        Check(state.ziyun.mode3_pet._ttk_boss_auxiliary, "Ziyun channeler is not auxiliary")
        Check(state.registry.entries.ziyunboss.status == "alive",
            "Ziyun registry completed before the channeler died")
        state.ziyun.mode3_pet.components.health:SetInvincible(false)
        state.ziyun.mode3_pet.components.health:Kill()
    end)
    AddStep(5, function()
        Check(state.registry.entries.ziyunboss.status == "dead", "Ziyun final death was not recorded")
        print("PHAM_NHAN_BOSS_RELOAD_PASS")
    end)
end

local function BuildFinalReloadQueue()
    AddStep(6, function()
        local registry=GetRegistry()
        Check(registry.ready,"final reload did not reconcile")
        for _,key in ipairs(defs.order) do
            Check(registry.entries[key].status=="dead","final reload reset death: "..key)
            Check(CountMain(key)==0,"final reload revived a main boss: "..key)
        end
        Check(CountPrefab("ttk_boss_deerclops_ziyun_aux")==0,"final corpse rebuilt a deer helper")
        Check(CountPrefab("ttk_boss_ziyunboss_channeler")==0,"final corpse rebuilt a channeler")
        print("PHAM_NHAN_BOSS_FINAL_RELOAD_PASS")
    end)
end

if phase == "final_reload" then BuildFinalReloadQueue()
elseif phase == "reload" then BuildReloadQueue() else BuildCreateQueue() end
RunNext()
