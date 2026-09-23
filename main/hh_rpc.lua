local iFkuiCkKf = require("utils/hh_utils")
local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")
local HHRankDefs = require("guild/hh_rank_defs")
local TTKNativeOpenAck = require("ui/ttk_native_open_ack")
local iffugcgKk = require("enums/hh_items")
local uFfUgCkKf = require("enums/hh_hoverer")
local kFiUcCikf = require("enums/hh_enchant")
local uFkUkCfKf = kFiUcCikf["HH_EQUIP_BUFF_LIST"]
local fffUgCnKu = true -- Cố định thông tin đầy đủ.
local kfiuuCkkg = require("cooking")
local nFfUkCiKi = kfiuuCkkg["ingredients"]
local nFnUiCukf = {
    ["GENERIC"] = "Thông dụng",
    ["MEAT"] = "Phẩm thịt",
    ["VEGGIE"] = "Phẩm rau",
    ["ELEMENTAL"] = "Tự nhiên",
    ["GEARS"] = "Gears",
    ["HORRIBLE"] = "Nhiên liệu ác mộng",
    ["INSECT"] = "Côn trùng",
    ["SEEDS"] = "Hạt giống",
    ["BERRY"] = "Quả dại",
    ["RAW"] = "Thô",
    ["BURNT"] = "Chất cháy",
    ["ROUGHAGE"] = "Bón ăn",
    ["WOOD"] = "Chất đốt",
    ["GOODIES"] = "Vặt",
    ["MONSTER"] = "Phẩm quái",
    ["NIL"] = "kxđ"
}
local nfuUuCikc = {
    ["CHOP"] = "Chặt",
    ["DIG"] = "Đào",
    ["HAMMER"] = "Đập",
    ["MINE"] = "Khai thác",
    ["NET"] = "Bắt",
    ["PLAY"] = "Chơi",
    ["UNSADDLE"] = "Tháo yên",
    ["REACH_HIGH"] = " đến"
}
local ifiUgCnki = {
    ["veggie"] = " Rau củ:",
    ["fruit"] = " Quả:",
    ["monster"] = " Quái vật:",
    ["sweetener"] = " Ngọt:",
    ["meat"] = " Thịt:",
    ["fish"] = " Cá:",
    ["magic"] = " Ma thuật:",
    ["egg"] = " Trứng:",
    ["decoration"] = " Vảy:",
    ["dairy"] = " Sữa:",
    ["fat"] = " Dầu mỡ:",
    ["inedible"] = " Cành:",
    ["frozen"] = " Băng:",
    ["seed"] = " Hạt giống:",
    ["fungus"] = " Nấm:",
    ["mushrooms"] = " Nấm:",
    ["poultry"] = " Gia cầm:",
    ["wings"] = " Cánh:",
    ["seafood"] = " Hải sản:",
    ["nut"] = " Hạt:",
    ["cactus"] = " Xương rồng:",
    ["starch"] = " Tinh bột:",
    ["grapes"] = " Nho:",
    ["citrus"] = " Quýt:",
    ["tuber"] = " Củ:",
    ["shellfish"] = " Vỏ sò:",
    ["rawmilk"] = " Sữa;",
    ["bulb"] = " Quả sáng:",
    ["spices"] = " Gia vị:",
    ["challa"] = " Bánh mì:",
    ["flour"] = "Bột mì:",
    ["cacao_cooked"] = " Cacao:"
}
local function cfnufCiKf(kFcUicuki, ifuunCnKg, ...)
    local format_config = uFfUgCkKf[ifuunCnKg]
    if format_config == nil and type(ifuunCnKg) == "string"
        and string.match(ifuunCnKg, "^hh_99_special_%d+$") then
        format_config = {["format"] = "%s"}
    end
    if kFcUicuki and format_config and format_config["format"] then
        if not kFcUicuki[ifuunCnKg] then
            kFcUicuki[ifuunCnKg] = {}
        end
        kFcUicuki[ifuunCnKg]["bool"] = (493 * 128 * 153 * 11 * 232 ~= 24639335429)
        kFcUicuki[ifuunCnKg]["str"] = string["format"](format_config["format"], ...)
    end
end
local function kffugCkKi(gfcUuCgkn)
    local kfiukCgKu = _G["Prefabs"][gfcUuCgkn["prefab"]]
    local cfcUfckKg = debug["getinfo"](kfiukCgKu["fn"], "S")
    return cfcUfckKg["source"]
end
local function uFkUcCikg(uFgugCnKc)
    if
        uFgugCnKc:IsValid() and iFkuiCkKf:HasComponents(uFgugCnKc, "health") and
            not uFgugCnKc["components"]["health"]:IsDead()
     then
        return (483 - 414 - 211 == -142)
    end
    return (285 + 2 - 356 - 309 == -376)
end
local function cFnUkcikf(cfgUucgKg, uFuuiciKi)
    if not iFkuiCkKf:IsHHType(uFuuiciKi, "number") or uFuuiciKi <= 0 then
        return 0
    end
    local gFgUgcfKf = 1
    local uFkucCcKn =
        cfgUucgKg["components"]["inventoryitem"] and cfgUucgKg["components"]["inventoryitem"]["owner"] or nil
    if not uFkucCcKn and cfgUucgKg["components"]["occupier"] then
        uFkucCcKn = cfgUucgKg["components"]["occupier"]:GetOwner()
    end
    local gfiuiCcKc = uFkucCcKn ~= nil and uFkucCcKn:GetPosition() or cfgUucgKg:GetPosition()
    if uFkucCcKn then
        if uFkucCcKn["components"]["preserver"] ~= nil then
            gFgUgcfKf = uFkucCcKn["components"]["preserver"]:GetPerishRateMultiplier(cfgUucgKg) or gFgUgcfKf
        elseif uFkucCcKn:HasTag("fridge") then
            if cfgUucgKg:HasTag("frozen") and not uFkucCcKn:HasTag("nocool") and not uFkucCcKn:HasTag("lowcool") then
                gFgUgcfKf = TUNING["PERISH_COLD_FROZEN_MULT"]
            else
                gFgUgcfKf = TUNING["PERISH_FRIDGE_MULT"]
            end
        elseif uFkucCcKn:HasTag("foodpreserver") then
            gFgUgcfKf = TUNING["PERISH_FOOD_PRESERVER_MULT"]
        elseif uFkucCcKn:HasTag("cage") and cfgUucgKg:HasTag("small_livestock") then
            gFgUgcfKf = TUNING["PERISH_CAGE_MULT"]
        end
        if uFkucCcKn:HasTag("spoiler") then
            gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_GROUND_MULT"]
        end
    else
        gFgUgcfKf = TUNING["PERISH_GROUND_MULT"]
    end
    if cfgUucgKg:GetIsWet() and not cfgUucgKg["components"]["perishable"]["ignorewentness"] then
        gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_WET_MULT"]
    end
    if GetTemperatureAtXZ(gfiuiCcKc["x"], gfiuiCcKc["z"]) < 0 then
        if cfgUucgKg:HasTag("frozen") and not cfgUucgKg["components"]["perishable"]["frozenfiremult"] then
            gFgUgcfKf = TUNING["PERISH_COLD_FROZEN_MULT"]
        else
            gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_WINTER_MULT"]
        end
    end
    if cfgUucgKg["components"]["perishable"]["frozenfiremult"] then
        gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_FROZEN_FIRE_MULT"]
    end
    if GetTemperatureAtXZ(gfiuiCcKc["x"], gfiuiCcKc["z"]) > TUNING["OVERHEAT_TEMP"] then
        gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_SUMMER_MULT"]
    end
    gFgUgcfKf = gFgUgcfKf * cfgUucgKg["components"]["perishable"]["localPerishMultiplyer"]
    gFgUgcfKf = gFgUgcfKf * TUNING["PERISH_GLOBAL_MULT"]
    local kFuUfCkkc = uFuuiciKi / gFgUgcfKf
    return math["max"](kFuUfCkkc, 0)
end
local fFgUkckkf = function(fFuUgcikf, ffcUuCfkc)
    return tonumber(string["format"]("%." .. (ffcUuCfkc or 0) .. "f", fFuUgcikf))
