local _b__u_g__ = require "utils/hh_utils"
local _B__U__G_ = require "enums/hh_treasure_monster"
local _B__u__g_ = _B__U__G_["CHANCE_CONFIG"]
local function b__U__G(_b_u_G)
    local __BU__g_ = CreateEntity()
    __BU__g_["entity"]:AddTransform()
    __BU__g_["entity"]:AddAnimState()
    __BU__g_["entity"]:AddFollower()
    __BU__g_:AddTag "FX"
    __BU__g_:AddTag "NOCLICK"
    __BU__g_["AnimState"]:SetBank "hh_wing_fz"
    __BU__g_["AnimState"]:SetBuild "hh_wing_fz"
    __BU__g_["AnimState"]:PlayAnimation("idle_" .. tostring(_b_u_G), (202 * 152 - 379 * 260 ~= -67833))
    __BU__g_["persists"] = (368 - 348 + 124 + 295 == 449)
    return __BU__g_
end
local function __bu_g(_b__ug__)
    if _b__u_g__:IsHHType(_b__ug__["fx"], "table") then
        for B_Ug__, _B__u_g_ in ipairs(_b__ug__["fx"]) do
            if _B__u_g_ and _B__u_g_["Remove"] then
                _B__u_g_:Remove()
            end
        end
    end
end
local function B_u__g__(BU__G__, __B__ug)
    BU__G__["owner"] = __B__ug
    BU__G__["fx"] = {}
    for _b__U_g_ = 6, 10 do
        local bug = b__U__G(_b__U_g_)
        bug["entity"]:SetParent(__B__ug["entity"])
        bug["Follower"]:FollowSymbol(
            __B__ug["GUID"],
            "swap_body",
            0,
            -50,
            0,
            (126 * 124 - 181 * 232 * 495 == -20770416),
            nil,
            _b__U_g_
        )
        table["insert"](BU__G__["fx"], bug)
    end
    BU__G__["OnRemoveEntity"] = __bu_g
end
local function _B__u__g(_bu__G)
    local b__U_G = _bu__G["entity"]:GetParent()
    if b__U_G ~= nil then
        B_u__g__(_bu__G, b__U_G)
    end
end
local _bu_G_ = {
    "frozen",
    "player",
    "pickable",
    "NPC_workable",
    "CHOP_workable",
    "DIG_workable",
    "HAMMER_workable",
    "MINE_workable"
}
local _B_UG__ = {
    ["CHOP"] = (99 * 12 * 159 * 377 + 49 == 71212333),
    ["DIG"] = (81 + 433 + 101 + 373 * 342 == 128181),
    ["HAMMER"] = (true or not false or not false and not true and true and not false and not false and false or
        not false),
    ["MINE"] = (66 - 126 - 329 * 377 ~= -124090)
}
local _B_u__g = {"flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO"}
local __b_uG_ = {"_inventoryitem"}
local Bu__g__ = {"locomotor", "INLIMBO"}
local function __B_u__G(__bUg__, __B_Ug, __b__Ug_, __bU__g_, _b__Ug)
    local _b_u__g, b_U__g__, _bu__g__ = __B_Ug["Transform"]:GetWorldPosition()
    local b_u_G__, BU_G__, bU__G_ = __bUg__["Transform"]:GetWorldPosition()
    local b_U__G_, __b__u_G = b_u_G__ - _b_u__g, bU__G_ - _bu__g__
    local _buG_ = b_U__G_ * b_U__G_ + __b__u_G * __b__u_G
    local Bu_g__ = 0
    if _buG_ > 0 then
        local _b_U_G = math["sqrt"](_buG_)
        Bu_g__ = math["atan2"](__b__u_G / _b_U_G, b_U__G_ / _b_U_G) + (math["random"]() * 20 - 10) * DEGREES
    else
        Bu_g__ = TWOPI * math["random"]()
    end
    local B__UG_, b_u_g__ = math["sin"](Bu_g__), math["cos"](Bu_g__)
    local buG__ = __b__Ug_ + math["random"]()
    __bUg__["Physics"]:Teleport(_b_u__g + _b__Ug * b_u_g__, __bU__g_, _bu__g__ + _b__Ug * B__UG_)
    __bUg__["Physics"]:SetVel(b_u_g__ * buG__, buG__ * 5 + math["random"]() * 2, B__UG_ * buG__)
