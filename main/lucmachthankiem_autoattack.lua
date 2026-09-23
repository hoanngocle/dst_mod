local G = GLOBAL
local EQUIPSLOTS, TUNING, STRINGS, FRAMES = G.EQUIPSLOTS, G.TUNING, G.STRINGS, G.FRAMES
local net_bool, SendModRPCToServer, MOD_RPC = G.net_bool, G.SendModRPCToServer, G.MOD_RPC
local resolvefilepath = G.resolvefilepath
local CRAFTING_ATLAS, CRAFTING_ICONS_ATLAS = G.CRAFTING_ATLAS, G.CRAFTING_ICONS_ATLAS
local ACTIONS, ActionHandler, IsEntityDead = G.ACTIONS, G.ActionHandler, G.IsEntityDead

local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local function GetLucMachThanKiem(player)
    local inventory = player.components.inventory
    if inventory then
        for k, v in pairs(inventory.equipslots) do
            if v and v:HasTag"lucmachthankiem" then
                return v
            end
        end
    end
end

AddModRPCHandler("lucmachthankiem", "ToggleAutoAttack", function(player, auto, recall)
    auto = auto or false

    local classified = player.player_classified
    if classified then
        classified.lucmachthankiem_auto_attack:set(auto)
        player.lucmachthankiem_auto_attack = auto
    end

    if auto == false then
        local lucmachthankiem = GetLucMachThanKiem(player)
        if lucmachthankiem then
            lucmachthankiem:Recall(recall)
        end
    end

end)

AddPrefabPostInit("player_classified" ,function(inst)
    inst.lucmachthankiem_auto_attack = net_bool(inst.GUID, "lucmachthankiem_auto_attack", "lucmachthankiem_auto_attack")
    inst.lucmachthankiem_auto_attack:set(true)

    inst.equip_lucmachthankiem = net_bool(inst.GUID, "equip_lucmachthankiem", "equip_lucmachthankiem")

    inst:ListenForEvent("equip_lucmachthankiem", function(inst)
        if inst._parent then
            local equip = inst.equip_lucmachthankiem:value()
            inst._parent:PushEvent("equip_lucmachthankiem", {equip = equip})
        end
    end)
end)

local function BuildAutoAttackButton(controls)
    if controls.inv == nil or controls.inv.equip == nil or controls.inv.hand_inv == nil then
        return nil
    end
    local hands = controls.inv.equip[EQUIPSLOTS.HANDS]
    if hands == nil then return nil end
    local offset_x = hands:GetPosition().x

    if TUNING.LUCMACHTHANKIEM_SLOT == 0 then
        offset_x = 0
    elseif TUNING.LUCMACHTHANKIEM_SLOT == 2 and EQUIPSLOTS.NECK and controls.inv.equip[EQUIPSLOTS.NECK] then
        offset_x = controls.inv.equip[EQUIPSLOTS.NECK]:GetPosition().x - offset_x
    else
        local body = controls.inv.equip[EQUIPSLOTS.BODY]
        offset_x = body and body:GetPosition().x - offset_x or 0
    end

    local w = controls.inv.hand_inv:AddChild(Widget())
    w:SetPosition(offset_x/1.5, 35, 0)
    w:SetScale(0.7)

    local atlas = resolvefilepath(CRAFTING_ATLAS)
    w.button = w:AddChild(ImageButton(atlas, "filterslot_frame.tex", "filterslot_frame_highlight.tex", nil, nil, "filterslot_frame_select.tex"))

    w.img = w:AddChild(Image(resolvefilepath(CRAFTING_ICONS_ATLAS), "filter_weapon.tex"))
    w.img:ScaleToSize(54, 54)
    w.img:MoveToBack()

    w.bg = w:AddChild(Image(atlas, "filterslot_bg_highlight.tex"))
    w.bg:MoveToBack()

    w.auto = true
    w:SetTooltip(STRINGS.LUCMACHTHANKIEM_AUTOATTACK.ENABLED)

    w.button:SetOnClick(function()
        local classified = controls.owner and controls.owner.player_classified
        if classified then
            local auto = classified.lucmachthankiem_auto_attack:value()
            if auto then
                auto = false
                w:SetTooltip(STRINGS.LUCMACHTHANKIEM_AUTOATTACK.DISABLED)
                w.bg:SetTexture(atlas, "filterslot_bg.tex")
            else
                auto = true
                w:SetTooltip(STRINGS.LUCMACHTHANKIEM_AUTOATTACK.ENABLED)
                w.bg:SetTexture(atlas, "filterslot_bg_highlight.tex")
            end
            w.auto = auto
            SendModRPCToServer(MOD_RPC["lucmachthankiem"]["ToggleAutoAttack"], auto, true)
        end
    end)

    w:Hide()
    return w
end

AddClassPostConstruct("widgets/controls", function(self)
    -- Wait EquipSlot initialized
    self.inst:DoTaskInTime(10*FRAMES, function()
        self.lucmachthankiem_button = BuildAutoAttackButton(self)
        if self.lucmachthankiem_button == nil then return end

        local classified = self.owner.player_classified
        if classified and classified.equip_lucmachthankiem:value() then
            self.lucmachthankiem_button:Show()
        end

        self.inst:ListenForEvent("equip_lucmachthankiem", function(player, data)
            local equip = data and data.equip
            if equip then
                self.lucmachthankiem_button:Show()
            else
                self.lucmachthankiem_button:Hide()
            end
        end, self.owner)
    end)
end)
