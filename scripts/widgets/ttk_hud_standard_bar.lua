-- Standard renderer adapted from Simple Health Bar DST 2.16 by DYC.
-- This module intentionally keeps only the original Standard visual path.
local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")

local Standard = {}

local BASIC_ATLAS = "images/ttk_dyc_white.xml"
local BASIC_TEXTURE = "ttk_dyc_white.tex"
local BASE_WIDTH = 120
local FIXED_HEIGHT = 22
local BAR_MARGIN = 3
local OPACITY = 0.8
local FONT_SIZE = 24
local HEALTH_REDUCTION_DURATION = 0.8

local ENTITY_RULES = {
    {prefab = "shadowtentacle", width = 0.5, height = 2},
    {prefab = "mean_flytrap", width = 0.9, height = 2.3},
    {prefab = "thunderbird", width = 0.85, height = 2.05},
    {prefab = "glowfly", width = 0.6, height = 2},
    {prefab = "peagawk", width = 0.85, height = 2.1},
    {prefab = "krampus", width = 1, height = 3.75},
    {prefab = "nightmarebeak", width = 1, height = 4.5},
    {prefab = "terrorbeak", width = 1, height = 4.5},
    {prefab = "spiderqueen", width = 2, height = 4.5},
    {prefab = "warg", width = 1.7, height = 5},
    {prefab = "pumpkin_lantern", width = 0.7, height = 1.5},
    {prefab = "jellyfish_planted", width = 0.7, height = 1.5},
    {prefab = "babybeefalo", width = 1, height = 2.2},
    {prefab = "beeguard", width = 0.65, height = 2},
    {prefab = "shadow_rook", width = 1.8, height = 3.5},
    {prefab = "shadow_bishop", width = 0.9, height = 3.2},
    {prefab = "walrus", width = 1.1, height = 3.2},
    {prefab = "teenbird", width = 1, height = 3.6},
    {tag = "player", width = 1, height = 2.65},
    {tag = "ancient_hulk", width = 1.85, height = 4.5},
    {tag = "antqueen", width = 2.4, height = 8},
    {tag = "ro_bin", width = 0.9, height = 2.8},
    {tag = "gnat", width = 0.75, height = 3},
    {tag = "spear_trap", width = 0.75, height = 3},
    {tag = "hangingvine", width = 0.85, height = 4},
    {tag = "weevole", width = 0.6, height = 1.2},
    {tag = "flytrap", width = 1, height = 3.4},
    {tag = "vampirebat", width = 1, height = 3},
    {tag = "pangolden", width = 1.4, height = 3.8},
    {tag = "spider_monkey", width = 1.6, height = 4},
    {tag = "hippopotamoose", width = 1.35, height = 3.1},
    {tag = "piko", width = 0.5, height = 1},
    {tag = "pog", width = 0.85, height = 2},
    {tag = "ant", width = 0.8, height = 2.3},
    {tag = "scorpion", width = 0.85, height = 2},
    {tag = "dungbeetle", width = 0.8, height = 2.3},
    {tag = "civilized", width = 1, height = 3.2},
    {tag = "koalefant", width = 1.7, height = 4},
    {tag = "spat", width = 1.5, height = 3.5},
    {tag = "lavae", width = 0.8, height = 1.5},
    {tag = "glommer", width = 0.9, height = 2.9},
    {tag = "deer", width = 1, height = 3.1},
    {tag = "snake", width = 0.85, height = 1.7},
    {tag = "eyeturret", width = 1, height = 4.5},
    {tag = "primeape", width = 0.85, height = 1.5},
    {tag = "monkey", width = 0.85, height = 1.5},
    {tag = "ox", width = 1.5, height = 3.75},
    {tag = "beefalo", width = 1.5, height = 3.75},
    {tag = "kraken", width = 2, height = 5.5},
    {tag = "nightmarecreature", width = 1.25, height = 3.5},
    {tag = "bishop", width = 1, height = 4},
    {tag = "rook", width = 1.25, height = 4},
    {tag = "knight", width = 1, height = 3},
    {tag = "bat", width = 0.8, height = 3},
    {tag = "minotaur", width = 1.75, height = 4.5},
    {tag = "packim", width = 0.9, height = 3.75},
    {tag = "stungray", width = 0.9, height = 3.75},
    {tag = "ghost", width = 0.9, height = 3.75},
    {tag = "tallbird", width = 1.25, height = 5},
    {tag = "chester", width = 0.85, height = 1.5},
    {tag = "hutch", width = 0.85, height = 1.5},
    {tag = "wall", width = 0.5, height = 1.5},
    {tag = "largecreature", width = 2, height = 7.2},
    {tag = "insect", width = 0.5, height = 1.6},
    {tag = "smallcreature", width = 0.85, height = 1.5},
}

