local M={}

local function ResolvePlayer(entity,seen)
    if (type(entity)~="table" and type(entity)~="userdata") or not entity.IsValid or not entity:IsValid() then return end
    if entity:HasTag("player") and not entity:HasTag("playerghost") then return entity end
    seen=seen or {}
    if seen[entity] then return end
    seen[entity]=true
    local c=entity.components or {}
    return ResolvePlayer(c.follower and c.follower.leader,seen)
        or ResolvePlayer(c.projectile and c.projectile.attacker,seen)
        or ResolvePlayer(c.complexprojectile and c.complexprojectile.attacker,seen)
        or ResolvePlayer(c.inventoryitem and c.inventoryitem:GetGrandOwner(),seen)
        or ResolvePlayer(entity.owner,seen) or ResolvePlayer(entity._owner,seen)
end

local function Neutral(inst,def)
    return def.unique and inst._ttk_boss_main and not inst._ttk_boss_provoked
end

local function Drop(inst,prefab,count)
    for _=1,count do
        local item=inst.components.lootdropper:SpawnLootPrefab(prefab)
        if item==nil then print("[Phàm Nhân] Missing boss loot: "..prefab) end
    end
end

function M.OnDeath(inst,def)
    if not inst._ttk_boss_main or inst._ttk_boss_auxiliary or inst._ttk_boss_rewarded
        or inst._ttk_boss_phase_transition or (def.key=="ziyunboss" and inst.mode==1) then return false end
    local registry=TheWorld.components.ttk_bossregistry
    if not registry or not registry:MarkDead(def.key,inst) then return false end
    inst._ttk_boss_rewarded=true
    if def.blueprint then Drop(inst,def.blueprint,1) end
    if def.unique then
        Drop(inst,"ttk_lingshi4",10)
        Drop(inst,"ttk_lingshi3",100)
        for _,gem in ipairs({"redgem","bluegem","purplegem"}) do Drop(inst,gem,10) end
        for _,gem in ipairs({"yellowgem","orangegem","greengem"}) do Drop(inst,gem,5) end
    else
        Drop(inst,def.food,1)
        Drop(inst,def.summon,1)
        Drop(inst,"ttk_lingshi3",math.random(2,5))
    end
    return true
end

function M.Install(inst,def)
    -- Native source drops still run through lootdropper; root awards are gated
    -- by the world registry, excluding phase changes and auxiliary instances.
    inst._ttk_boss_managed=true
    local oldsave,oldload=inst.OnSave,inst.OnLoad
    inst.OnSave=function(ent,data,...)
        local refs=oldsave and oldsave(ent,data,...) or nil
        data.ttk_boss_main=ent._ttk_boss_main or nil
        data.ttk_boss_provoked=ent._ttk_boss_provoked or nil
        data.ttk_boss_rewarded=ent._ttk_boss_rewarded or nil
        data.ttk_boss_home=ent._ttk_boss_home
        return refs
    end
    inst.OnLoad=function(ent,data,...)
        if data then
            ent._ttk_boss_main=data.ttk_boss_main or nil
            ent._ttk_boss_key=ent._ttk_boss_main and def.key or nil
            ent._ttk_boss_provoked=data.ttk_boss_provoked or nil
            ent._ttk_boss_rewarded=data.ttk_boss_rewarded or nil
            ent._ttk_boss_home=data.ttk_boss_home
        end
        if oldload then return oldload(ent,data,...) end
    end
    inst:ListenForEvent("death",function() M.OnDeath(inst,def) end)
    if def.unique then
        local combat=inst.components.combat
        if combat then
            local attacked,settarget,doattack,cantarget=combat.GetAttacked,combat.SetTarget,combat.DoAttack,combat.CanTarget
            combat.GetAttacked=function(c,attacker,...)
                if Neutral(inst,def) and ResolvePlayer(attacker) then inst._ttk_boss_provoked=true end
                return attacked(c,attacker,...)
            end
            combat.SetTarget=function(c,target,...)
                if target and Neutral(inst,def) then return false end
                return settarget(c,target,...)
            end
            combat.DoAttack=function(c,...)
                if Neutral(inst,def) then return false end
                return doattack(c,...)
            end
            combat.CanTarget=function(c,...)
                if Neutral(inst,def) then return false end
                return cantarget(c,...)
            end
        end
        local aura=inst.components.sanityaura
        if aura then
            local get=aura.GetAura
            aura.GetAura=function(c,...)
                if Neutral(inst,def) then return 0 end
                return get(c,...)
            end
        end
    end
end

M.IsNeutral=Neutral
return M
