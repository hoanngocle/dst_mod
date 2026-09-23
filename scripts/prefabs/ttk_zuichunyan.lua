-- Tree lifecycle and harvest ported from Tu Tien 19.7 by tools/port_phamnhan_seed_tree.py.
local assets =
{
    Asset("ANIM", "anim/xd_zuichunyan_green.zip"),
    Asset("ANIM", "anim/xd_zuichunyan_purple.zip"),
    Asset("SOUND", "sound/forest.fsb"),
}
local prefabs =
{
    "log",
    "charcoal",
    "small_puff", "ttk_boss_zcyseed",
    "ttk_boss_zuichunyan_green_leaves_fall", "ttk_boss_zuichunyan_green_leaves_chop",
    "ttk_boss_zuichunyan_purple_leaves_fall", "ttk_boss_zuichunyan_purple_leaves_chop",
}
local builds =
{
    green = {
        file="xd_zuichunyan_green",
        file_bank = "xd_zuichunyan_green",
        prefab_name = "ttk_zuichunyan_green",
        grow_times = TUNING.EVERGREEN_GROW_TIME,
        short_loot = {"log","log","ttk_boss_zcyseed"},
        tall_loot = {"log", "log", "log", "ttk_boss_zcyseed", "ttk_boss_zcyseed"},
        chop_camshake_delay = 0.4,
        fx="ttk_boss_zuichunyan_green_leaves_fall",
        chopfx="ttk_boss_zuichunyan_green_leaves_chop",
    },
    purple = {
        file="xd_zuichunyan_purple",
        file_bank = "xd_zuichunyan_green",
        prefab_name = "ttk_zuichunyan_purple",
        grow_times = TUNING.EVERGREEN_GROW_TIME,
        short_loot = {"log","log","ttk_boss_zcyseed"},
        tall_loot = {"log", "log", "log", "ttk_boss_zcyseed", "ttk_boss_zcyseed"},
        chop_camshake_delay = 0.4,
        fx="ttk_boss_zuichunyan_purple_leaves_fall",
        chopfx="ttk_boss_zuichunyan_purple_leaves_chop",
    },
}
local function makeanims(stage)
    return {
        idle="idle_"..stage,
        chop="chop_"..stage,
        fallleft = "fallleft_"..stage,
        fallright =  "fallleft_"..stage ,
        stump ="stump_"..stage,
        burning ="burning_loop_"..stage,
        burnt="burnt_"..stage,
        chop_burnt="chop_burnt_"..stage,
        idle_chop_burnt="idle_chop_burnt_"..stage,
    }
end
local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local function dig_up_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end
local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    if math.random() < 1/3 then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    inst.components.lootdropper:DropLoot()
end
local function GetBuild(inst)
    return builds[inst.build] or builds["green"]
end
local function SpawnLeafFX(inst, waittime, chop)
    if (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or
        inst:HasTag("stump") or
        inst:HasTag("burnt") or
        inst:IsAsleep() then
        return
    elseif waittime ~= nil then
        inst:DoTaskInTime(waittime, SpawnLeafFX, nil, chop)
        return
    end
    local fx = nil
    if chop then
        if GetBuild(inst).chopfx ~= nil then
            fx = SpawnPrefab(GetBuild(inst).chopfx)
        end
    elseif GetBuild(inst).fx ~= nil then
        fx = SpawnPrefab(GetBuild(inst).fx)
    end
    if fx ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst.components.growable ~= nil then
            if inst.components.growable.stage == 1 then
                y = y + 0.3
            elseif inst.components.growable.stage == 2 then
                y = y + 0
            elseif inst.components.growable.stage == 3 then
            end
        end
        fx.Transform:SetPosition(x, chop and y + math.random() * 2 or y, z)
    end
end
local function OnBurnt(inst, immediate)
    local function changes()
        if inst.components.burnable ~= nil then
            inst.components.burnable:Extinguish()
        end
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("growable")
        inst:RemoveComponent("hauntable")
        inst:RemoveTag("shelter")
        MakeHauntableWork(inst)
        inst.components.lootdropper:SetLoot({})
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnWorkCallback(nil)
            inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
        end
    end
    if immediate then
        changes()
    else
        inst:DoTaskInTime(.5, changes)
    end
    inst.AnimState:PlayAnimation(inst.anims.burnt, true)
    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")
    inst.MiniMapEntity:SetIcon("ttk_zuichunyan_burnt.tex")
end
local function SetShort(inst)
    inst.anims = short_anims
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_SMALL)
    end
    inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
    inst:AddTag("shelter")
    inst.AnimState:PushAnimation(inst.anims.idle, true)
