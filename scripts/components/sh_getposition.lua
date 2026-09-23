local __BU__G__ =
    Class(
    function(self, Bug_)
        self["inst"] = Bug_
        self["maxnum"] = 63
        self["num"] = 0
        self["pos_x"] = -1440
        self["num_old"] = 0
        self["pos_x_old"] = -1440
    end
)
local function IsSafeSpot(x, z)
    if TheWorld == nil or TheWorld.Map == nil then return true end
    for dx = -48, 48, 8 do
        for dz = -48, 48, 8 do
            if TheWorld.Map:IsVisualGroundAtPoint(x + dx, 0, z + dz) then
                return false
            end
        end
    end
    local ents = TheSim:FindEntities(x, 0, z, 55, nil, {"INLIMBO", "FX", "NOCLICK", "DECOR", "catchable"})
    for _, ent in ipairs(ents) do
        if ent and ent:IsValid() then
            local prefab = ent.prefab or ""
            if not string.match(prefab, "wave") and not ent:HasTag("oceanfish") and not ent:HasTag("bird") and prefab ~= "oceanfish_shoalspawner" then
                return false
            end
        end
    end
    return true
end

function __BU__G__:GetPosition()
    local attempts = 0
    while not self:IsMax() and attempts < 100 do
        local bU_g = self["num"] % 4
        local __B__u_G_ = self["pos_x"]
        local x, z = 0, 0
        if bU_g == 0 then
            x, z = math.floor((__B__u_G_) / 4) * 4 + 2, math.floor((-1440) / 4) * 4 + 2
        elseif bU_g == 1 then
            x, z = math.floor(1440 / 4) * 4 + 2, math.floor(__B__u_G_ / 4) * 4 + 2
        elseif bU_g == 2 then
            x, z = math.floor(-__B__u_G_ / 4) * 4 + 2, math.floor(1440 / 4) * 4 + 2
        elseif bU_g == 3 then
            x, z = math.floor(-1440 / 4) * 4 + 2, math.floor(-__B__u_G_ / 4) * 4 + 2
        end

        if IsSafeSpot(x, z) then
            return x, 0, z
        else
            self:CreateHome()
            attempts = attempts + 1
        end
    end
end

function __BU__G__:GetPosition_old()
    local attempts = 0
    while self["num_old"] < self["maxnum"] and attempts < 100 do
        local __B__u_G__ = self["num_old"] % 4
        local b_U__g__ = self["pos_x_old"]
        
        self["num_old"] = self["num_old"] + 1
        if self["num_old"] % 4 == 0 then
            self["pos_x_old"] = self["pos_x_old"] + 180
        end

        local x, z = 0, 0
        if __B__u_G__ == 0 then
            x, z = math.floor((b_U__g__) / 4) * 4 + 2, math.floor((-1440) / 4) * 4 + 2
        elseif __B__u_G__ == 1 then
            x, z = math.floor(1440 / 4) * 4 + 2, math.floor(b_U__g__ / 4) * 4 + 2
        elseif __B__u_G__ == 2 then
            x, z = math.floor(-b_U__g__ / 4) * 4 + 2, math.floor(1440 / 4) * 4 + 2
        elseif __B__u_G__ == 3 then
            x, z = math.floor(-1440 / 4) * 4 + 2, math.floor(-b_U__g__ / 4) * 4 + 2
        end

        if IsSafeSpot(x, z) then
            return x, 0, z
        end
        attempts = attempts + 1
    end
end
function __BU__G__:IsMax()
    return self["num"] >= self["maxnum"]
end
function __BU__G__:CreateHome()
    self["num"] = self["num"] + 1
    if self["num"] % 4 == 0 then
        self["pos_x"] = self["pos_x"] + 180
    end
end
function __BU__G__:OnLoad(__bU__G_)
    if __bU__G_ then
        self["pos_x"] = __bU__G_["pos_x"]
        self["num"] = __bU__G_["num"]
        self["num_old"] = __bU__G_["num_old"]
        self["pos_x_old"] = __bU__G_["pos_x_old"]
    end
end
function __BU__G__:OnSave()
    return {pos_x = self["pos_x"], num = self["num"], num_old = self["num_old"], pos_x_old = self["pos_x_old"]}
end
return __BU__G__