local function HasTag(entity, tag)
    return entity ~= nil and entity.HasTag ~= nil and entity:HasTag(tag)
end

local function EntityRuleValue(entity, key, default)
    if entity == nil then return default end
    for _, rule in ipairs(ENTITY_RULES) do
        if rule[key] ~= nil and (entity.prefab == rule.prefab
            or (rule.tag ~= nil and HasTag(entity, rule.tag))) then
            return rule[key]
        end
    end
    return default
end

function Standard.GetEntityWidth(entity)
    return EntityRuleValue(entity, "width", 1)
end

function Standard.GetEntityHeight(entity)
    return EntityRuleValue(entity, "height", 2.65)
end

function Standard.ResolveDynamic2(owner, player)
    if owner ~= nil and owner == player then return 0.15, 0.55, 0.7, 1 end

    local components = owner ~= nil and owner.components or nil
    local combat = components ~= nil and components.combat or nil
    if combat ~= nil and combat.target == player and not HasTag(owner, "chester")
        and type(combat.defaultdamage) == "number" and combat.defaultdamage > 0 then
        return 0.8, 0, 0, 1
    end

    local replica = owner ~= nil and owner.replica or nil
    local replica_combat = replica ~= nil and replica.combat or nil
    if replica_combat ~= nil and replica_combat.GetTarget ~= nil
        and replica_combat:GetTarget() == player then
        return 0.8, 0, 0, 1
    end

    local follower = components ~= nil and components.follower or nil
    if follower ~= nil and follower.leader == player then return 0.1, 0.7, 0.2, 1 end
    local replica_follower = replica ~= nil and replica.follower or nil
    if replica_follower ~= nil and replica_follower.GetLeader ~= nil
        and replica_follower:GetLeader() == player then
        return 0.1, 0.7, 0.2, 1
    end
    if HasTag(owner, "hostile") then return 0.8, 0.5, 0.1, 1 end
    if HasTag(owner, "monster") then return 0.7, 0.7, 0.1, 1 end
    if HasTag(owner, "chester") or HasTag(owner, "companion") then
        return 0.1, 0.7, 0.2, 1
    end
    if HasTag(owner, "player") then return 117 / 255, 27 / 255, 198 / 255, 1 end
    return 0.7, 0.7, 0.7, 1
end

local function Lerp(a, b, amount)
    return a + (b - a) * amount
end

local function GetCameraDistance(target)
    if TheSim.GetCameraPos ~= nil then
        return Vector3(TheSim:GetCameraPos()):Dist(target:GetPosition())
    end

    local pitch = TheCamera.pitch * DEGREES
    local heading = TheCamera.heading * DEGREES
    local cos_pitch = math.cos(pitch)
    local cos_heading = math.cos(heading)
    local sin_heading = math.sin(heading)
    local forward_x = -cos_pitch * cos_heading
    local forward_y = -math.sin(pitch)
    local forward_z = -cos_pitch * sin_heading
    local x_offset, z_offset = 0, 0
    if TheCamera.currentscreenxoffset ~= 0 then
        local screen_offset = 2 * TheCamera.currentscreenxoffset / RESOLUTION_Y
        local half_width = math.tan(TheCamera.fov * 0.5 * DEGREES)
            * TheCamera.distance * 1.03
        x_offset = -screen_offset * sin_heading * half_width
        z_offset = screen_offset * cos_heading * half_width
    end
    local camera = Vector3(
        TheCamera.currentpos.x - forward_x * TheCamera.distance + x_offset,
        TheCamera.currentpos.y - forward_y * TheCamera.distance,
        TheCamera.currentpos.z - forward_z * TheCamera.distance + z_offset)
    return camera:Dist(target:GetPosition())
end