end
local function GrowShort(inst)
    inst.AnimState:PlayAnimation("grow_old_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")
end
local function SetTall(inst)
    inst.anims = tall_anims
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_TALL)
    end
    inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)
    inst:AddTag("shelter")
    inst.AnimState:PlayAnimation(inst.anims.idle, true)
end
local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_small_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    inst.AnimState:PushAnimation(inst.anims.idle, true)
end
local function inspect_tree(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("stump") and "CHOPPED")
        or nil
end
local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "short",
            time = function(inst) return math.random(1400,1480) end,
            fn = SetShort,
            growfn = GrowShort,
        },
        {
            name = "tall",
            time = function(inst) return  math.random(20) end,
            fn = SetTall,
            growfn = GrowTall,
        },
    }
end
local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["small"]
end
local function chop_tree(inst, chopper, chopsleft, numchops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end
    SpawnLeafFX(inst, nil, true)
    inst.AnimState:PlayAnimation(inst.anims.chop)
    inst.AnimState:PushAnimation(inst.anims.idle, true)
end
local function chop_down_tree_shake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03,
        inst.components.growable ~= nil and
        inst.components.growable.stage > 2 and .5 or .25,
        inst, 6)
end
local function make_stump(inst)
    inst:RemoveComponent("burnable")
    MakeSmallBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("workable")
    inst:RemoveTag("shelter")
    inst:RemoveComponent("hauntable")
    MakeHauntableIgnite(inst)
    RemovePhysicsColliders(inst)
    inst:AddTag("stump")
    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end
    inst.MiniMapEntity:SetIcon("ttk_zuichunyan_stump.tex")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
