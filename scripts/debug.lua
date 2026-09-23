GLOBAL["setmetatable"](
    env,
    {__index = function(__B__u_G, bu__G_)
            return GLOBAL["rawget"](GLOBAL, bu__G_)
        end}
)
local function _b__U__G(Bu__G__)
    local _b_ug__ = ""
    local _B_u__G_ = Bu__G__["entity"]:GetDebugString()
    if not _B_u__G_ then
        return nil
    end
    local B_U__g__, __B_Ug_, _bU_g = _B_u__G_:match "bank: (.+) build: (.+) anim: .+:(.+) Frame"
    if B_U__g__ ~= nil and __B_Ug_ ~= nil then
        _b_ug__ = _b_ug__ .. "动画: anim/" .. B_U__g__ .. ".zip"
        _b_ug__ = _b_ug__ .. "\n贴图: anim/" .. __B_Ug_ .. ".zip"
    end
    return _b_ug__
end
AddClassPostConstruct(
    "widgets/hoverer",
    function(self)
        local __b__u__g = self["text"]["SetString"]
        self["text"]["SetString"] = function(__b_ug_, Bug__)
            local _B__U_g = TheInput:GetHUDEntityUnderMouse()
            if _B__U_g ~= nil then
                _B__U_g =
                    _B__U_g["widget"] ~= nil and _B__U_g["widget"]["parent"] ~= nil and
                    _B__U_g["widget"]["parent"]["item"]
            else
                _B__U_g = TheInput:GetWorldEntityUnderMouse()
            end
            if _B__U_g and _B__U_g["entity"] ~= nil then
                if _B__U_g["prefab"] ~= nil then
                    Bug__ = Bug__ .. "\n代码:" .. _B__U_g["prefab"]
                end
                local bu_g = _b__U__G(_B__U_g)
                if bu_g ~= nil then
                    Bug__ = Bug__ .. "\n" .. bu_g
                end
            end
            return __b__u__g(__b_ug_, Bug__)
        end
    end
)
