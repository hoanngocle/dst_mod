local G=GLOBAL
for _,name in ipairs({"ttk_boss_zcyseed","ttk_zuichunyan","ttk_zuichunyan_saplings"}) do table.insert(PrefabFiles,name) end
for _,variant in ipairs({"green","purple","stump","burnt"}) do
    AddMinimapAtlas("images/map_icons/ttk_zuichunyan_"..variant..".xml")
end
RegisterInventoryItemAtlas("images/inventoryimages/xd_zcyseed.xml","xd_zcyseed.tex")
G.STRINGS.NAMES.TTK_BOSS_ZCYSEED="Hạt Tử Chi"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_BOSS_ZCYSEED="Trồng trực tiếp xuống đất thành cây xanh hoặc tím. Ăn hồi 5 máu, 12 độ no và 2 tinh thần."
G.STRINGS.NAMES.TTK_ZUICHUNYAN="Cây Tử Chi"
G.STRINGS.NAMES.TTK_ZUICHUNYAN_SAPLING="Cây Tử Chi Non"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_ZUICHUNYAN="Cây tán rủ, chặt lấy gỗ và hạt."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_ZUICHUNYAN_SAPLING="Cây non đang bén rễ."
for _,colour in ipairs({"green","purple"}) do
    for _,suffix in ipairs({"","_short","_tall","_stump","_burnt","_sapling"}) do
        local key=string.upper("ttk_zuichunyan_"..colour..suffix)
        G.STRINGS.NAMES[key]=suffix=="_sapling" and "Cây Tử Chi Non" or (colour=="green" and "Cây Tử Chi Xanh" or "Cây Tử Chi Tím")
        G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[key]="Cây tán rủ, chặt lấy gỗ và hạt."
    end
end