end
local function chop_down_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = inst:GetPosition()
    local he_right = true
    if chopper then
        local hispos = chopper:GetPosition()
        he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    else
        if math.random() > 0.5 then
            he_right = false
        end
    end
    SpawnLeafFX(inst, nil, false)
    if he_right then
        inst.AnimState:PlayAnimation(inst.anims.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(inst.anims.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end
    if inst.components.growable.stage == 2 and math.random() < 0.17 then
        inst.components.lootdropper:SpawnLootPrefab("livinglog")
    end
    inst:DoTaskInTime(GetBuild(inst).chop_camshake_delay, chop_down_tree_shake)
    make_stump(inst)
    inst.AnimState:PushAnimation(inst.anims.stump, false)
end
local function tree_burnt(inst)
    OnBurnt(inst)
end
local function handler_growfromseed(inst)
    inst.components.growable:SetStage(1)
    inst.AnimState:PlayAnimation("grow_old_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    inst.AnimState:PushAnimation(inst.anims.idle, true)
end
local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    if inst:HasTag("stump") then
        data.stump = true
    end
end
local function onload(inst, data)
    if data ~= nil then
        if data.stump then
            make_stump(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            if data.burnt or inst:HasTag("burnt") then
                DefaultBurntFn(inst)
            end
        elseif data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst, true)
        end
        if not inst:IsValid() then
            return
        end
    end
end
local function OnEntitySleep(inst)
    local doBurnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning()
    if doBurnt and inst:HasTag("stump") then
        DefaultBurntFn(inst)
    else
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("inspectable")
        if doBurnt then
            inst:RemoveComponent("growable")
            inst:AddTag("burnt")
        end
    end
end
local function OnEntityWake(inst)
    if inst:HasTag("burnt") then
        tree_burnt(inst)
    else
        local isstump = inst:HasTag("stump")
        if not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            if inst.components.burnable == nil then
                if isstump then
                    MakeSmallBurnable(inst)
                else
                    MakeLargeBurnable(inst, TUNING.TREE_BURN_TIME)
                    inst.components.burnable:SetFXLevel(5)
                    inst.components.burnable:SetOnBurntFn(tree_burnt)
                end
            end
            if inst.components.propagator == nil then
                if isstump then
                    MakeSmallPropagator(inst)
                else
                    MakeMediumPropagator(inst)
                end
            end
        end
    end
    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end
end
local function onhauntwork(inst, haunter)
    if inst.components.workable ~= nil and math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        inst.components.workable:WorkedBy(haunter, 1)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end
local function tree(name, build, stage, data,map)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, .25)
        inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
        inst:AddTag("ttk_zuichunyan")
        inst.MiniMapEntity:SetIcon(map..".tex")
        inst:AddTag("shelter")
        inst.MiniMapEntity:SetPriority(-1)
        inst:AddTag("plant")
        inst:AddTag("tree")
        inst.build = build
        inst.AnimState:SetBank(GetBuild(inst).file_bank)
        inst.AnimState:SetBuild(GetBuild(inst).file)
        inst:SetPrefabName(GetBuild(inst).prefab_name)
        inst:AddTag(GetBuild(inst).prefab_name)
        inst:SetPrefabNameOverride("ttk_zuichunyan")
        MakeSnowCoveredPristine(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        local color = .5 + math.random() * .5
        inst.AnimState:SetMultColour(color, color, color, 1)
        MakeLargeBurnable(inst, TUNING.TREE_BURN_TIME)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(tree_burnt)
        MakeMediumPropagator(inst)
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)
        inst:AddComponent("lootdropper")
        inst:AddComponent("growable")
        inst.components.growable.stages = GetGrowthStages(inst)
        inst.components.growable:SetStage(stage == 0 and math.random(1, 2) or stage)
        inst.components.growable.loopstages = false
        inst.components.growable.springgrowth = true
        inst.components.growable.magicgrowable = true
        inst.components.growable:StartGrowing()
        inst:AddComponent("simplemagicgrower")
        inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages - 1)
        inst.growfromseed = handler_growfromseed
        inst:AddComponent("timer")
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetOnHauntFn(onhauntwork)
        inst.OnSave = onsave
        inst.OnLoad = onload
        MakeSnowCovered(inst)
        if data == "stump" then
            RemovePhysicsColliders(inst)
            inst:AddTag("stump")
            inst:RemoveTag("shelter")
            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(dig_up_stump)
            inst.components.workable:SetWorkLeft(1)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst.MiniMapEntity:SetIcon("ttk_zuichunyan_stump.tex")
        else
            inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
            if data == "burnt" then
                OnBurnt(inst)
            end
        end
        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
local WAXED_PLANTS = require "prefabs/waxed_plant_common"
return  tree("ttk_zuichunyan_green", "green", 0,nil,"ttk_zuichunyan_green"),
        tree("ttk_zuichunyan_green_short", "green", 1,nil,"ttk_zuichunyan_green"),
        tree("ttk_zuichunyan_green_tall", "green", 2,nil,"ttk_zuichunyan_green"),
        tree("ttk_zuichunyan_purple", "purple", 0,nil,"ttk_zuichunyan_purple"),
        tree("ttk_zuichunyan_purple_short", "purple", 1,nil,"ttk_zuichunyan_purple"),
        tree("ttk_zuichunyan_purple_tall", "purple", 2,nil,"ttk_zuichunyan_purple"),
        tree("ttk_zuichunyan_green_burnt", "green", 0, "burnt","ttk_zuichunyan_green"),
        tree("ttk_zuichunyan_green_stump", "green", 0, "stump","ttk_zuichunyan_green"),
        tree("ttk_zuichunyan_purple_burnt", "purple", 0, "burnt","ttk_zuichunyan_purple"),
        tree("ttk_zuichunyan_purple_stump", "purple", 0, "stump","ttk_zuichunyan_purple")
