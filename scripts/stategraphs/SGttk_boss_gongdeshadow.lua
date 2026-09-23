-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
require("stategraphs/commonstates")
local events=
{
}
local function DoLunge(doer, startingpos, targetpos)
    local p1 = { x = startingpos.x, y = startingpos.z }
    local p2 = { x = targetpos.x, y = targetpos.z }
    local dx, dy = p2.x - p1.x, p2.y - p1.y
    local dist = dx * dx + dy * dy
    local toskip = {}
    local pv = {}
    local r, cx, cy
    if dist > 0 then
        dist = math.sqrt(dist)
        r = 3
        dx, dy = dx / dist, dy / dist
        cx, cy = p1.x + dx * r, p1.y + dy * r
        local attacker = doer.attacker or doer.owner
        if attacker and attacker:IsValid() and doer.owner and doer.owner:IsValid() then
            local ents = XD_GetDamageTargets(cx, 0, cy,3,doer.not_aoetags)
            for i,v in pairs(ents) do
                toskip[v] = true
                if v and v:IsValid() and v ~= attacker and XD_CanAttackTrget(attacker,v) then
                    pv.x, pv._, pv.y = v.Transform:GetWorldPosition()
                    local vrange = 1 + v:GetPhysicsRadius(0.5)
                    if DistPointToSegmentXYSq(pv, p1, p2) < vrange * vrange then
                        local damage = doer.owner.attackdamage or doer.attackdamage or 210
                        if not doer.no_calcdamage then
                            damage = Xd_CalcDamage(attacker,damage,v,nil,1)
                        end
                        v.components.combat:GetAttacked(attacker,damage)
                    end
                end
            end
        end
    end
    local angle = (doer.Transform:GetRotation() + 90) * DEGREES
    local p3 = { x = p2.x + 2 * math.sin(angle), y = p2.y + 2 * math.cos(angle) }
    local attacker = doer.attacker or doer.owner
    if doer.owner and doer.owner:IsValid() and attacker and attacker:IsValid() then
        local ents = XD_GetDamageTargets(p2.x, 0, p2.y,5,doer.not_aoetags)
        for i,v in pairs(ents) do
            if v and v:IsValid() and not toskip[v] and v ~= attacker and XD_CanAttackTrget(attacker,v) then
                pv.x, pv._, pv.y = v.Transform:GetWorldPosition()
                local vradius = v:GetPhysicsRadius(0.5)
                local vrange = 2 + vradius
                if distsq(pv.x, pv.y, p2.x, p2.y) < vrange * vrange then
                    vrange = 1 + vradius
                    if DistPointToSegmentXYSq(pv, p2, p3) < vrange * vrange then
                        local damage = doer.owner.attackdamage or doer.attackdamage or 210
                        if not doer.no_calcdamage then
                            damage = Xd_CalcDamage(attacker,damage,v,nil,1)
                        end
                        v.components.combat:GetAttacked(attacker,damage)
                    end
                end
            end
        end
    end
	local fx = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
    fx.Transform:SetPosition(targetpos:Get())
    fx.Transform:SetRotation(doer:GetRotation())
    return true
end
local states=
{
    State{
        name = "ttk_boss_gongde_lunge",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },
        onenter = function(inst,pos)
            inst.targets = {}
            inst.AnimState:PlayAnimation("lunge_pst")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
            local pt = inst:GetPosition()
			local dir
			if pos.x ~= pos.x or pos.z ~= pos.z then
				dir = inst:GetAngleToPoint(pos)
				inst.Transform:SetRotation(dir)
			end
            local facing_angle = inst.Transform:GetRotation() * DEGREES
            local targetpos = Vector3(pt.x + 7 * math.cos(facing_angle), pt.y + 0, pt.z - 7 * math.sin(facing_angle))
            if DoLunge(inst, pt, targetpos) then
                inst.Physics:Teleport(targetpos.x, 0, targetpos.z)
            end
        end,
        onupdate = function(inst)
        end,
        timeline =
        {
            FrameEvent(8, function(inst)
            end),
            TimeEvent(12 * FRAMES, function(inst)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.attack_count >= 3 or not (inst.owner and inst.owner:IsValid()) then
                        inst.sg:GoToState("superjump_start")
                    else
                        inst.attack_count = inst.attack_count + 1
                        local pos
                        if inst.attack_count == 2 then
                            pos = inst.startpos
                        elseif inst.target and inst.target:IsValid() then
                            pos = inst.target:GetPosition()
                        elseif inst.owner and inst.owner:IsValid() then
                            pos = inst.owner:GetPosition()
                        end
                        if pos then
                            inst.sg:GoToState("ttk_boss_gongde_lunge_start",pos)
                        else
                            inst.sg:GoToState("superjump_start")
                        end
                    end
                end
            end),
        },
        onexit = function(inst)
        end,
    },
    State{
        name = "ttk_boss_gongde_lunge_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },
        onenter = function(inst,pos)
            if pos then
                inst.sg.statemem.pos = pos
                inst:ForceFacePoint(pos:Get())
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("lunge_pre")
        end,
        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil, true)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("lunge_lag")
                    inst.sg:GoToState("ttk_boss_gongde_lunge",inst.sg.statemem.pos)
                end
            end),
        },
    },
    State{
        name = "idle",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },
    State{
        name = "superjump_land",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("superjump_land")
            inst.AnimState:SetMultColour(1, 1, 1, .4)
            inst.sg:SetTimeout(22 * FRAMES)
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(1, 1, 1, .7)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, .9)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                local pt = inst:GetPosition()
                SpawnAt("ttk_boss_gongdeshadow_fx",pt)
                local attacker = inst.attacker or inst.owner
                if inst.owner and inst.owner:IsValid() and attacker and attacker:IsValid() then
                    local ents = XD_GetDamageTargets(pt.x, pt.y, pt.z,7,inst.not_aoetags)
                    for i,v in pairs(ents) do
                        if  v:IsValid() and v ~= attacker and XD_CanAttackTrget(attacker,v) then
                            local damage = inst.damage or 245
                            if not inst.no_calcdamage then
                                damage = Xd_CalcDamage(attacker,damage,v,nil,1)
                            end
                            v.components.combat:GetAttacked(attacker,damage)
                        end
                    end
                end
            end),
        },
        ontimeout = function(inst)
            inst.attack_count = inst.attack_count + 1
            local pos
            if inst.attack_count == 2 then
                pos = inst.startpos
            elseif inst.target and inst.target:IsValid() then
                pos = inst.target:GetPosition()
            elseif inst.owner and inst.owner:IsValid() then
                pos = inst.owner:GetPosition()
            end
            if pos then
                inst.sg:GoToState("ttk_boss_gongde_lunge_start",pos)
            else
                inst.sg:GoToState("superjump_start")
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.attack_count = inst.attack_count + 1
                    local pos
                    if inst.attack_count == 2 then
                        pos = inst.startpos
                    elseif inst.target and inst.target:IsValid() then
                        pos = inst.target:GetPosition()
                    elseif inst.owner and inst.owner:IsValid() then
                        pos = inst.owner:GetPosition()
                    end
                    if pos then
                        inst.sg:GoToState("ttk_boss_gongde_lunge_start",pos)
                    else
                        inst.sg:GoToState("superjump_start")
                    end
                end
            end),
        },
        onexit = function(inst)
        end,
    },
    State{
        name = "superjump_start",
        tags = {"doing", "busy",},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.AnimState:PushAnimation("superjump",false)
        end,
        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:Remove()
            end),
        },
    }
}
return StateGraph("ttk_boss_gongdeshadow", states, events, "superjump_land")
