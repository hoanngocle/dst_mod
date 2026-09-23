-- Guild actions can be used remotely from the shared interface.
local function CanUseGuild(player)
    if player == nil or not player:IsValid() or player:HasTag("playerghost") then
        return false, "Không thể sử dụng Hiệp Hội trong trạng thái hiện tại."
    end
    if TheWorld.state.phase == "night" then
        return false, "Nhân Viên Hiệp Hội đã đi ngủ."
    end
    return true
end

local function GuildAction(player, action, value, nonce)
    if type(action) ~= "string" then
        return
    end

    nonce = tonumber(nonce)
    if nonce == nil or nonce ~= math.floor(nonce) or nonce <= 0 then
        return
    end
    if player == nil then
        return
    end
    if player._hh_guild_rpc_nonce ~= nil and nonce <= player._hh_guild_rpc_nonce then
        return
    end
    player._hh_guild_rpc_nonce = nonce

    local rank = player and player.components.hh_rank
    local quest = player and player.components.hh_guild_quest
    local shop = player and player.components.hh_guild_shop
    if rank == nil or quest == nil or shop == nil then
        return
    end

    if action == "close" then
        rank:CloseInterface()
        return
    end

    local now = GetTime()
    if player._hh_guild_rpc_time and now - player._hh_guild_rpc_time < 0.15 then
        rank:SetNotice("Thao tác quá nhanh.")
        return
    end
    player._hh_guild_rpc_time = now

    local allowed, reason = CanUseGuild(player)
    if not allowed then
        rank:SetNotice(reason)
        rank:CloseInterface()
        return
    end

    if action == "refresh" then
        shop:EnsureCycle()
        rank:RefreshExamAvailability()
        quest:EnsureOffers()
        quest:Sync()
        rank:Sync()
    elseif action == "quest_accept" then
        local quest_id = tonumber(value)
        if quest_id ~= nil and quest_id > 0 then
            quest:StartQuest(quest_id)
        else
            quest:StartRandomQuest()
        end
    elseif action == "quest_submit" then
        quest:TrySubmitDelivery()
    elseif action == "quest_abandon" then
        quest:AbandonQuest()
    elseif action == "exam_start" then
        rank:StartExam()
    elseif action == "exam_claim" then
        rank:ClaimExam()
        rank:CloseInterface()
    elseif action == "reward_claim" then
        rank:ClaimPendingRewards()
        rank:CloseInterface()
    elseif action == "shop_buy" then
        local product_id = tonumber(value)
        if product_id == nil or product_id ~= math.floor(product_id) then
            rank:SetNotice("Mã sản phẩm không hợp lệ.")
            return
        end
        local success, message = shop:Purchase(product_id, 1)
        if not success then
            rank:SetNotice(message)
        end
    else
        rank:SetNotice("Thao tác Guild không hợp lệ.")
    end
end

AddModRPCHandler("hh_rpc", "hh_guild_action", GuildAction)
