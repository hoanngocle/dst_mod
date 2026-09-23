local Defs = require("alchemy/ttk_alchemy_defs")

local MAX_STAGE = 15

local function IsFiniteInteger(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
        and value == math.floor(value)
end

local function NormalizeStage(value)
    if not IsFiniteInteger(value) then return 0 end
    return math.max(0, math.min(MAX_STAGE, value))
end

local function PrefixMask(stage)
    return math.pow(2, stage) - 1
end

local function RebuildConsumed(stage)
    local consumed = {}
    for index = 1, stage do
        local row = Defs.GetCultivationStage(index)
        if row ~= nil and row.prefab ~= nil then consumed[row.prefab] = true end
    end
    return consumed
end

local function IsCultivationPrefab(prefab)
    for index = 1, MAX_STAGE do
        local row = Defs.GetCultivationStage(index)
        if row ~= nil and row.prefab == prefab then return true end
    end
    return false
end

local TtkCultivation = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.stage = 0
    self.consumed = {}
end)

function TtkCultivation:GetStage()
    return self.stage
end

function TtkCultivation:CanConsume(prefab)
    if type(prefab) ~= "string" then return false, "invalid_prefab" end
    if not IsFiniteInteger(self.stage) or self.stage < 0 or self.stage > MAX_STAGE then
        return false, "invalid_stage"
    end
    if self.consumed[prefab] then return false, "already_consumed" end

    local nextrow = Defs.GetCultivationStage(self.stage + 1)
    if nextrow == nil then return false, "max_stage" end
    if nextrow.prefab == prefab then return true end
    if IsCultivationPrefab(prefab) then return false, "wrong_stage" end
    return false, "invalid_prefab"
end

function TtkCultivation:Consume(prefab)
    local ok, reason = self:CanConsume(prefab)
    if not ok then return false, reason end

    self.stage = self.stage + 1
    self.consumed[prefab] = true
    self.inst:PushEvent("ttk_cultivation_advanced", {stage=self.stage, prefab=prefab})
    return true, self.stage
end

function TtkCultivation:OnSave()
    local stage = NormalizeStage(self.stage)
    return {
        version = self.version,
        stage = stage,
        consumed_mask = PrefixMask(stage),
    }
end

function TtkCultivation:OnLoad(data)
    local saved_stage = type(data) == "table" and data.stage or nil
    self.stage = NormalizeStage(saved_stage)
    self.consumed = RebuildConsumed(self.stage)
end

return TtkCultivation
