local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

local ART = "images/ttt_portal/"
local CREAM = { 0.91, 0.85, 0.72, 1 }
local VIOLET = { 0.72, 0.64, 0.95, 1 }

local function IsFinite(value)
    return value ~= nil and value == value and value > -math.huge and value < math.huge
end

local function Label(parent, size, y, width, colour)
    local text = parent:AddChild(Text(BODYTEXTFONT, size))
    text:SetPosition(0, y)
    text:SetRegionSize(width, size + 10)
    text:SetHAlign(ANCHOR_MIDDLE)
    text:SetColour(unpack(colour or CREAM))
    return text
end

local TravelScreen = Class(Screen, function(self, owner, attach)
    Screen._ctor(self, "TTTPortalSelector")
    self.owner = owner
    self.attach = attach
    self.isopen = true
    self.dest_infos = {}
    self.selected_index = 1
    self.angle = 0
    self.refresh_time = 0

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.scalingroot = self:AddChild(Widget("ttt_portal_scaling"))
    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
    self.inst:ListenForEvent("continuefrompause", function()
        if self.isopen then self.scalingroot:SetScale(TheFrontEnd:GetHUDScale()) end
    end, TheWorld)
    self.inst:ListenForEvent("refreshhudsize", function(_, scale)
        if self.isopen then self.scalingroot:SetScale(scale) end
    end, owner.HUD.inst)
    self.root = self.scalingroot:AddChild(TEMPLATES.ScreenRoot("root"))

    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.72)
    self.black.OnMouseButton = function(_, button, down)
        if down then self:OnCancel() end
        return true
    end

    self.panel = self.root:AddChild(Widget("ttt_portal_panel"))
    self.background = self.panel:AddChild(Image(ART .. "panel.xml", "panel.tex"))
    self.background:SetSize(490, 700)
    -- The panel consumes clicks so only clicks outside it close the screen.
    self.background.OnMouseButton = function() return true end

    self.title = Label(self.panel, 32, 263, 365)
    self.title:SetString("CHỌN ĐIỂM ĐẾN")
    self.current = Label(self.panel, 19, 226, 330, VIOLET)

    self.vortex_root = self.panel:AddChild(Widget("ttt_portal_vortex"))
    self.vortex_root:SetPosition(0, 31)
    self.vortex_root:SetScale(0.80, 1.05, 1)
    self.vortex = self.vortex_root:AddChild(Image(ART .. "vortex.xml", "vortex.tex"))
    self.vortex:SetSize(190, 190)
    self.vortex:SetClickable(false)
    self.gate = self.panel:AddChild(Image(ART .. "frame.xml", "frame.tex"))
    self.gate:SetSize(300, 300)
    self.gate:SetPosition(0, 45)
    self.gate:SetClickable(false)

    self.previous = self.panel:AddChild(TEMPLATES.StandardButton(
        function() self:StepDestination(-1) end, "<", { 55, 48 }))
    self.previous:SetPosition(-171, 43)
    self.next = self.panel:AddChild(TEMPLATES.StandardButton(
        function() self:StepDestination(1) end, ">", { 55, 48 }))
    self.next:SetPosition(171, 43)

    self.destination = Label(self.panel, 29, -108, 345)
    self.counter = Label(self.panel, 20, -143, 335, VIOLET)
    self.hunger = Label(self.panel, 23, -178, 155)
    self.hunger:SetPosition(-86, -178)
    self.sanity = Label(self.panel, 23, -178, 165)
    self.sanity:SetPosition(86, -178)
    self.travelbutton = self.panel:AddChild(TEMPLATES.StandardButton(
        function() self:Travel(self.selected_index) end, "DỊCH CHUYỂN", { 265, 48 }))
    self.travelbutton:SetPosition(0, -231)
    self.cancelbutton = self.panel:AddChild(TEMPLATES.StandardButton(
        function() self:OnCancel() end, "ĐÓNG", { 130, 39 }))
    self.cancelbutton:SetPosition(0, -284)

    self.previous:SetFocusChangeDir(MOVE_RIGHT, self.next)
    self.next:SetFocusChangeDir(MOVE_LEFT, self.previous)
    local function DownFromArrow()
        return self.travelbutton.enabled and self.travelbutton or self.cancelbutton
    end
    local function UpFromCancel()
        return self.travelbutton.enabled and self.travelbutton
            or (self.next.enabled and self.next or nil)
    end
    self.previous:SetFocusChangeDir(MOVE_DOWN, DownFromArrow)
    self.next:SetFocusChangeDir(MOVE_DOWN, DownFromArrow)
    self.travelbutton:SetFocusChangeDir(MOVE_UP, function()
        return self.next.enabled and self.next or self.cancelbutton
    end)
    self.travelbutton:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, UpFromCancel)
    self.default_focus = self.cancelbutton

    self:LoadDests()
    self:StartUpdating()
end)

function TravelScreen:GetReplica()
    return self.attach ~= nil and self.attach:IsValid()
        and self.attach.replica.ttt_travelable or nil
end

