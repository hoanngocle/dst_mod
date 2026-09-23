local B__uG__ = require "utils/hh_utils"
local __b_uG__ = {}
local B__uG__ = require "utils/hh_utils"
local __b_uG__ = {}
local B__uG__ = require "utils/hh_utils"
local __b_uG__ = {}
local a = require "utils/hh_utils"
local b = TUNING["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"]
local c = string["format"]("", 0)
local function d(e, f, g)
    if a:HasComponents(e, "hh_player") and a:IsHHType(f, "table") then
        for h, i in pairs(f) do
            if a:IsHHType(i, "number") and i > 0 then
                if g then
                    e["components"]["hh_player"]:AddEffectValueByKey(h, i)
                else
                    e["components"]["hh_player"]:ReduceEffectValueByKey(h, i)
                end
            end
        end
    end
end
local j = {
    ["gem_jd"] = {
        "Extraordinary",
        "Generous",
        "Extraordinary",
        "Superb technology",
        "Climbing the pole",
        "Integrate",
        "Exquisite",
        "Wise super",
        "Technical first -class",
        "Bogu tongjin",
        "Talented",
        "Five cars in learning",
        "Excellent technology",
        "Taka -high dou",
        "Talented",
        "Talented",
        "Taishan beidou",
        "Skilled",
        "Talented",
        "Superb skills",
        "Extraordinary technology",
        "Wise",
        "Exquisite",
        "Smart",
        "Talent",
        "Profound",
        "Profound",
        "Technology",
        "Superb skills",
        "Talented",
        "Technical unique",
        "Shenlong sees the head",
        "技",
        "Exquisite technique",
        "Talent",
        "Fascinating",
        "Amazing",
        "Outstanding",
        "One skill",
        "Excessive technology",
        "Acute",
        "Talented",
        "Superb skills",
        "Profound",
        "Technical",
        "Superb skills",
        "Technically",
        "Outstanding skills",
        "Excessive technology",
        "Superpopy"
    },
    ["gem_ph"] = {
        "Stars fall",
        "I dance alone in the endless void",
        "Crushed darkness",
        "Welcome to the birth of light!",
        "Sword refers to the sky",
        "Cherish thorns",
        "Bloody burning",
        "Just to protect the pure land in my heart!",
        "Gorgeous",
        "Thunderous",
        "I am proud alone",
        "Staring at the end of this chaotic world!",
        "Dark coming",
        "Mourning",
        "I use the hot heart",
        "Burning life",
        "Light the road to move forward!",
        "Broken dream",
        "Reorganization",
        "I use unyielding will",
        "Challenge the shackles of fate!",
        "Stormy",
        "Move forward",
        "I write the legend with enthusiasm",
        "It is brilliant with courage!",
        "Under the sky",
        "Beings to look up",
        "I stand alone",
        "Let the world witness my existence!",
        "Bloody",
        "Sword",
        "I use unyielding spirit",
        "Challenge the limits of the world!",
        "Dark",
        "Light flashing",
        "I use faith to ignite hope",
        "Light the direction of moving forward!",
        "Starry",
        "Time 荏苒",
        "I use life to guard the faith",
        "Let your dreams come into reality!"
    },
    ["eight_pig"] = {"Handsome"},
    ["gem_spl"] = {
        string["format"]("%s into%s, can i not enter?", 13, 5),
        "It hurts, it hurts!intersectionintersection",
        "Lost my love forever",
        "Gang",
        "Heaven",
        "Why do you want to hide from me!intersectionintersection",
        "The corner of its length",
        "Looking forward to a future that makes me peaceful and happy",
        "Its passes also took away the killing wolf",
        "Wolf comes here",
        "Since i am tired of pursuing",
        "I have learned to lie directly",
        "Since an anti -wind strike",
        "I can move with the wind",
        "Unwilling",
        "Liver",
        "It's just a momentary achievement",
        "Only swinging is eternal",
        "And it will never be tired"
    },
    ["gem_xm"] = {"Send"},
    ["gem_xl"] = {"Zi li cute"},
    ["gem_ls"] = {"Lu sheng is unparalleled in the world"},
    ["gem_nk"] = {"Zhijiang cake hand"}
}
local function k(e, l, m)
    a:HHKillTask(e, l)
    if j[m] then
        local n = j[m]
        local o = #n
        e[l] =
            e:DoPeriodicTask(
            0.3,
            function()
                if not a:IsHHType(e["hh_str_index"], "number") or not n[e["hh_str_index"]] or e["hh_str_index"] > o then
                    e["hh_str_index"] = 1
                end
                local p = j[m]
                local q = math["random"](1, #j[m])
                a:SpawnClientStrFx(e, p[q])
                e["hh_str_index"] = e["hh_str_index"] + 1
            end
        )
    end
end
local function r(s, t)
    if not a:HasComponents(s, "equippable") or not (s["components"]["equippable"]["equipslot"] == t) then
        return false, "vui lòng hợp thành trang bị phù hợp"
    end
    return true, "đáp ứng các điều kiện"
end
local function u(v, w, x, y, z, A, B, C)
    local D = {
        ["name"] = tostring(v),
        ["client_text"] = tostring(w),
        ["desc"] = tostring(x),
        ["only_one"] = true,
        ["is_suit"] = true,
        ["client_color"] = B or {94 / 255, 38 / 255, 18 / 255, 1},
        ["suit_str"] = tostring(y),
        ["check_equip_can_add"] = function(s)
            return r(s, EQUIPSLOTS[tostring(z)])
        end,
        ["id"] = C or 9999
    }
    if A then
        D["person_one"] = true
    end
    return D
end
local function E(s)
    if s:IsValid() and a:HasComponents(s, "health") and not s["components"]["health"]:IsDead() then
        return true
    end
    return false
end
local function F(s, G)
    if
        a:HasComponents(s, "armor") and not s["components"]["armor"]["indestructible"] or
            a:HasComponents(s, "finiteuses") or
            a:HasComponents(s, "fueled") or
            a:HasComponents(s, "perishable")
     then
        if not G then
            if
                s["prefab"] == "greenstaff" or s["prefab"] == "greenamulet" or s["prefab"] == "yellowstaff" or
                    s["prefab"] == "yellowamulet" or
                    s["prefab"] == "orangeamulet" or
                    s["prefab"] == "telestaff" or
                    s["prefab"] == "purpleamulet" or
                    s["prefab"] == "icestaff" or
                    s["prefab"] == "blueamulet" or
                    s["prefab"] == "firestaff" or
                    s["prefab"] == "amulet" or
                    s["prefab"] == "opalstaff"
             then
                return false
            end
        end
        return true
    end
    return false
end
local function H(e, I)
    if e:IsValid() and a:HasComponents(e, "health") and a:IsHHType(I, "number") then
        local J = e["components"]["health"]:GetPercent()
        local K = e["components"]["health"]["maxhealth"]
        if I > 0 then
            e["components"]["health"]["maxhealth"] = math["min"](K + I, 60000)
            e["components"]["health"]:SetPercent(J)
        else
            e["components"]["health"]["maxhealth"] = math["max"](K + I, 1)
            e["components"]["health"]:SetPercent(J)
        end
    end
end
local function L(M)
    if a:HasComponents(M, "hh_player") then
        M["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
        M["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
        M["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
        M["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
        M["components"]["hh_player"]:AddEffectValueByKey("immuneReduceSpeed", 1)
        M["components"]["hh_player"]:AddEffectValueByKey("immuneSuppressNum", 1)
    end
    if a:HasComponents(M, "hh_buff") then
        M["components"]["hh_buff"]:RemoveBuff "poison"
    end
end
local function N(M)
    if a:HasComponents(M, "hh_player") then
        M["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
        M["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
        M["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
        M["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
        M["components"]["hh_player"]:ReduceEffectValueByKey("immuneReduceSpeed", 1)
        M["components"]["hh_player"]:ReduceEffectValueByKey("immuneSuppressNum", 1)
    end
end
local O = "hh_equip"
local function P(s)
    if not a:HasComponents(s, "equippable") then
        return
    end
    local Q = s["components"]["equippable"]["onequipfn"]
    s["components"]["equippable"]["onequipfn"] = function(R, M, ...)
        if a:HasComponents(R, O) and M:IsValid() and M:HasTag "player" then
            R["components"][O]:HandleEquipBuffToPlayer(M, true)
        end
        if Q then
            Q(R, M, ...)
        end
    end
    local S = s["components"]["equippable"]["onunequipfn"]
    s["components"]["equippable"]["onunequipfn"] = function(R, M, ...)
        if a:HasComponents(R, O) and M:IsValid() and M:HasTag "player" then
            R["components"][O]:HandleEquipBuffToPlayer(M, false)
        end
        if S then
            S(R, M, ...)
        end
    end
end
local function T(s)
    if a:HasComponents(s, "forgerepairable") and s:HasTag "broken" then
        if a:IsHHType(s["components"]["forgerepairable"]["onrepaired"], "function") then
            s["components"]["forgerepairable"]["onrepaired"](s)
        end
    end
end
local function U(s, V)
    if not a:IsHHType(V, "number") or V < 0 then
        return
    end
    if a:HasComponents(s, "armor") and not s["components"]["armor"]["indestructible"] then
        local W = s["components"]["armor"]:GetPercent()
        if W < 1 then
            local X = s["components"]["armor"]["condition"]
            s["components"]["armor"]:SetCondition(X + V)
        end
    end
    if a:HasComponents(s, "finiteuses") then
        local Y = s["components"]["finiteuses"]:GetPercent()
        if Y < 1 then
            local Z = s["components"]["finiteuses"]["total"]
            local X = s["components"]["finiteuses"]:GetUses()
            s["components"]["finiteuses"]:SetUses(math["min"](Z, X + V))
        end
    end
    if a:HasComponents(s, "fueled") then
        local _ = s["components"]["fueled"]:GetPercent()
        if _ < 1 then
            s["components"]["fueled"]:DoDelta(V)
        end
    end
    if a:HasComponents(s, "perishable") then
        local a0 = s["components"]["perishable"]:GetPercent()
        if a0 < 1 then
            local a1 = s["components"]["perishable"]["perishremainingtime"]
            local Z = s["components"]["perishable"]["perishtime"]
            if a1 and Z and Z > 0 then
                a1 = a1 + V
                local a2 = a1 / Z
                s["components"]["perishable"]:SetPercent(a2)
            end
        end
    end
    local a3, a4 = pcall(T, s)
end
local function a5(s, a6)
    if not a:IsHHType(a6, "number") or a6 < 0 then
        return
    end
    if a:HasComponents(s, "armor") and not s["components"]["armor"]["indestructible"] then
        local W = s["components"]["armor"]:GetPercent()
        if W < 1 then
            local a7 = math["min"](W + a6, 1)
            s["components"]["armor"]:SetPercent(a7)
        end
    end
    if a:HasComponents(s, "finiteuses") then
        local Y = s["components"]["finiteuses"]:GetPercent()
        if Y < 1 then
            local a7 = math["min"](Y + a6, 1)
            s["components"]["finiteuses"]:SetPercent(a7)
        end
    end
    if a:HasComponents(s, "fueled") then
        local _ = s["components"]["fueled"]:GetPercent()
        if _ < 1 then
            local a7 = math["min"](_ + a6, 1)
            s["components"]["fueled"]:SetPercent(a7)
        end
    end
    if a:HasComponents(s, "perishable") then
        local a0 = s["components"]["perishable"]:GetPercent()
        if a0 < 1 then
            local a7 = math["min"](a0 + a6, 1)
            s["components"]["perishable"]:SetPercent(a7)
        end
    end
    local a3, a4 = pcall(T, s)
end
local function a8(s, a9, aa)
    if not a:IsHHType(a9, "number") then
        return
    end
    if a:HasComponents(s, "armor") and not s["components"]["armor"]["indestructible"] then
        local W = s["components"]["armor"]:GetPercent()
        local ab = s["components"]["armor"]["maxcondition"]
        s["components"]["armor"]["maxcondition"] = math["max"](ab + a9)
        s["components"]["armor"]:SetPercent(W)
    end
    if a:HasComponents(s, "finiteuses") then
        local Y = s["components"]["finiteuses"]:GetPercent()
        local ac = s["components"]["finiteuses"]["total"]
        s["components"]["finiteuses"]["total"] = math["max"](ac + a9, 1)
        s["components"]["finiteuses"]:SetPercent(Y)
    end
    if a:HasComponents(s, "fueled") then
        local _ = s["components"]["fueled"]:GetPercent()
        local ad = s["components"]["fueled"]["maxfuel"]
        s["components"]["fueled"]["maxfuel"] = math["max"](ad + a9, 1)
        s["components"]["fueled"]:SetPercent(_)
    end
    if a:HasComponents(s, "perishable") then
        local a0 = s["components"]["perishable"]:GetPercent()
        local ae = s["components"]["perishable"]["perishtime"]
        if ae and ae > 0 then
            s["components"]["perishable"]["perishtime"] = math["max"](ae + a9, 1)
            s["components"]["perishable"]:SetPercent(a0)
        end
    end
end
local af = {
    ["follow_reduce_damage"] = {
        ["id"] = 96,
        ["name"] = "Trợ Thủ-PT",
        ["only_one"] = true,
        ["client_text"] = "TT\nThủ",
        ["desc"] = b["follow_reduce_damage"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 5, ["max"] = 10},
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addFollowReduceDamage", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addFollowReduceDamage", I)
        end
    },
    ["follow_add_damage"] = {
        ["id"] = 95,
        ["name"] = "Trợ Thủ-TC",
        ["client_text"] = "TT\nCông",
        ["desc"] = b["follow_damage"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 10, ["max"] = 20},
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addFollowDamage", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addFollowDamage", I)
        end
    },
    ["fast_act"] = {
        ["id"] = 94,
        ["name"] = "Tháo Vát-TH",
        ["client_text"] = "TV\nTH",
        ["desc"] = b["fast_act"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, e, I)
            if a:HasComponents(e, "hh_player") then
                e["components"]["hh_player"]:AddEffectValueByKey("fast_act", 1)
            end
            a:HHClientRpc(e, "hh_fast_act", true)
        end,
        ["un_equip_fn"] = function(s, e, I)
            if a:HasComponents(e, "hh_player") then
                e["components"]["hh_player"]:ReduceEffectValueByKey("fast_act", 1)
                if e["components"]["hh_player"]:HasSpecialEffect "fast_act" then
                    a:HHClientRpc(e, "hh_fast_act", true)
                else
                    a:HHClientRpc(e, "hh_fast_act", false)
                end
            end
        end
    },
    ["work_speed"] = {
        ["id"] = 93,
        ["name"] = "Tháo Vát-KT",
        ["client_text"] = "TV\nKT",
        ["desc"] = b["work_speed"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("workAddSpeed", 1)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("workAddSpeed", 1)
            end
        end
    },
    ["shadow_camp"] = {
        ["id"] = 92,
        ["name"] = "Phục Ma-BT",
        ["client_text"] = "PM\nBT",
        ["desc"] = b["shadow_camp"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("shadowCamp", 1)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("shadowCamp", 1)
            end
        end
    },
    ["moon_camp"] = {
        ["id"] = 91,
        ["name"] = "Phục Ma-VĐ",
        ["client_text"] = "PM\nVĐ",
        ["desc"] = b["moon_camp"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("moonCamp", 1)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("moonCamp", 1)
            end
        end
    },
    ["add_speed"] = {
        ["id"] = 89,
        ["name"] = "Nhanh Nhẹn",
        ["client_text"] = "NN",
        ["desc"] = b["add_speed"],
        ["check_desc"] = "trang bị tay",
        ["only_one"] = true,
        ["can_add"] = true,
        ["value_range"] = {["min"] = 5, ["max"] = 25},
        ["star_rating"] = 8,
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", I)
        end
    },
    ["add_light"] = {
        ["id"] = 90,
        ["name"] = "☆Phổ Độ",
        ["client_text"] = "PĐ",
        ["desc"] = b["add_light"],
        ["check_desc"] = "tất cả",
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            a:HHRemoveFx(M, "hh_add_light_fx")
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("add_light", 1)
                M["hh_add_light_fx"] = SpawnPrefab "hh_light_fx"
                if M["hh_add_light_fx"] then
                    M["hh_add_light_fx"]["entity"]:SetParent(M["entity"])
                end
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            a:HHRemoveFx(M, "hh_add_light_fx")
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("add_light", 1)
                if M["components"]["hh_player"]:HasSpecialEffect "add_light" then
                    M["hh_add_light_fx"] = SpawnPrefab "hh_light_fx"
                    if M["hh_add_light_fx"] then
                        M["hh_add_light_fx"]["entity"]:SetParent(M["entity"])
                    end
                end
            end
        end
    },
    ["add_max_use_small"] = {
        ["id"] = 87,
        ["name"] = "Bền Bỉ I",
        ["desc"] = b["add_max_use"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["client_text"] = "BB\nI",
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 20, ["max"] = 80},
        ["check_equip_can_add"] = function(s)
            if F(s) and a:HasComponents(s, "hh_equip") then
                if s["components"]["hh_equip"]:HasEffectByName "add_max_use_big" then
                    return false, "chỉ được ép tối đa 1 viên Bền Bỉ"
                end
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["start_fn"] = function(s, I)
            a8(s, I)
        end,
        ["end_fn"] = function(s, I)
            a8(s, -I)
        end
    },
    ["add_max_use_big"] = {
        ["id"] = 88,
        ["name"] = "Bền Bỉ II",
        ["desc"] = b["add_max_use"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["client_text"] = "BB\nII",
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 40, ["max"] = 160},
        ["check_equip_can_add"] = function(s)
            if F(s) and a:HasComponents(s, "hh_equip") then
                if s["components"]["hh_equip"]:HasEffectByName "add_max_use_small" then
                    return false, "chỉ được ép tối đa 1 viên Bền Bỉ"
                end
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["start_fn"] = function(s, I)
            a8(s, I)
        end,
        ["end_fn"] = function(s, I)
            a8(s, -I)
        end
    },
    ["add_critical_hit_rate_small"] = {
        ["id"] = 79,
        ["name"] = "Bạo Kích I",
        ["client_text"] = "CK\nI",
        ["desc"] = b["add_critical_hit_rate"],
        ["check_desc"] = "ngoại trừ giáp",
        ["can_add"] = true,
        ["only_one"] = false,
        ["value_range"] = {["min"] = 1, ["max"] = 10},
        ["star_rating"] = 4,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "armor") then
                return false, "ko ép được giáp"
            end
            return true, "đáp ứng các điều kiện"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", I)
            end
        end
    },
    ["add_critical_hit_rate_med"] = {
        ["id"] = 80,
        ["name"] = "Bạo Kích II",
        ["client_text"] = "CK\nII",
        ["desc"] = b["add_critical_hit_rate"],
        ["check_desc"] = "ngoại trừ giáp",
        ["can_add"] = true,
        ["only_one"] = false,
        ["value_range"] = {["min"] = 1, ["max"] = 20},
        ["star_rating"] = 6,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "armor") then
                return false, "ko ép được giáp"
            end
            return true, "đáp ứng các điều kiện"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", I)
            end
        end
    },
    ["add_critical_hit_rate_big"] = {
        ["id"] = 77,
        ["name"] = "☆Bạo Kích III",
        ["client_text"] = "CK\nIII",
        ["desc"] = b["add_critical_hit_rate"],
        ["check_desc"] = "ngoại trừ giáp",
        ["can_add"] = false,
        ["only_one"] = false,
        ["value_range"] = {["min"] = 1, ["max"] = 30},
        ["star_rating"] = 8,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "armor") then
                return false, "ko ép được giáp"
            end
            return true, "đáp ứng các điều kiện"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", I)
            end
        end
    },
    ["add_critical_hit_rate_special"] = {
        ["id"] = 78,
        ["name"] = "★Bạo Kích IV",
        ["client_text"] = "CK\nIV",
        ["desc"] = b["add_critical_hit_rate"],
        ["check_desc"] = "ngoại trừ giáp",
        ["can_add"] = false,
        ["only_one"] = false,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 1, ["max"] = 50},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "armor") then
                return false, "ko ép được giáp"
            end
            return true, "đáp ứng các điều kiện"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitEffect", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", I)
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitEffect", I)
            end
        end
    },
    ["atk_speed_small"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "attack_speed",
        ["id"] = 75,
        ["name"] = "Liên Kích I",
        ["client_text"] = "LK\nI",
        ["desc"] = b["atk_speed"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 5, ["max"] = 10},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào trang bị ở vị trí tay"
        end,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, true)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, false)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end
    },
    ["atk_speed_med"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "attack_speed",
        ["id"] = 76,
        ["name"] = "Liên Kích II",
        ["client_text"] = "LK\nII",
        ["desc"] = b["atk_speed"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 15, ["max"] = 25},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào trang bị ở vị trí tay"
        end,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, true)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, false)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end
    },
    ["atk_speed_big"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "attack_speed",
        ["id"] = 73,
        ["name"] = "☆Liên Kích III",
        ["client_text"] = "LK\nIII",
        ["desc"] = b["atk_speed"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 30, ["max"] = 45},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào trang bị ở vị trí tay"
        end,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, true)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, false)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end
    },
    ["atk_speed_special"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "attack_speed",
        ["id"] = 74,
        ["name"] = "★Liên Kích IV",
        ["client_text"] = "LK\nIV",
        ["desc"] = b["atk_speed"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 50, ["max"] = 70},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào trang bị ở vị trí tay"
        end,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, true)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["atk_speed"] = I}, false)
            if a:HasComponents(M, "hh_player") then
                local ag = M["components"]["hh_player"]:GetEffectValueByKey "atk_speed"
                a:HHClientRpc(M, "hh_atk_speed", ag)
            end
        end
    },
    ["restore_use_10s_1use"] = {
        ["id"] = 71,
        ["name"] = "Gia Trì I",
        ["client_text"] = "GT\nI",
        ["desc"] = b["restore_use_10s_1use"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 4,
        ["xml"] = "images/inventoryimages2.xml",
        ["tex"] = "sewing_kit.tex",
        ["check_equip_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["start_fn"] = function(s)
            a:HHKillTask(s, "restore_use_10s_1use_task")
            s["restore_use_10s_1use_task"] =
                s:DoPeriodicTask(
                10,
                function()
                    U(s, 1)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "restore_use_10s_1use_task")
        end
    },
    ["restore_use_5s_1use"] = {
        ["id"] = 72,
        ["name"] = "Gia Trì II",
        ["client_text"] = "GT\nII",
        ["desc"] = b["restore_use_5s_1use"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["check_equip_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["start_fn"] = function(s)
            a:HHKillTask(s, "restore_use_5s_1use_task")
            s["restore_use_5s_1use_task"] =
                s:DoPeriodicTask(
                5,
                function()
                    U(s, 1)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "restore_use_5s_1use_task")
        end
    },
    ["restore_use_3s_1use"] = {
        ["id"] = 69,
        ["name"] = "☆Gia Trì III",
        ["client_text"] = "GT\nIII",
        ["desc"] = b["restore_use_3s_1use"],
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["check_equip_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["start_fn"] = function(s)
            a:HHKillTask(s, "restore_use_3s_1use_task")
            s["restore_use_3s_1use_task"] =
                s:DoPeriodicTask(
                1,
                function()
                    U(s, 1)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "restore_use_3s_1use_task")
        end
    },
    ["restore_use_1s_2_percent"] = {
        ["id"] = 70,
        ["name"] = "★Gia Trì IV",
        ["client_text"] = "GT\nIV",
        ["desc"] = b["restore_use_1s_2_percent"],
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["check_equip_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị ko phù hợp"
        end,
        ["check_desc"] = "trang bị có độ tươi, độ bền",
        ["start_fn"] = function(s)
            a:HHKillTask(s, "restore_use_1s_2_percent_task")
            s["restore_use_1s_2_percent_task"] =
                s:DoPeriodicTask(
                1,
                function()
                    a5(s, 0.02)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "restore_use_1s_2_percent_task")
        end
    },
    ["add_max_use_armor_01"] = {
        ["id"] = 67,
        ["name"] = "Hộ Giáp I",
        ["desc"] = b["add_max_use_armor_01"],
        ["can_add"] = true,
        ["only_one"] = false,
        ["client_text"] = "HG\nI",
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 200, ["max"] = 500},
        ["check_equip_can_add"] = function(s)
            if F(s) and a:HasComponents(s, "hh_equip") then
                if
                    s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_02" or
                        s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_03"
                 then
                    return false, "chỉ được ép tối đa 1 viên Hộ Giáp"
                end
                if a:HasComponents(s, "armor") then
                    return true, "đáp ứng các điều kiện"
                end
                return false, "chỉ ép được vào giáp"
            end
            return false, "chỉ ép được vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["start_fn"] = function(s, I)
            a8(s, I)
        end,
        ["end_fn"] = function(s, I)
            a8(s, -I)
        end
    },
    ["add_max_use_armor_02"] = {
        ["id"] = 68,
        ["name"] = "Hộ Giáp II",
        ["desc"] = b["add_max_use_armor_02"],
        ["can_add"] = true,
        ["only_one"] = false,
        ["client_text"] = "HG\nII",
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 500, ["max"] = 1000},
        ["check_equip_can_add"] = function(s)
            if F(s) and a:HasComponents(s, "hh_equip") then
                if
                    s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_01" or
                        s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_03"
                 then
                    return false, "chỉ được ép tối đa 1 viên Hộ Giáp"
                end
                if a:HasComponents(s, "armor") then
                    return true, "đáp ứng các điều kiện"
                end
                return false, "chỉ ép được vào giáp"
            end
            return false, "chỉ ép được vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["start_fn"] = function(s, I)
            a8(s, I)
        end,
        ["end_fn"] = function(s, I)
            a8(s, -I)
        end
    },
    ["add_max_use_armor_03"] = {
        ["id"] = 65,
        ["name"] = "☆Hộ Giáp III",
        ["desc"] = b["add_max_use_armor_03"],
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_text"] = "HG\nIII",
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 1000, ["max"] = 3000},
        ["check_equip_can_add"] = function(s)
            if F(s) and a:HasComponents(s, "hh_equip") then
                if
                    s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_01" or
                        s["components"]["hh_equip"]:HasEffectByName "add_max_use_armor_02"
                 then
                    return false, "chỉ được ép tối đa 1 viên Hộ Giáp"
                end
                if a:HasComponents(s, "armor") then
                    return true, "đáp ứng các điều kiện"
                end
                return false, "chỉ ép được vào giáp"
            end
            return false, "chỉ ép được vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["start_fn"] = function(s, I)
            a8(s, I)
        end,
        ["end_fn"] = function(s, I)
            a8(s, -I)
        end
    },
    ["armor_immune_amount"] = {
        ["id"] = 66,
        ["name"] = "★Hộ Giáp IV",
        ["client_text"] = "HG\nIV",
        ["desc"] = b["armor_immune_amount"],
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 10, ["max"] = 80},
        ["check_desc"] = "giáp hấp thụ dưới 100% ST",
        ["check_equip_can_add"] = function(s)
            if not a:HasComponents(s, "armor") then
                return false, "chỉ ép được vào giáp"
            end
            if not s["components"]["armor"]["indestructible"] then
                return true, "đáp ứng các điều kiện"
            end
            local ah = s["components"]["armor"]["absorb_percent"] or 0
            if not a:IsHHType(ah, "number") then
                return false, "lỗi thông số gi"
            end
            if ah >= 1 then
                return false, "chỉ ép được vào giáp block dưới 100%"
            end
            return false, "chỉ ép được vào giáp"
        end,
        ["on_equip_fn"] = function(s, M, I)
        end,
        ["un_equip_fn"] = function(s, M, I)
        end
    },
    ["true_damage_small"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "armor_pierce",
        ["id"] = 63,
        ["name"] = "Xuyên Giáp I",
        ["client_text"] = "XG\nI",
        ["desc"] = b["true_damage"],
        ["check_desc"] = "vũ khí" .. c,
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 3, ["max"] = 5},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", I)
            end
        end
    },
    ["true_damage_med"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "armor_pierce",
        ["id"] = 64,
        ["name"] = "Xuyên Giáp II",
        ["client_text"] = "XG\nII",
        ["desc"] = b["true_damage"],
        ["check_desc"] = "vũ khí" .. c,
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 6, ["max"] = 10},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", I)
            end
        end
    },
    ["true_damage_big"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "armor_pierce",
        ["id"] = 61,
        ["name"] = "☆Xuyên Giáp III",
        ["client_text"] = "XG\nIII",
        ["desc"] = b["true_damage"],
        ["check_desc"] = "vũ khí" .. c,
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 11, ["max"] = 15},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", I)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", I)
            end
        end
    },
    ["true_damage_special"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "armor_pierce",
        ["id"] = 62,
        ["name"] = "★Xuyên Giáp IV",
        ["client_text"] = "XG\nIV",
        ["desc"] = b["true_damage"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 16, ["max"] = 20},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["trueDamageNum"] = I}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["trueDamageNum"] = I}, false)
        end
    },
    ["blood_outburst"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "adversity",
        ["id"] = 50,
        ["name"] = "Nghịch Cảnh-Máu",
        ["client_text"] = "NC\nMáu",
        ["desc"] = b["blood_outburst"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("bloodOutburst", 1)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("bloodOutburst", 1)
        end
    },
    ["spirit_fade"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "adversity",
        ["id"] = 48,
        ["name"] = "Nghịch Cảnh-Não",
        ["client_text"] = "NC\nNão",
        ["desc"] = b["spirit_fade"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("spiritFade", 1)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("spiritFade", 1)
        end
    },
    ["hunger_assault"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "adversity",
        ["id"] = 47,
        ["name"] = "Nghịch Cảnh-Đói",
        ["client_text"] = "NC\nĐói",
        ["desc"] = b["hunger_assault"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("hungerAssault", 1)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("hungerAssault", 1)
        end
    },
    ["add_damage_small"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "dragon_damage",
        ["id"] = 33,
        ["name"] = "Thanh Long I",
        ["client_text"] = "TL\nI",
        ["desc"] = b["add_damage_small"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 3, ["max"] = 5},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", I)
        end
    },
    ["add_damage_med"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "dragon_damage",
        ["id"] = 34,
        ["name"] = "Thanh Long II",
        ["client_text"] = "TL\nII",
        ["desc"] = b["add_damage_med"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 6, ["max"] = 10},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", I)
        end
    },
    ["add_damage_big"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "dragon_damage",
        ["id"] = 31,
        ["name"] = "☆Thanh Long III",
        ["client_text"] = "TL\nIII",
        ["desc"] = b["add_damage_big"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 11, ["max"] = 15},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", I)
        end
    },
    ["special_bhtg"] = {
        ["slot"] = "hand",
        ["exclusive_group"] = "dragon_damage",
        ["id"] = 32,
        ["name"] = "★Thanh Long IV",
        ["client_text"] = "TL\nIV",
        ["desc"] = b["special_bhtg"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 16, ["max"] = 20},
        ["check_equip_can_add"] = function(s)
            if r(s, EQUIPSLOTS["HANDS"]) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", I)
                M["components"]["hh_player"]:AddEffectValueByKey("targetPercentDamage", 3)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", I)
                M["components"]["hh_player"]:ReduceEffectValueByKey("targetPercentDamage", 3)
            end
        end
    },
    ["absorb_small"] = {
        ["id"] = 27,
        ["name"] = "Bạch Hổ-G1",
        ["client_text"] = "BH\nG1",
        ["desc"] = b["absorb_small"],
        ["check_desc"] = "tất cả (giảm tối đa 80%)",
        ["can_add"] = true,
        ["only_one"] = false,
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 1, ["max"] = 5},
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, false)
        end
    },
    ["absorb_mid"] = {
        ["id"] = 28,
        ["name"] = "Bạch Hổ-G2",
        ["client_text"] = "BH\nG2",
        ["desc"] = b["absorb_small"],
        ["check_desc"] = "tất cả (giảm tối đa 80%)",
        ["can_add"] = true,
        ["only_one"] = false,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 1, ["max"] = 15},
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, false)
        end
    },
    ["absorb_big"] = {
        ["id"] = 25,
        ["name"] = "Bạch Hổ-G3",
        ["client_text"] = "BH\nG3",
        ["desc"] = b["absorb_small"],
        ["check_desc"] = "tất cả (giảm tối đa 80%)",
        ["can_add"] = true,
        ["only_one"] = false,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 1, ["max"] = 25},
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, false)
        end
    },
    ["absorb_special"] = {
        ["id"] = 26,
        ["name"] = "☆Bạch Hổ-G4",
        ["client_text"] = "BH\nG4",
        ["desc"] = b["absorb_small"],
        ["check_desc"] = "tất cả (giảm tối đa 80%)",
        ["can_add"] = false,
        ["only_one"] = false,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 1, ["max"] = 35},
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["absorbDamage"] = I}, false)
        end
    },
    ["reduce_damage_small"] = {
        ["id"] = 23,
        ["name"] = "Bạch Hổ I",
        ["desc"] = b["reduce_damage"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["client_text"] = "BH\nI",
        ["star_rating"] = 4,
        ["value_range"] = {["min"] = 1, ["max"] = 5},
        ["check_equip_can_add"] = function(s)
            if
                s["components"]["hh_equip"]:HasEffectByName "special_sgsy" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_mid" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_big"
             then
                return false, "chỉ được ép tối đa 1 viên Bạch Hổ"
            end
            if a:HasComponents(s, "armor") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("absorbDamage", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("absorbDamage", I)
        end
    },
    ["reduce_damage_mid"] = {
        ["id"] = 24,
        ["name"] = "Bạch Hổ II",
        ["client_text"] = "BH\nII",
        ["desc"] = b["reduce_damage"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 5, ["max"] = 15},
        ["check_equip_can_add"] = function(s)
            if
                s["components"]["hh_equip"]:HasEffectByName "reduce_damage_small" or
                    s["components"]["hh_equip"]:HasEffectByName "special_sgsy" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_big"
             then
                return false, "chỉ được ép tối đa 1 viên Bạch Hổ"
            end
            if a:HasComponents(s, "armor") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("absorbDamage", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("absorbDamage", I)
        end
    },
    ["reduce_damage_big"] = {
        ["id"] = 21,
        ["name"] = "☆Bạch Hổ III",
        ["client_text"] = "BH\nIII",
        ["desc"] = b["reduce_damage"],
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 10, ["max"] = 25},
        ["check_equip_can_add"] = function(s)
            if
                s["components"]["hh_equip"]:HasEffectByName "reduce_damage_small" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_mid" or
                    s["components"]["hh_equip"]:HasEffectByName "special_sgsy"
             then
                return false, "chỉ được ép tối đa 1 viên Bạch Hổ"
            end
            if a:HasComponents(s, "armor") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("absorbDamage", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("absorbDamage", I)
        end
    },
    ["special_sgsy"] = {
        ["id"] = 22,
        ["name"] = "★Bạch Hổ IV",
        ["client_text"] = "BH\nIV",
        ["desc"] = b["special_sgsy"],
        ["check_equip_can_add"] = function(s)
            if
                s["components"]["hh_equip"]:HasEffectByName "reduce_damage_small" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_mid" or
                    s["components"]["hh_equip"]:HasEffectByName "reduce_damage_big"
             then
                return false, "chỉ được ép tối đa 1 viên Bạch Hổ"
            end
            if a:HasComponents(s, "armor") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào giáp"
        end,
        ["check_desc"] = "giáp",
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 1, ["max"] = 1000},
        ["on_equip_fn"] = function(s, M, I)
            d(
                M,
                {["absorbDamage"] = 80, ["immuneSuppressNum"] = 1},
                true
            )
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(
                M,
                {["absorbDamage"] = 80, ["immuneSuppressNum"] = 1},
                false
            )
        end
    },
    ["add_immune_cold"] = {
        ["id"] = 20,
        ["name"] = "Huyền Vũ-Lạnh",
        ["client_text"] = "HV\nLạnh",
        ["desc"] = b["add_immune_cold"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
        end
    },
    ["add_immune_hot"] = {
        ["id"] = 19,
        ["name"] = "Huyền Vũ-Nóng",
        ["client_text"] = "HV\nNóng",
        ["desc"] = b["add_immune_hot"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
        end
    },
    ["add_immune_poison"] = {
        ["id"] = 18,
        ["name"] = "Huyền Vũ-Độc",
        ["client_text"] = "HV\nĐộc",
        ["desc"] = b["add_immune_poison"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
            end
            if a:HasComponents(M, "hh_buff") then
                M["components"]["hh_buff"]:RemoveBuff "poison"
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
            end
        end
    },
    ["add_immune_freeze"] = {
        ["id"] = 17,
        ["name"] = "Huyền Vũ-Băng",
        ["client_text"] = "HV\nBăng",
        ["desc"] = b["add_immune_freeze"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
            end
        end
    },
    ["immunity_moisture"] = {
        ["id"] = 16,
        ["name"] = "Huyền Vũ-Ướt",
        ["client_text"] = "HV\nƯớt",
        ["desc"] = b["immunity_moisture"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("immunityMoisture", 1)
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("immunityMoisture", 1)
            end
        end
    },
    ["immunity_reduce_speed"] = {
        ["id"] = 15,
        ["name"] = "Huyền Vũ-Chậm",
        ["client_text"] = "HV\nChậm",
        ["desc"] = b["porter"],
        ["check_desc"] = "tất cả",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 6,
        ["value_range"] = {["min"] = 10, ["max"] = 80},
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["porter"] = 1, ["immuneReduceSpeed"] = 1}, true)
            if a:HasComponents(M, "hh_buff") then
                M["components"]["hh_buff"]:RemoveBuff "reduce_speed"
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["porter"] = 1, ["immuneReduceSpeed"] = 1}, false)
        end
    },
    ["immune_sleep"] = {
        ["id"] = 13,
        ["name"] = "Huyền Vũ-Ngủ",
        ["client_text"] = "HV\nNgủ",
        ["desc"] = b["immune_sleep"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["check_desc"] = "tất cả",
        ["star_rating"] = 6,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["immunitySleep"] = 1}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["immunitySleep"] = 1}, false)
        end
    },
    ["immune_suppress"] = {
        ["id"] = 11,
        ["name"] = "Miễn Giảm Hồi Máu",
        ["client_text"] = "Miễn\nGHM",
        ["desc"] = b["immune_suppress"],
        ["can_add"] = true,
        ["only_one"] = true,
        ["check_desc"] = "tất cả",
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            d(M, {["immuneSuppressNum"] = 1}, true)
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(M, {["immuneSuppressNum"] = 1}, false)
        end
    },
    ["immune_debuff"] = {
        ["id"] = 12,
        ["name"] = "☆Huyền Vũ-TT",
        ["client_text"] = "HV\nTT",
        ["desc"] = b["immune_debuff"],
        ["check_desc"] = "tất cả",
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("immunityMoisture", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("immuneCold", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("immuneHot", 1)
            end
            if a:HasComponents(M, "hh_buff") then
                M["components"]["hh_buff"]:RemoveBuff "add_cold"
                M["components"]["hh_buff"]:RemoveBuff "add_hot"
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("immunityMoisture", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("immuneCold", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("immuneHot", 1)
            end
        end
    },
    ["immune_debuff_2"] = {
        ["id"] = 9,
        ["name"] = "☆Huyền Vũ-KC",
        ["client_text"] = "HV\nKC",
        ["desc"] = b["immune_debuff_2"],
        ["check_desc"] = "tất cả",
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["on_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("immuneFreeze", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("immunePoison", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("immuneReduceSpeed", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("porter", 1)
                M["components"]["hh_player"]:AddEffectValueByKey("immunitySleep", 1)
            end
            if a:HasComponents(M, "hh_buff") then
                M["components"]["hh_buff"]:RemoveBuff "poison"
                M["components"]["hh_buff"]:RemoveBuff "reduce_speed"
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("immuneFreeze", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("immunePoison", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("immuneReduceSpeed", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("porter", 1)
                M["components"]["hh_player"]:ReduceEffectValueByKey("immunitySleep", 1)
            end
        end
    },
    ["special_zqrf"] = {
        ["id"] = 10,
        ["name"] = "★Huyền Vũ-BX",
        ["client_text"] = "HV\nBX",
        ["desc"] = b["special_zqrf"],
        ["check_desc"] = "tất cả",
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["on_equip_fn"] = function(s, M, I)
            d(
                M,
                {
                    ["immunitySleep"] = 1,
                    ["immuneReduceSpeed"] = 1,
                    ["porter"] = 1,
                    ["immuneFreeze"] = 1,
                    ["immunePoison"] = 1,
                    ["immuneCold"] = 1,
                    ["immuneHot"] = 1,
                    ["immunityMoisture"] = 1
                },
                true
            )
            if a:HasComponents(M, "hh_buff") then
                M["components"]["hh_buff"]:RemoveBuff "poison"
                M["components"]["hh_buff"]:RemoveBuff "reduce_speed"
                M["components"]["hh_buff"]:RemoveBuff "add_cold"
                M["components"]["hh_buff"]:RemoveBuff "add_hot"
            end
        end,
        ["un_equip_fn"] = function(s, M, I)
            d(
                M,
                {
                    ["immuneReduceSpeed"] = 1,
                    ["porter"] = 1,
                    ["immuneFreeze"] = 1,
                    ["immunePoison"] = 1,
                    ["immuneCold"] = 1,
                    ["immuneHot"] = 1,
                    ["immunityMoisture"] = 1,
                    ["immunitySleep"] = 1
                },
                false
            )
        end
    },
    ["health_suppress_num"] = {
        ["id"] = 3,
        ["name"] = "Giảm Hồi Máu",
        ["only_one"] = true,
        ["client_text"] = "Giảm\nHM",
        ["desc"] = b["health_suppress_num"],
        ["check_desc"] = "vũ khí",
        ["can_add"] = true,
        ["only_one"] = true,
        ["star_rating"] = 5,
        ["value_range"] = {["min"] = 10, ["max"] = 50},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("addSuppressAddHealth", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("addSuppressAddHealth", I)
        end
    },
    ["atk_blood_suck"] = {
        ["id"] = 1,
        ["name"] = "☆Chu Tước-HM",
        ["client_text"] = "CT\nHM",
        ["desc"] = b["atk_blood_suck"],
        ["check_desc"] = "vũ khí" .. c,
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["can_add"] = false,
        ["only_one"] = true,
        ["star_rating"] = 8,
        ["value_range"] = {["min"] = 1, ["max"] = 3},
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("bloodSuck", I)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("bloodSuck", I)
        end
    },
    ["special_xwsh"] = {
        ["id"] = 2,
        ["name"] = "★Chu Tước-TM",
        ["client_text"] = "CT\nTM",
        ["desc"] = b["special_xwsh"],
        ["check_desc"] = "vũ khí" .. c,
        ["can_add"] = false,
        ["only_one"] = true,
        ["client_color"] = {255 / 255, 0 / 255, 0 / 255, 1},
        ["only_compound"] = true,
        ["star_rating"] = 10,
        ["value_range"] = {["min"] = 2, ["max"] = 5},
        ["check_equip_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "chỉ ép vào vũ khí"
        end,
        ["on_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:AddEffectValueByKey("bloodSuck", I)
            M["components"]["hh_player"]:AddEffectValueByKey("addSuppressAddHealth", 100)
        end,
        ["un_equip_fn"] = function(s, M, I)
            if not a:HasComponents(M, "hh_player") then
                return
            end
            M["components"]["hh_player"]:ReduceEffectValueByKey("bloodSuck", I)
            M["components"]["hh_player"]:ReduceEffectValueByKey("addSuppressAddHealth", 100)
        end
    }
}
-- Canonical weapon procs share the same slot/group validation as rolled affixes.
local function WeaponProc(id, name, short_name, group, effect, value, desc, rare)
    return {
        id = id, name = name, client_text = short_name, desc = desc,
        check_desc = "vũ khí", slot = "hand", exclusive_group = group,
        only_one = true, can_add = not rare, star_rating = rare and 8 or 4,
        value_range = {min = value, max = value},
        on_equip_fn = function(_, player) d(player, {[effect] = value}, true) end,
        un_equip_fn = function(_, player) d(player, {[effect] = value}, false) end,
    }
end

local burst_tiers = {
    {"more_damage_30_150", "moreDamage30To150", "I", 30, 150},
    {"more_damage_20_200", "moreDamage20To200", "II", 20, 200},
    {"more_damage_15_300", "moreDamage10To300", "III", 10, 300},
    {"more_damage_8_500", "moreDamage8To500", "IV", 8, 500},
}
for tier, row in ipairs(burst_tiers) do
    local effect = WeaponProc(96 + tier, "Bạo Phát " .. row[3], "BP\n" .. row[3],
        "burst", row[2], row[5], b[row[1]], true)
    effect.only_compound = true
    effect.chance, effect.multiplier = row[4], row[5] / 100
    af[row[1]] = effect
end
for tier, suffix in ipairs({"small", "med", "big", "special"}) do
    local roman = ({"I", "II", "III", "IV"})[tier]
    af["atk_add_poison_" .. suffix] = WeaponProc(100 + tier, "Hạ Độc " .. roman, "Độc\n" .. roman,
        "poison", "atkAddPoisonChance", tier * 10, b.atk_add_poison, tier >= 3)
    af["atk_add_poison_" .. suffix].chance = tier * 10
    af["atk_add_freeze_" .. suffix] = WeaponProc(104 + tier, "Đóng Băng " .. roman, "Băng\n" .. roman,
        "freeze", "atkChanceAddFreeze", tier * 5, b.atk_add_freeze, tier >= 3)
    af["atk_add_freeze_" .. suffix].chance = tier * 5
end

local function ai(aj)
    if a:IsHHType(aj, "number") then
        return aj
    end
    return 0
end
local function ak(M, al, am, an, ao, ap, aq)
    if not M or not a:IsHHType(al, "string") or not a:IsHHType(am, "string") then
        return
    end
    a:HHRemoveFx(M, al)
    M[al] = SpawnPrefab(am)
    if M[al] then
        if a:IsHHType(an, "string") and M[al]["AnimState"] then
            M[al]["AnimState"]:PlayAnimation(an, true)
        end
        M[al]["entity"]:AddFollower()
        M[al]["entity"]:SetParent(M["entity"])
        local ar = ai(ao)
        local as = ai(ap)
        local at = ai(aq)
        M[al]["Follower"]:FollowSymbol(M["GUID"], "swap_body", ar, as, at)
    end
end
local function au(e)
    if not e or not e["sg"] or e:HasTag "playerghost" then
        return
    end
    local av = e["sg"]:HasStateTag "moving"
    local aw = e["sg"]:HasStateTag "running"
    if (av or aw) and e["Transform"] then
        local ax = SpawnPrefab "hh_footprint_fz_fx"
        if ax and ax["Transform"] then
            local ay, az, aA = e["Transform"]:GetWorldPosition()
            local aB = e["Transform"]:GetRotation()
            local aC, aD = 0, 0
            local aE = 0.3
            if not e["hh_foot_to_change"] then
                e["hh_foot_to_change"] = true
            else
                aE = -0.3
                e["hh_foot_to_change"] = false
            end
            aC = ay + aE * math["cos"]((-aB + 90) * DEGREES)
            aD = aA + aE * math["sin"]((-aB + 90) * DEGREES)
            ax["Transform"]:SetPosition(aC, 0, aD)
            ax["Transform"]:SetRotation(aB)
        end
    end
end
local ELEMENTBEAD_GOGGLES_SOURCE_TAG = "hh_elementbead_goggles_source"
local aF = {
    ["durableGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["durableGem"],
        ["check_gem_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị phải có độ bền"
        end,
        ["only_one"] = true,
        ["start_fn"] = function(s)
            a:HHKillTask(s, "gem_durableGem_task")
            s["gem_durableGem_task"] =
                s:DoPeriodicTask(
                1,
                function()
                    U(s, 1)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "gem_durableGem_task")
        end
    },
    ["powerMettleStone"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["powerMettleStone"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", 10)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", 10)
            end
        end
    },
    ["strideBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["strideBead"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", 3)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", 3)
            end
        end
    },
    ["critStrikeStone"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["critStrikeStone"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 5)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 5)
            end
        end
    },
    ["resistDamageGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["resistDamageGem"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("absorbDamage", 5)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("absorbDamage", 5)
            end
        end
    },
    ["followCritical"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followCritical"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addFollowCritical", 10)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addFollowCritical", 10)
            end
        end
    },
    ["followDamage"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followDamage"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addFollowDamage", 15)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addFollowDamage", 15)
            end
        end
    },
    ["followArmor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["followArmor"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addFollowReduceDamage", 5)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addFollowReduceDamage", 5)
            end
        end
    },
    ["elementBead"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["elementBead"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            L(M)
        end,
        ["un_equip_fn"] = function(s, M)
            N(M)
        end,
        ["start_fn"] = function(s)
            if s and s:IsValid() then
                if s["_hh_elementbead_added_goggles"] == true then
                    if not s:HasTag "goggles" then
                        s:AddTag "goggles"
                    end
                    if not s:HasTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG) then
                        s:AddTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG)
                    end
                elseif not s:HasTag "goggles" then
                    s:AddTag "goggles"
                    s:AddTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG)
                    s["_hh_elementbead_added_goggles"] = true
                else
                    s["_hh_elementbead_added_goggles"] = false
                    if s:HasTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG) then
                        s:RemoveTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG)
                    end
                end
            end
        end,
        ["end_fn"] = function(s)
            if s and s:IsValid() then
                if s["_hh_elementbead_added_goggles"] == true then
                    s:RemoveTag "goggles"
                end
                if s:HasTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG) then
                    s:RemoveTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG)
                end
                s["_hh_elementbead_added_goggles"] = nil
            end
        end
    },
    ["eightPigGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["eightPigGem"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            L(M)
            k(M, "eight_pig_task", "eight_pig")
        end,
        ["un_equip_fn"] = function(s, M)
            N(M)
            a:HHKillTask(M, "eight_pig_task")
        end
    },
    ["nkGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["nkGem"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị phải có độ bền"
        end,
        ["start_fn"] = function(s)
            a:HHKillTask(s, "nkGemTask")
            s["nkGemTask"] =
                s:DoPeriodicTask(
                1,
                function()
                    a5(s, 0.02)
                end
            )
            a8(s, 750)
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "nkGemTask")
            a8(s, -750)
        end,
        ["on_equip_fn"] = function(s, M)
            L(M)
            k(M, "gem_nk_task", "gem_nk")
        end,
        ["un_equip_fn"] = function(s, M)
            N(M)
            a:HHKillTask(M, "gem_nk_task")
        end
    },
    ["baconOmeletteBlessArmor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessArmor"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị phải có độ bền"
        end,
        ["start_fn"] = function(s)
            a:HHKillTask(s, "nkGemTask")
            s["nkGemTask"] =
                s:DoPeriodicTask(
                1,
                function()
                    a5(s, 0.02)
                end
            )
            a8(s, 1000)
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "nkGemTask")
            a8(s, -1000)
        end,
        ["on_equip_fn"] = function(s, M)
            L(M)
        end,
        ["un_equip_fn"] = function(s, M)
            N(M)
        end
    },
    ["baconOmeletteSpeed"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteSpeed"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not (a:HasComponents(s, "weapon") or a:HasComponents(s, "armor") or (s.components.equippable and s.components.equippable.equipslot == EQUIPSLOTS.HEAD)) then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 6 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy mình có thể chạy nhanh như một con báo"
        end,
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addSpeedPercent", 6)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addSpeedPercent", 6)
            end
        end
    },
    ["baconOmeletteAOE"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteAOE"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not (a:HasComponents(s, "weapon") or a:HasComponents(s, "armor") or (s.components.equippable and s.components.equippable.equipslot == EQUIPSLOTS.HEAD)) then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 6 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy mình có thể một mình đối đầu với một băng đảng Mafia !"
        end,
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addSplashDamageAOE", 20)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addSplashDamageAOE", 20)
            end
        end
    },
    ["baconOmeletteDodge"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteDodge"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not (a:HasComponents(s, "weapon") or a:HasComponents(s, "armor") or (s.components.equippable and s.components.equippable.equipslot == EQUIPSLOTS.HEAD)) then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 6 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy mình có thể né những đòn tấn công trong những lúc nguy cấp !"
        end,
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("chanceDodgeAttack", 15)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("chanceDodgeAttack", 15)
            end
        end
    },
    ["baconOmeletteKill"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteKill"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not (a:HasComponents(s, "weapon") or a:HasComponents(s, "armor") or (s.components.equippable and s.components.equippable.equipslot == EQUIPSLOTS.HEAD)) then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 6 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy mình có thể kết liễu đối thủ khi chúng ở ngưỡng máu thấp !"
        end,
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("killUnderThreshold", 15)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("killUnderThreshold", 15)
            end
        end
    },
    ["baconOmeletteBlessAtk"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessAtk"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", 20)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", 20)
            end
        end
    },
    ["baconOmeletteFire"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteFire"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not a:HasComponents(s, "weapon") then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 6 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy một luồng năng lượng rực cháy siêu nóng bỏng bên trong vũ khí này"
        end,
        ["on_equip_fn"] = function(s, M)
        end,
        ["un_equip_fn"] = function(s, M)
        end
    },
    ["baconOmeletteBlessCritical"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteBlessCritical"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 40)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 40)
            end
        end
    },
    ["baconOmeletteTrueDamage"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["baconOmeletteTrueDamage"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("trueDamageNum", 20)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("trueDamageNum", 20)
            end
        end
    },
    ["phGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["phGem"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_ph_task", "gem_ph")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_ph_task")
        end
    },
    ["fxGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["fxGem"],
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_ph_task", "gem_jd")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_ph_task")
        end
    },
    ["z_spl_gem"] = {
        ["name"] = "Play text special effects (exclusive: kill the wolf)",
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_spl_task", "gem_spl")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_spl_task")
        end
    },
    ["z_xm_gem"] = {
        ["name"] = "Play text special effects (exclusive: xiao ming)",
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_xm_task", "gem_xm")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_xm_task")
        end
    },
    ["z_xl_gem"] = {
        ["name"] = "Play text special effects (exclusive: zili)",
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_xl_task", "gem_xl")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_xl_task")
        end
    },
    ["z_ls_gem"] = {
        ["name"] = "Play text special effects (exclusive: lu sheng)",
        ["only_one"] = true,
        ["on_equip_fn"] = function(s, M)
            k(M, "gem_ls_task", "gem_ls")
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHKillTask(M, "gem_ls_task")
        end
    },
    ["z_fz_weapon"] = {
        ["name"] = "Appearance: fan sauce exclusive weapon appearance",
        ["only_one"] = true,
        ["check_gem_can_add"] = function(s)
            if a:HasComponents(s, "weapon") then
                return true, "đáp ứng các điều kiện"
            end
            return false, "Only allow weapons"
        end,
        ["on_equip_fn"] = function(s, M)
            M["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", "z_fz_weapon")
        end,
        ["start_fn"] = function(s)
            if not a:IsHHType(s["hh_can_life"], "number") then
                s["hh_can_life"] = 0
            end
            s["hh_can_life"] = s["hh_can_life"] + 1
        end,
        ["end_fn"] = function(s)
            if not a:IsHHType(s["hh_can_life"], "number") then
                s["hh_can_life"] = 0
            else
                s["hh_can_life"] = math["max"](0, s["hh_can_life"] - 1)
            end
        end
    },
    ["treasure_armor"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_armor"],
        ["only_one"] = true,
        ["check_gem_can_add"] = function(s)
            if F(s) then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị phải có độ bền"
        end,
        ["start_fn"] = function(s)
            a:HHKillTask(s, "treasure_armor_task")
            s["treasure_armor_task"] =
                s:DoPeriodicTask(
                1,
                function()
                    a5(s, 0.02)
                end
            )
        end,
        ["end_fn"] = function(s)
            a:HHKillTask(s, "treasure_armor_task")
        end
    },
    ["treasure_fireGem"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_fireGem"],
        ["only_one"] = true,
        ["check_equip_can_add"] = function(s)
            if not a:HasComponents(s, "weapon") then
                return false, "Không đủ điều kiện để cường hóa"
            end
            if not a:HasComponents(s, "wb_strengthen") or s["components"]["wb_strengthen"]:GetLevel() < 3 then
                return false, "Không đủ điều kiện để cường hóa"
            end
            return true, "Tôi cảm thấy một luồng năng lượng rực cháy bên trong vũ khí này"
        end,
        ["on_equip_fn"] = function(s, M)
            -- Logic DOT sẽ được xử lý qua hook Burnable:Ignite
        end,
        ["un_equip_fn"] = function(s, M)
            -- Không có tác động trực tiếp lên player stats
        end
    },
    ["treasure_atk"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_atk"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("addComDamagePercent", 15)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("addComDamagePercent", 15)
            end
        end
    },
    ["treasure_bj"] = {
        ["name"] = TUNING["HH_FORMAT_CONFIG"]["GEM_EFFECT"]["treasure_bj"],
        ["on_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:AddEffectValueByKey("criticalHitRate", 20)
            end
        end,
        ["un_equip_fn"] = function(s, M)
            if a:HasComponents(M, "hh_player") then
                M["components"]["hh_player"]:ReduceEffectValueByKey("criticalHitRate", 20)
            end
        end
    },
    ["z_fz_wing"] = {
        ["name"] = "Appearance: fan sauce exclusive wings appearance",
        ["only_one"] = true,
        ["check_gem_can_add"] = function(s)
            if
                EQUIPSLOTS["BACK"] and r(s, EQUIPSLOTS["BACK"]) or EQUIPSLOTS["BELLY"] and r(s, EQUIPSLOTS["BELLY"]) or
                    EQUIPSLOTS["NECK"] and r(s, EQUIPSLOTS["NECK"]) or
                    r(s, EQUIPSLOTS["BODY"])
             then
                return true, "đáp ứng các điều kiện"
            end
            return false, "trang bị phải ở vị trí thân hoặc cánh"
        end,
        ["on_equip_fn"] = function(s, M)
            a:HHRemoveFx(M, "hh_wing_fx")
            M["hh_wing_fx"] = SpawnPrefab "hh_wing_fx"
            if M["hh_wing_fx"] and M["hh_wing_fx"]["AttachToOwner"] then
                M["hh_wing_fx"]:AttachToOwner(M)
            end
            M["g_spawn_fx_task"] =
                M:DoPeriodicTask(
                0.3,
                function(e)
                    au(e)
                end
            )
        end,
        ["un_equip_fn"] = function(s, M)
            a:HHRemoveFx(M, "hh_wing_fx")
            a:HHKillTask(M, "g_spawn_fx_task")
        end
    }
}
local function aG(e, f)
    if not a:HasComponents(e, "hh_player") or not a:IsHHType(f, "table") then
        return false
    end
    local aH = false
    for h, i in ipairs(f) do
        if not e["components"]["hh_player"]:HasSpecialEffect(i) then
            aH = true
            break
        end
    end
    if aH then
        return false
    end
    return true