end
local function cFcuuckkg(nFiufCikn, nfcuicgKn, uFiufCcKu, kfuugCuku, nffUuCnKc)
    if fffUgCnKu then
        local fFfuicfKu = nfcuicgKn["components"]
        if kfuugCuku["health"] then
            local fFkUfCiKk = string["format"]("%.0f", kfuugCuku["health"]["currenthealth"] or "0")
            local ffuUfcfKi = string["format"]("%.0f", kfuugCuku["health"]["maxhealth"] or "0")
            local nFnUkciKc = 0
            if kfuugCuku["health"]["absorb"] ~= 0 or kfuugCuku["health"]["playerabsorb"] ~= 0 then
                nFnUkciKc =
                    math["min"](
                    (1 - (1 - kfuugCuku["health"]["absorb"]) * (1 - kfuugCuku["health"]["playerabsorb"])) * 100,
                    100
                )
            end
            if kfuugCuku["health"]["externalabsorbmodifiers"] then
                nFnUkciKc =
                    nFnUkciKc + (100 - nFnUkciKc) * math["min"](kfuugCuku["health"]["externalabsorbmodifiers"]:Get(), 1)
            end
            nFnUkciKc = string["format"]("%.1f", nFnUkciKc)
            cfnufCiKf(nFiufCikn, "hh_02_health", fFkUfCiKk, ffuUfcfKi, nFnUkciKc)
        end
        if kfuugCuku["hunger"] then
            if kfuugCuku["hunger"]["current"] and kfuugCuku["hunger"]["max"] then
                local gfkUuCfki = string["format"]("%.0f", kfuugCuku["hunger"]["current"] or "0")
                local cFuufcgKc = string["format"]("%.0f", kfuugCuku["hunger"]["max"] or "0")
                cfnufCiKf(nFiufCikn, "hh_02_hunger", gfkUuCfki, cFuufcgKc)
            end
        end
        if kfuugCuku["combat"] then
            local gFgUiCiKf = kfuugCuku["combat"]["defaultdamage"] or "0"
            local iFuUuCkKn = kfuugCuku["combat"]["attackrange"] or "0"
            local kfcUcCnkc = kfuugCuku["combat"]["damagemultiplier"] or "1"
            cfnufCiKf(nFiufCikn, "hh_03_combat", tostring(gFgUiCiKf), tostring(iFuUuCkKn), tostring(kfcUcCnkc))
        end
        if kfuugCuku["health"] and kfuugCuku["combat"] then
            local treasure_id = kfuugCuku["hh_monster"] and kfuugCuku["hh_monster"]["treasure_id"]
            local meta = treasure_id and TUNING.HH_TREASURE_BOSS_EXP[treasure_id] or nil
            if not meta and uFiufCcKu.hh_is_dungeon_boss then
                meta = TUNING.HH_DUNGEON_BOSS_EXP[nffUuCnKc]
            end
            if not meta and TUNING.HH_MOB_EXP[nffUuCnKc] then
                meta = {
                    exp = TUNING.HH_MOB_EXP[nffUuCnKc],
                    level = TUNING.HH_MOB_RECOMMENDED_LEVEL[nffUuCnKc] or 1,
                    class = TUNING.HH_BOSS_PREFABS[nffUuCnKc] and "boss"
                        or TUNING.HH_MINIBOSS_PREFABS[nffUuCnKc] and "miniboss"
                        or "normal",
                }
            end
            if meta then
                local factor = 1
                if meta.class ~= "boss" and meta.class ~= "superboss" then
                    local player_level = nfcuicgKn.components.hh_leveling and nfcuicgKn.components.hh_leveling.level or 1
                    local gap = player_level - (meta.level or 1)
                    for _, row in ipairs(TUNING.HH_EXP_BALANCE.LEVEL_FACTORS) do
                        if gap >= row.gap then factor = row.factor break end
                    end
                end
                local class_name = meta.class == "superboss" and "Super Boss"
                    or meta.class == "boss" and "Boss"
                    or meta.class == "miniboss" and "Mini Boss"
                    or "Thường"
                cfnufCiKf(nFiufCikn, "hh_03_recommended_level", tostring(meta.level or 1))
                cfnufCiKf(nFiufCikn, "hh_03_exp", tostring(meta.exp or 0), tostring(math.floor(factor * 100 + 0.5)), class_name)
            end
        end
        if kfuugCuku["weapon"] then
            local iFnunccKu = 0
            local cFuUgccKi = 0
            local gFuUkcfKf = kfuugCuku["weapon"]["damage"]
            if type(gFuUkcfKf) ~= "number" then
                iFnunccKu = "？？？"
            else
                iFnunccKu = string["format"]("%.1f", kfuugCuku["weapon"]["damage"] or "0")
                cFuUgccKi = kfuugCuku["weapon"]["attackrange"] or "1"
            end
            cfnufCiKf(nFiufCikn, "hh_03_weapon", iFnunccKu, cFuUgccKi)
        end
        if kfuugCuku["planardamage"] then
            local cfuufccku = 0
            local nfuunCukc = kfuugCuku["planardamage"]["basedamage"]
            if type(nfuunCukc) ~= "number" then
                cfuufccku = "？？？"
            else
                cfuufccku = string["format"]("%.1f", kfuugCuku["planardamage"]["basedamage"] or "0")
            end
            cfnufCiKf(nFiufCikn, "hh_03_planar", cfuufccku)
        end
        if kfuugCuku["planardefense"] then
            local kFfuuccku = 0
            local kFiUkCnKi = kfuugCuku["planardefense"]["basedefense"]
            if type(kFiUkCnKi) ~= "number" then
                kFfuuccku = "？？？"
            else
                kFfuuccku = string["format"]("%.1f", kfuugCuku["planardefense"]["basedefense"] or "0")
            end
            cfnufCiKf(nFiufCikn, "hh_06_planar", kFfuuccku)
        end
        if kfuugCuku["edible"] then
            local fFgufCnkc =
                (true and false or false and not true and not false or not false and not true or
                not false and true and not false and not true and not false)
            if iFkuiCkKf:HasComponents(nfcuicgKn, "eater") then
                fFgufCnkc = fFfuicfKu["eater"]:CanEat(uFiufCcKu)
            end
            if fFgufCnkc then
                local ifiunCgkc = fFgUkckkf(kfuugCuku["edible"]:GetHunger(nfcuicgKn), 1)
                local kFuUccgkg = fFgUkckkf(kfuugCuku["edible"]:GetSanity(nfcuicgKn), 1)
                local nfcUcCkKi = fFgUkckkf(kfuugCuku["edible"]:GetHealth(nfcuicgKn), 1)
                local ifcUucukn = nFnUiCukf[tostring(kfuugCuku["edible"]["foodtype"])] or "Non -type"
                local gfcUucnkf = 1
                if iFkuiCkKf:HasComponents(nfcuicgKn, "foodmemory") then
                    gfcUucnkf = nfcuicgKn["components"]["foodmemory"]:GetFoodMultiplier(nffUuCnKc) or 1
                end
                local ifkuicukg = (tonumber(fFfuicfKu["eater"]["hungerabsorption"]) or 1) * gfcUucnkf
                local fffUnciKg = (tonumber(fFfuicfKu["eater"]["sanityabsorption"]) or 1) * gfcUucnkf
                local ufuUgcgki = (tonumber(fFfuicfKu["eater"]["healthabsorption"]) or 1) * gfcUucnkf
                ifiunCgkc = ifiunCgkc * ifkuicukg
                kFuUccgkg = kFuUccgkg * fffUnciKg
                nfcUcCkKi = nfcUcCkKi * ufuUgcgki
                cfnufCiKf(nFiufCikn, "hh_04_edible", ifcUucukn, ifiunCgkc, kFuUccgkg, nfcUcCkKi)
            end
        end
        if nFfUkCiKi and nFfUkCiKi[nffUuCnKc] and iFkuiCkKf:IsHHType(nFfUkCiKi[nffUuCnKc]["tags"], "table") then
            local uffUkCgKu = ""
            for cfgufcnKu, cFgugcgKk in pairs(nFfUkCiKi[nffUuCnKc]["tags"]) do
                if ifiUgCnki[cfgufcnKu] then
                    uffUkCgKu = uffUkCgKu .. (ifiUgCnki[cfgufcnKu] or "") .. tostring(cFgugcgKk)
                end
            end
            cfnufCiKf(nFiufCikn, "hh_05_food_tag", uffUkCgKu)
        end
        if kfuugCuku["armor"] then
            local nFfukCiKc = (kfuugCuku["armor"]["absorb_percent"] or 0) * 100
            local cFgugCgKi = nFfukCiKc .. "% "
            if not kfuugCuku["armor"]["indestructible"] then
                local nFcUgCuKi = string["format"]("%.1f", kfuugCuku["armor"]["condition"] or "0")
                local ufkukcnki = string["format"]("%.1f", kfuugCuku["armor"]["maxcondition"] or "0")
                cFgugCgKi = cFgugCgKi .. nFcUgCuKi .. "/" .. ufkukcnki
            end
            cfnufCiKf(nFiufCikn, "hh_06_armor", cFgugCgKi)
        end
        if kfuugCuku["finiteuses"] then
            local ffiUcCfKk = string["format"]("%.0f", kfuugCuku["finiteuses"]["current"] or "0")
            local uFfUncikk = string["format"]("%.0f", kfuugCuku["finiteuses"]["total"] or "0")
            cfnufCiKf(nFiufCikn, "hh_07_finiteuses", ffiUcCfKk, uFfUncikk)
        end
        if kfuugCuku["fueled"] then
            local ifuunCnkk = string["format"]("%.0f", kfuugCuku["fueled"]["currentfuel"] or "0")
            local ffgUkcuKg = string["format"]("%.0f", kfuugCuku["fueled"]["maxfuel"] or "0")
            cfnufCiKf(nFiufCikn, "hh_08_fueled", ifuunCnkk, ffgUkcuKg)
        end
        if kfuugCuku["tool"] and kfuugCuku["tool"]["actions"] then
            local kffufcukg = kfuugCuku["tool"]["actions"]
            local kfnUkckKc = ""
            for kfiunCuKg, gfcugCckc in pairs(kffufcukg) do
                if
                    kfiunCuKg and kfiunCuKg["id"] and nfuUuCikc[kfiunCuKg["id"]] and
                        iFkuiCkKf:IsHHType(gfcugCckc, "number")
                 then
                    kfnUkckKc = kfnUkckKc .. nfuUuCikc[kfiunCuKg["id"]]
                end
            end
            cfnufCiKf(nFiufCikn, "hh_09_tool", kfnUkckKc)
        end
        if kfuugCuku["stackable"] then
            local gfgUkCikc = kfuugCuku["stackable"]["stacksize"] or "0"
            local gfkuiciKi = kfuugCuku["stackable"]["maxsize"] or "0"
            cfnufCiKf(nFiufCikn, "hh_10_stackable", gfgUkCikc, gfkuiciKi)
        end
        if kfuugCuku["container"] then
            local cFiUcCfki = 0
            local kFcufckkf = ""
            if iFkuiCkKf:IsHHType(kfuugCuku["container"]["slots"], "table") then
                for kfnuicukg, cFiUnCcKk in pairs(kfuugCuku["container"]["slots"]) do
                    cFiUcCfki = cFiUcCfki + 1
                    if cFiUnCcKk["components"]["stackable"] and cFiUnCcKk["components"]["stackable"]["stacksize"] then
                        kFcufckkf =
                            kFcufckkf ..
                            (cFiUnCcKk["name"] or "kxđ") ..
                                "x" .. cFiUnCcKk["components"]["stackable"]["stacksize"] .. " "
                    else
                        kFcufckkf = kFcufckkf .. (cFiUnCcKk["name"] or "kxđ") .. " "
                    end
                end
            end
            if iFkuiCkKf:GetStringWordNum(kFcufckkf) > 20 then
                kFcufckkf = iFkuiCkKf:SubStringUTF8(kFcufckkf, 1, 20) .. "..."
            end
            if kFcufckkf ~= "" then
                kFcufckkf = "\nVật phẩm:" .. kFcufckkf
            end
            cfnufCiKf(nFiufCikn, "hh_12_container", cFiUcCfki, kfuugCuku["container"]["numslots"] or "0", kFcufckkf)
        end
        if kfuugCuku["perishable"] then
            local nFkunCgku = kfuugCuku["perishable"]["perishremainingtime"]
            local ffkugcuKf = cFnUkcikf(uFiufCcKu, nFkunCgku)
            cfnufCiKf(nFiufCikn, "hh_13_perishable", string["format"]("%.1f", ffkugcuKf / TUNING["TOTAL_DAY_TIME"]))
        end
        if
            kfuugCuku["unwrappable"] and kfuugCuku["unwrappable"]["itemdata"] and
                type(kfuugCuku["unwrappable"]["itemdata"]) == "table"
         then
            local ufiuiCnkk = ""
            for ufgUuCgkc, iffuiCgki in ipairs(kfuugCuku["unwrappable"]["itemdata"]) do
                if iffuiCgki["prefab"] then
                    local fffunCikc =
                        iffuiCgki["data"] and iffuiCgki["data"]["perishable"] and
                        iffuiCgki["data"]["perishable"]["time"]
                    local fFiUkCckk =
                        iffuiCgki["data"] and iffuiCgki["data"]["stackable"] and iffuiCgki["data"]["stackable"]["stack"]
                    local gFkUuCgkc =
                        iffuiCgki["data"] and iffuiCgki["data"]["named"] and iffuiCgki["data"]["named"]["name"] or
                        iffuiCgki["name"] or
                        "kxđ"
                    gFkUuCgkc = STRINGS["NAMES"][string["upper"](iffuiCgki["prefab"])] or "kxđ"
                    if ufgUuCgkc ~= 1 then
                        ufiuiCnkk = ufiuiCnkk .. "\n"
                    end
                    ufiuiCnkk = ufiuiCnkk .. tostring(gFkUuCgkc)
                    if fffunCikc ~= nil then
                        ufiuiCnkk =
                            ufiuiCnkk ..
                            "(" .. string["format"]("%.1f", fffunCikc / TUNING["TOTAL_DAY_TIME"]) .. " ngày)"
                    end
                    if fFiUkCckk ~= nil then
                        ufiuiCnkk = ufiuiCnkk .. "x" .. fFiUkCckk
                    end
                end
            end
            cfnufCiKf(nFiufCikn, "hh_14_unwrappable", ufiuiCnkk)
        end
        if
            kfuugCuku["stewer"] and kfuugCuku["stewer"]["product"] and kfuugCuku["stewer"]["IsCooking"] and
                kfuugCuku["stewer"]:IsCooking()
         then
            local kfgufCkkn = kfuugCuku["stewer"]["targettime"] - GetTime()
            if kfgufCkkn < 0 then
                kfgufCkkn = 0
            end
            local iFnUnciku = kfuugCuku["stewer"]["product"]
            cfnufCiKf(
                nFiufCikn,
                "hh_15_stewer",
                STRINGS["NAMES"][string["upper"](tostring(iFnUnciku))] or "kxđ",
                string["format"]("%.0f", kfgufCkkn)
            )
        end
        if kfuugCuku["growable"] and kfuugCuku["growable"]["stage"] then
            local nFfuiCkKn =
                (kfuugCuku["growable"]["pausedremaining"] ~= nil and
                math["max"](0, math["floor"](kfuugCuku["growable"]["pausedremaining"]))) or
                (kfuugCuku["growable"]["targettime"] ~= nil and
                    math["floor"](kfuugCuku["growable"]["targettime"] - GetTime())) or
                nil
            if nFfuiCkKn then
                local ifgufcgkf = kfuugCuku["growable"]["stage"] ~= 1 and tonumber(kfuugCuku["growable"]["stage"]) or 1
                local gFnUfcfkk = kfuugCuku["growable"]["stages"] and kfuugCuku["growable"]["stages"][ifgufcgkf]
                cfnufCiKf(
                    nFiufCikn,
                    "hh_16_growable",
                    gFnUfcfkk and gFnUfcfkk["name"] or ifgufcgkf,
                    string["format"]("%.1f", nFfuiCkKn / TUNING["TOTAL_DAY_TIME"])
                )
            end
        end
        if kfuugCuku["pickable"] and kfuugCuku["pickable"]["task"] and kfuugCuku["pickable"]["targettime"] then
            local cFiuickkf = kfuugCuku["pickable"]["targettime"] - GetTime()
            if cFiuickkf > 0 then
                cfnufCiKf(nFiufCikn, "hh_17_pickable", string["format"]("%.1f", cFiuickkf / TUNING["TOTAL_DAY_TIME"]))
            end
        end
        if
            kfuugCuku["insulator"] and iFkuiCkKf:IsHHType(kfuugCuku["insulator"]["insulation"], "number") and
                kfuugCuku["insulator"]["insulation"] ~= 0
         then
            local fFnUkcnkn = string["format"]("%.0f", kfuugCuku["insulator"]["insulation"] or 0)
            cfnufCiKf(nFiufCikn, "hh_18_insulator", fFnUkcnkn)
            if kfuugCuku["insulator"]["type"] == SEASONS["WINTER"] then
                nFiufCikn["hh_18_insulator"]["name"] = "Giữ ấm"
            elseif kfuugCuku["insulator"]["type"] == SEASONS["SUMMER"] then
                nFiufCikn["hh_18_insulator"]["name"] = "Cách nhiệt"
            end
        end
        if
            kfuugCuku["fishable"] and kfuugCuku["fishable"]["fishleft"] and
                type(kfuugCuku["fishable"]["fishleft"]) == "number"
         then
            cfnufCiKf(nFiufCikn, "hh_20_fishable", string["format"]("%.0f", kfuugCuku["fishable"]["fishleft"]))
        end
        if
            kfuugCuku["follower"] and kfuugCuku["follower"]["leader"] and kfuugCuku["follower"]["leader"]:IsValid() and
                kfuugCuku["follower"]["leader"]:HasTag("player") and
                kfuugCuku["follower"]["leader"]["name"] and
                kfuugCuku["follower"]["leader"]["name"] ~= ""
         then
            local gFnunCiKc = kfuugCuku["follower"]["leader"]["name"]
            local cfiUgcfkf = 0
            if kfuugCuku["follower"]["maxfollowtime"] then
                cfiUgcfkf = kfuugCuku["follower"]["maxfollowtime"]
            end
            local nFkuccikf = kfuugCuku["follower"]:GetLoyaltyPercent()
            cfnufCiKf(nFiufCikn, "hh_21_follower", gFnunCiKc, math["floor"](nFkuccikf * cfiUgcfkf + 0.5))
        end
        if
            kfuugCuku["equippable"] and kfuugCuku["equippable"]["walkspeedmult"] and
                kfuugCuku["equippable"]["walkspeedmult"] ~= 1
         then
            local uFiuickKn = math["floor"]((kfuugCuku["equippable"]["walkspeedmult"] - 1) * 100 + 0.5)
            cfnufCiKf(nFiufCikn, "hh_23_equippable", fFgUkckkf(uFiuickKn))
        end
        if
            kfuugCuku["tradable"] and
                ((kfuugCuku["tradable"]["goldvalue"] and kfuugCuku["tradable"]["goldvalue"] > 0) or
                    (kfuugCuku["tradable"]["rocktribute"] and kfuugCuku["tradable"]["rocktribute"] > 0))
         then
            local ufgukCcku = 0
            local kFfunCfKk = 0
            if kfuugCuku["tradable"]["goldvalue"] and kfuugCuku["tradable"]["goldvalue"] > 0 then
                ufgukCcku = kfuugCuku["tradable"]["goldvalue"]
            end
            if kfuugCuku["tradable"]["rocktribute"] and kfuugCuku["tradable"]["rocktribute"] > 0 then
                kFfunCfKk = kfuugCuku["tradable"]["rocktribute"]
            end
            cfnufCiKf(nFiufCikn, "hh_24_tradable", ufgukCcku, kFfunCfKk)
        end
        if
            kfuugCuku["childspawner"] and kfuugCuku["childspawner"]["childreninside"] and
                kfuugCuku["childspawner"]["maxchildren"]
         then
            local uFuuiCgkk = tonumber(kfuugCuku["childspawner"]["childreninside"])
            local gfuUnCnkk = tonumber(kfuugCuku["childspawner"]["maxchildren"])
            if uFuuiCgkk and uFuuiCgkk ~= 0 and gfuUnCnkk and gfuUnCnkk ~= 0 then
                cfnufCiKf(
                    nFiufCikn,
                    "hh_26_childspawner",
                    string["format"]("%.0f", uFuuiCgkk),
                    string["format"]("%.0f", gfuUnCnkk)
                )
            end
        end
        if kfuugCuku["domesticatable"] ~= nil then
            local fFcukccKu = 0
            local ffnunciKk = 0
            local fFuufCkkc = ""
            local nFfunckkc = (54 - 350 * 243 == -84993)
            if
                kfuugCuku["domesticatable"]["GetObedience"] and
                    type(kfuugCuku["domesticatable"]:GetDomestication()) == "number"
             then
                nFfunckkc = (485 * 182 + 417 == 88687)
                fFcukccKu = tonumber(kfuugCuku["domesticatable"]:GetObedience()) * 100
                fFuufCkkc = fFuufCkkc .. "Nghe lời:" .. string["format"]("%.0f", fFcukccKu) .. "%"
            end
            if
                kfuugCuku["domesticatable"]["GetDomestication"] and
                    type(kfuugCuku["domesticatable"]:GetDomestication()) == "number"
             then
                nFfunckkc = (208 + 145 - 430 * 367 * 72 == -11361967)
                ffnunciKk = tonumber(kfuugCuku["domesticatable"]:GetDomestication()) * 100
                fFuufCkkc = fFuufCkkc .. "Thuần hoá:" .. string["format"]("%.0f", ffnunciKk) .. "%"
            end
            if nFfunckkc then
                cfnufCiKf(nFiufCikn, "hh_27_domesticatable", fFuufCkkc)
            end
        end
        if kfuugCuku["dryer"] and kfuugCuku["dryer"]["IsDrying"] then
            if kfuugCuku["dryer"]:IsDrying() and kfuugCuku["dryer"]["GetTimeToDry"] then
                cfnufCiKf(
                    nFiufCikn,
                    "hh_28_dryer",
                    string["format"]("%.1f", kfuugCuku["dryer"]:GetTimeToDry() / TUNING["TOTAL_DAY_TIME"]) ..
                        "ngày sẽ khô"
                )
            elseif kfuugCuku["dryer"]["IsDone"] and kfuugCuku["dryer"]:IsDone() and kfuugCuku["dryer"]["GetTimeToSpoil"] then
                cfnufCiKf(
                    nFiufCikn,
                    "hh_28_dryer",
                    string["format"]("%.1f", kfuugCuku["dryer"]:GetTimeToSpoil() / TUNING["TOTAL_DAY_TIME"]) ..
                        "ngày sẽ hỏng"
                )
            end
        end
        if kfuugCuku["farmplantstress"] and kfuugCuku["farmplantstress"]["stress_points"] then
            local fFiufcnKk = kfuugCuku["farmplantstress"]["stress_points"]
            cfnufCiKf(nFiufCikn, "hh_29_farmplantstress", fFiufcnKk)
        end
        if kfuugCuku["cookable"] and kfuugCuku["cookable"]["product"] then
            local iffUnCkkf = kfuugCuku["cookable"]["product"]
            if type(iffUnCkkf) == "string" then
                cfnufCiKf(nFiufCikn, "hh_30_cookable", STRINGS["NAMES"][string["upper"](tostring(iffUnCkkf))] or "kxđ")
            end
        end
        if kfuugCuku["locomotor"] and kfuugCuku["locomotor"]["walkspeed"] and kfuugCuku["locomotor"]["runspeed"] then
            cfnufCiKf(
                nFiufCikn,
                "hh_31_locomotor",
                kfuugCuku["locomotor"]["runspeed"],
                kfuugCuku["locomotor"]["walkspeed"]
            )
        end
    end
    if uFiufCcKu["hh_tags"] and iFkuiCkKf:IsHHType(uFiufCcKu["hh_tags"], "table") then
        local kfiUfcuKg = iFkuiCkKf:TableSortKeys(uFiufCcKu["hh_tags"])
        if #kfiUfcuKg > 0 then
            local iFuUccnkg = ""
            for gfnUuCiku, kFcUiCuKi in ipairs(kfiUfcuKg) do
                local nFkUkcuku = tostring(uFiufCcKu["hh_tags"][kFcUiCuKi])
                iFuUccnkg = iFuUccnkg .. nFkUkcuku .. " "
            end
            cfnufCiKf(nFiufCikn, "hh_31_hh_tag", iFuUccnkg)
        end
    end
    local gffukCgku = ""
    local ifnunciKn, cFnUucukk =
        pcall(
        function()
            return GetDescription(nfcuicgKn, uFiufCcKu)
        end
    )
    if ifnunciKn and iFkuiCkKf:IsHHType(cFnUucukk, "string") then
        gffukCgku = cFnUucukk
        local nFcUncgkg = iFkuiCkKf:GetStringWordNum(gffukCgku)
        if nFcUncgkg > 20 then
            gffukCgku = iFkuiCkKf:SubStringUTF8(gffukCgku, 1, 20) .. "..."
        end
        cfnufCiKf(nFiufCikn, "hh_01_text", tostring(gffukCgku))
    end
    if kfuugCuku["hh_equip"] then
        local cFfukCukk = kfuugCuku["hh_equip"]:GetGemDebugString()
        cfnufCiKf(nFiufCikn, "hh_32_hh_gem", tostring(cFfukCukk))
        nFiufCikn["hh_32_hh_gem"]["child_ui"] = kfuugCuku["hh_equip"]:GetGemDebugList()
        if kfuugCuku["hh_equip"]:CanShowBuffUi() then
            local gfuUiciku = kfuugCuku["hh_equip"]:GetBuffDebugString()
            cfnufCiKf(nFiufCikn, "hh_32_hh_equip", tostring(gfuUiciku))
            nFiufCikn["hh_32_hh_equip"]["child_ui"] = kfuugCuku["hh_equip"]:GetBuffDebugList(nfcuicgKn)
            local uFgUgckku = kfuugCuku["hh_equip"]:HasSuitEffect()
            if
                uFgUgckku and TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][uFgUgckku] and
                    iFkuiCkKf:CheckSuitEffect(nfcuicgKn, uFgUgckku)
             then
                local ifkuccnki = TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][uFgUgckku]["effect_str"]
                cfnufCiKf(nFiufCikn, "hh_32_hh_equip_suit", tostring(ifkuccnki))
            end
        end
    end
    if kfuugCuku["hh_player"] then
        local ufguicnkc = kfuugCuku["hh_player"]:GetDebugStr()
        cfnufCiKf(nFiufCikn, "hh_32_hh_player", tostring(ufguicnkc))
    end
    if nffUuCnKc == "hh_effect_stone" and uFiufCcKu["hh_effect"] and uFkUkCfKf[uFiufCcKu["hh_effect"]] then
        local gfcUgCuki = uFiufCcKu["hh_effect"]
        local cffUuCkkk = uFkUkCfKf[gfcUgCuki]["name"]
        if uFkUkCfKf[gfcUgCuki]["desc"] then
            local cfiufcnKg = "?"
            if uFkUkCfKf[gfcUgCuki]["value_range"] then
                cfiufcnKg = iFkuiCkKf:Template("({{min}}~{{max}})", uFkUkCfKf[gfcUgCuki]["value_range"])
                cffUuCkkk = string["format"](uFkUkCfKf[gfcUgCuki]["desc"], cfiufcnKg)
            else
                cffUuCkkk = uFkUkCfKf[gfcUgCuki]["desc"]
            end
            if uFkUkCfKf[gfcUgCuki]["check_desc"] then
                local iFgufckkk = uFkUkCfKf[gfcUgCuki]["check_desc"]
                cfnufCiKf(nFiufCikn, "hh_32_hh_gem_check", tostring(iFgufckkk))
            end
        end
        cfnufCiKf(nFiufCikn, "hh_32_hh_equip", tostring(cffUuCkkk))
    end
    if kfuugCuku["hh_monster"] then
        local fFkUncuku = kfuugCuku["hh_monster"]:GetAllBuffNum()
        if fFkUncuku > 0 then
            local kfgUuCkKk = kfuugCuku["hh_monster"]:GetDebugString()
            cfnufCiKf(nFiufCikn, "hh_32_hh_monster", kfgUuCkKk)
        end
    end
    if nffUuCnKc == "hh_save_stone" then
        local ifnUfcnKn = uFiufCcKu["hh_save_list"]
        if iFkuiCkKf:IsHHType(ifnUfcnKn, "table") and ifnUfcnKn["user_id"] then
            local cFuUcCkKk = ifnUfcnKn["user_id"]
            local cfkUuCfKc = ifnUfcnKn["user_name"]
            cfnufCiKf(nFiufCikn, "hh_32_hh_save", tostring(cFuUcCkKk), tostring(cfkUuCfKc))
        end
    end
    if nfcuicgKn["HHNeedShowInfo"] then
        cfnufCiKf(nFiufCikn, "hh_99_prefab", nffUuCnKc)
        local nfnUgCnKc = kffugCkKi(uFiufCcKu)
        local fFnUkcuKu = string["find"](nfnUgCnKc, "/[^/]*$")
        if fFnUkcuKu then
            local iFcukCcKi = string["sub"](nfnUgCnKc, fFnUkcuKu + 1)
            cfnufCiKf(nFiufCikn, "hh_99_path", iFcukCcKi)
        end
        if uFiufCcKu["AnimState"] and uFiufCcKu["AnimState"]["GetHistoryData"] then
            local kFuUgCgKn = uFiufCcKu["AnimState"]:GetBuild()
            local kFguncfkg, cfiunCckc = uFiufCcKu["AnimState"]:GetHistoryData()
            cfnufCiKf(nFiufCikn, "hh_99_idle", tostring(kFguncfkg), tostring(kFuUgCgKn), tostring(cfiunCckc))
        end
    end
    if
        kfuugCuku["follower"] and kfuugCuku["follower"]["leader"] and
            iFkuiCkKf:HasComponents(kfuugCuku["follower"]["leader"], "hh_player")
     then
        local fFcuuCuki = kfuugCuku["follower"]["leader"]
        if
            fFcuuCuki["components"]["hh_player"]:HasSpecialEffect("addFollowDamage") or
                fFcuuCuki["components"]["hh_player"]:HasSpecialEffect("addFollowReduceDamage") or
                fFcuuCuki["components"]["hh_player"]:HasSpecialEffect("addFollowCritical")
         then
            local cFfuuCnKu = fFcuuCuki["components"]["hh_player"]:GetEffectValueByKey("addFollowDamage")
            local gFcUucukf = fFcuuCuki["components"]["hh_player"]:GetEffectValueByKey("addFollowReduceDamage")
            local ifkUuCkkf = fFcuuCuki["components"]["hh_player"]:GetEffectValueByKey("addFollowCritical")
            local uFkugcukg = string["format"]("ST:(%s) Giáp:(%s) Crit:(%s %%)", cFfuuCnKu, gFcUucukf, ifkUuCkkf)
            cfnufCiKf(nFiufCikn, "hh_33_hh_follow", uFkugcukg)
        end
    end
    if uFiufCcKu["GetHHSpDesc01"] then
        local ufuucCkku = uFiufCcKu:GetHHSpDesc01(nfcuicgKn)
        if iFkuiCkKf:IsHHType(ufuucCkku, "table") then
            cfnufCiKf(nFiufCikn, "hh_99_special_01", tostring(ufuucCkku["desc"]))
            if iFkuiCkKf:IsHHType(ufuucCkku["title"], "string") then
                nFiufCikn["hh_99_special_01"]["name"] = ufuucCkku["title"] .. ":"
            end
            if iFkuiCkKf:IsHHType(ufuucCkku["color"], "table") then
                nFiufCikn["hh_99_special_01"]["str_color"] = ufuucCkku["color"]
            end
            if ufuucCkku["rainbow"] == true then
                nFiufCikn["hh_99_special_01"]["rainbow"] = true
            end
        end
    end
    if uFiufCcKu["GetHHSpDesc02"] then
        local uFkufccKi = uFiufCcKu:GetHHSpDesc02(nfcuicgKn)
        if iFkuiCkKf:IsHHType(uFkufccKi, "table") then
            cfnufCiKf(nFiufCikn, "hh_99_special_02", tostring(uFkufccKi["desc"]))
            if iFkuiCkKf:IsHHType(uFkufccKi["title"], "string") then
                nFiufCikn["hh_99_special_02"]["name"] = uFkufccKi["title"] .. ":"
            end
            if iFkuiCkKf:IsHHType(uFkufccKi["color"], "table") then
                nFiufCikn["hh_99_special_02"]["str_color"] = uFkufccKi["color"]
            end
            if uFkufccKi["rainbow"] == true then
                nFiufCikn["hh_99_special_02"]["rainbow"] = true
            end
        end
    end
    if uFiufCcKu["GetHHSpDesc03"] then
        local nfnufCuKg = uFiufCcKu:GetHHSpDesc03(nfcuicgKn)
        if iFkuiCkKf:IsHHType(nfnufCuKg, "table") then
            cfnufCiKf(nFiufCikn, "hh_99_special_03", tostring(nfnufCuKg["desc"]))
            if iFkuiCkKf:IsHHType(nfnufCuKg["title"], "string") then
                nFiufCikn["hh_99_special_03"]["name"] = nfnufCuKg["title"] .. ":"
            end
            if iFkuiCkKf:IsHHType(nfnufCuKg["color"], "table") then
                nFiufCikn["hh_99_special_03"]["str_color"] = nfnufCuKg["color"]
            end
            if nfnufCuKg["rainbow"] == true then
                nFiufCikn["hh_99_special_03"]["rainbow"] = true
            end
        end
    end
    if uFiufCcKu["GetHHSpDesc04"] then
        local nFuukCiKk = uFiufCcKu:GetHHSpDesc04(nfcuicgKn)
        if iFkuiCkKf:IsHHType(nFuukCiKk, "table") then
            cfnufCiKf(nFiufCikn, "hh_99_special_04", tostring(nFuukCiKk["desc"]))
            if iFkuiCkKf:IsHHType(nFuukCiKk["title"], "string") then
                nFiufCikn["hh_99_special_04"]["name"] = nFuukCiKk["title"] .. ":"
            end
            if iFkuiCkKf:IsHHType(nFuukCiKk["color"], "table") then
                nFiufCikn["hh_99_special_04"]["str_color"] = nFuukCiKk["color"]
            end
            if nFuukCiKk["rainbow"] == true then
                nFiufCikn["hh_99_special_04"]["rainbow"] = true
            end
        end
    end
    if uFiufCcKu["GetHHSpDesc05"] then
        local ufiucciKg = uFiufCcKu:GetHHSpDesc05(nfcuicgKn)
        if iFkuiCkKf:IsHHType(ufiucciKg, "table") then
            cfnufCiKf(nFiufCikn, "hh_99_special_05", tostring(ufiucciKg["desc"]))
            if iFkuiCkKf:IsHHType(ufiucciKg["title"], "string") then
                nFiufCikn["hh_99_special_05"]["name"] = ufiucciKg["title"] .. ":"
            end
            if iFkuiCkKf:IsHHType(ufiucciKg["color"], "table") then
                nFiufCikn["hh_99_special_05"]["str_color"] = ufiucciKg["color"]
            end
            if ufiucciKg["rainbow"] == true then
                nFiufCikn["hh_99_special_05"]["rainbow"] = true
            end
        end
    end
    for hh_desc_index = 6, 99 do
        local hh_suffix = string.format("%02d", hh_desc_index)
        local hh_getter = uFiufCcKu["GetHHSpDesc" .. hh_suffix]
        if type(hh_getter) == "function" then
            local hh_desc = hh_getter(uFiufCcKu, nfcuicgKn)
            if type(hh_desc) == "table" then
                local hh_key = "hh_99_special_" .. hh_suffix
                cfnufCiKf(nFiufCikn, hh_key, tostring(hh_desc.desc or ""))
                if type(hh_desc.title) == "string" then nFiufCikn[hh_key].name = hh_desc.title .. ":" end
                if type(hh_desc.color) == "table" then nFiufCikn[hh_key].str_color = hh_desc.color end
                if hh_desc.rainbow == true then nFiufCikn[hh_key].rainbow = true end
            end
        end
    end
