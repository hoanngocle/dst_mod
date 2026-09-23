require("prefabutil")
local defs = require("ttk_mine_defs")
local assets = {Asset("ANIM", "anim/ttk_rocks.zip")}
for tier = 1, 3 do
    table.insert(assets, Asset("ATLAS", "images/map_icons/ttk_rock" .. tier .. ".xml"))
    table.insert(assets, Asset("IMAGE", "images/map_icons/ttk_rock" .. tier .. ".tex"))
end

local function Refresh(inst)
    local exhausted = inst._ttk_exhausted == true
    -- The source has only idle1/2/3, so dim the permanent vein while it recharges.
    local tint = exhausted and 0.3 or 1
    inst.AnimState:SetMultColour(tint, tint, tint, 1)
    inst.components.workable:SetWorkable(not exhausted)
end

local function MigrateCrafted(inst)
    if not inst:IsValid() then return end
    local workshop = SpawnPrefab("ttk_spirit_workshop")
    if workshop == nil then
        inst:DoTaskInTime(5, MigrateCrafted)
        return
    end
    workshop.Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst._ttk_exhausted then
        workshop:BeginProduction(inst.components.timer:GetTimeLeft("regrow"))
    end
    inst:Remove()
end

local function ScheduleMigration(inst, newly_built)
    inst._ttk_crafted = true
    if newly_built then inst._ttk_exhausted = true end
    inst.components.workable:SetWorkable(false)
    -- Component timers are loaded after the prefab's OnLoad callback.
    inst:DoTaskInTime(0, MigrateCrafted)
end

local function MakeMine(tier)
    local def = defs[tier]
    local name = "ttk_rock" .. tier
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, 1)
        inst.AnimState:SetBank("xd_rocks")
        inst.AnimState:SetBuild("xd_rocks")
        inst.AnimState:PlayAnimation("idle" .. tier)
        inst.MiniMapEntity:SetIcon(name .. ".tex")
        inst:AddTag("boulder")
        inst:AddTag("ttk_spirit_mine")
        MakeSnowCoveredPristine(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = function(ent)
            return ent._ttk_exhausted and "EXHAUSTED" or (ent._ttk_crafted and "CRAFTED" or "GENERIC")
        end
        inst:AddComponent("timer")
        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(def.loot)
        if def.chance then inst.components.lootdropper:AddChanceLoot(def.chance[1], def.chance[2]) end
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(def.hits)
        inst.components.workable.savestate = true
        inst.components.workable:SetOnFinishCallback(function(ent)
            if ent._ttk_exhausted then return end
            ent._ttk_exhausted = true
            if ent._ttk_crafted then
                Refresh(ent)
                ent.components.timer:StartTimer("regrow", def.days * TUNING.TOTAL_DAY_TIME)
            end
            ent.components.lootdropper:DropLoot(ent:GetPosition())
            local fx = SpawnPrefab("rock_break_fx")
            if fx then fx.Transform:SetPosition(ent.Transform:GetWorldPosition()) end
            if not ent._ttk_crafted then ent:Remove() end
        end)
        inst:ListenForEvent("onbuilt", function(ent)
            ScheduleMigration(ent, true)
        end)
        inst:ListenForEvent("timerdone", function(ent, data)
            if data.name == "regrow" and ent._ttk_crafted then
                ent._ttk_exhausted = false
                ent.components.workable:SetWorkLeft(def.hits)
                Refresh(ent)
            end
        end)
        inst.OnSave = function(ent, data)
            data.crafted = ent._ttk_crafted == true
            data.exhausted = ent._ttk_exhausted == true
        end
        inst.OnLoad = function(ent, data)
            if data then
                ent._ttk_crafted = data.crafted == true
                ent._ttk_exhausted = data.exhausted == true
                Refresh(ent)
                if ent._ttk_crafted then ScheduleMigration(ent) end
            end
        end
        MakeSnowCovered(inst)
        MakeHauntableWork(inst)
        return inst
    end
    return Prefab(name, fn, assets, {"rocks", "flint", "ttk_lingshi" .. tier, "rock_break_fx", "ttk_spirit_workshop"})
end

return MakeMine(1), MakeMine(2), MakeMine(3),
    MakePlacer("ttk_rock1_placer", "xd_rocks", "xd_rocks", "idle1"),
    MakePlacer("ttk_rock2_placer", "xd_rocks", "xd_rocks", "idle2"),
    MakePlacer("ttk_rock3_placer", "xd_rocks", "xd_rocks", "idle3")