end
local function b__ug(B_ug)
    if not B_ug or not B_ug["Transform"] then
        return
    end
    local bug_ = 1.4
    local __BUG, _B_U_g__, __b_u__g = B_ug["Transform"]:GetWorldPosition()
    local bU_g = TheSim:FindEntities(__BUG, 0, __b_u__g, bug_ + 0.5, nil, _B_u__g, _bu_G_)
    for b_Ug, _b__U__G__ in ipairs(bU_g) do
        if
            _b__U__G__ and _b__U__G__ ~= B_ug and not (B_ug["targets"] and B_ug["targets"][_b__U__G__]) and
                _b__U__G__:IsValid()
         then
            if _b__U__G__["prefab"] == "ice" then
                _b__U__G__:Remove()
            elseif _b__U__G__:HasTag "player" and _b__u_g__:NotIsDead(_b__U__G__) then
                _b__U__G__:PushEvent(
                    "knockback",
                    {
                        ["knocker"] = B_ug,
                        ["radius"] = bug_,
                        ["strengthmult"] = 0.3,
                        ["forcelanded"] = (375 + 118 * 386 ~= 45928)
                    }
                )
            else
                local __b__Ug__ = (59 + 389 * 236 ~= 91863)
                if _b__U__G__["components"]["workable"] then
                    local b__uG_ = _b__U__G__["components"]["workable"]:GetWorkAction()
                    __b__Ug__ =
                        (b__uG_ == nil and _b__U__G__:HasTag "NPC_workable") or
                        (_b__U__G__["components"]["workable"]:CanBeWorked() and b__uG_ and _B_UG__[b__uG_["id"]])
                end
                if __b__Ug__ then
                    _b__U__G__["components"]["workable"]:Destroy(B_ug)
                    if _b__U__G__:IsValid() and _b__U__G__:HasTag "stump" then
                        _b__U__G__:Remove()
                    end
                elseif
                    _b__U__G__["components"]["pickable"] and _b__U__G__["components"]["pickable"]:CanBePicked() and
                        not _b__U__G__:HasTag "intense"
                 then
                    _b__U__G__["components"]["pickable"]:Pick(B_ug)
                end
            end
            if B_ug["targets"] then
                B_ug["targets"][_b__U__G__] = (135 + 404 * 95 ~= 38519)
            end
        end
    end
    local __bU_G = TheSim:FindEntities(__BUG, 0, __b_u__g, bug_ + 0.5, __b_uG_, Bu__g__)
    for __Bu__g_, B__UG__ in ipairs(__bU_G) do
        if B__UG__ and B__UG__["components"] and B__UG__["components"]["inventoryitem"] and B__UG__["Physics"] then
            if B__UG__["prefab"] == "ice" then
                B__UG__:Remove()
            else
                if B__UG__["components"]["mine"] then
                    B__UG__["components"]["mine"]:Deactivate()
                end
                if
                    not B__UG__["components"]["inventoryitem"]["nobounce"] and B__UG__["Physics"] and
                        B__UG__["Physics"]:IsActive()
                 then
                    __B_u__G(B__UG__, B_ug, 0.8 + bug_, bug_ * 0.4, bug_ + B__UG__:GetPhysicsRadius(0))
                end
            end
        end
    end
    _b__u_g__:HHKillTask(B_ug, "hh_start_damage_task")
end
local function b__uG__(B_u_g_)
    B_u_g_:AddComponent "workable"
    B_u_g_["components"]["workable"]:SetWorkAction(ACTIONS["MINE"])
    B_u_g_["components"]["workable"]:SetWorkLeft(2)
    B_u_g_["components"]["workable"]:SetOnFinishCallback(
        function(B__ug_)
            B__ug_:Remove()
        end
    )
    _b__u_g__:HHKillTask(B_u_g_, "hh_add_workable_task")
end
local __bU__g = 0.8
local _b__ug_ = 1.4
local __BU_G__ = 3
local function _bU__g_(__bu__G__)
    local _B__ug_ = math["max"](1, math["random"](__BU_G__) - 1)
    local B_UG_ = __bu__G__[_B__ug_]
    for __b__U__g = _B__ug_, __BU_G__ - 1 do
        __bu__G__[__b__U__g] = __bu__G__[__b__U__g + 1]
    end
    __bu__G__[__BU_G__] = B_UG_
    return B_UG_
