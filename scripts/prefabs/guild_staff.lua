local assets = {
    Asset("ANIM", "anim/guild_staff.zip"),
    Asset("IMAGE", "images/hh_icon/guild_staff.tex"),
    Asset("ATLAS", "images/hh_icon/guild_staff.xml"),
}

local GuildStaffBrain = require("brains/guild_staffbrain")
local TALK_SOUND = "dontstarve/characters/wendy/talk_LP"

local GUILD_STAFF_DIALOGUES = {
    "Hiệp Hội luôn có nhiệm vụ phù hợp với từng bậc Rank.",
    "Hãy kiểm tra thời hạn trước khi nhận nhiệm vụ Hiệp Hội.",
    "Xu Hiệp Hội chỉ nhận được khi hoàn thành nhiệm vụ.",
    "Cửa hàng Hiệp Hội sẽ mở thêm vật phẩm khi Rank của bạn tăng.",
    "Thợ săn Rank E cũng có thể tiến xa nếu chuẩn bị cẩn thận.",
    "Kỳ thi thăng Rank chỉ mở khi bạn đạt đủ cấp độ yêu cầu.",
    "Đừng bước vào dungeon khi trang bị và vật phẩm hồi phục chưa đủ.",
    "Dungeon càng nguy hiểm thì phần thưởng càng đáng giá.",
    "Hãy luôn chừa đường rút lui khi khám phá dungeon.",
    "Sinh vật trong dungeon có thể nguy hiểm hơn vẻ ngoài của chúng.",
    "Igris là một chiến binh bóng tối đáng tin cậy.",
    "Beru sở hữu sức mạnh đáng sợ, nhưng việc trích xuất không hề dễ dàng.",
    "Fruitfly có thể hỗ trợ công việc quanh căn cứ.",
    "Tỷ lệ trích xuất bóng ma sẽ tăng theo bậc Rank của thợ săn.",
    "Hãy quản lý ma lực trước khi triệu hồi các đệ tử bóng tối.",
    "Đội quân bóng tối mạnh đến đâu cũng cần một chủ nhân biết tính toán.",
    "Nhiệm vụ Hiệp Hội kéo dài nhiều ngày, đừng để thời gian cạn kiệt.",
    "Bạn chỉ có thể nhận một nhiệm vụ Hiệp Hội tại một thời điểm.",
    "Hủy nhiệm vụ sẽ được ghi nhận là một lần thất bại.",
    "Sau khi hủy nhiệm vụ, Hiệp Hội cần thời gian xử lý hồ sơ mới.",
    "Hounds thường tấn công theo đàn, hãy chuẩn bị trước khi giao chiến.",
    "Clockwork trong Tàn Tích có đòn đánh rất nguy hiểm.",
    "Nhiên liệu ác mộng là tài nguyên hữu ích nhưng luôn đi kèm hiểm họa.",
    "Thulecite rất quý giá; đừng mạo hiểm vào Tàn Tích khi chưa sẵn sàng.",
    "Sinh vật Mặt Trăng có những cách tấn công khác với quái vật thông thường.",
    "Boss không chỉ cần sát thương cao mà còn cần chuẩn bị đúng chiến thuật.",
    "Thuốc hồi phục nên được mang theo trước mọi nhiệm vụ khó.",
    "Nhiệm vụ giao vật phẩm được hoàn tất trực tiếp qua bảng nhiệm vụ.",
    "Hãy xem tiến độ nhiệm vụ trong bảng chỉ số khi ở xa Hiệp Hội.",
    "Pig King là cột mốc dễ nhận biết để tìm Nhân Viên Hiệp Hội.",
}

local function ShuffleGuildStaffDialogues(inst)
    local order = {}
    for index = 1, #GUILD_STAFF_DIALOGUES do
        order[index] = index
    end
    for index = #order, 2, -1 do
        local swap_index = math.random(index)
        order[index], order[swap_index] = order[swap_index], order[index]
    end
    if inst._hh_last_dialogue_index ~= nil and order[1] == inst._hh_last_dialogue_index then
        order[1], order[2] = order[2], order[1]
    end
    inst._hh_dialogue_order = order
    inst._hh_dialogue_position = 1
end

local function SayGuildStaffDialogue(inst)
    if TheWorld.state.phase == "night" or inst.components.talker == nil then
        return
    end
    if inst._hh_dialogue_order == nil or inst._hh_dialogue_position > #inst._hh_dialogue_order then
        ShuffleGuildStaffDialogues(inst)
    end
    local dialogue_index = inst._hh_dialogue_order[inst._hh_dialogue_position]
    inst._hh_dialogue_position = inst._hh_dialogue_position + 1
    inst._hh_last_dialogue_index = dialogue_index
    inst.components.talker:Say(GUILD_STAFF_DIALOGUES[dialogue_index])
end

local function OnGuildStaffTalk(inst)
    inst.SoundEmitter:PlaySound(TALK_SOUND, "talk")
end

