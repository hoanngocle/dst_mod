-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require "behaviours/follow"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/runaway"
require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/faceentity"
require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/runaway")
require("behaviours/wander")
local RESET_COMBAT_DELAY = 10
local MIN_STALKING_TIME = 2
local MAX_STALKING_CHASE_TIME = 4
local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 13
local HUNTER_PARAMS =
{
	tags = { "_combat" },
	notags = { "INLIMBO", "playerghost", "invisible", "hidden", "flight", "shadowcreature" },
	oneoftags = { "character", "monster", "largecreature", "shadowminion" },
	fn = function(ent, inst)
		return ent.components.combat:TargetIs(inst)
			or ent:HasTag("character")
			or ent:HasTag("monster")
			or ent:HasTag("shadowminion")
	end,
}
local DaywalkerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)
local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end
local function ShouldStalk(inst)
	return inst:IsStalking() and (inst.components.combat:InCooldown() or not inst.components.combat:HasTarget())
end
local function ShouldStalkLunge(inst)
	return inst.canlungestalk and inst:GetStalkingLunge() ~= nil
end
local function IsNoStalking(inst)
	return inst:GetStalkingLunge() == nil
end
local function ShouldDodge(inst)
	return inst.components.combat:HasTarget() and inst.components.combat:InCooldown() and not inst:IsStalking()
end
local function ShouldChase(inst)
	return inst.components.combat:HasTarget() and not inst.components.combat:InCooldown()
end
local function DoStalking(inst)
	local target =  ShouldStalkLunge(inst) and inst:GetStalkingLunge() or inst:GetStalking()
	if target ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		local dist = math.sqrt(dx * dx + dz * dz)
		local strafe_angle = Remap(math.clamp(dist, 4, RUN_AWAY_DIST), 4, RUN_AWAY_DIST, 135, 75)
		local rot = inst.Transform:GetRotation()
		local rot1 = math.atan2(-dz, dx) * RADIANS
		local rota = rot1 - strafe_angle
		local rotb = rot1 + strafe_angle
		if DiffAngle(rot, rota) < 30 then
			rot1 = rota
		elseif DiffAngle(rot, rotb) < 30 then
			rot1 = rotb
		else
			rot1 = math.random() < 0.5 and rota or rotb
		end
		rot1 = rot1 * DEGREES
		return Vector3(x + math.cos(rot1) * 10, 0, z - math.sin(rot1) * 10)
	end
end
local function IsStalkingFar(inst)
	local target = inst:GetStalking()
	return target ~= nil and not inst:IsNear(target, RUN_AWAY_DIST)
end
local function IsStalkingTooClose(inst)
	local target = inst:GetStalking()
	return target ~= nil and inst:IsNear(target, TUNING.DAYWALKER_ATTACK_RANGE)
end
local function GetFaceTargetFn(inst)
	return inst.components.combat.target
end
local function KeepFaceTargetFn(inst, target)
	return inst.components.combat:TargetIs(target)
end
local function ShouldUseAbility(self)
	local target = self.inst.components.combat.target
	if target and target:HasTag("player") then
		self.abilityname = "doskill1"
	end
    return self.abilityname ~= nil
end
local function ShouldUseSkill12(inst)
	local target = inst.components.combat.target
	return target and target:IsValid() and target:HasTag("player") and inst:IsValid() and not inst.components.timer:TimerExists("skill")
		and inst.skillmode <= 4
		and inst:IsNear(target,20)
end
local function ShouldUseSkill3(inst)
	local target = inst.components.combat.target
	return target and target:HasTag("player") and not inst.components.timer:TimerExists("skill")
		and inst.skillmode > 4
end
local function ShouldReset(self)
    if not self.inst.reset and  not self.inst.components.health:IsDead() then
        local dx, dy, dz = self.inst.Transform:GetWorldPosition()
        local spx, spy, spz = self.inst.components.knownlocations:GetLocation("spawnpoint"):Get()
        if distsq(spx, spz, dx, dz) >= (240 * 240) then
            return true
        end
    end
end
function DaywalkerBrain:OnStart()
	local root = PriorityNode({
		WhileNode(
			function()
				return not (self.inst.sg:HasStateTag("jumping") or
							self.inst.sg:HasStateTag("tired"))
			end,
			"<busy state guard>",
			PriorityNode({
				WhileNode(function() return ShouldReset(self) end, "Reset Fight",
				ActionNode(function()
					self.inst.reset = true
					self.inst:GoHome()
				end)),
				WhileNode(function()return ShouldUseSkill12(self.inst) end, "ShouldUseSkill1",
					ActionNode(function()
						self.inst:PushEvent("skill_taunt")
					end)
				),
				WhileNode(function()return ShouldUseSkill3(self.inst) end, "ShouldUseSkill3",
				ActionNode(function()
					self.inst:PushEvent("skill_3")
				end)
			),
				WhileNode(function()return ShouldStalkLunge(self.inst) end, "StalkingLunge",
					ParallelNode{
						SequenceNode{
							ParallelNodeAny{
								WaitNode(3),
								ConditionWaitNode(function() return IsNoStalking(self.inst) end),
							},
							ActionNode(function()
								self.inst.canlungestalk = false
								if self.inst.skillmode == 2 or self.inst.skillmode == 4 then
									self.inst:PushEvent("skill_lunge",self.inst.lungeplayers)
								else
									self.inst:PushEvent("skill_tele",self.inst.lungeplayers)
								end
							end),
						},
						Leash(self.inst, DoStalking, 0, 0, false)
					}
				),
				WhileNode(function() return ShouldStalk(self.inst) end, "Stalking",
					ParallelNode{
						SequenceNode{
							ParallelNodeAny{
								WaitNode(MIN_STALKING_TIME),
								ConditionWaitNode(function() return IsStalkingFar(self.inst) end),
							},
							ConditionWaitNode(function() return IsStalkingTooClose(self.inst) end),
							ActionNode(function() self.inst.components.combat:ResetCooldown() end),
						},
						Leash(self.inst, DoStalking, 0, 0, false),
					}),
				WhileNode(function() return ShouldChase(self.inst) end, "Chase",
					PriorityNode({
						WhileNode(function() return self.inst:IsStalking() end, "Stalking Chase",
							ParallelNodeAny{
								SequenceNode{
									WaitNode(MAX_STALKING_CHASE_TIME),
									ActionNode(function() self.inst:SetStalking(nil) end),
								},
								ChaseAndAttack(self.inst, nil, nil, nil, nil, true),
							}),
						ChaseAndAttack(self.inst),
					}, 0.5)),
				FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
				ParallelNode{
					SequenceNode{
						WaitNode(RESET_COMBAT_DELAY),
					},
					PriorityNode({
						FailIfSuccessDecorator(Leash(self.inst, GetHomePos, 16, 2, true)),
						Wander(self.inst, GetHomePos, 6)
					}, 0.5),
				},
			}, 0.5)),
	}, 0.5)
	self.bt = BT(self.inst, root)
end
function DaywalkerBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end
return DaywalkerBrain