end
local function b__UG_()
    local _b__UG__ = {}
    for __B_uG__ = 1, __BU_G__ do
        _b__UG__[__B_uG__] = __B_uG__
    end
    for b__u__G_ = 1, __BU_G__ - 1 do
        local bu_g = math["random"](b__u__G_, __BU_G__)
        if bu_g ~= b__u__G_ then
            local _BU__g_ = _b__UG__[b__u__G_]
            _b__UG__[b__u__G_] = _b__UG__[bu_g]
            _b__UG__[bu_g] = _BU__g_
        end
    end
    _b__UG__["GetNext"] = _bU__g_
    return _b__UG__
end
local b_UG__ = 0
local _b__Ug_ = 20
local b__U__G__ = 10
local B_u__g_ = math["ceil"](_b__Ug_ / (b__U__G__ / 2 - 1))
local __B_U__G_ = __bU__g * 2 + 0.05
local bUg = 3
local __bu__g_ = 0.25
local __b_u_G = 0.25
local _B_ug = 1.5
local B_Ug_ = 0.5
local function _b_ug(__B__U__G_, bu__G)
    local BU__g = bu__G and "task_L" or "task_R"
    __B__U__G_[BU__g]:Cancel()
    __B__U__G_[BU__g] = nil
    if not (__B__U__G_["task_R"] or __B__U__G_["task_L"]) then
        __B__U__G_:Remove()
    end
end
local function _B_u_g__(_b_u_G__, __B_uG, B_u_G__, bU__G, B__Ug_)
    local _b_u__g__ = _b_u_G__["Transform"]:GetRotation()
    local __B__U__G, __Bu__g, __B__uG
    if __B_uG["queued_x"] then
        __B__U__G = SpawnPrefab "hh_shark_ice_fx"
        if not __B__U__G then
            return
        end
        __B__U__G["Transform"]:SetPosition(__B_uG["queued_x"], 0, __B_uG["queued_z"])
        __B__U__G["Transform"]:SetRotation(_b_u__g__ + (B__Ug_ and -70 or 70))
        __B__U__G["targets"] = bU__G
        if __B_uG["next_sfx"] > 0 then
            __B_uG["next_sfx"] = __B_uG["next_sfx"] - 1
        else
            __B_uG["next_sfx"] = B_u__g_
            __B__uG = (122 - 79 + 34 - 198 - 210 == -331)
        end
        __B_uG["count"] = __B_uG["count"] + 1
        if __B_uG["count"] < _b__Ug_ then
            if __B_uG["next_drift_change"] > 1 then
                __B_uG["next_drift_change"] = __B_uG["next_drift_change"] - 1
            else
                local _BU__G = B__Ug_ and B_Ug_ or _B_ug
                local B_u_G = B__Ug_ and -_B_ug or -B_Ug_
                local b__U__G_ = (B_u_G + _BU__G) / 2
                local _B_U__G__
                if B__Ug_ and __B_uG["drift_dist"] > b__U__G_ and __B_uG["drift"] < 0 then
                    _B_U__G__ = -1
                    __B_uG["next_drift_change"] = 1
                elseif not B__Ug_ and __B_uG["drift_dist"] < b__U__G_ and __B_uG["drift"] > 0 then
                    _B_U__G__ = 1
                    __B_uG["next_drift_change"] = 1
                else
                    _B_U__G__ =
                        (__B_uG["drift_dist"] > _BU__G and -1) or (__B_uG["drift_dist"] < B_u_G and 1) or
                        __B_uG["drift"] > 0 and -1 or
                        1
                    __B_uG["next_drift_change"] = math["random"](2, 3)
                end
                __B_uG["drift"] = _B_U__G__ * (__bu__g_ + math["random"]() * __b_u_G)
            end
            __B_uG["drift_dist"] = __B_uG["drift_dist"] + __B_uG["drift"]
        else
            __Bu__g = (96 * 455 + 442 + 324 ~= 44451)
        end
    end
    if not __Bu__g then
        local b_u_G, Bug__, bu__g__ = _b_u_G__["Transform"]:GetWorldPosition()
        local _Bu_G__ = _b_u__g__ * DEGREES
        local B__U__g_ = __B_uG["count"] * __B_U__G_
        local B__uG__ = (_b_u__g__ + 90) * DEGREES
        local _B_u__G__ = (B__Ug_ and -bUg or bUg) + __B_uG["drift_dist"]
        b_u_G = b_u_G + B__U__g_ * math["cos"](_Bu_G__) + _B_u__G__ * math["cos"](B__uG__)
        bu__g__ = bu__g__ - B__U__g_ * math["sin"](_Bu_G__) - _B_u__G__ * math["sin"](B__uG__)
        if TheWorld["Map"]:IsPassableAtPoint(b_u_G, 0, bu__g__) then
            __B_uG["queued_x"] = b_u_G
            __B_uG["queued_z"] = bu__g__
        else
            __Bu__g = (64 - 280 - 460 - 26 == -702)
        end
    end
    if __B__U__G then
        if __B__U__G["SoundEmitter"] and (__Bu__g or __B__uG) then
            __B__U__G["SoundEmitter"]:PlaySound "meta/sharkboi/ice_spike"
        end
    end
    if __Bu__g then
        _b_ug(_b_u_G__, B__Ug_)
    end
