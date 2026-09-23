require("behaviours/wander")
require("behaviours/standstill")

local GuildStaffBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMES = {
    minwalktime = 2,
    randwalktime = 3,
    minwaittime = 2,
    randwaittime = 5,
}

local function GetWanderRadius()
    return TUNING.HH_GUILD and TUNING.HH_GUILD.STAFF_WANDER_RADIUS or 40
end

local function GetHome(inst)
    return inst.components.knownlocations:GetLocation("home")
end

local function MustStandStill(inst)
    return GetHome(inst) == nil
        or TheWorld.state.phase == "night"
        or (inst.IsGuildBusy ~= nil and inst:IsGuildBusy())
end

local function IsInsideGuildArea(inst, point)
    local home = GetHome(inst)
    local radius = GetWanderRadius()
    return home ~= nil and point ~= nil and distsq(home.x, home.z, point.x, point.z) <= radius * radius
end

function GuildStaffBrain:OnStart()
    local root = PriorityNode({
        WhileNode(
            function()
                return MustStandStill(self.inst)
            end,
            "Guild unavailable",
            StandStill(self.inst, nil, MustStandStill)
        ),
        Wander(
            self.inst,
            GetHome,
            GetWanderRadius,
            WANDER_TIMES,
            nil,
            nil,
            function(point)
                return IsInsideGuildArea(self.inst, point)
            end,
            { wander_dist = 8 }
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

return GuildStaffBrain