end
local function aI(e, aJ)
    if a:HasComponents(e, "hh_buff") then
        return e["components"]["hh_buff"]:HasBuff(aJ)
    end
    return false
end
local function aK(M, aL)
    if
        not a:NotIsDead(M) or not a:HasComponents(M, "hh_buff") or aI(M, "suit_basalt_cd") or not aL or
            not a:IsHHType(aL["damageresolved"], "number") or
            aL["damageresolved"] <= 0
     then
        return
    end
    M["components"]["health"]:DoDelta(10)
    a:HandleSuitBuff(M, "suit_basalt")
    a:HandleSuitBuff(M, "suit_basalt_cd", 20, true)
end
local aO = {
    ["suit_zqrf"] = {
        ["check_fn"] = aG,
        ["effect_list"] = {"z_suit_zqrf_hand", "z_suit_zqrf_body", "z_suit_zqrf_hat"},
        ["start_fn"] = function(e, R)
            d(
                e,
                {["trueDamageNum"] = 10, ["bloodSuck"] = 3, ["immuneSuppressNum"] = 1, ["immuneReduceSpeed"] = 1},
                true
            )
        end,
        ["stop_fn"] = function(e, R)
            d(
                e,
                {["trueDamageNum"] = 10, ["bloodSuck"] = 3, ["immuneSuppressNum"] = 1, ["immuneReduceSpeed"] = 1},
                false
            )
        end
    }
}
local aP, aQ = "images/dyc_gem_enc.xml", "dyc_gem_enc.tex"
local aR = "images/inventoryimages.xml"
local aS = {
    {
        ["id"] = "z_suit_zqrf_hand",
        ["recipe"] = {
            {["id"] = "hh_essence", ["num"] = 10, ["xml"] = aP, ["tex"] = "dyc_gem_enc.tex"},
            {["id"] = "feather_canary", ["num"] = 10, ["xml"] = aR, ["tex"] = "feather_canary.tex"},
            {["id"] = "thulecite", ["num"] = 5, ["xml"] = aR, ["tex"] = "thulecite.tex"},
            {["id"] = "goldnugget", ["num"] = 20, ["xml"] = aR, ["tex"] = "goldnugget.tex"}
        }
    },
    {
        ["id"] = "z_suit_zqrf_body",
        ["recipe"] = {
            {["id"] = "hh_essence", ["num"] = 10, ["xml"] = aP, ["tex"] = "dyc_gem_enc.tex"},
            {["id"] = "feather_crow", ["num"] = 10, ["xml"] = aR, ["tex"] = "feather_crow.tex"},
            {["id"] = "steelwool", ["num"] = 5, ["xml"] = aR, ["tex"] = "steelwool.tex"},
            {["id"] = "beefalowool", ["num"] = 20, ["xml"] = aR, ["tex"] = "beefalowool.tex"}
        }
    },
    {
        ["id"] = "z_suit_zqrf_hat",
        ["recipe"] = {
            {["id"] = "hh_essence", ["num"] = 10, ["xml"] = aP, ["tex"] = "dyc_gem_enc.tex"},
            {["id"] = "feather_robin", ["num"] = 10, ["xml"] = aR, ["tex"] = "feather_robin.tex"},
            {["id"] = "feather_robin_winter", ["num"] = 10, ["xml"] = aR, ["tex"] = "feather_robin_winter.tex"},
            {["id"] = "silk", ["num"] = 40, ["xml"] = aR, ["tex"] = "silk.tex"}
        }
    }
}
return {["HH_EQUIP_BUFF_LIST"] = af, ["HH_GEM_BUFF_LIST"] = aF, ["HH_SUIT_LIST"] = aO, ["HH_SUIT_RECIPE"] = aS}
