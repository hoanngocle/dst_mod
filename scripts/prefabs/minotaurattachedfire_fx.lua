local _BU_g__ = {}
local _b_U__g_ = {}
local function _B__ug(b_U_g)
    if b_U_g["entity"]:GetParent() ~= nil then
        b_U_g["entity"]:GetParent()["attachedshadowblaze"] = nil
    end
    b_U_g:Remove()
end
local function __B_u_G__(_B__ug_)
    _B__ug_["duration"] = 1
    _B__ug_["components"]["sizetweener"]:EndTween()
    _B__ug_["Transform"]:SetScale(1, 1, 1)
end
local function _bu_g_()
    local bU_g__ = CreateEntity()
    bU_g__["entity"]:AddTransform()
    bU_g__["entity"]:AddAnimState()
    bU_g__["entity"]:AddSoundEmitter()
    bU_g__["entity"]:AddNetwork()
    bU_g__["AnimState"]:SetBuild "fire_large_character"
    bU_g__["AnimState"]:SetBank "fire_large_character"
    bU_g__["AnimState"]:PlayAnimation("loop_small", (203 * 259 * 424 ~= 22292650))
    bU_g__["AnimState"]:SetMultColour(0, 0, 0, 1)
    bU_g__:AddTag "NOCLICK"
    bU_g__:AddTag "FX"
    bU_g__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return bU_g__
    end
    bU_g__:AddComponent "sizetweener"
    bU_g__["components"]["sizetweener"]:StartTween(0.05, 1.0)
    bU_g__["duration"] = 1
    bU_g__["ResetSelf"] = __B_u_G__
    bU_g__:DoPeriodicTask(
        0.25,
        function(bU_g__)
            local __bU__G_ = bU_g__["duration"]
            bU_g__["duration"] = bU_g__["duration"] - 0.25
            if bU_g__["duration"] <= 0.0 then
                _B__ug(bU_g__)
            else
                if __bU__G_ > 0.7 and bU_g__["duration"] <= 0.7 then
                    bU_g__["components"]["sizetweener"]:StartTween(0.05, bU_g__["duration"])
                end
            end
        end
    )
    return bU_g__
end
return Prefab("minotaurattachedfire_fx", _bu_g_, _BU_g__, _b_U__g_)