end

local function ResolveHoverInfoEntity(hovered_entity)
    if hovered_entity == nil or not hovered_entity:IsValid() then
        return hovered_entity
    end
    local is_worm_piece =
        hovered_entity:HasTag("worm_boss_piece") or hovered_entity["prefab"] == "worm_boss_dirt"
    if not is_worm_piece then
        return hovered_entity
    end

    local root = hovered_entity.worm
    if root ~= nil and root ~= hovered_entity and root:IsValid() and root.prefab == "worm_boss" then
        return root
    end

    return hovered_entity
end

AddModRPCHandler(
    "hh_rpc",
    "hh_hoverer_server",
    function(iFuuccgkn, kfguccukc, nfiuicfKg)
        if not (iFuuccgkn and kfguccukc and iFuuccgkn:IsValid() and kfguccukc:IsValid()) then
            return
        end
        local kFiuuCnkg = {}
        local hovered_entity = kfguccukc
        local info_entity = ResolveHoverInfoEntity(hovered_entity)
        local hovered_prefab = hovered_entity["prefab"]
        local uFkufCkKc = info_entity["prefab"]
        local nfnufcfKg = info_entity["components"]
        local is_worm_boss_info = uFkufCkKc == "worm_boss"
        if hovered_prefab ~= "abigail" and hovered_prefab ~= "hh_macanh_shadow" and hovered_prefab ~= "hh_hacanh_shadow" and not is_worm_boss_info and hovered_entity:HasTag("NOBLOCK") and not hovered_entity:HasTag("monster") then
            return
        end
        if nfiuicfKg then
            cfnufCiKf(kFiuuCnkg, "hh_01_name", tostring(nfiuicfKg))
        end
        local ufuUgcuku, iFcuicgku = pcall(cFcuuckkg, kFiuuCnkg, iFuuccgkn, info_entity, nfnufcfKg, uFkufCkKc)
        if not ufuUgcuku then
            local iFcufcgkg = tostring(iFcuicgku)
            local fFuuiCgKu = string["find"](iFcufcgkg, ":")
            local cfkuuCgKu = "Ngoại lệ trong việc đọc dữ liệu"
            if fFuuiCgKu then
                cfkuuCgKu = string["sub"](iFcufcgkg, fFuuiCgKu + 1)
            end
            cfnufCiKf(kFiuuCnkg, "hh_99_exception", tostring(cfkuuCgKu))
        end
        local gFuUfCiki = iFkuiCkKf:HHCompareTable(iFuuccgkn["HH_LAST_HOVERER_LIST"], kFiuuCnkg)
        if gFuUfCiki then
            SendModRPCToClient(
                CLIENT_MOD_RPC["hh_rpc"]["hh_rpc_client"],
                iFuuccgkn["userid"],
                "hh_hoverer_list",
                "Refresh"
            )
            return
        else
            SendModRPCToClient(
                CLIENT_MOD_RPC["hh_rpc"]["hh_rpc_client"],
                iFuuccgkn["userid"],
                "hh_hoverer_list",
                iFkuiCkKf:TableToStr(kFiuuCnkg)
            )
            iFuuccgkn["HH_LAST_HOVERER_LIST"] = iFkuiCkKf:HHCopyTable(kFiuuCnkg)
        end
    end
)
AddClientModRPCHandler(
    "hh_rpc",
    "hh_rpc_client",
    function(uFnuiciKn, kFcucckki)
        if ThePlayer and uFnuiciKn and type(uFnuiciKn) == "string" then
            if kFcucckki == "Refresh" then
            else
                ThePlayer[uFnuiciKn] = iFkuiCkKf:StrToTable(kFcucckki)
            end
            ThePlayer:PushEvent("hh_update_hoverer")
        end
    end
)
local function IsHHContainerOpen(player, use_suit)
    local hh_player = player ~= nil and player["components"] ~= nil and player["components"]["hh_player"] or nil
    local container = hh_player ~= nil and (use_suit and hh_player["forge_container"] or hh_player["ui_container"]) or nil
    return
        container ~= nil and
        container["components"] ~= nil and
        container["components"]["container"] ~= nil and
        container["components"]["container"]:IsOpenedBy(player)