local StandardBar = Class(Widget, function(self)
    Widget._ctor(self, "TTKSimpleHealthBarStandard")
    self:SetClickable(false)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(999)

    self.worldOffset = Vector3(0, 0, 0)
    self.screen_offset = Vector3(0, 0, 0)
    self.bg = self:AddChild(Image(BASIC_ATLAS, BASIC_TEXTURE))
    self.bg:SetClickable(false)
    self.bg2 = self:AddChild(Image(BASIC_ATLAS, BASIC_TEXTURE))
    self.bg2:SetClickable(false)
    self.text = self:AddChild(Text(NUMBERFONT, 20, ""))
    self.bar = self:AddChild(Image(BASIC_ATLAS, BASIC_TEXTURE))
    self.bar:SetClickable(false)
    self.bar:MoveToFront()
    self.text:MoveToFront()

    self.healthReductions = {}
    self.showValue = true
    self.percentage = 1
    self.opacity = OPACITY
    self.hbWidth = BASE_WIDTH
    self.hbHeight = 18
    self.fontSize = 20
    self.hrDuration = HEALTH_REDUCTION_DURATION
    self.screenWidth, self.screenHeight = TheSim:GetScreenSize()
    self.barColor = {r = 1, g = 1, b = 1}
    self.hrColor = {r = 1, g = 1, b = 1}
    self:SetHBSize(BASE_WIDTH, 18)
    self:SetFontSize(20)
    self:SetOpacity(OPACITY)
    self:StartUpdating()
end)

function StandardBar:GetSize()
    return self.bg:GetSize()
end

function StandardBar:GetBarFullSize()
    local width, height = self:GetSize()
    return math.max(width - BAR_MARGIN * 2, 2),
        math.max(height - BAR_MARGIN * 2, 2)
end

function StandardBar:GetBarVirtualSize()
    local width, height = self:GetSize()
    return math.max(width - BAR_MARGIN * 2, 0),
        math.max(height - BAR_MARGIN * 2, 0)
end

function StandardBar:SetHBSize(width, height)
    width = math.max(width or self.hbWidth, 0)
    height = math.max(height or self.hbHeight, 0)
    self.hbWidth, self.hbHeight = width, height
    self.bg:SetSize(width, height)
    self.bg2:SetSize(math.max(width - 2, 0), math.max(height - 2, 0))
    self:SetPercentage(self.percentage, true)
end

function StandardBar:SetFontSize(size)
    self.fontSize = size or self.fontSize
    self.text:SetSize(self.fontSize)
    self.text:SetPosition(0, 0, 0)
end

function StandardBar:SetOpacity(opacity)
    self.opacity = opacity or self.opacity
    self.bg:SetTint(1, 1, 1, self.opacity)
    self.bg2:SetTint(0, 0, 0, self.opacity)
    self.bar:SetTint(self.barColor.r, self.barColor.g, self.barColor.b, self.opacity)
end

function StandardBar:SetBarColor(r, g, b)
    self.barColor.r, self.barColor.g, self.barColor.b = r or 1, g or 1, b or 1
    self:SetOpacity(self.opacity)
end

function StandardBar:SetTextColor(r, g, b, a)
    self.text:SetColour(r or 1, g or 1, b or 1, a or 1)
end

