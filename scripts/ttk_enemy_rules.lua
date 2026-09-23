local EXCLUDED_PREFABS = {
    alterguardian_phase1 = true,
    alterguardian_phase2 = true,
    hh_igris_shadow = true,
    hh_beru_shadow = true,
    hh_macanh_shadow = true,
    hh_hacanh_shadow = true,
    hh_fruitfly_shadow = true,
}

local EXCLUDED_TAGS = {
    "player",
    "playerghost",
    "FX",
    "structure",
    "companion",
    "critter",
    "shadowminion",
    "shadow_minion",
}

local NORMAL_PREFABS = {
    killerbee = true,
    mosquito = true,
}

local function HasTruthyHHTag(inst, name)
    return type(inst.hh_tags) == "table"
        and inst.hh_tags[name] ~= nil
        and inst.hh_tags[name] ~= false
end

local function HasExcludedTag(inst)
    for _, tag in ipairs(EXCLUDED_TAGS) do
        if inst:HasTag(tag) then
            return true
        end
    end
    return false
end

local function HasPlayerLeader(inst)
    local follower = inst.components.follower
    local leader = follower ~= nil and follower.leader or nil
    return leader ~= nil and leader.HasTag ~= nil and leader:HasTag("player")
end

local function Classify(inst)
    if inst == nil
        or inst.prefab == nil
        or inst.components == nil
        or inst.components.health == nil
        or inst.components.combat == nil
        or EXCLUDED_PREFABS[inst.prefab]
        or HasExcludedTag(inst)
        or HasPlayerLeader(inst)
    then
        return nil
    end

    if inst:HasTag("epic")
        or inst:HasTag("boss")
        or HasTruthyHHTag(inst, "boss_monster")
        or HasTruthyHHTag(inst, "endgameboss_monster")
    then
        return "boss"
    end

    if inst:HasTag("monster")
        or inst:HasTag("hostile")
        or NORMAL_PREFABS[inst.prefab]
        or inst.hh_is_dungeon_monster == true
        or inst:HasTag("hh_dungeon_mob")
    then
        return "normal"
    end

    return nil
end

return {
    Classify = Classify,
    excluded_prefabs = EXCLUDED_PREFABS,
    normal_prefabs = NORMAL_PREFABS,
}
