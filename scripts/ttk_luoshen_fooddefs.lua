return {
    ttk_luoshen_qingshu = {
        name = "ttk_luoshen_qingshu",
        test = function(cooker, names, tags)
            return names.ttk_luoshen_huayin ~= nil and not tags.meat
        end,
        priority = 10, weight = 1, foodtype = FOODTYPE.VEGGIE,
        health = 200, hunger = 42.5, sanity = 80,
        perishtime = 15 * TUNING.TOTAL_DAY_TIME, cooktime = .75,
        overridebuild = "xd_luoshen_qingshu", overridesymbolname = "xd_luoshen_qingshu",
    },
    ttk_luoxiang_pengrou = {
        name = "ttk_luoxiang_pengrou",
        test = function(cooker, names, tags)
            return names.ttk_luoshen_huayin ~= nil and tags.meat ~= nil and tags.meat > 0
        end,
        priority = 10, weight = 1, foodtype = FOODTYPE.MEAT,
        health = 10, hunger = 75, sanity = 62.5,
        perishtime = 20 * TUNING.TOTAL_DAY_TIME, cooktime = .75,
        overridebuild = "xd_luoxiang_pengrou", overridesymbolname = "xd_luoxiang_pengrou",
        oneatenfn = function(inst, eater)
            if eater ~= nil and eater.components.debuffable ~= nil then
                eater:AddDebuff("ttk_luoxiang_pengrou_buff", "ttk_luoxiang_pengrou_buff")
            end
        end,
    },
}