end
local function kfkUkcuKu(iFcUcCcKc, container_mode, request_id)
    local use_suit = container_mode == true or container_mode == "forge_container"
    local prefab = use_suit and "hh_forge_container" or "hh_ui_container"
    if not uFkUcCikg(iFcUcCcKc) or iFcUcCcKc:HasTag("playerghost") then
        TTKNativeOpenAck.SendFailure(iFcUcCcKc, prefab, request_id, "Không thể mở giao diện trong trạng thái hiện tại")
        return
    end
    local is_closing = IsHHContainerOpen(iFcUcCcKc, use_suit)
    if iFcUcCcKc["components"]["rider"] ~= nil and iFcUcCcKc["components"]["rider"]:IsRiding() and not is_closing then
        local reason = "Không thể hoạt động ở trạng thái đang cưỡi bò"
        iFkuiCkKf:HHSay(iFcUcCcKc, reason)
        TTKNativeOpenAck.SendFailure(iFcUcCcKc, prefab, request_id, reason)
        return
    end
    if iFcUcCcKc["time_refiner"] and not is_closing then
        local reason = "Nhanh quá"
        iFkuiCkKf:HHSay(iFcUcCcKc, reason)
        TTKNativeOpenAck.SendFailure(iFcUcCcKc, prefab, request_id, reason)
        return
    end
    if iFcUcCcKc["components"]["hh_player"] ~= nil then
        if use_suit then
            iFcUcCcKc["components"]["hh_player"]:OpenSuitContainer()
        else
            iFcUcCcKc["components"]["hh_player"]:OpenContainer("ui_container")
        end
    else
        TTKNativeOpenAck.SendFailure(iFcUcCcKc, prefab, request_id, "Không có quyền sử dụng")
        return
    end
    iFcUcCcKc["time_refiner"] = (236 - 255 + 325 == 306)
    iFcUcCcKc:DoTaskInTime(
        0.2,
        function()
            iFcUcCcKc["time_refiner"] = (43 - 25 - 75 ~= -57)
        end
    )