function StandardBar:DisplayHealthReduction(old_percentage, new_percentage)
    local reduction = self.bg2:AddChild(Image(BASIC_ATLAS, BASIC_TEXTURE))
    reduction:SetClickable(false)
    local width, height = self:GetBarVirtualSize()
    local reduction_width = width * math.max(0, old_percentage - new_percentage)
    local x = ((new_percentage + old_percentage) / 2 - 0.5) * width
    reduction:SetSize(reduction_width, height)
    reduction:SetPosition(x, 0, 0)
    reduction:SetTint(self.hrColor.r, self.hrColor.g, self.hrColor.b, self.opacity)
    reduction.fadeTimer = self.hrDuration
    self.healthReductions[#self.healthReductions + 1] = reduction
end

function StandardBar:SetPercentage(percentage, instant)
    local old_percentage = self.percentage
    percentage = math.max(0, math.min(percentage or old_percentage, 1))
    if old_percentage - percentage > 0.01 and not instant and self.shown then
        self:DisplayHealthReduction(old_percentage, percentage)
    end
    self.percentage = percentage

    local full_width, bar_height = self:GetBarFullSize()
    local virtual_width = self:GetBarVirtualSize()
    local width = full_width - virtual_width * (1 - percentage)
    self.bar:SetSize(width, bar_height)
    self.bar:SetPosition(-(full_width - width) / 2, 0, 0)
end

function StandardBar:SetValue(current, maximum, instant)
    maximum = math.max(1, maximum or 1)
    current = current or 0
    self.text:SetString(string.format("%d/%d", current, maximum))
    self:SetPercentage(current / maximum, instant)
end

function StandardBar:SetTarget(target)
    self.target = target
    self.entityHeight = Standard.GetEntityHeight(target)
end

function StandardBar:SetWorldOffset(offset)
    self.worldOffset = offset
end

function StandardBar:SetScreenOffset(x, y)
    self.screen_offset.x, self.screen_offset.y = x, y
end

function StandardBar:GetScreenOffset()
    return self.screen_offset.x, self.screen_offset.y
end

function StandardBar:SetYOffSet(offset)
    local screen_scale = self.screenWidth / 1920
    self:SetScreenOffset(-5 * screen_scale, offset * screen_scale)
end

function StandardBar:AnimateIn(speed)
    self.animHBWidth = self.hbWidth
    self.animIn = true
    self.animSpeed = speed or 5
    self:SetHBSize(0, self.hbHeight)
end

function StandardBar:AnimateOut(speed)
    self.animHBWidth = 0
    self.animOut = true
    self.animSpeed = speed or 5
end

function StandardBar:OnUpdate(dt)
    dt = dt or 0
    if self.target ~= nil and self.target:IsValid() then
        if dt > 0 then
            local distance = math.max(GetCameraDistance(self.target), 0.001)
            self:SetYOffSet((self.entityHeight or 2.65) * 60 * 30 / distance)
            if self.fontSize ~= FONT_SIZE then self:SetFontSize(FONT_SIZE) end
        end
        local world_position
        if self.target.AnimState ~= nil then
            world_position = Vector3(self.target.AnimState:GetSymbolPosition(
                self.symbol or "", self.worldOffset.x, self.worldOffset.y, self.worldOffset.z))
        else
            world_position = self.target:GetPosition()
        end
        if world_position ~= nil then
            local screen_position = Vector3(TheSim:GetScreenPos(world_position:Get()))
            screen_position.x = screen_position.x + self.screen_offset.x
            screen_position.y = screen_position.y + self.screen_offset.y
            self:SetPosition(screen_position)
        end
    end

    if self.animOut and dt > 0 then
        if math.abs(self.hbWidth - self.animHBWidth) < 3 then
            self.animOut = false
            self:SetHBSize(self.animHBWidth, self.hbHeight)
            self:Kill()
            return
        end
        self:SetHBSize(Lerp(self.hbWidth, self.animHBWidth, self.animSpeed * dt), self.hbHeight)
    elseif self.animIn and dt > 0 then
        if math.abs(self.hbWidth - self.animHBWidth) < 1 then
            self.animIn = false
            self:SetHBSize(self.animHBWidth, self.hbHeight)
        else
            self:SetHBSize(Lerp(self.hbWidth, self.animHBWidth, self.animSpeed * dt), self.hbHeight)
        end
    end

    for index = #self.healthReductions, 1, -1 do
        local reduction = self.healthReductions[index]
        reduction.fadeTimer = reduction.fadeTimer - dt
        if reduction.fadeTimer < 0 then
            table.remove(self.healthReductions, index)
            reduction:Kill()
            break
        end
        reduction:SetTint(self.hrColor.r, self.hrColor.g, self.hrColor.b,
            self.opacity * reduction.fadeTimer / self.hrDuration)
    end

    if self.showValue and not self.text.shown then
        self.text:Show()
    elseif not self.showValue and self.text.shown then
        self.text:Hide()
    end

    local width, height = TheSim:GetScreenSize()
    if width ~= self.screenWidth or height ~= self.screenHeight then
        self.screenWidth, self.screenHeight = width, height
        local distance = self.target ~= nil and math.max(GetCameraDistance(self.target), 0.001) or 30
        self:SetYOffSet((self.entityHeight or 2.65) * 60 * 30 / distance)
    end
end

Standard.Widget = StandardBar
Standard.BASE_WIDTH = BASE_WIDTH
Standard.FIXED_HEIGHT = FIXED_HEIGHT
Standard.OPACITY = OPACITY
Standard.FONT_SIZE = FONT_SIZE
Standard.HEALTH_REDUCTION_DURATION = HEALTH_REDUCTION_DURATION

return Standard
