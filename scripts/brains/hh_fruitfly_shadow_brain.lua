require "behaviours/findfarmplant"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local WORK_RADIUS = 20
local RETURN_TO_STATION_DISTANCE = 1.25
local STATION_REACHED_DISTANCE = 0.5

local function GetWorkPosition(inst)
    return inst.GetHHWorkPosition ~= nil and inst:GetHHWorkPosition() or inst:GetPosition()
end

local function IsPlantInWorkArea(inst, plant)
    if inst._hh_is_relocating or plant == nil or not plant:IsValid() then
        return false
    end

    local workpos = GetWorkPosition(inst)
    local plantpos = plant:GetPosition()
    local dx = plantpos.x - workpos.x
    local dz = plantpos.z - workpos.z
    local radius = inst._hh_work_radius or WORK_RADIUS
    return dx * dx + dz * dz < radius * radius
end

local HHFruitFlyShadowBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function HHFruitFlyShadowBrain:OnStart()
    local root =
    PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),
        BrainCommon.ElectricFencePanicTrigger(self.inst),
        WhileNode(
            function()
                return not self.inst._hh_is_relocating
            end,
            "WorkAtStation",
            PriorityNode(
            {
                FindFarmPlant(self.inst, ACTIONS.INTERACT_WITH, true, GetWorkPosition, IsPlantInWorkArea),
                Leash(self.inst, GetWorkPosition, RETURN_TO_STATION_DISTANCE, STATION_REACHED_DISTANCE, false),
            }, .25)
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

return HHFruitFlyShadowBrain
