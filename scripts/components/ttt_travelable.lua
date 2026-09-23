local debugutil = require "ttt_debugutil"
local print = debugutil.print

local ALL_TRAVELABLES = {}

local function ontraveller(self, traveller)
    self.inst.replica.ttt_travelable:SetTraveller(traveller)
end

local default_dist_cost = 32
local max_hunger_cost = 75
local min_hunger_cost = 5
local sanity_cost_ratio = 0.2

local ownershiptag = "uid_private"

local function SafeArrival(destination)
    if not destination:IsValid() or destination.components.ttt_travelable == nil
        or destination:HasTag("burnt") or destination:HasTag("fire") then return nil end
    local point = destination:GetPosition()
    local function Safe(candidate)
        local x, z = candidate.x, candidate.z
        return TheWorld.Map:IsPassableAtPoint(x, 0, z)
            and not TheWorld.Map:IsPointNearHole(Vector3(x, 0, z))
            and not TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z))
    end
    local offset = FindWalkableOffset(point, math.random() * TWOPI, 1.5, 12, true, false, Safe)
    if offset ~= nil then return point + offset end
    if Safe(point) then return point end
end

local Travelable = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("ttt_travelable")

    self.traveller = nil
    self.destinations = {}
    self.travellers = {}

    self.onclosepopups = function(traveller) -- yay closures ~gj -- yay ~v2c
        if traveller == self.traveller then self:EndTravel() end
    end

    self.generatorfn = nil
    table.insert(ALL_TRAVELABLES, self)
end, nil, { traveller = ontraveller })

local function IsNearDanger(traveller)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = traveller.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    return FindEntity(traveller, 10, function(target)
            return target.components.combat ~= nil and
                target.components.combat.target == traveller
        end,
        { "_combat", "_health" },
        { "INLIMBO", "player" },
        nil
    ) ~= nil
end

local function DistToCost(dist)
    local cost_hunger = min_hunger_cost + dist / default_dist_cost
    cost_hunger = math.min(cost_hunger, max_hunger_cost)
    local cost_sanity = cost_hunger * sanity_cost_ratio
    if TheWorld.state.season == "winter" then
        cost_sanity = cost_sanity * 1.25
    elseif TheWorld.state.season == "summer" then
        cost_sanity = cost_sanity * 0.75
    end

    cost_hunger = math.ceil(cost_hunger * TTT_TRAVEL.HUNGER_COST)
    cost_sanity = math.ceil(cost_sanity * TTT_TRAVEL.SANITY_COST)
    return cost_hunger, cost_sanity
end

function Travelable:ListDestination(traveller)
    self.destinations = {}

    for i, v in ipairs(ALL_TRAVELABLES) do
        if v.inst:IsValid() and not v.inst:HasTag("burnt") and not v.inst:HasTag("fire")
            and not (v.ownership and v.inst:HasTag(ownershiptag) and
                traveller.userid ~= nil and
                not v.inst:HasTag("uid_" .. traveller.userid)) and
            TTT_TRAVEL.CampSecurityCheckPermissionUse(traveller, v.inst) then
            table.insert(self.destinations, v.inst)
        end
    end

    table.sort(self.destinations, function(destA, destB)
        local writeA = destA.components.writeable
        local writeB = destB.components.writeable
        if writeA == nil or writeA:GetText() == nil or writeA:GetText() == "" then
            return false
        end
        if writeB == nil or writeB:GetText() == nil or writeB:GetText() == "" then
            return true
        end
        return string.lower(writeA:GetText()) < string.lower(writeB:GetText())
    end)

    self.totalsites = #self.destinations
    self.site = self.totalsites
end

