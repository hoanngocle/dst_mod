local _B_uG_ = require "utils/hh_utils"
local b_u__g = require "brains/hh_sharkboi"
local hh_com_brain = require("brains/hh_com_monster")
local function _B_ug_(__B_uG__)
    local __B__U__g__ = {}
    if _B_uG_:IsHHType(__B_uG__, "table") then
        __B__U__g__ = __B_uG__
    end
    local BUg__ = CreateEntity()
    BUg__:AddTag "FX"
    BUg__["persists"] = (299 + 6 - 39 - 409 * 264 == -107706)
    BUg__["entity"]:AddTransform()
    BUg__["entity"]:AddAnimState()
    BUg__["entity"]:AddFollower()
    BUg__["Transform"]:SetFourFaced()
    BUg__["AnimState"]:SetBank "lunar_flame"
    BUg__["AnimState"]:SetBuild "lunar_flame"
    if _B_uG_:IsHHType(__B__U__g__["anim"], "string") then
        BUg__["AnimState"]:PlayAnimation(__B__U__g__["anim"], (216 * 172 + 162 ~= 37319))
    else
        BUg__["AnimState"]:PlayAnimation("flameanim", (388 * 199 - 84 - 156 + 490 == 77462))
    end
    if _B_uG_:IsHHType(__B__U__g__["color"], "table") then
        BUg__["AnimState"]:SetMultColour(unpack(__B__U__g__["color"]))
    else
        BUg__["AnimState"]:SetMultColour(1, 1, 1, 1)
    end
    BUg__["AnimState"]:SetLightOverride(0.1)
    BUg__["AnimState"]:SetBloomEffectHandle "shaders/anim.ksh"
    return BUg__
end
local function __bUg__(__B_U_g_, bu__G_, b_u__G_)
    local _b__UG_ = __B_U_g_["entity"]:AddPhysics()
    _b__UG_:SetMass(bu__G_)
    _b__UG_:SetFriction(0.1)
    _b__UG_:SetDamping(5)
    _b__UG_:SetCollisionGroup(COLLISION["CHARACTERS"])
    _b__UG_:ClearCollisionMask()
    _b__UG_:CollidesWith(COLLISION["WORLD"])
    _b__UG_:CollidesWith(COLLISION["OBSTACLES"])
    _b__UG_:CollidesWith(COLLISION["SMALLOBSTACLES"])
    _b__UG_:CollidesWith(COLLISION["CHARACTERS"])
    _b__UG_:CollidesWith(COLLISION["GIANTS"])
    _b__UG_:SetCapsule(b_u__G_, 1)
    return _b__UG_
end
local function _bu__G_(__B__uG_)
    return FindEntity(
        __B__uG_,
        14,
        function(bu_g)
            return bu_g and __B__uG_["components"]["combat"]:CanTarget(bu_g)
        end,
        {"_combat"},
        {"prey", "smallcreature", "INLIMBO"}
    )
end
local function __bU_g(__BUg, _b_u_g__)
    if
        _B_uG_:HasComponents(__BUg, "combat") and _B_uG_:HasComponents(_b_u_g__, "combat") and
            _B_uG_:NotIsDead(_b_u_g__) and
            __BUg["components"]["combat"]:CanTarget(_b_u_g__) and
            _B_uG_:CanHitTarget(__BUg, _b_u_g__)
     then
        return (288 + 364 * 35 ~= 13037)
    end
    return (462 * 373 - 272 == 172057)
end
local function __B_u_G(BU_G_)
    if BU_G_["components"]["commander"] then
        for BU_g_, Bu__g_ in ipairs(BU_G_["components"]["commander"]:GetAllSoldiers()) do
            if Bu__g_:IsAsleep() then
                Bu__g_:Remove()
            end
        end
    end
    BU_G_:Remove()
end
local function _b__u_G(__b_UG_)
    if __b_UG_["_sleeptask"] ~= nil then
        __b_UG_["_sleeptask"]:Cancel()
    end
    __b_UG_["_sleeptask"] = not (__b_UG_["components"]["health"]:IsDead()) and __b_UG_:DoTaskInTime(10, __B_u_G) or nil