function TravelScreen:LoadDests()
    local replica = self:GetReplica()
    local info_pack = replica ~= nil and replica:GetDestInfos() or ""
    if info_pack == self.last_info_pack then return end
    local first_load = self.last_info_pack == nil or #self.dest_infos == 0
    self.last_info_pack = info_pack
    self.dest_infos = {}
    self.current_name = nil

    if type(info_pack) == "string" and info_pack ~= "" then
        for line in (info_pack .. "\n"):gmatch("(.-)\n") do
            local index, name, hunger, sanity = line:match("^(%d+)\t([^\t]*)\t([^\t]+)\t([^\t]+)$")
            index, hunger, sanity = tonumber(index), tonumber(hunger), tonumber(sanity)
            if index ~= #self.dest_infos + 1 or not IsFinite(hunger) or not IsFinite(sanity) then
                self.dest_infos = {}
                break
            end
            name = name ~= "~nil" and name ~= "" and name or "Chưa đặt tên"
            self.dest_infos[index] = { index = index, name = name, cost_hunger = hunger, cost_sanity = sanity }
            if hunger == -1 and sanity == -1 then self.current_name = name end
        end
    end

    self.selected_index = math.min(self.selected_index, math.max(1, #self.dest_infos))
    if first_load then
        for index, info in ipairs(self.dest_infos) do
            if info.cost_hunger >= 0 and info.cost_sanity >= 0 then
                self.selected_index = index
                break
            end
        end
    end
    self:RefreshSelection()
end

function TravelScreen:SetTravelAvailable(available)
    if available then
        self.travelbutton:Enable()
    else
        local had_focus = self.travelbutton.focus
        self.travelbutton:Disable()
        if had_focus then self.cancelbutton:SetFocus() end
    end
end

function TravelScreen:RefreshSelection()
    local count = #self.dest_infos
    local info = self.dest_infos[self.selected_index]
    self.current:SetTruncatedString("Đang ở: " .. (self.current_name or "Chưa đặt tên"), 330, nil, "...")
    if count > 1 then
        self.previous:Enable()
        self.next:Enable()
    else
        self.previous:Disable()
        self.next:Disable()
    end
    if info == nil then
        self.destination:SetString("Không có điểm đến")
        self.counter:SetString("Đặt thêm cổng để kết nối")
        self.hunger:SetString("Độ no: —")
        self.sanity:SetString("Tinh thần: —")
        self.vortex:SetTint(0.4, 0.4, 0.4, 0.35)
        self:SetTravelAvailable(false)
        return
    end

    self.destination:SetTruncatedString(info.name, 345, nil, "...")
    local available = info.cost_hunger >= 0 and info.cost_sanity >= 0
    local current = info.cost_hunger == -1 and info.cost_sanity == -1
    self.counter:SetString(current and "Bạn đang ở đây"
        or (available and string.format("Điểm %d / %d", self.selected_index, count) or "Không thể đến điểm này"))
    self.hunger:SetString("Độ no: " .. (available and tostring(math.ceil(info.cost_hunger)) or "—"))
    self.sanity:SetString("Tinh thần: " .. (available and tostring(math.ceil(info.cost_sanity)) or "—"))
    self.vortex:SetTint(available and 1 or 0.5, available and 1 or 0.5, 1, available and 1 or 0.45)
    self:SetTravelAvailable(available)
end

function TravelScreen:StepDestination(step)
    local count = #self.dest_infos
    if not self.isopen or count < 2 then return end
    self.selected_index = ((self.selected_index - 1 + step) % count) + 1
    self:RefreshSelection()
end

function TravelScreen:Travel(index)
    if not self.isopen then return end
    local replica = self:GetReplica()
    local info = self.dest_infos[index]
    if replica == nil or info == nil or info.cost_hunger < 0 or info.cost_sanity < 0 then return end
    replica:Travel(self.owner, index)
    self.owner.HUD:CloseTTTTravelScreen()
end

function TravelScreen:OnCancel()
    if not self.isopen then return end
    local replica = self:GetReplica()
    if replica ~= nil then replica:Travel(self.owner, nil) end
    if self.owner ~= nil and self.owner.HUD ~= nil then
        self.owner.HUD:CloseTTTTravelScreen()
    else
        self:Close()
    end
end

function TravelScreen:OnControl(control, down)
    if not down then
        if control == CONTROL_CANCEL then
            self:OnCancel()
            return true
        elseif control == CONTROL_MOVE_LEFT then
            self:StepDestination(-1)
            return true
        elseif control == CONTROL_MOVE_RIGHT then
            self:StepDestination(1)
            return true
        elseif control == CONTROL_OPEN_DEBUG_CONSOLE then
            return true
        end
    end
    return TravelScreen._base.OnControl(self, control, down)
end

function TravelScreen:OnUpdate(dt)
    if not self.isopen then return end
    if self:GetReplica() == nil or self.attach:HasTag("burnt") or self.attach:HasTag("fire") then
        self:OnCancel()
        return
    end
    self.angle = (self.angle + dt * 14) % 360
    self.vortex:SetRotation(self.angle)
    self.refresh_time = self.refresh_time + dt
    if self.refresh_time >= 0.25 then
        self.refresh_time = 0
        self:LoadDests()
    end
end

function TravelScreen:Close()
    if not self.isopen then return end
    self.isopen = false
    self:StopUpdating()
    self.attach = nil
    self.inst:DoTaskInTime(0, function() TheFrontEnd:PopScreen(self) end)
end

return TravelScreen