function Travelable:MakeInfos()
    local infos = ""
    for i, destination in ipairs(self.destinations) do
        local name = destination.components.writeable and
            destination.components.writeable:GetText() or "~nil"
        name = name:gsub("[\r\n\t]", " ")
        local cost_hunger, cost_sanity = 0, 0
        if destination == self.inst then
            cost_hunger = -1
            cost_sanity = -1
        else
            local xi, yi, zi = self.inst.Transform:GetWorldPosition()
            local xf, yf, zf = destination.Transform:GetWorldPosition()
            -- entity may be removed
            if xi ~= nil and zi ~= nil and xf ~= nil and zf ~= nil then
                local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)
                cost_hunger, cost_sanity = DistToCost(dist)
            end
        end

        infos = infos .. (infos == "" and "" or "\n") .. i .. "\t" .. name ..
            "\t" .. cost_hunger .. "\t" .. cost_sanity
    end
    self.inst.replica.ttt_travelable:SetDestInfos(infos)
end

function Travelable:BeginTravel(traveller)
    local comment = self.inst.components.talker
    if not traveller then
        if comment then comment:Say("Ai vừa chạm vào tôi vậy?") end
        return
    end
    local talk = traveller.components.talker

    if self.ownership and self.inst:HasTag(ownershiptag) and traveller.userid ~=
        nil and not self.inst:HasTag("uid_" .. traveller.userid) then
        if comment then
            comment:Say("Tài sản riêng.")
        elseif talk then
            talk:Say("Bảng hiệu này là tài sản riêng.")
        end
        return
    elseif self.traveller then
        if comment then
            comment:Say("Chưa đến lượt bạn.")
        elseif talk then
            talk:Say("Chưa đến lượt tôi.")
        end
        return
    elseif IsNearDanger(traveller) then
        if talk then
            talk:Say("Đang có nguy hiểm, không thể dịch chuyển.")
        elseif comment then
            comment:Say("Đang có nguy hiểm, không thể dịch chuyển.")
        end
        return
    end

    local isintask = false
    for k, v in pairs(self.travellers) do
        if v == traveller then isintask = true end
    end

    if not self.traveltask or isintask then
        self.inst:StartUpdatingComponent(self)

        self:ListDestination(traveller)
        self:MakeInfos()
        self:CancelTravel(traveller)
        self.travellers = {}

        self.traveller = traveller
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, traveller)
        self.inst:ListenForEvent("onremove", self.onclosepopups, traveller)

        if traveller.HUD ~= nil then
            self.screen = traveller.HUD:ShowTTTTravelScreen(self.inst)
        end
    else
        self:CancelTravel(traveller)
        self:Travel(traveller, self.site)
    end
end