end
local b__u_g = {
    ["hh_sharkboi"] = {
        ["assets"] = {
            Asset("ANIM", "anim/sharkboi_build.zip"),
            Asset("ANIM", "anim/sharkboi_build_brows.zip"),
            Asset("ANIM", "anim/sharkboi_build_manes.zip"),
            Asset("ANIM", "anim/sharkboi_basic.zip"),
            Asset("ANIM", "anim/sharkboi_action.zip"),
            Asset("ANIM", "anim/sharkboi_actions1.zip")
        },
        ["name"] = "Super Frostjaw",
        ["recipe_str"] = "Super Frostjaw",
        ["desc"] = "Super Frostjaw",
        ["client_fn"] = function(__BUG, _bU_G_)
            __BUG["entity"]:AddSoundEmitter()
            __BUG["entity"]:AddDynamicShadow()
            __BUG["DynamicShadow"]:SetSize(3.5, 1.5)
            __BUG:SetPhysicsRadiusOverride(1)
            __bUg__(__BUG, 1, __BUG["physicsradiusoverride"])
            __BUG["AnimState"]:SetBank "sharkboi"
            __BUG["AnimState"]:SetBuild "sharkboi_build"
            __BUG["AnimState"]:PlayAnimation("idle", (75 - 167 + 170 - 326 ~= -245))
            __BUG["Transform"]:SetScale(1.6, 1.6, 1.6)
            __BUG["AnimState"]:SetSymbolMultColour("sharkboi_eye_white", 1, 0, 0, 1)
            __BUG["Transform"]:SetFourFaced()
            __BUG["hh_eye_fx"] = _B_ug_({["anim"] = "mouthflameanim"})
            __BUG["hh_eye_fx"]["entity"]:SetParent(__BUG["entity"])
            __BUG["hh_eye_fx"]["Follower"]:FollowSymbol(
                __BUG["GUID"],
                "sharkboi_eye_white",
                50,
                20,
                0,
                (false or false and not false and not false or false or
                    not false and true and not false and not false and not false and not false and not false or
                    not false or
                    true)
            )
            __BUG["hh_hand_fx"] = _B_ug_({["anim"] = "mouthflameanim"})
            __BUG["hh_hand_fx"]["entity"]:SetParent(__BUG["entity"])
            __BUG["hh_hand_fx"]["Follower"]:FollowSymbol(
                __BUG["GUID"],
                "sharkboi_forearm_fin",
                -30,
                40,
                0,
                (495 - 333 * 190 ~= -62766)
            )
            __BUG:AddTag "monster"
            __BUG:AddTag "epic"
            __BUG:AddTag "hostile"
            __BUG:AddComponent "talker"
            __BUG["components"]["talker"]["fontsize"] = 50
            __BUG["components"]["talker"]["colour"] = Vector3(1, 0.5, 0.75, 1)
            __BUG["components"]["talker"]["offset"] = Vector3(0, -400, 0)
        end,
        ["server_fn"] = function(__B_UG_, __b_UG)
            __B_UG_:AddComponent "inspectable"
            __B_UG_:AddComponent "locomotor"
            __B_UG_["components"]["locomotor"]["runspeed"] = 9
            __B_UG_["components"]["locomotor"]["walkspeed"] = 9
            __B_UG_:AddComponent "combat"
            __B_UG_["components"]["combat"]:SetDefaultDamage(50)
            __B_UG_["components"]["combat"]:SetAttackPeriod(3)
            __B_UG_["components"]["combat"]:SetRange(4.5)
            __B_UG_["components"]["combat"]:SetRetargetFunction(3, _bu__G_)
            __B_UG_["components"]["combat"]:SetKeepTargetFunction(__bU_g)
            __B_UG_["components"]["combat"]["hiteffectsymbol"] = "sharkboi_torso"
            __B_UG_["components"]["combat"]["battlecryenabled"] = (102 + 106 + 299 ~= 507)
            __B_UG_["components"]["combat"]["forcefacing"] =
                (false and not false or not false and true and not false and false and false or
                false and not false and not false)
            __B_UG_:AddComponent "health"
            __B_UG_["components"]["health"]:SetMaxHealth(50000)
            __B_UG_["components"]["health"]["fire_damage_scale"] = 0
            __B_UG_:AddComponent "timer"
            __B_UG_:AddComponent "grouptargeter"
            __B_UG_:AddComponent "commander"
            __B_UG_["components"]["commander"]:SetTrackingDistance(30)
            __B_UG_:AddComponent "lootdropper"
            __B_UG_["components"]["lootdropper"]:SetChanceLootTable "hh_treasure_monster"
            __B_UG_:AddComponent "planarentity"
            __B_UG_:AddComponent "planardamage"
            __B_UG_["components"]["planardamage"]:SetBaseDamage(30)
            __B_UG_:SetStateGraph "SGhh_sharkboi"
            __B_UG_:SetBrain(b_u__g)
            __B_UG_["OnEntitySleep"] = _b__u_G
            __B_UG_:ListenForEvent(
                "attacked",
                function(_b__UG, _bUG_)
                    if not _bUG_["attacker"] then
                        return
                    end
                    local _bu_G_ = _bUG_["attacker"]
                    if
                        _B_uG_:NotIsDead(_bu_G_) and _B_uG_:NotIsDead(_b__UG) and _B_uG_:HasComponents(_bu_G_, "combat") and
                            _B_uG_:CanHitTarget(_b__UG, _bu_G_)
                     then
                        _b__UG["components"]["combat"]:SetTarget(_bu_G_)
                    end
                end
            )
        end
    },
    ["hh_beetle_pig"] = {
        ["assets"] = {
            Asset("ANIM", "anim/lavaarena_beetletaur.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_basic.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_actions.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_block.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
        },
        ["name"] = "Lợn Rừng Bọ Hung", ["recipe_str"] = "Lợn Rừng Bọ Hung", ["desc"] = "Lợn Rừng Bọ Hung",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            inst:SetPhysicsRadiusOverride(1.5)
            __bUg__(inst, 1000, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("beetletaur")
            inst["AnimState"]:SetBuild("lavaarena_beetletaur")
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["Transform"]:SetFourFaced()

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 7
            inst["components"]["locomotor"]["walkspeed"] = 7
            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(50)
            inst["components"]["combat"]:SetAttackPeriod(2)
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, _bu__G_)
            inst["components"]["combat"]:SetKeepTargetFunction(__bU_g)
            inst["components"]["combat"]["hiteffectsymbol"] = "body"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            
            -- Inject hh_monster securely to ensure it is treated as a Super Boss
            if not inst["components"]["hh_monster"] then
                inst:AddComponent("hh_monster")
            end
            if not inst["components"]["hh_buff"] then
                inst:AddComponent("hh_buff")
            end
            if not inst["hh_tags"] then
                inst["hh_tags"] = {}
            end
            inst["hh_tags"]["boss_monster"] = "Quái trùm"
            inst["HasHHTag"] = function(self, tag) 
                return self["hh_tags"] and self["hh_tags"][tag] ~= nil 
            end

            inst:AddComponent("health")
            inst["components"]["health"]:SetMaxHealth(50000)
            inst["components"]["health"]["fire_damage_scale"] = 0
            inst:AddComponent("timer")
            inst["components"]["timer"]:StartTimer("pig_jump_cd", 7)
            inst["components"]["timer"]:StartTimer("pig_strong_cd", 27)
            inst["components"]["timer"]:StartTimer("pig_control_cd", 45)
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
            inst:AddComponent("planarentity")
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(30)
            inst:SetStateGraph("SGhh_beetle_pig")
            inst:SetBrain(hh_com_brain)
            inst["OnEntitySleep"] = _b__u_G
            inst:ListenForEvent(
                "attacked",
                function(_b__UG, _bUG_)
                    if not _bUG_["attacker"] then return end
                    local _bu_G_ = _bUG_["attacker"]
                    if _B_uG_:NotIsDead(_bu_G_) and _B_uG_:NotIsDead(_b__UG) and _B_uG_:HasComponents(_bu_G_, "combat") and _B_uG_:CanHitTarget(_b__UG, _bu_G_) then
                        _b__UG["components"]["combat"]:SetTarget(_bu_G_)
                    end
                end
            )
        end,
    },
    ["hh_dual_wield_pig"] = {
        ["assets"] = {
            Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),
        },
        ["name"] = "Siêu Lợn Song Kiếm", ["recipe_str"] = "Siêu Lợn Song Kiếm", ["desc"] = "Siêu Lợn Song Kiếm",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            inst:SetPhysicsRadiusOverride(1.5)
            __bUg__(inst, 1000, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("boarrior")
            inst["AnimState"]:SetBuild("lavaarena_boarrior_basic")
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["Transform"]:SetFourFaced()

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 7
            inst["components"]["locomotor"]["walkspeed"] = 7
            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(50)
            inst["components"]["combat"]:SetAttackPeriod(2)
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, _bu__G_)
            inst["components"]["combat"]:SetKeepTargetFunction(__bU_g)
            inst["components"]["combat"]["hiteffectsymbol"] = "body"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            
            -- Inject hh_monster securely to ensure it is treated as a Super Boss
            if not inst["components"]["hh_monster"] then
                inst:AddComponent("hh_monster")
            end
            if not inst["components"]["hh_buff"] then
                inst:AddComponent("hh_buff")
            end
            if not inst["hh_tags"] then
                inst["hh_tags"] = {}
            end
            inst["hh_tags"]["boss_monster"] = "Quái trùm"
            inst["HasHHTag"] = function(self, tag) 
                return self["hh_tags"] and self["hh_tags"][tag] ~= nil 
            end

            inst:AddComponent("health")
            inst["components"]["health"]:SetMaxHealth(50000)
            inst["components"]["health"]["fire_damage_scale"] = 0
            inst:AddComponent("timer")
            inst["components"]["timer"]:StartTimer("pig_around_cd", 12)
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
            inst:AddComponent("planarentity")
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(30)
            inst:SetStateGraph("SGhh_dual_wield_pig")
            inst:SetBrain(hh_com_brain)
            inst["OnEntitySleep"] = _b__u_G
            inst:ListenForEvent(
                "attacked",
                function(_b__UG, _bUG_)
                    if not _bUG_["attacker"] then return end
                    local _bu_G_ = _bUG_["attacker"]
                    if _B_uG_:NotIsDead(_bu_G_) and _B_uG_:NotIsDead(_b__UG) and _B_uG_:HasComponents(_bu_G_, "combat") and _B_uG_:CanHitTarget(_b__UG, _bu_G_) then
                        _b__UG["components"]["combat"]:SetTarget(_bu_G_)
                    end
                end
            )
        end,
    },
    -------------------- CÁC BOSS BÊN DƯỚI NÀY CHỈ XUẤT HIỆN DUY NHẤT TRONG HẦM NGỤC ---------------------
    ["hh_igris_dungeon"] = {
        ["assets"] = {
            Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),  -- Tải khung xương gốc
            Asset("ANIM", "anim/igris_dungeon.zip"),   -- Tải lớp da mới
        },
        ["name"] = "Igris", ["recipe_str"] = "Igris", ["desc"] = "Igris",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            inst:SetPhysicsRadiusOverride(1.5)
            __bUg__(inst, 1000, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("boarrior")
            inst["AnimState"]:SetBuild("ttk_igris_dungeon")
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["Transform"]:SetFourFaced()

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 7
            inst["components"]["locomotor"]["walkspeed"] = 7
            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(40)
            inst["components"]["combat"]:SetAttackPeriod(2)
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, _bu__G_)
            inst["components"]["combat"]:SetKeepTargetFunction(__bU_g)
            inst["components"]["combat"]["hiteffectsymbol"] = "body"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            
            -- Inject hh_monster securely to ensure it is treated as a Super Boss
            if not inst["components"]["hh_monster"] then
                inst:AddComponent("hh_monster")
            end
            if not inst["components"]["hh_buff"] then
                inst:AddComponent("hh_buff")
            end
            if not inst["hh_tags"] then
                inst["hh_tags"] = {}
            end
            inst["hh_tags"]["boss_monster"] = "Quái trùm"
            inst["HasHHTag"] = function(self, tag) 
                return self["hh_tags"] and self["hh_tags"][tag] ~= nil 
            end

            inst:AddComponent("health")
            inst["components"]["health"]:SetMaxHealth(400000)
            inst["components"]["health"]["fire_damage_scale"] = 0
            inst:AddComponent("timer")
            inst["components"]["timer"]:StartTimer("pig_around_cd", 12)
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
            inst:AddComponent("planarentity")
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(20)
            inst:SetStateGraph("SGhh_igris_dungeon")
            inst:SetBrain(hh_com_brain)
            inst["OnEntitySleep"] = _b__u_G
            inst:ListenForEvent(
                "attacked",
                function(_b__UG, _bUG_)
                    if not _bUG_["attacker"] then return end
                    local _bu_G_ = _bUG_["attacker"]
                    if _B_uG_:NotIsDead(_bu_G_) and _B_uG_:NotIsDead(_b__UG) and _B_uG_:HasComponents(_bu_G_, "combat") and _B_uG_:CanHitTarget(_b__UG, _bu_G_) then
                        _b__UG["components"]["combat"]:SetTarget(_bu_G_)
                    end
                end
            )
            inst:ListenForEvent("death", function(inst)
                inst:AddTag("NOCLICK")
                if inst.components.health then
                    inst.components.health.nofadeout = true
                end
            end)
        end,
    }
}
return b__u_g
