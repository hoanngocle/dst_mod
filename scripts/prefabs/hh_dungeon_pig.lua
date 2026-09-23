local assets = {
    Asset("ANIM", "anim/hh_dungeon_pig_build.zip"),
    Asset("ANIM", "anim/ds_pig_charge.zip"),
    Asset("ANIM", "anim/ds_pig_uppercut.zip"),
}

local function fn()
    -- Create the base pigguard entity using vanilla fn
    local inst = Prefabs["pigguard"].fn()

    inst.AnimState:SetBuild("hh_dungeon_pig_build")

    -- Add custom tags for our mod logic
    inst:AddTag("hh_dungeon_mob")
    inst:AddTag("pigattacker")

    if not TheWorld.ismastersim then
        return inst
    end

    -- Boost stats for dungeon
    if inst.components.health then
        inst.components.health:SetMaxHealth(TUNING.PIG_HEALTH * 3)
    end

    -- AI memory from Uncom
    inst.remembered_threats = {}

    -- Ghi đè lời thoại chiến đấu thông qua hook chính thức của DST engine (resolvechatterfn)
    -- Khi brain gọi Chatter(), engine sẽ gọi hàm này để tra cứu chuỗi hiển thị.
    -- Nếu trả về chuỗi custom, engine dùng chuỗi đó thay vì tra STRINGS gốc.
    if inst.components.talker then
        local custom_battlecries = {
            "Phải bảo vệ Hầm Ngục !",
            "Có thợ săn đột nhập !",
            "Hầm Ngục không dành cho kẻ yếu !"
        }
        inst.components.talker.resolvechatterfn = function(inst, strid, strtbl)
            local tbl_name = strtbl:value()
            if tbl_name:find("PIG_") then
                return custom_battlecries[math.random(#custom_battlecries)]
            end
            -- Trả về nil để engine tự tra STRINGS gốc cho các thoại không liên quan chiến đấu
            return nil
        end
    end

    if inst.components.combat ~= nil then
        local _OldRetarget = inst.components.combat.targetfn
        local period = inst.components.combat.retargetperiod or 3

        inst.components.combat:SetRetargetFunction(period, function(inst)
            if inst:HasTag("NPC_contestant") then
                return nil
            end

            local RETARGET_MUST_TAGS = { "_combat" }
            local exclude_tags = { "playerghost", "INLIMBO", "NPC_contestant" }
            if inst.components.follower and inst.components.follower.leader ~= nil then
                table.insert(exclude_tags, "abigail")
            end
            if inst.components.minigame_spectator ~= nil then
                table.insert(exclude_tags, "player")
            end

            local oneof_tags = { "monster", "wonkey", "pirate", "player" }
            if not inst:HasTag("merm") then
                table.insert(oneof_tags, "merm")
            end

            return not inst:IsInLimbo()
                and FindEntity(
                    inst,
                    TUNING.PIG_TARGET_DIST,
                    function(guy)
                        return guy.userid ~= nil and table.contains(inst.remembered_threats, guy.userid) and guy:IsInLight() and inst.components.combat:CanTarget(guy)
                    end,
                    RETARGET_MUST_TAGS,
                    exclude_tags,
                    oneof_tags
                )
                or (_OldRetarget ~= nil and _OldRetarget(inst) or nil)
        end)
    end

    inst:ListenForEvent("newcombattarget", function(inst, data)
        if data ~= nil and data.target ~= nil and data.target:HasTag("player") and data.target.userid then
            if table.contains(inst.remembered_threats, data.target.userid) then
                local strtbl = STRINGS["PIG_REMEMBER_THREAT"]
                if strtbl ~= nil and inst.components.talker then
                    local strid = math.random(#strtbl)
                    inst.components.talker:Chatter("PIG_REMEMBER_THREAT", strid)
                end
            else
                table.insert(inst.remembered_threats, data.target.userid)
            end
        end
    end)

    local MAX_TARGET_SHARES = 5
    local SHARE_TARGET_DIST = 30

    inst:ListenForEvent("attacked", function(inst, data)
        local attacker = data.attacker
        inst:ClearBufferedAction()

        if attacker ~= nil and not inst:HasTag("werepig") then
            if attacker:HasTag("player") then
                if inst.components.combat then
                    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude.prefab == inst.prefab end, MAX_TARGET_SHARES)
                end
            end
        end
    end)

    local _OldOnSave = inst.OnSave
    local _OldOnLoad = inst.OnLoad

    inst.OnSave = function(inst, data)
        data.remembered_threats = inst.remembered_threats
        if _OldOnSave ~= nil then
            return _OldOnSave(inst, data)
        end
    end

    inst.OnLoad = function(inst, data)
        if data then
            inst.remembered_threats = data.remembered_threats or inst.remembered_threats
        end
        if _OldOnLoad ~= nil then
            return _OldOnLoad(inst, data)
        end
    end

    return inst
end

return Prefab("hh_dungeon_pig", fn, assets)