function Travelable:Travel(traveller, index)
    local destination = self.destinations[index]

    if traveller and destination then
        self.site = index
        local comment = self.inst.components.talker
        local talk = traveller.components.talker

        -- Site information
        local desc = destination.components.writeable and
            destination.components.writeable:GetText()
        local description = desc and string.format('"%s"', desc) or
            "Điểm đến chưa đặt tên"
        local information = ""
        local cost_hunger = min_hunger_cost
        local cost_sanity = 0
        local xi, yi, zi = self.inst.Transform:GetWorldPosition()
        local xf, yf, zf = destination.Transform:GetWorldPosition()
        -- entity may be removed
        if xi ~= nil and zi ~= nil and xf ~= nil and zf ~= nil then
            local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)
            cost_hunger, cost_sanity = DistToCost(dist)
        end

        if destination.components.ttt_travelable then
            table.insert(self.travellers, traveller)

            information = string.format(
                "Đến: %s (%d/%d)\nTiêu hao độ no: %.0f\nTiêu hao tinh thần: %.0f",
                description, self.site, self.totalsites,
                cost_hunger, cost_sanity)
            if comment then
                comment:Say(information, 3)
            elseif talk then
                talk:Say(information, 3)
            end

            local travel_delay
            if TTT_TRAVEL.COUNTDOWN_ENABLE then
                travel_delay = 8
            else
                travel_delay = 0
            end

            self.traveltask = self.inst:DoTaskInTime(travel_delay, function()
                self.traveltask = nil
                local arrival = SafeArrival(destination)
                if arrival ~= nil then xf, yf, zf = arrival:Get() end
                for k, who in pairs(self.travellers) do
                    if arrival == nil then
                        if comment then
                            comment:Say("Không còn có thể dịch chuyển đến điểm này.")
                        elseif talk then
                            talk:Say("Không còn có thể dịch chuyển đến điểm này.")
                        end
                    elseif who == nil or
                        (who.components.health and
                            who.components.health:IsDead()) then
                        if comment then
                            comment:Say("Không thể dịch chuyển người đã chết.")
                        end
                    elseif not (who:IsValid() and self.inst:IsValid() and
                            who:IsNear(self.inst, 10)) then
                        print("Người chơi hoặc bảng hiệu không còn hợp lệ, hoặc cách nhau quá xa.")
                    elseif IsNearDanger(who) then
                        if talk then
                            talk:Say("Đang có nguy hiểm, không thể dịch chuyển.")
                        elseif comment then
                            comment:Say("Đang có nguy hiểm, không thể dịch chuyển.")
                        end
                    elseif not TTT_TRAVEL.CampSecurityCheckPermissionUse(who, destination)
                        or (destination.components.ttt_travelable.ownership and
                        destination:HasTag(ownershiptag) and who.userid ~= nil and
                        not destination:HasTag("uid_" .. who.userid)) then
                        if comment then
                            comment:Say("Điểm đến riêng tư. Không cho phép khách ghé thăm.")
                        elseif talk then
                            talk:Say("Điểm đến này là riêng tư.")
                        end
                    elseif who.components.hunger and who.components.sanity then
                        who.components.hunger:DoDelta(-cost_hunger)
                        who.components.sanity:DoDelta(-cost_sanity)
                        if who.Physics ~= nil then
                            who.Physics:Teleport(xf, 0, zf)
                        else
                            who.Transform:SetPosition(xf, 0, zf)
                        end

                        -- follow
                        if who.components.leader and
                            who.components.leader.followers then
                            for kf, vf in pairs(who.components.leader.followers) do
                                if kf.Physics ~= nil then
                                    kf.Physics:Teleport(xf, 0, zf)
                                else
                                    kf.Transform:SetPosition(xf, 0, zf)
                                end
                            end
                        end

                        local inventory = who.components.inventory
                        if inventory then
                            for ki, vi in pairs(inventory.itemslots) do
                                if vi.components.leader and
                                    vi.components.leader.followers then
                                    for kif, vif in pairs(vi.components.leader.followers) do
                                        if kif.Physics ~= nil then
                                            kif.Physics:Teleport(xf, 0, zf)
                                        else
                                            kif.Transform:SetPosition(xf, 0, zf)
                                        end
                                    end
                                end
                            end
                        end

                        local container = inventory ~= nil and inventory:GetOverflowContainer() or nil
                        if container then
                            for kb, vb in pairs(container.slots) do
                                if vb.components.leader and
                                    vb.components.leader.followers then
                                    for kbf, vbf in pairs(vb.components.leader.followers) do
                                        if kbf.Physics ~= nil then
                                            kbf.Physics:Teleport(xf, 0, zf)
                                        else
                                            kbf.Transform:SetPosition(xf, 0, zf)
                                        end
                                    end
                                end
                            end
                        end

                        -- heavy objects nearby
                        if xi ~= nil and yi ~= nil and zi ~= nil then
                            local heavy_insts = TheSim:FindEntities(
                                xi, yi, zi, 3, { "heavy" })
                            for i, v in ipairs(heavy_insts) do
                                if v.components.equippable then
                                    if v.Physics ~= nil then
                                        v.Physics:Teleport(xf, 0, zf)
                                    else
                                        v.Transform:SetPosition(xf, 0, zf)
                                    end
                                end
                            end
                        end

                        if self.inst.components.writeable and
                            not self.inst.components.writeable:IsWritten() then
                            self.inst:Remove()
                        end
                    else
                        if talk then
                            talk:Say("Tôi không thể dịch chuyển.")
                        elseif comment then
                            comment:Say("Bạn không thể dịch chuyển.")
                        end
                    end
                end
                self.travellers = {}
            end)

            if TTT_TRAVEL.COUNTDOWN_ENABLE then
                self.traveltask5 = self.inst:DoTaskInTime(3, function()
                    comment:Say("Dịch chuyển sau 5 giây.")
                end)
                self.traveltask4 = self.inst:DoTaskInTime(4, function()
                    comment:Say("Hãy đứng gần bảng hiệu.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask3 = self.inst:DoTaskInTime(5, function()
                    comment:Say("Dịch chuyển sau 3 giây.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask2 = self.inst:DoTaskInTime(6, function()
                    comment:Say("Dịch chuyển sau 2 giây.")
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
                self.traveltask1 = self.inst:DoTaskInTime(7, function()
                    comment:Say("Dịch chuyển sau 1 giây.", 1)
                    self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
                end)
            end
        elseif comment then
            comment:Say("Không thể dịch chuyển đến điểm này.")
        elseif talk then
            talk:Say("Không thể dịch chuyển đến điểm này.")
        end
    end
    self:EndTravel()
end

function Travelable:CancelTravel(traveller)
    if self.traveltask ~= nil then
        self.traveltask:Cancel()
        self.traveltask = nil
    end
    if self.traveltask1 ~= nil then
        self.traveltask1:Cancel()
        self.traveltask1 = nil
    end
    if self.traveltask2 ~= nil then
        self.traveltask2:Cancel()
        self.traveltask2 = nil
    end
    if self.traveltask3 ~= nil then
        self.traveltask3:Cancel()
        self.traveltask3 = nil
    end
    if self.traveltask4 ~= nil then
        self.traveltask4:Cancel()
        self.traveltask4 = nil
    end
    if self.traveltask5 ~= nil then
        self.traveltask5:Cancel()
        self.traveltask5 = nil
    end
end

function Travelable:EndTravel()
    if self.traveller ~= nil then
        self.inst:StopUpdatingComponent(self)

        if self.screen ~= nil then
            self.traveller.HUD:CloseTTTTravelScreen()
            self.screen = nil
        end

        self.inst:RemoveEventCallback("ms_closepopups", self.onclosepopups, self.traveller)
        self.inst:RemoveEventCallback("onremove", self.onclosepopups, self.traveller)

        if IsXB1() then
            if self.traveller:HasTag("player") and
                self.traveller:GetDisplayName() then
                local ClientObjs = TheNet:GetClientTable()
                if ClientObjs ~= nil and #ClientObjs > 0 then
                    for i, v in ipairs(ClientObjs) do
                        if self.traveller:GetDisplayName() == v.name then
                            self.netid = v.netid
                            break
                        end
                    end
                end
            end
        end

        self.traveller = nil
    elseif self.screen ~= nil then
        -- Should not have screen with no traveller, but just in case...
        if self.screen.inst:IsValid() then self.screen:Kill() end
        self.screen = nil
    end
end

--------------------------------------------------------------------------
-- Check for auto-closing conditions
--------------------------------------------------------------------------

function Travelable:OnUpdate(dt)
    if self.traveller == nil then
        self.inst:StopUpdatingComponent(self)
    elseif not (self.traveller:IsNear(self.inst, 3) and
            CanEntitySeeTarget(self.traveller, self.inst)) then
        self:EndTravel()
    end
end

--------------------------------------------------------------------------

function Travelable:OnRemoveFromEntity()
    self:OnRemoveEntity()
    self.inst:RemoveTag("ttt_travelable")
end

function Travelable:OnRemoveEntity()
    self:EndTravel()
    for i, v in ipairs(ALL_TRAVELABLES) do
        if v == self then
            table.remove(ALL_TRAVELABLES, i)
            break
        end
    end
end

return Travelable
