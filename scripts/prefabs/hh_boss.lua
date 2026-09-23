local _bU_g__ = require "enums/hh_boss"
local function _b__U__g(__B_u__G, _BUG)
    local function b_u_G__()
        local _b_U_g__ = CreateEntity()
        _b_U_g__["entity"]:AddTransform()
        _b_U_g__["entity"]:AddAnimState()
        _b_U_g__["entity"]:AddNetwork()
        if _BUG and _BUG["client_fn"] then
            _BUG["client_fn"](_b_U_g__, __B_u__G)
        end
        _b_U_g__["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _b_U_g__
        end
        if _BUG and _BUG["server_fn"] then
            _BUG["server_fn"](_b_U_g__, __B_u__G)
        end
        return _b_U_g__
    end
    return Prefab(__B_u__G, b_u_G__, _BUG["assets"] or {})
end
local b__uG_ = {}
for b__U_g, __b__ug_ in pairs(_bU_g__) do
    table["insert"](b__uG_, _b__U__g(b__U_g, __b__ug_))
    STRINGS["NAMES"][string["upper"](b__U_g)] = __b__ug_["name"] or "Undefined"
    STRINGS["RECIPE_DESC"][string["upper"](b__U_g)] = __b__ug_["recipe_str"] or "Undefined"
    STRINGS["CHARACTERS"]["GENERIC"]["DESCRIBE"][string["upper"](b__U_g)] = __b__ug_["desc"] or "Undefined"
end
return unpack(b__uG_)