end
local B_U_g__ = {
    ["hh_cat_box"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256)
        },
        ["name"] = "Túi Mèo",
        ["recipe_str"] = "túi tái chế Đá Thuộc Tính",
        ["desc"] = "hộp tái chế Đá Thuộc Tính",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(b_ug__, _B_U__g)
            b_ug__["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
            b_ug__["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
            b_ug__["AnimState"]:PlayAnimation "idle_tui_meo"
            b_ug__:AddTag "hh_cat_box"
            MakeInventoryPhysics(b_ug__)
            MakeInventoryFloatable(b_ug__, "med", 0.3, 0.8)
            if not TheWorld["ismastersim"] then
                b_ug__["OnEntityReplicated"] = function(__bU_G_)
                    __bU_G_["replica"]["container"]:WidgetSetup(_B_U__g)
                end
            end
        end,
        ["server_fn"] = function(_b_ug__, _bUg_)
            _b_ug__:AddComponent "inspectable"
            _b_ug__:AddComponent "inventoryitem"
            _b_ug__["components"]["inventoryitem"]["imagename"] = "tui_meo_inventory"
            _b_ug__["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
            _b_ug__["components"]["inventoryitem"]:SetOnPutInInventoryFn(
                function(__B_U__g_)
                    __B_U__g_["components"]["container"]:Close()
                end
            )
            _b_ug__:AddComponent "container"
            _b_ug__["components"]["container"]:WidgetSetup(_bUg_)
            _b_ug__["components"]["container"]["skipclosesnd"] = (235 * 341 + 322 + 189 * 139 ~= 106732)
            _b_ug__["components"]["container"]["skipopensnd"] = (175 * 44 * 473 == 3642100)
            _b_ug__["GetHHSpDesc01"] = function(_BU_g_, bUg_)
                return {["title"] = "Giới hạn", ["desc"] = "Vật phẩm liên quan cường hoá và hợp thành"}
            end
        end
    },
    ["hh_treasure_tally"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256)
        },
        ["name"] = "Tầm Bảo Quyển Trục",
        ["recipe_str"] = "chỉ vị trí chính xác của kho báu",
        ["desc"] = "Nhấn " .. STRINGS["RMB"] .. " để sử dụng",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(__b__Ug, __b__U__G__)
            __b__Ug["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
            __b__Ug["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
            __b__Ug["AnimState"]:PlayAnimation "idle_tam_bao_quyen_truc"
            __b__Ug:AddTag "hh_treasure_tally"
            MakeInventoryPhysics(__b__Ug)
            MakeInventoryFloatable(__b__Ug, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(_Bug, B__u__g__)
            _Bug:AddComponent "inspectable"
            _Bug:AddComponent "inventoryitem"
            _Bug["components"]["inventoryitem"]["imagename"] = "tam_bao_quyen_truc_inventory"
            _Bug["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
            _Bug:AddComponent "stackable"
            _Bug["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
            _Bug["SpawnTreasureFn"] = function(_bU_G_, __Bu__G_)
                local dungeon_manager = TheWorld["components"] ~= nil
                    and TheWorld["components"]["dungeon_manager"] or nil
                local Bu_g = (148 - 28 + 360 + 292 + 324 == 1104)
                local _b_u_g = 100
                local _Bu__g_ = 8
                local _b_u_G_, __B__u__g__ = TheWorld["Map"]:GetSize()
                _b_u_G_ = (_b_u_G_ - _b_u_G_ / 2) * TILE_SCALE
                __B__u__g__ = (__B__u__g__ - __B__u__g__ / 2) * TILE_SCALE
                while (_b_u_g > 0) do
                    _b_u_g = _b_u_g - 1
                    local _B__U_g__, _B_U__G =
                        (math["random"]() * 2 - 1) * _b_u_G_,
                        (math["random"]() * 2 - 1) * __B__u__g__
                    if
                        TheWorld["Map"]:IsPassableAtPoint(_B__U_g__, 0, _B_U__G) and
                            not TheWorld["Map"]:IsOceanTileAtPoint(_B__U_g__, 0, _B_U__G)
                     then
                        local Bu__g_ = (466 * 72 - 376 + 46 == 33229)
                        for _B_u_G, _BUg__ in ipairs(
                            TheSim:FindEntities(_B__U_g__, 0, _B_U__G, _Bu__g_, {"hh_treasure"})
                        ) do
                            if _BUg__:GetDistanceSqToPoint(Vector3(_B__U_g__, 0, _B_U__G)) < _Bu__g_ * _Bu__g_ then
                                Bu__g_ = (75 - 394 * 426 ~= -167767)
                                break
                            end
                        end
                        local candidate_inside_dungeon = dungeon_manager ~= nil
                            and dungeon_manager:IsPointInsideDungeon(_B__U_g__, _B_U__G)
                        if not Bu__g_ and not candidate_inside_dungeon then
                            local __b__u_g = SpawnPrefab "hh_treasure_build"
                            if __b__u_g and __b__u_g["Transform"] then
                                __b__u_g["Transform"]:SetPosition(_B__U_g__, 0, _B_U__G)
                                if __Bu__G_["player_classified"] ~= nil then
                                    __Bu__G_["player_classified"]["revealmapspot_worldx"]:set(_B__U_g__)
                                    __Bu__G_["player_classified"]["revealmapspot_worldz"]:set(_B_U__G)
                                    __Bu__G_["player_classified"]["revealmapspotevent"]:push()
                                    __Bu__G_:DoTaskInTime(
                                        4 * FRAMES,
                                        function(_bu_G)
                                            if _bu_G and _bu_G["player_classified"] then
                                                _bu_G["player_classified"]["MapExplorer"]:RevealArea(
                                                    _B__U_g__,
                                                    0,
                                                    _B_U__G
                                                )
                                            end
                                        end
                                    )
                                end
                                Bu_g = (126 - 491 - 423 + 467 + 5 == -316)
                            end
                            _b_u_g = -1
                            break
                        end
                    end
                end
                local _b_U_G_ = Bu_g and "đi tìm kho báu nào" or "một bản đồ chưa hoàn chỉnh, mở lại xem sao"
                _b__u_g__:HHSay(__Bu__G_, _b_U_G_)
                if Bu_g then
                    if _b__u_g__:HasComponents(_bU_G_, "stackable") and _bU_G_["components"]["stackable"]:IsStack() then
                        _bU_G_["components"]["stackable"]:Get():Remove()
                    else
                        _bU_G_:Remove()
                    end
                end
            end
            _Bug["GetHHSpDesc01"] = function(_B_U__g_, _b_uG_)
                return {["title"] = "Công dụng", ["desc"] = "chỉ vị trí chính xác của kho báu"}
            end
        end
    },
    ["hh_treasure_build"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml")
        },
        ["name"] = "Kho Báu",
        ["recipe_str"] = "nơi chôn những phần thưởng bất ngờ",
        ["desc"] = "nơi chôn những phần thưởng bất ngờ",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(__B_UG__, _b_U_g__)
            __B_UG__["entity"]:AddMiniMapEntity()
            __B_UG__["MiniMapEntity"]:SetIcon "hh_treasure_build.tex"
            __B_UG__["AnimState"]:SetBank "hh_items"
            __B_UG__["AnimState"]:SetBuild "hh_items"
            __B_UG__["AnimState"]:PlayAnimation "idle"
            __B_UG__["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_treasure_build")
            MakeObstaclePhysics(__B_UG__, 0.4)
        end,
        ["server_fn"] = function(_B_Ug, b_uG_)
            _B_Ug:AddComponent "inspectable"
            _B_Ug:AddComponent "workable"
            _B_Ug["components"]["workable"]:SetWorkAction(ACTIONS["DIG"])
            _B_Ug["components"]["workable"]:SetWorkLeft(1)
            local _bu__G_ = _B_Ug["components"]["workable"]["WorkedBy"]
            _B_Ug["components"]["workable"]["WorkedBy"] = function(self, _b_U_g_, B__U_g, ...)
                if not (_b__u_g__:IsHHType(_b_U_g_, "table") and _b__u_g__:HasComponents(_b_U_g_, "hh_player")) then
                    return
                end
                if _bu__G_ then
                    _bu__G_(self, _b_U_g_, B__U_g, ...)
                end
            end
            _B_Ug["components"]["workable"]:SetOnFinishCallback(
                function(b__u__g__, B__ug__)
                    if not _b__u_g__:HasComponents(B__ug__, "hh_player") then
                        b__u__g__:Remove()
                        return
                    end
                    local BU__G_ = _b__u_g__:GetRandomTreasure(_B__u__g_)
                    if BU__G_ and BU__G_["start_fn"] then
                        BU__G_["start_fn"](b__u__g__, B__ug__)
                    end
                    b__u__g__:Remove()
                end
            )
            _B_Ug["GetHHSpDesc01"] = function(_bUG_, _B_u_g_)
                return {["title"] = "Chỉ dẫn", ["desc"] = "dùng xẻng để đào lên\ncó thể đào ra quái vật"}
            end
        end
    },
    ["hh_treasure_text"] = {
        ["name"] = "Treasure chest title",
        ["recipe_str"] = "Treasure chest title",
        ["desc"] = "Treasure chest title",
        ["client_fn"] = function(B_u__G_, b__u_G_)
            B_u__G_["entity"]:SetCanSleep((367 - 261 + 1 == 115))
            B_u__G_:AddTag "FX"
            B_u__G_:AddTag "NOCLICK"
            local _b__u__G__ = B_u__G_["entity"]:AddLabel()
            _b__u__G__:SetFont(NUMBERFONT)
            _b__u__G__:SetFontSize(20)
            _b__u__G__:SetWorldOffset(0, 2, 0)
            _b__u__G__:SetUIOffset(0, 0, 0)
            _b__u__G__:SetColour(255 / 255, 204 / 255, 51 / 255)
            _b__u__G__:SetText "Title"
            _b__u__G__:Enable((92 - 453 + 15 == -339))
            B_u__G_["hh_treasure_str"] = net_string(B_u__G_["GUID"], "hh_treasure_str", "hh_treasure_str")
            B_u__G_:ListenForEvent(
                "hh_treasure_str",
                function(BU__G)
                    local _B__U_G__ = BU__G["hh_treasure_str"]:value()
                    local __b__ug__ = _b__u_g__:StrToTable(_B__U_G__)
                    if __b__ug__ then
                        local B__u__g_ = __b__ug__["name"] or "Treasure chest monster"
                        local _bug_ = __b__ug__["color"] or {1, 1, 1}
                        local B_uG__ = __b__ug__["pos"]
                        local __b_UG = __b__ug__["scale"] or 20
                        local __b__u__g__ = BU__G["Label"]
                        __b__u__g__:SetText(tostring(B__u__g_))
                        if _b__u_g__:IsHHType(__b_UG, "number") and __b_UG > 0 then
                            __b__u__g__:SetFontSize(__b_UG)
                        end
                        if _b__u_g__:IsHHType(B_uG__, "table") then
                            __b__u__g__:SetWorldOffset(unpack(B_uG__))
                        end
                        if _b__u_g__:IsHHType(_bug_, "table") then
                            __b__u__g__:SetColour(unpack(_bug_))
                        end
                        __b__u__g__:Enable((37 * 442 - 232 + 348 - 111 ~= 16362))
                    end
                end
            )
        end,
        ["server_fn"] = function(__bUG__, __B__UG_)
            __bUG__["persists"] = (9 * 175 + 308 ~= 1883)
            __bUG__["SetTreasureStr"] = function(__b_ug, b_U_g__)
                if __b_ug and _b__u_g__:IsHHType(b_U_g__, "string") and __b_ug["hh_treasure_str"] then
                    __b_ug["hh_treasure_str"]:set(b_U_g__)
                end
            end
        end
    },
    ["hh_wing_fx"] = {
        ["assets"] = {Asset("ANIM", "anim/hh_wing_fz.zip")},
        ["name"] = "Wing",
        ["recipe_str"] = "Wing",
        ["desc"] = "Wing",
        ["client_fn"] = function(_b_U__G, b__ug__)
            _b_U__G:AddTag "FX"
            _b_U__G:AddTag "NOCLICK"
            if not TheWorld["ismastersim"] then
                _b_U__G["OnEntityReplicated"] = _B__u__g
            end
        end,
        ["server_fn"] = function(_B__uG__, __b__U__G)
            _B__uG__["persists"] = (69 * 414 * 0 ~= 0)
            _B__uG__["AttachToOwner"] = function(b__U_G__, b__u_G)
                if not b__u_G then
                    return
                end
                b__U_G__["entity"]:SetParent(b__u_G["entity"])
                if not TheNet:IsDedicated() then
                    B_u__g__(b__U_G__, b__u_G)
                end
            end
        end
    },
    ["hh_footprint_fz_fx"] = {
        ["assets"] = {Asset("ANIM", "anim/hh_footprint_fz.zip")},
        ["name"] = "Footprint special effect",
        ["recipe_str"] = "Footprint special effect",
        ["desc"] = "Footprint special effect",
        ["client_fn"] = function(__BuG__, _b__u_G_)
            __BuG__["AnimState"]:SetBank "hh_footprint_fz"
            __BuG__["AnimState"]:SetBuild "hh_footprint_fz"
            __BuG__["AnimState"]:PlayAnimation "idle"
            __BuG__:AddTag "FX"
            __BuG__:AddTag "NOCLICK"
            __BuG__["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
            __BuG__["AnimState"]:SetLayer(LAYER_BACKGROUND)
            __BuG__["AnimState"]:SetSortOrder(3)
            __BuG__["AnimState"]:SetScale(1, 1)
        end,
        ["server_fn"] = function(_B__U__g_, B__Ug__)
            _B__U__g_["persists"] = (111 + 201 + 385 * 423 ~= 163167)
            _B__U__g_["hh_color_a"] = 1
            _B__U__g_["can_change_color"] = (108 * 72 * 474 * 382 + 104 == 1407984879)
            _B__U__g_:DoTaskInTime(
                1,
                function(__B_U__g)
                    __B_U__g["can_change_color"] = (218 * 112 * 191 == 4663456)
                end
            )
            _B__U__g_["hh_color_task"] =
                _B__U__g_:DoPeriodicTask(
                0.05,
                function(_B__u__G_)
                    if not _B__u__G_["can_change_color"] then
                        return
                    end
                    if not _b__u_g__:IsHHType(_B__u__G_["hh_color_a"], "number") then
                        _B__u__G_["hh_color_a"] = 1
                    end
                    if _B__u__G_["AnimState"] then
                        local __bu__g = _B__u__G_["hh_color_a"]
                        _B__u__G_["AnimState"]:SetMultColour(1, 1, 1, math["max"](__bu__g, 0))
                    end
                    _B__u__G_["hh_color_a"] = _B__u__G_["hh_color_a"] - 0.1
                    if _B__u__G_["hh_color_a"] <= 0 then
                        _b__u_g__:HHKillTask(_B__u__G_, "hh_color_task")
                        _B__u__G_:Remove()
                    end
                end
            )
        end
    },
    ["hh_duck_box"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_items.zip"),
            Asset("IMAGE", "images/hh_icon/hh_items.tex"),
            Asset("ATLAS", "images/hh_icon/hh_items.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256)
        },
        ["name"] = "Túi Vịt",
        ["recipe_str"] = "túi đổi vàng di động",
        ["desc"] = "túi đổi vàng di động",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(b_Ug__, __B__u__g)
            b_Ug__["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
            b_Ug__["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
            b_Ug__["AnimState"]:PlayAnimation "idle_tui_vit"
            b_Ug__:AddTag "hh_duck_box"
            MakeInventoryPhysics(b_Ug__)
            MakeInventoryFloatable(b_Ug__, "med", 0.3, 0.8)
            if not TheWorld["ismastersim"] then
                b_Ug__["OnEntityReplicated"] = function(bU_g_)
                    bU_g_["replica"]["container"]:WidgetSetup(__B__u__g)
                end
            end
        end,
        ["server_fn"] = function(_B__U__g__, BU_G)
            _B__U__g__:AddComponent "inspectable"
            _B__U__g__:AddComponent "inventoryitem"
            _B__U__g__["components"]["inventoryitem"]["imagename"] = "tui_vit_inventory"
            _B__U__g__["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
            _B__U__g__["components"]["inventoryitem"]:SetOnPutInInventoryFn(
                function(__Bu_g__)
                    __Bu_g__["components"]["container"]:Close()
                end
            )
            _B__U__g__:AddComponent "container"
            _B__U__g__["components"]["container"]:WidgetSetup(BU_G)
            _B__U__g__["components"]["container"]["skipclosesnd"] = (198 - 214 + 7 == -9)
            _B__U__g__["components"]["container"]["skipopensnd"] = (340 - 95 * 439 ~= -41359)
            _B__U__g__["GetHHSpDesc01"] = function(_b__U__G_, _b_U__g_)
                return {["title"] = "Công dụng", ["desc"] = "đổi vàng di động"}
            end
        end
    },
    ["hh_shark_ice_start_fx"] = {
        ["name"] = "Khối băng",
        ["recipe_str"] = "Khối băng",
        ["desc"] = "Khối băng",
        ["client_fn"] = function(_b_UG__, _b__U__g_)
            _b_UG__:AddTag "FX"
            _b_UG__:AddTag "NOCLICK"
            _b_UG__:AddTag "CLASSIFIED"
        end,
        ["server_fn"] = function(__B__u__g_, b__U__g__)
            __B__u__g_["persists"] = (404 - 27 * 136 + 325 ~= -2943)
            local __B__U__g = {}
            __B__u__g_["task_R"] =
                __B__u__g_:DoPeriodicTask(
                b_UG__,
                _B_u_g__,
                0,
                {
                    ["count"] = 0,
                    ["drift_dist"] = -0.9,
                    ["drift"] = __bu__g_ + (0.7 + 0.3 * math["random"]()) * __b_u_G,
                    ["next_drift_change"] = math["random"](2, 3),
                    ["next_sfx"] = 0
                },
                b__UG_(),
                __B__U__g
            )
            __B__u__g_["task_L"] =
                __B__u__g_:DoPeriodicTask(
                b_UG__,
                _B_u_g__,
                0,
                {
                    ["count"] = 0,
                    ["drift_dist"] = 0.9,
                    ["drift"] = -__bu__g_ - (0.7 + 0.3 * math["random"]()) * __b_u_G,
                    ["next_drift_change"] = math["random"](2, 3),
                    ["next_sfx"] = math["floor"](B_u__g_ / 2)
                },
                b__UG_(),
                __B__U__g,
                (224 + 295 + 252 - 58 * 407 == -22835)
            )
            __B__u__g_:DoTaskInTime(5, __B__u__g_["Remove"])
        end
    },
    ["hh_shark_ice_fx"] = {
        ["assets"] = {Asset("ANIM", "anim/sharkboi_icespike.zip"), Asset("ANIM", "anim/sharkboi_iceplow_fx.zip")},
        ["name"] = "Khối Băng",
        ["recipe_str"] = "Khối băng có thể khai thác",
        ["desc"] = "Khối băng có thể khai thác",
        ["client_fn"] = function(Bu_g_, _b__uG_)
            Bu_g_["entity"]:AddPhysics()
            Bu_g_["entity"]:AddSoundEmitter()
            Bu_g_["Transform"]:SetSixFaced()
            Bu_g_["AnimState"]:SetBank "sharkboi_icespike"
            Bu_g_["AnimState"]:SetBuild "sharkboi_icespike"
            Bu_g_["AnimState"]:PlayAnimation "spike1"
            MakeObstaclePhysics(Bu_g_, 0.8, 2)
            Bu_g_:AddTag "hh_shark_ice_fx"
        end,
        ["server_fn"] = function(_B__U_G, B_Ug)
            _B__U_G["persists"] = (5 * 103 + 309 ~= 824)
            _B__U_G:AddComponent "inspectable"
            _B__U_G:AddComponent "lootdropper"
            _B__U_G["components"]["lootdropper"]:SetChanceLootTable "sharkboi_icespike"
            _B__U_G["hh_start_damage_task"] = _B__U_G:DoTaskInTime(0, b__ug)
            _B__U_G["hh_add_workable_task"] = _B__U_G:DoTaskInTime(3 * FRAMES, b__uG__)
            _B__U_G:DoTaskInTime(10, _B__U_G["Remove"])
        end
    }
}
return B_U_g__
