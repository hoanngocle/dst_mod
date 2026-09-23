require("behaviours/chaseandattack")
require("behaviours/chattynode")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/wander")

local FAR_TRADE_DIST_SQ = 20 * 20
local NEAR_TRADE_DIST_SQ = 4 * 4

local HH_Brain = Class(Brain, function(self, inst)
    Brain["_ctor"](self, inst)
end)

local function GetTarget(inst)
    return inst["components"]["combat"]["target"]
end

local function IsTarget(inst, target)
    return inst["components"]["combat"]:TargetIs(target)
end

local function GetTargetPos(inst)
    local target = GetTarget(inst)
    return target and target:GetPosition() or nil
end

local function GetNearbyPlayerFn(inst)
    local player, distsq = FindClosestPlayerToInst(inst, 6, true)
    if player then
        return player
    end
end

local function KeepNearbyPlayerFn(inst, target)
    return not (target["components"]["health"] and target["components"]["health"]:IsDead() or target:HasTag("playerghost"))
end

local function GetWanderDir(inst)
    if inst["hole"] then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        local x1, y1, z1 = inst["hole"]["Transform"]:GetWorldPosition()
        if x ~= x1 or z ~= z1 then
            local dx = x1 - x
            local dz = z1 - z
            local dsq = dx * dx + dz * dz
            local angle = math["atan2"](-dz, dx)
            local rad = inst["hole"]:GetPhysicsRadius(0) + 2.5
            if dsq <= rad * rad then
                return angle + PI
            end
            local theta = math["abs"](math["asin"](rad / math["sqrt"](dsq)))
            return angle + theta + math["random"]() * (PI2 - 2 * theta)
        end
    end
end

local WANDER_DATA = { ["wander_dist"] = 5.5 }
--游荡
local function WanderAroundHole(inst)
    return Wander(inst, nil, nil, nil, GetWanderDir, nil, nil, WANDER_DATA)
end
function HH_Brain:OnStart()
    local root = PriorityNode({
        WhileNode(
                function()
                    return not self["inst"]["sg"]:HasAnyStateTag("jumping", "defeated", "sleeping")
                end,
                "<busy state guard>",
                PriorityNode({
                    WhileNode(
                            function()
                                return self["inst"]["components"]["combat"]:InCooldown()
                            end,
                            "Chase",
                            PriorityNode({
                                FailIfSuccessDecorator(
                                        Leash(self.inst, GetTargetPos, 4.5, 3, true)),
                                FaceEntity(self["inst"], GetTarget, IsTarget),
                            }, 0.5)),
                    ParallelNode {
                        ConditionWaitNode(function()
                            local target = self["inst"]["components"]["combat"]["target"]
                            if target and not self["inst"]["components"]["combat"]:InCooldown() and
                                    self["inst"]:IsNear(target, 8 + target:GetPhysicsRadius(0))
                            then
                                self["inst"]["components"]["combat"]["ignorehitrange"] = true
                                self["inst"]["components"]["combat"]:TryAttack(target)
                                self["inst"]["components"]["combat"]["ignorehitrange"] = false
                            end
                            return false
                        end),
                        ChaseAndAttack(self["inst"], 9.5, 32),
                    },
                    --When first spawned; alternate between wandering and looking at you
                    SequenceNode {
                        FaceEntity(self["inst"], GetNearbyPlayerFn, KeepNearbyPlayerFn, 4),
                        ParallelNodeAny {
                            WanderAroundHole(self["inst"]),
                            WaitNode(10),
                        },
                    },
                    WanderAroundHole(self.inst),
                }, 0.5)),
    }, 0.5)

    self["bt"] = BT(self["inst"], root)
end

return HH_Brain
