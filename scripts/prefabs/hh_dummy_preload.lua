local deps = {

    "krampus",
    "walrus",
    "mutatedbearger",
    "mutateddeerclops",
    "frostjaw",
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("NOCLICK")
    return inst
end

return Prefab("hh_dummy_preload", fn, nil, deps)