end
AddModRPCHandler("hh_rpc", "hh_ui_container", kfkUkcuKu)

local function GetMonarchStorage(player)
    local hh_player = player ~= nil and player.components ~= nil and player.components.hh_player or nil
    return hh_player, hh_player ~= nil and hh_player.monarch_storage or nil
end

AddModRPCHandler("hh_rpc", "hh_monarch_storage_open", function(player, request_id)
    if not uFkUcCikg(player) or player:HasTag("playerghost") then
        TTKNativeOpenAck.SendFailure(
            player, "hh_monarch_storage_container", request_id,
            "Không thể mở Kho Quân Vương trong trạng thái hiện tại"
        )
        return
    end
    local rank = player.components.hh_rank ~= nil and player.components.hh_rank:GetRank() or HHRankDefs.RANK.E
    local hh_player = GetMonarchStorage(player)
    if rank >= HHRankDefs.RANK.A and hh_player ~= nil then
        hh_player:OpenMonarchStorage()
    else
        TTKNativeOpenAck.SendFailure(
            player, "hh_monarch_storage_container", request_id,
            rank < HHRankDefs.RANK.A and "Yêu cầu cấp bậc A để mở Kho Quân Vương" or "Không có quyền sử dụng"
        )
    end
end)

AddClientModRPCHandler("hh_rpc", "hh_native_open_failed", function(prefab, request_id, reason)
    if ThePlayer ~= nil then
        TTKNativeOpenAck.HandleFailure(ThePlayer, prefab, request_id, reason)
    end
end)

AddModRPCHandler("hh_rpc", "hh_monarch_storage_close", function(player)
    if player == nil or not player:IsValid() then
        return
    end
    local _, storage = GetMonarchStorage(player)
    local container = storage ~= nil and storage.components ~= nil and storage.components.container or nil
    if container ~= nil and storage.hh_ui_owner == player and container:IsOpenedBy(player) then
        container:Close(player)
    end
end)

AddModRPCHandler("hh_rpc", "hh_monarch_storage_lock", function(player, slot, item_guid)
    if not uFkUcCikg(player) or player:HasTag("playerghost")
        or type(slot) ~= "number" or type(item_guid) ~= "number" then
        return
    end
    local rank = player.components.hh_rank ~= nil and player.components.hh_rank:GetRank() or HHRankDefs.RANK.E
    local hh_player, storage = GetMonarchStorage(player)
    local container = storage ~= nil and storage.components.container or nil
    if rank < HHRankDefs.RANK.A or hh_player == nil or container == nil
        or storage.hh_ui_owner ~= player or not container:IsOpenedBy(player)
        or slot < 1 or slot > container:GetNumSlots() or slot ~= math.floor(slot) then
        return
    end
    local item = container:GetItemInSlot(slot)
    if item == nil or item.GUID ~= item_guid or item.components.inventoryitem == nil then
        return
    end
    item.components.inventoryitem.islockedinslot = not item.components.inventoryitem.islockedinslot
    storage:PushEvent("refresh")
    player:PushEvent("refreshcrafting")
    SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_monarch_storage_lock_dirty"],
        player.userid, slot, item.GUID, item.components.inventoryitem.islockedinslot)
end)