local function OnGuildStaffDoneTalking(inst)
    inst.SoundEmitter:KillSound("talk")
end

local function UpdateMapIconPosition(inst)
    local target = inst._target
    if target ~= nil and target:IsValid() then
        local x, _, z = target.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, 0, z)
    end
end

local function TrackMapIconEntity(inst, target)
    inst._target = target
    inst:ListenForEvent("onremove", function()
        inst:Remove()
    end, target)
    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(UpdateMapIconPosition)
    UpdateMapIconPosition(inst)
end

local function mapicon_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst:AddTag("globalmapicon")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("hh_guild_employee_mapicon")
    inst:SetPrefabNameOverride("guild_staff")
    inst.MiniMapEntity:SetIcon("guild_staff.tex")
    inst.MiniMapEntity:SetPriority(10)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetIsProxy(true)
    inst.entity:SetCanSleep(false)
    RegisterGlobalMapIcon(inst, "guild_staff")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.TrackEntity = TrackMapIconEntity
    return inst
end

local function GetDisplayName()
    return STRINGS.NAMES.GUILD_STAFF or "Nhân Viên Hiệp Hội"
end

local function RefreshAnimation(inst)
    local sleeping = TheWorld.state.phase == "night"
    if sleeping and inst._hh_guild_sleeping ~= true then
        inst._hh_guild_sleeping = true
        if TheWorld.ismastersim and inst.sg ~= nil then
            inst.sg:GoToState("sleep")
        else
            inst.AnimState:PlayAnimation("dozy")
            inst.AnimState:PushAnimation("sleep_loop", true)
        end
        if TheWorld.ismastersim then
            for _, player in ipairs(AllPlayers or {}) do
                if player.components.hh_rank then
                    player.components.hh_rank:CloseInterface()
                end
            end
        end
    elseif not sleeping and inst._hh_guild_sleeping ~= false then
        local initialized = inst._hh_guild_sleeping ~= nil
        inst._hh_guild_sleeping = false
        if TheWorld.ismastersim and inst.sg ~= nil then
            inst.sg:GoToState(initialized and "wakeup" or "idle")
        elseif initialized then
            inst.AnimState:PlayAnimation("wakeup")
            inst.AnimState:PushAnimation("idle_loop", true)
        else
            inst.AnimState:PlayAnimation("idle_loop", true)
        end
    end
end

local function IsGuildBusy(inst)
    local busy = false
    for player in pairs(inst._hh_guild_users) do
        if player == nil or not player:IsValid() then
            inst._hh_guild_users[player] = nil
        else
            busy = true
        end
    end
    return busy
end

local function BeginGuildInteraction(inst, player)
    if player ~= nil and player:IsValid() then
        inst._hh_guild_users[player] = true
    end
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:Stop()
    end
end

local function EndGuildInteraction(inst, player)
    if player ~= nil then
        inst._hh_guild_users[player] = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    MakeCharacterPhysics(inst, 100, .5)

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(1.3, .65)
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("guild_staff")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.entity:SetCanSleep(false)
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Hide("HEAD_HAT")

    inst.MiniMapEntity:SetIcon("guild_staff.tex")
    inst.MiniMapEntity:SetPriority(10)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    if RegisterGlobalMapIcon ~= nil then
        RegisterGlobalMapIcon(inst, "guild_staff")
    end

    inst:AddTag("hh_guild_employee")
    inst:AddTag("NOBLOCK")
    inst:AddTag("character")
    inst:SetPrefabNameOverride("guild_staff")
    inst.displaynamefn = GetDisplayName

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 34
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -250, 0)
    inst.components.talker.name_colour = Vector3(0.35, 0.75, 1)
    inst.components.talker.ontalkfn = OnGuildStaffTalk
    inst.components.talker.donetalkingfn = OnGuildStaffDoneTalking

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(180)
    end

    inst:WatchWorldState("phase", RefreshAnimation)
    RefreshAnimation(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = true
    inst._hh_guild_users = {}
    inst.IsGuildBusy = IsGuildBusy
    inst.BeginGuildInteraction = BeginGuildInteraction
    inst.EndGuildInteraction = EndGuildInteraction

    inst:AddComponent("inspectable")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.HH_GUILD and TUNING.HH_GUILD.STAFF_WALK_SPEED or 2.5
    inst:AddComponent("knownlocations")
    inst:SetStateGraph("SGguild_staff")
    inst:SetBrain(GuildStaffBrain)

    inst._hh_mapicon = SpawnPrefab("guild_staff_mapicon")
    if inst._hh_mapicon ~= nil then
        inst._hh_mapicon:TrackEntity(inst)
    end

    inst._hh_guild_sleeping = nil
    RefreshAnimation(inst)
    inst._hh_dialogue_task = inst:DoPeriodicTask(10, SayGuildStaffDialogue, 10)

    return inst
end

return Prefab("guild_staff", fn, assets, { "guild_staff_mapicon" }),
    Prefab("guild_staff_mapicon", mapicon_fn, assets)
