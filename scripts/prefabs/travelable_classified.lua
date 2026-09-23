local function __Bu__G__(__b__u_G_)
    if __b__u_G_["_parent"] ~= nil then
        __b__u_G_["_parent"]["travelable_classified"] = nil
    end
end
local function bug(__BU_G__)
    __BU_G__["_parent"] = __BU_G__["entity"]:GetParent()
    if __BU_G__["_parent"] == nil then
        print "Unable to initialize classified data for travelable"
    elseif __BU_G__["_parent"]["replica"]["travelable"] ~= nil then
        __BU_G__["_parent"]["replica"]["travelable"]:AttachClassified(__BU_G__)
    else
        __BU_G__["_parent"]["travelable_classified"] = __BU_G__
        __BU_G__["OnRemoveEntity"] = __Bu__G__
    end
end
local function __b_UG__()
    local bU_g_ = CreateEntity()
    if TheWorld["ismastersim"] then
        bU_g_["entity"]:AddTransform()
    end
    bU_g_["entity"]:AddNetwork()
    bU_g_["entity"]:Hide()
    bU_g_:AddTag "CLASSIFIED"
    bU_g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        bU_g_["OnEntityReplicated"] = bug
        return bU_g_
    end
    bU_g_["persists"] = (214 - 120 * 432 + 84 == -51538)
    return bU_g_
end
return Prefab("travelable_classified", __b_UG__)
