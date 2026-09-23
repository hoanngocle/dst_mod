local assets = {
    Asset("ANIM", "anim/rock_treasure.zip"),
    Asset("MINIMAP_IMAGE", "rock_gold"),
}

-- [TÙY CHỈNH LOOT TẠI ĐÂY]
-- Khai báo bảng loot riêng cho cục đá của bạn giống hệt cách game gốc làm.
-- Cấu trúc: {'Tên_vật_phẩm', Tỷ_lệ_rớt} (1.00 = 100%, 0.50 = 50%, 0.05 = 5%)
SetSharedLootTable('rock_treasure_loot',
{
    {'bluegem',         1.00},
    {'redgem',          1.00},
    {'purplegem',       0.80},
    {'greengem',        0.60},
    {'orangegem',       0.40},
    {'yellowgem',       0.20},
    {'opalpreciousgem', 0.10},
    {'wb_enhancegem',   0.05},
})

local max_work = 6 -- Mặc định đập 6 nhát vỡ, bạn có thể chỉnh lên 15 nếu muốn trâu hơn

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x, pt.y, pt.z)
        inst.components.lootdropper:DropLoot(pt)

        if inst.showCloudFXwhenRemoved then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

        inst:Remove()
    else
        local anim = 
            (workleft < max_work / 3 and "low") or
            (workleft < max_work * 2 / 3 and "med") or
            "full"

        inst.AnimState:PlayAnimation(anim)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1) -- Vòng va chạm chuẩn của đá vanilla. Bạn có thể sửa 1 thành số nhỏ hơn (ví dụ 0.25) nếu thấy Boss bị kẹt nát đá.

    inst.MiniMapEntity:SetIcon("rock_gold.png")

    inst.AnimState:SetBank("rock2")
    inst.AnimState:SetBuild("rock_treasure")
    inst.AnimState:PlayAnimation("full")
    inst.scrapbook_anim = "full"

    MakeSnowCoveredPristine(inst)

    inst:AddTag("boulder")
    inst:AddTag("rock_treasure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_deps = {}

    inst:AddComponent("lootdropper")
    -- Gán bảng loot vừa khởi tạo ở đầu file vào cho cục đá này
    inst.components.lootdropper:SetChanceLootTable('rock_treasure_loot')

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.MINE)
    workable:SetWorkLeft(max_work)
    workable:SetOnWorkCallback(OnWork)
    -- workable.savestate = true -- [TÙY CHỈNH BẢO VỆ]: Bỏ dấu -- ở đầu dòng này để Boss không đập vỡ được cục đá (Tránh việc rớt đồ trước khi giết Boss)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "ROCK"

    MakeSnowCovered(inst)
    SetLunarHailBuildupAmountSmall(inst)
    MakeHauntableWork(inst)

    return inst
end

return Prefab("rock_treasure", fn, assets)