AddClientModRPCHandler("hh_rpc", "hh_monarch_storage_lock_dirty", function(slot, guid, locked)
    if ThePlayer ~= nil then
        ThePlayer:PushEvent("hh_monarch_storage_lock_dirty", {
            slot = slot,
            guid = guid,
            locked = locked == true,
        })
        ThePlayer:PushEvent("refreshcrafting")
    end
end)
local function iFcucCfkg(cfiugcikn, kFfUnCcKg, uFiucCkKk, forge_revision)
    if not uFkUcCikg(cfiugcikn) or cfiugcikn:HasTag("playerghost") or not iFkuiCkKf:IsHHType(kFfUnCcKg, "string") then
        iFkuiCkKf:HHSay(cfiugcikn, "Hoạt động không được phép trong tình trạng hiện tại!!!")
        return
    end
    if cfiugcikn["components"]["rider"] ~= nil and cfiugcikn["components"]["rider"]:IsRiding() then
        iFkuiCkKf:HHSay(cfiugcikn, "Không thể hoạt động ở trạng thái đang cưỡi bò")
        return
    end
    if not iFkuiCkKf:HasComponents(cfiugcikn, "hh_player") then
        iFkuiCkKf:HHSay(cfiugcikn, "Ko có quyền sử dụng !!!")
        return
    end
    if cfiugcikn["hh_rpc_cd"] then
        iFkuiCkKf:HHSay(cfiugcikn, "Nhanh quá !!!")
        if kFfUnCcKg == "CleanEffect" or kFfUnCcKg == "EquipInherit" or kFfUnCcKg == "ReplaceStone" then
            cfiugcikn.components.hh_player:UpdateForgeState()
        end
        return
    end
    if kFfUnCcKg == "CleanEffect" or kFfUnCcKg == "EquipInherit" or kFfUnCcKg == "ReplaceStone" then
        local hh_player = cfiugcikn.components.hh_player
        if type(forge_revision) ~= "number" or forge_revision ~= hh_player._ttk_forge_revision then
            hh_player:UpdateForgeState()
            return
        end
    end
    local cFkUfccKf, iFiUickki = (325 * 493 - 253 * 437 == 49668), nil
    if kFfUnCcKg == "ForgeTab" and type(uFiucCkKk) == "string" then
        cFkUfccKf, iFiUickki = cfiugcikn.components.hh_player:SetForgeMode(uFiucCkKk)
    elseif kFfUnCcKg == "MoveEquips" then
        cfiugcikn["components"]["hh_player"]:MoveEquips()
    elseif kFfUnCcKg == "RemoveEquips" then
        cfiugcikn["components"]["hh_player"]:RemoveEquips()
    elseif kFfUnCcKg == "EquipGems" then
        if iFkuiCkKf:IsHHType(uFiucCkKk, "string") then
            if uFiucCkKk == "aa_punchStone" then
                cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:AddEquipGemsLimit()
            elseif uFiucCkKk == "ab_decoderStone" then
                cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:RemoveEquipGems(nil)
            elseif iffugcgKk[uFiucCkKk] and iffugcgKk[uFiucCkKk]["is_item"] then
                cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:UseSpecialItem(uFiucCkKk)
            else
                cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:AddEquipGems(uFiucCkKk)
            end
        end
    elseif kFfUnCcKg == "AddEquipEffect" then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:AddEquipEffect()
    elseif kFfUnCcKg == "RemoveEquipEffect" then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:RemoveEquipEffect()
    elseif kFfUnCcKg == "UpdateEffectValue" then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:UpdateEffectValue()
    elseif kFfUnCcKg == "CleanEffect" and iFkuiCkKf:IsHHType(uFiucCkKk, "string") then
        cFkUfccKf, iFiUickki =
            cfiugcikn["components"]["hh_player"]:RemoveMoreEquipEffect(iFkuiCkKf:StrToTable(uFiucCkKk))
    elseif kFfUnCcKg == "CompositeSuit" and iFkuiCkKf:IsHHType(uFiucCkKk, "string") then
    elseif kFfUnCcKg == "EquipInherit" then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:EquipEffectInherit()
    elseif kFfUnCcKg == "EffectCompose" then
    elseif kFfUnCcKg == "ReplaceStone" then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:AddReplaceStone()
    elseif kFfUnCcKg == "CompoundSuitEffect" and iFkuiCkKf:IsHHType(uFiucCkKk, "string") then
        cFkUfccKf, iFiUickki = cfiugcikn["components"]["hh_player"]:CompoundEquipEffect(uFiucCkKk)
    end
    if kFfUnCcKg == "CleanEffect" or kFfUnCcKg == "EquipInherit" or kFfUnCcKg == "ReplaceStone" then
        cfiugcikn.components.hh_player:UpdateForgeState()
    end
    if iFiUickki then
        iFkuiCkKf:HHSay(cfiugcikn, tostring(iFiUickki))
    end
    cfiugcikn["hh_rpc_cd"] = (34 * 21 + 244 * 343 + 302 ~= 84713)
    cfiugcikn:DoTaskInTime(
        0.2,
        function()
            cfiugcikn["hh_rpc_cd"] = (34 + 468 + 385 ~= 887)
        end
    )
end
AddModRPCHandler("hh_rpc", "hh_handle_equip", iFcucCfkg)
local iFuUgciKc = {
    ["ttk_forge_state"] = true,
    ["hh_client_buff"] = (154 + 89 - 76 * 297 ~= -22324),
    ["hh_items"] = (146 - 116 + 21 + 194 * 455 == 88321),
    ["hh_hoverer_config"] = (171 + 99 + 37 + 169 ~= 485),
    ["hh_forge_equip"] = (392 * 362 + 337 ~= 142247),
    ["hh_forge_stone"] = (222 + 3 + 98 + 315 + 276 == 914),
    ["hh_suit_list"] = (352 + 372 * 263 - 14 * 399 ~= 92612),
    ["hh_skin_item_list"] = (303 + 237 * 335 ~= 79708)
}
AddClientModRPCHandler(
    "hh_rpc",
    "hh_client_value",
    function(fffuiCukg, kfiukckKf)
        if not ThePlayer then
            return
        end
        if not iFkuiCkKf:HasComponents(ThePlayer, "hh_client") then
            ThePlayer:AddComponent("hh_client")
        end
        if fffuiCukg and type(fffuiCukg) == "string" then
            if iFuUgciKc[fffuiCukg] then
                ThePlayer["components"]["hh_client"]:SetValue(fffuiCukg, iFkuiCkKf:StrToTable(kfiukckKf))
            else
                ThePlayer["components"]["hh_client"]:SetValue(fffuiCukg, kfiukckKf)
            end
        end
    end
)
local uFuukCfkn = GetModConfigData("key_config") or 120
if uFuukCfkn == KEY_B or uFuukCfkn == KEY_V then
    uFuukCfkn = KEY_X
end
if uFuukCfkn ~= KEY_L then
    local UnifiedOpen = require("ui/ttk_unified_open")
    local UnifiedRegistry = require("ui/ttk_unified_registry")
    TheInput:AddKeyUpHandler(
        uFuukCfkn,
        function()
            if HHGuideLock.IsOpen(ThePlayer) then
                return
            end
            if UnifiedRegistry.Get(ThePlayer) ~= nil then
                UnifiedOpen.Toggle(ThePlayer, "equipment")
                return
            end
            if ThePlayer ~= nil and ThePlayer.HHMonarchStorageOpen then
                return
            end
            if HHSummaryLock.IsOpen(ThePlayer) then
                HHSummaryLock.Close(ThePlayer)
                return
            end
            if ThePlayer then
                UnifiedOpen.Open(ThePlayer, "equipment")
            end
        end
    )
end
local nfiuiCkki = {
    {["hover"] = "Nhấn nút G để mở Bảng Tổng Hợp", ["description"] = "G", ["data"] = 103},
    {["hover"] = "Nhấn nút H để mở Bảng Tổng Hợp", ["description"] = "H", ["data"] = 104},
    {["hover"] = "Nhấn nút I để mở Bảng Tổng Hợp", ["description"] = "I", ["data"] = 105},
    {["hover"] = "Nhấn nút J để mở Bảng Tổng Hợp", ["description"] = "J", ["data"] = 106},
    {["hover"] = "Nhấn nút K để mở Bảng Tổng Hợp", ["description"] = "K", ["data"] = 107},
    {["hover"] = "Nhấn nút L để mở Bảng Tổng Hợp", ["description"] = "L", ["data"] = 108},
    {["hover"] = "Nhấn nút N để mở Bảng Tổng Hợp", ["description"] = "N", ["data"] = 110},
    {["hover"] = "Nhấn nút O để mở Bảng Tổng Hợp", ["description"] = "O", ["data"] = 111},
    {["hover"] = "Nhấn nút P để mở Bảng Tổng Hợp", ["description"] = "P", ["data"] = 112},
    {["hover"] = "Nhấn nút R để mở Bảng Tổng Hợp", ["description"] = "R", ["data"] = 114},
    {["hover"] = "Nhấn nút T để mở Bảng Tổng Hợp", ["description"] = "T", ["data"] = 116},
    {["hover"] = "Nhấn nút X để mở Bảng Tổng Hợp", ["description"] = "X", ["data"] = 120},
    {["hover"] = "Nhấn nút Z để mở Bảng Tổng Hợp", ["description"] = "Z", ["data"] = 122},
    {["hover"] = "Nhấn nút F1 để mở Bảng Tổng Hợp", ["description"] = "F1", ["data"] = 282},
    {["hover"] = "Nhấn nút F2 để mở Bảng Tổng Hợp", ["description"] = "F2", ["data"] = 283},
    {["hover"] = "Nhấn nút F3 để mở Bảng Tổng Hợp", ["description"] = "F3", ["data"] = 284},
    {["hover"] = "Nhấn nút F4 để mở Bảng Tổng Hợp", ["description"] = "F4", ["data"] = 285},
    {["hover"] = "Nhấn nút F5 để mở Bảng Tổng Hợp", ["description"] = "F5", ["data"] = 286},
    {["hover"] = "Nhấn nút F6 để mở Bảng Tổng Hợp", ["description"] = "F6", ["data"] = 287},
    {["hover"] = "Nhấn nút F7 để mở Bảng Tổng Hợp", ["description"] = "F7", ["data"] = 288},
    {["hover"] = "Nhấn nút F8 để mở Bảng Tổng Hợp", ["description"] = "F8", ["data"] = 289},
    {["hover"] = "Nhấn nút F9 để mở Bảng Tổng Hợp", ["description"] = "F9", ["data"] = 290},
    {["hover"] = "Nhấn nút F10 để mở Bảng Tổng Hợp", ["description"] = "F10", ["data"] = 291},
    {["hover"] = "Nhấn nút F11 để mở Bảng Tổng Hợp", ["description"] = "F11", ["data"] = 292},
    {["hover"] = "Nhấn nút F12 để mở Bảng Tổng Hợp", ["description"] = "F12", ["data"] = 293}
}
for uFiufcnKn, ifkufccKc in ipairs(nfiuiCkki) do
    if ifkufccKc and ifkufccKc["data"] == uFuukCfkn then
        TUNING["HH_KEY_CONFIG"] = ifkufccKc["description"]
    end
end
local function nffunccKg(kFgucCfKu, uFkugckKk)
    local cfiUnCnKn = math["random"]() * 4 + 2
    uFkugckKk = (uFkugckKk + math["random"]() * 60 - 30) * DEGREES
    kFgucCfKu["Physics"]:SetVel(
        cfiUnCnKn * math["cos"](uFkugckKk),
        math["random"]() * 2 + 8,
        cfiUnCnKn * math["sin"](uFkugckKk)
    )
end
_G["HHGetGoodEquipEffect"] = function()
    local uFguuCfkc = {}
    for nFuUfcikg, kFnUnCfKk in pairs(uFkUkCfKf) do
        if
            kFnUnCfKk and not kFnUnCfKk["can_add"] and not kFnUnCfKk["is_suit"] and not kFnUnCfKk["only_compound"] and
                not kFnUnCfKk["is_special"]
         then
            table["insert"](uFguuCfkc, nFuUfcikg)
        end
    end
    return uFguuCfkc
end
_G["HHGetRareEquipEffect"] = function()
    local nffUcCcKf = {}
    for cFuuucgKc, kFcUkCgki in pairs(uFkUkCfKf) do
        if kFcUkCgki and not kFcUkCgki["can_add"] and not kFcUkCgki["is_suit"] and kFcUkCgki["only_compound"] then
            table["insert"](nffUcCcKf, cFuuucgKc)
        end
    end
    return nffUcCcKf
end
_G["HHGetComEquipEffect"] = function()
    local uFguncuki = {}
    for cffUncuKg, nffUgcukn in pairs(uFkUkCfKf) do
        if nffUgcukn and nffUgcukn["can_add"] and not nffUgcukn["is_suit"] then
            table["insert"](uFguncuki, cffUncuKg)
        end
    end
    return uFguncuki
end
_G["HHSpawnGoodEffectStone"] = function()
    local cFnUicnKg = _G["HHGetGoodEquipEffect"]()
    local ifiUnCckc = math["random"](1, #cFnUicnKg)
    local kfnUicckn = SpawnPrefab("hh_effect_stone")
    if kfnUicckn then
        kfnUicckn["hh_effect"] = cFnUicnKg[ifiUnCckc]
        if kfnUicckn["HH_Update_Server"] then
            kfnUicckn:HH_Update_Server()
        end
        return kfnUicckn
    end
    return nil
end
_G["HHSpawnRareEffectStone"] = function()
    local kfuugCkki = _G["HHGetRareEquipEffect"]()
    local ifkUkcukg = math["random"](1, #kfuugCkki)
    local nfcufcikf = SpawnPrefab("hh_effect_stone")
    if nfcufcikf then
        nfcufcikf["hh_effect"] = kfuugCkki[ifkUkcukg]
        if nfcufcikf["HH_Update_Server"] then
            nfcufcikf:HH_Update_Server()
        end
        return nfcufcikf
    end
    return nil
end
_G["HHSpawnComEffectStone"] = function()
    local ifuUkCukk = _G["HHGetComEquipEffect"]()
    local nFgunCgKi = math["random"](1, #ifuUkCukk)
    local kFfUkciKu = SpawnPrefab("hh_effect_stone")
    if kFfUkciKu then
        kFfUkciKu["hh_effect"] = ifuUkCukk[nFgunCgKi]
        if kFfUkciKu["HH_Update_Server"] then
            kFfUkciKu:HH_Update_Server()
        end
        return kFfUkciKu
    end
    return nil
end
_G["HHSpawnStoneById"] = function(kFgUucnKi)
    local gFiUiCgkc = SpawnPrefab("hh_effect_stone")
    if gFiUiCgkc then
        if uFkUkCfKf[kFgUucnKi] then
            gFiUiCgkc["hh_effect"] = kFgUucnKi
            if gFiUiCgkc["HH_Update_Server"] then
                gFiUiCgkc:HH_Update_Server()
            end
        end
        return gFiUiCgkc
    end
    return nil
end
local function kfnUccnkn(uFgUfciKc, iFuuiCfkg)
    local gfnUfCkku = uFgUfciKc["components"]["hh_equip"]:CanShowBuffUi()
    if not gfnUfCkku then
        return nil
    end
    local cfiUncuKf = uFgUfciKc["prefab"]
    local cFiugCgkc = STRINGS["NAMES"][string["upper"](tostring(cfiUncuKf))] or "Trang bị"
    local cFkugCikk = iFuuiCfkg["prefab"]
    local nfgufcuKf = iFuuiCfkg["hh_title"]
    local ffcUkckKk = iFuuiCfkg["name"] or STRINGS["NAMES"][string["upper"](cFkugCikk)] or "Người chơi?"
    local kFuUnckKc = uFgUfciKc["components"]["hh_equip"]:GetBuffDebugList(iFuuiCfkg)
    local cfgUuCnKi = ""
    local cFuucCikf = #kFuUnckKc
    for nFcukCiKk, iFuuuCkKu in ipairs(kFuUnckKc) do
        if iFuuuCkKu and iFuuuCkKu["desc"] then
            cfgUuCnKi = cfgUuCnKi .. iFuuuCkKu["desc"]
            if nFcukCiKk < cFuucCikf then
                cfgUuCnKi = cfgUuCnKi .. "\n"
            end
        end
    end
    local iffugcnkg = uFgUfciKc["components"]["hh_equip"]:GetGemDebugList(iFuuiCfkg)
    local ifiuiCgkg = #iffugcnkg
    local ffkUfCgKk = nil
    if ifiuiCgkg > 0 then
        ffkUfCgKk = ""
        for iFuUicfKg, nFkUucuKc in ipairs(iffugcnkg) do
            if nFkUucuKc and nFkUucuKc["desc"] then
                ffkUfCgKk = ffkUfCgKk .. nFkUucuKc["desc"]
                if iFuUicfKg < ifiuiCgkg then
                    ffkUfCgKk = ffkUfCgKk .. "\n"
                end
            end
        end
    end
    local nFnUiCiKk = {
        ["effect"] = cfgUuCnKi,
        ["gem"] = ffkUfCgKk,
        ["player"] = tostring(ffcUkckKk),
        ["equip"] = tostring(cFiugCgkc),
        ["player_title"] = nfgufcuKf
    }
    return nFnUiCiKk
end
local function kFiUicnKi(uFcUkcfki, uFfunCkkf)
    local nfuuuCckf = "Mục nhập trống"
    local gfuUuciKk = uFcUkcfki["hh_effect"] or "kxđ"
    if uFkUkCfKf[gfuUuciKk] then
        nfuuuCckf = uFkUkCfKf[gfuUuciKk]["name"]
    end
    local kffUkCnku = uFfunCkkf["prefab"]
    local ufgukciku = uFfunCkkf["hh_title"]
    local ifcukCuKf = uFfunCkkf["name"] or STRINGS["NAMES"][string["upper"](kffUkCnku)] or "Người chơi?"
    local ifcUiCfKf = {
        ["effect"] = tostring(nfuuuCckf),
        ["gem"] = nil,
        ["player"] = tostring(ifcukCuKf),
        ["equip"] = "Đá Thuộc Tính-" .. tostring(nfuuuCckf),
        ["player_title"] = ufgukciku
    }
    return ifcUiCfKf
end
AddModRPCHandler(
    "hh_rpc",
    "hh_share_equip",
    function(uFcuiCnKi, cfkufcikk)
        if not uFcuiCnKi then
            return (166 * 201 * 306 - 43 == 10209961)
        end
        if not iFkuiCkKf:IsHHType(AllPlayers, "table") then
            return (370 + 7 * 221 * 107 * 25 == 4138600)
        end
        if uFcuiCnKi["hh_share_cd"] then
            iFkuiCkKf:HHSay(uFcuiCnKi, "Nhanh quá")
            return
        end
        local iFuUkCgkk = nil
        if iFkuiCkKf:HasComponents(cfkufcikk, "hh_equip") then
            iFuUkCgkk = kfnUccnkn(cfkufcikk, uFcuiCnKi)
        elseif cfkufcikk["hh_effect"] then
            iFuUkCgkk = kFiUicnKi(cfkufcikk, uFcuiCnKi)
        end
        if not iFkuiCkKf:IsHHType(iFuUkCgkk, "table") then
            return
        end
        for gFgUccfKu, cfnunCnkn in ipairs(AllPlayers) do
            if cfnunCnkn and cfnunCnkn["userid"] then
                SendModRPCToClient(
                    CLIENT_MOD_RPC["hh_rpc"]["hh_share_equip_client"],
                    cfnunCnkn["userid"],
                    iFkuiCkKf:TableToStr(iFuUkCgkk)
                )
            end
        end
        uFcuiCnKi["hh_share_cd"] = (459 + 35 - 194 + 410 - 123 ~= 589)
        uFcuiCnKi:DoTaskInTime(
            1,
            function()
                uFcuiCnKi["hh_share_cd"] = (350 - 67 + 332 * 301 == 100219)
            end
        )
    end
)
AddClientModRPCHandler(
    "hh_rpc",
    "hh_share_equip_client",
    function(gFkukCuKf)
        if ThePlayer and gFkukCuKf and type(gFkukCuKf) == "string" then
            local uFnuuCgKu = iFkuiCkKf:StrToTable(gFkukCuKf)
            iFkuiCkKf:SetClientValue(ThePlayer, "hh_share_equip_client", uFnuuCgKu)
        end
    end
)

-- Kỹ năng Trỗi Dậy (Arise)
AddModRPCHandler(
    "hh_rpc",
    "hh_arise",
    function(player, prefab)
        if player == nil or not player:IsValid()
            or player.components.health == nil or player.components.health:IsDead()
            or player:HasTag('playerghost')
            or type(prefab) ~= 'string' then
            return
        end
        if player.components.hh_shadow_manager then
            player.components.hh_shadow_manager:Arise(prefab)
        end
    end
)

AddModRPCHandler(
    "hh_rpc",
    "hh_shadow_upgrade",
    function(player, prefab, talent_id)
        if player == nil or not player:IsValid()
            or player.components.health == nil or player.components.health:IsDead()
            or player:HasTag("playerghost")
            or type(prefab) ~= "string" or type(talent_id) ~= "string" then
            return
        end
        local progression = player.components.hh_shadow_progression
        if progression == nil then return end
        local success, message = progression:PurchaseTalent(prefab, talent_id)
        if player.components.talker ~= nil and message ~= nil then
            player.components.talker:Say(message)
        end
        if success then
            player:PushEvent("hh_shadow_talent_purchased", {
                prefab = prefab,
                talent_id = talent_id,
            })
        end
    end
)

AddModRPCHandler(
    "hh_rpc",
    "hh_command_fruitfly",
    function(player, x, y, z)
        if player == nil or not player:IsValid() or
            player.components.health == nil or player.components.health:IsDead() or
            player:HasTag("playerghost") or
            player.components.hh_shadow_manager == nil then
            return
        end
        player.components.hh_shadow_manager:CommandFruitFly(x, y, z)
    end
)

local HH_SHADOW_EXTRACT_INFO = {
    ["hh_corpse_igris"] = {prefab = "hh_igris_shadow", name = "Igris"},
    ["hh_corpse_beru"] = {prefab = "hh_beru_shadow", name = "Beru"},
    ["hh_corpse_fruitfly"] = {prefab = "hh_fruitfly_shadow", name = "Fruitfly"},
}

local function HHShadowExtractSay(player, message)
    if player ~= nil and player.components.talker ~= nil then
        player.components.talker:Say(message)
    end
end

local function HHShadowExtractGetChance(player)
    local rank_component = player ~= nil and player.components.hh_rank or nil
    local rank = rank_component ~= nil and rank_component:GetRank() or 1
    return TUNING["HH_SHADOW_EXTRACTION_CHANCE_BY_RANK"][rank] or 0.15
end

local function HHShadowExtractHasShadow(manager, prefab)
    if manager.shadows ~= nil then
        for _, shadow in ipairs(manager.shadows) do
            if shadow.prefab == prefab then
                return true
            end
        end
    end
    return false
end

local function HHShadowExtractDetachTargetListener(context)
    if context == nil or context.target == nil or context.on_target_removed == nil then
        return
    end

    local target = context.target
    if target:IsValid() then
        target:RemoveEventCallback("onremove", context.on_target_removed)
    end
    context.on_target_removed = nil
end

local function HHShadowExtractUnlock(context)
    HHShadowExtractDetachTargetListener(context)
    local target = context.target
    if target ~= nil and target:IsValid() and target._hh_extracting_player == context.player then
        target.extracted = false
        target._hh_extracting_player = nil
    end
    if context.player ~= nil and context.player:IsValid() and context.player._hh_shadow_extraction == context then
        context.player._hh_shadow_extraction = nil
    end
end

local function HHShadowExtractCancel(player, context)
    if context == nil or context.finished or context.committed then
        return
    end
    context.finished = true
    HHShadowExtractUnlock(context)
end

local function HHShadowExtractCleanup(player)
    local context = player ~= nil and player._hh_shadow_extraction or nil
    if context ~= nil then
        HHShadowExtractCancel(player, context)
    end
end

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    -- ms_playerleft can happen before the player entity is fully removed.
    -- Clear the corpse lock at that boundary as well as on onremove.
    inst:ListenForEvent("ms_playerleft", function(_, player)
        if player == inst then
            HHShadowExtractCleanup(inst)
        end
    end, TheWorld)
    inst:ListenForEvent("onremove", function()
        HHShadowExtractCleanup(inst)
    end)
    inst:ListenForEvent("death", function()
        HHShadowExtractCleanup(inst)
    end)
    inst:ListenForEvent("makeplayerghost", function()
        HHShadowExtractCleanup(inst)
    end)
end)

local function HHShadowExtractCommitSuccess(player, context)
    if context.finished or context.committed then
        return true
    end

    if not context.success then
        context.finished = true
        HHShadowExtractSay(player, "Trích xuất bóng thất bại !")
        HHShadowExtractUnlock(context)
        if context.target ~= nil and context.target:IsValid() then
            context.target._hh_extraction_failures =
                (context.target._hh_extraction_failures or 0) + 1
            if context.target._hh_extraction_failures >= 3 then
                context.target:Remove()
            end
        end
        return false
    end

    local target = context.target
    local manager = player ~= nil and player:IsValid() and player.components.hh_shadow_manager or nil
    if player == nil or not player:IsValid() or target == nil or not target:IsValid() or
        target._hh_extracting_player ~= player or manager == nil or
        not manager:ExtractShadow(context.shadow.prefab) then
        HHShadowExtractCancel(player, context)
        return false
    end

    context.committed = true
    context.finished = true
    player._hh_shadow_extraction = nil
    HHShadowExtractSay(player, "Trích xuất bóng thành công !")
    HHShadowExtractDetachTargetListener(context)
    target:Remove()
    return true
end

AddModRPCHandler(
    "hh_rpc",
    "hh_extract_shadow",
    function(player, target)
        if player == nil or not player:IsValid() or target == nil or not target:IsValid() then
            return
        end

        local shadow_info = HH_SHADOW_EXTRACT_INFO[target.prefab]
        local manager = player.components.hh_shadow_manager
        if shadow_info == nil or manager == nil or player.sg == nil then
            return
        end

        if player.components.health == nil or player.components.health:IsDead()
            or player:HasTag("playerghost") then
            return
        end
        if player.components.rider ~= nil and player.components.rider:IsRiding() then
            HHShadowExtractSay(player, "Tôi không thể vừa cưỡi vừa làm việc này !")
            return
        end
        if not target:HasTag("shadow_corpse")
            or player:GetDistanceSqToInst(target) > 25
            or player.sg:HasStateTag("busy") then
            return
        end
        if player._hh_shadow_extraction ~= nil then
            HHShadowExtractSay(player, "Tôi đang trích xuất một bóng ma khác!")
            return
        end
        if target.extracted or target._hh_extracting_player ~= nil then
            HHShadowExtractSay(player, "Cái xác đã được thợ săn khác trích xuất")
            return
        end
        if HHShadowExtractHasShadow(manager, shadow_info.prefab) then
            HHShadowExtractSay(player, shadow_info.name .. " sẽ không thích điều này !")
            return
        end
        if not manager:CanExtract() then
            HHShadowExtractSay(player, "Tôi không thể chứa thêm bóng ma nào nữa!")
            return
        end

        local context = {
            player = player,
            target = target,
            shadow = shadow_info,
            finished = false,
            committed = false,
            success = math.random() < HHShadowExtractGetChance(player),
            oncommit = HHShadowExtractCommitSuccess,
            oncancel = HHShadowExtractCancel,
        }
        context.on_target_removed = function()
            if not context.finished and not context.committed then
                HHShadowExtractCancel(player, context)
            end
        end
        player._hh_shadow_extraction = context
        target.extracted = true
        target._hh_extracting_player = player
        target:ListenForEvent("onremove", context.on_target_removed)
        player.sg:GoToState("hh_shadow_extract_success", context)
    end
)

-- Kỹ năng Thu hồi (Recall)
AddModRPCHandler(
    "hh_rpc",
    "hh_recall",
    function(player, prefab)
        if player == nil or not player:IsValid()
            or player.components.health == nil or player.components.health:IsDead()
            or player:HasTag("playerghost")
            or type(prefab) ~= "string" then
            return
        end
        if player.components.hh_shadow_manager then
            player.components.hh_shadow_manager:Recall(prefab)
        end
    end
)

-- Client hotkeys may only request a whitelisted feedback line. The server
-- recomputes the state and calls the canonical Talker path, so a client
-- prediction cannot create text without the matching voice/mouth state or
-- submit arbitrary speech.
local function SayHHHotkeyFeedback(player, feedback_id)
    if player == nil or not player:IsValid()
        or player.components == nil
        or player.components.health == nil
        or player.components.health:IsDead()
        or player:HasTag("playerghost")
        or player.components.talker == nil
        or type(feedback_id) ~= "string" then
        return
    end

    local talker = player.components.talker
    local manager = player.components.hh_shadow_manager
    if feedback_id == "arise_no_shadows" then
        if manager ~= nil and #manager.shadows == 0 then
            talker:Say("Tôi chưa sở hữu đệ tử bóng ma nào cả !")
        end
    elseif feedback_id == "arise_cooldown" then
        local remaining = manager ~= nil
            and math.max(0, math.ceil(manager.arise_ready_time - GetTime())) or 0
        if remaining > 0 then
            talker:Say("Kỹ năng Trỗi Dậy sẽ hồi lại sau " .. tostring(remaining) .. " giây")
        end
    elseif feedback_id == "recall_no_active" then
        local has_active = false
        for _, shadow_data in ipairs(manager ~= nil and manager.shadows or {}) do
            if shadow_data.is_spawned then
                has_active = true
                break
            end
        end
        if not has_active then
            talker:Say("Không có đệ tử bóng ma nào đang hoạt động!")
        end
    elseif feedback_id == "recall_cooldown" then
        local remaining = manager ~= nil
            and math.max(0, math.ceil(manager.recall_ready_time - GetTime())) or 0
        if remaining > 0 then
            talker:Say("Kỹ năng Thu Hồi sẽ hồi lại sau " .. tostring(remaining) .. " giây")
        end
    elseif feedback_id == "sanctuary_cooldown" then
        local component = player.components.hh_sanctuary
        local remaining = component ~= nil and component.GetRemainingCooldown ~= nil
            and component:GetRemainingCooldown() or 0
        local strings = STRINGS ~= nil and STRINGS.HH_SANCTUARY or nil
        if remaining > 0 and strings ~= nil and strings.COOLDOWN ~= nil then
            talker:Say(string.format(strings.COOLDOWN, remaining))
        end
    elseif feedback_id == "godslayer_cooldown" then
        local component = player.components.hh_godslayer
        local remaining = component ~= nil and component.GetRemainingCooldown ~= nil
            and component:GetRemainingCooldown() or 0
        local strings = STRINGS ~= nil and STRINGS.HH_GODSLAYER or nil
        if remaining > 0 and strings ~= nil and strings.COOLDOWN ~= nil then
            talker:Say(string.format(strings.COOLDOWN, remaining))
        end
    elseif feedback_id == "ruler_cooldown" then
        local component = player.components.hh_ruler
        local remaining = component ~= nil and component.GetRemainingCooldown ~= nil
            and component:GetRemainingCooldown() or 0
        local strings = STRINGS ~= nil and STRINGS.HH_RULER or nil
        if remaining > 0 and strings ~= nil and strings.COOLDOWN ~= nil then
            talker:Say(string.format(strings.COOLDOWN, remaining))
        end
    elseif feedback_id == "king_cooldown" then
        local component = player.components.hh_king
        local remaining = component ~= nil and component.GetRemainingCooldown ~= nil
            and component:GetRemainingCooldown() or 0
        local strings = STRINGS ~= nil and STRINGS.HH_KING or nil
        if remaining > 0 and strings ~= nil and strings.COOLDOWN ~= nil then
            talker:Say(string.format(strings.COOLDOWN, remaining))
        end
    end
end

AddModRPCHandler(
    "hh_rpc",
    "hh_hotkey_feedback",
    SayHHHotkeyFeedback
)

-- Kỹ năng Thánh Vực Hồi Phục
AddModRPCHandler(
    "hh_rpc",
    "hh_sanctuary_cast",
    function(player)
        if player ~= nil and player.components.hh_sanctuary ~= nil then
            player.components.hh_sanctuary:Cast()
        end
    end
)

-- Kỹ năng Diệt Thần
AddModRPCHandler(
    "hh_rpc",
    "hh_godslayer_cast",
    function(player)
        if player ~= nil and player.components.hh_godslayer ~= nil then
            player.components.hh_godslayer:Cast()
        end
    end
)

-- Kỹ năng Nhà Vua
AddModRPCHandler(
    "hh_rpc",
    "hh_king_cast",
    function(player)
        if player ~= nil and player.components.hh_king ~= nil then
            player.components.hh_king:Cast()
        end
    end
)

-- Kỹ năng Kẻ Thống Trị. AOE confirmation continues through the native
-- playercontroller/CASTAOE path; these RPCs only open or cancel the server
-- validated internal proxy.
AddModRPCHandler(
    "hh_rpc",
    "hh_ruler_begin",
    function(player)
        if player ~= nil and player.components.hh_ruler ~= nil then
            player.components.hh_ruler:BeginTargeting()
        end
    end
)

AddModRPCHandler(
    "hh_rpc",
    "hh_ruler_cancel",
    function(player)
        if player ~= nil and player.components.hh_ruler ~= nil then
            player.components.hh_ruler:CancelTargeting()
        end
    end
)

-- Kỹ năng Hoán Đổi với Fruit Fly Bóng Ma
AddModRPCHandler(
    "hh_rpc",
    "hh_swap",
    function(player)
        if player ~= nil and player:IsValid()
            and player.components.health ~= nil and not player.components.health:IsDead()
            and not player:HasTag("playerghost")
            and player.components.hh_shadow_manager ~= nil then
            player.components.hh_shadow_manager:SwapToFruitFly()
        end
    end
)

-- Kỹ năng Cộng chỉ số (Pick Stat)
AddModRPCHandler(
    "hh_rpc",
    "hh_pick_stat",
    function(player, stat_name)
        if player and player.components.hh_leveling then
            player.components.hh_leveling:PickStat(stat_name)
        end
    end
)

-- Xác nhận tiến vào Hầm Ngục từ popup phía client.
AddModRPCHandler(
    "hh_rpc",
    "hh_enter_dungeon",
    function(player, gate)
        if player == nil or not player:IsValid()
            or gate == nil or not gate:IsValid()
            or gate.prefab ~= "dungeon_gate"
            or not gate:HasTag("dungeon_gate")
            or player.sg == nil
            or player:HasTag("playerghost")
            or player:HasTag("hh_dungeon_transition")
            or player:GetDistanceSqToInst(gate) > 36 then
            return
        end

        local manager = TheWorld.components.dungeon_manager
        if manager ~= nil and manager:IsActiveGate(gate) and manager:CanEnterDungeon(player, true) then
            player.sg:GoToState("hh_dungeon_migrate", {mode = "enter"})
        end
    end
)
