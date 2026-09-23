local __b_u__g__ = require "utils/hh_utils"
local B_ug_ =
    Class(
    function(self, b__U_G)
        self["inst"] = b__U_G
    end
)
function B_ug_:SetValue(b__u__g__, __B__Ug__)
    self[b__u__g__] = __B__Ug__
    self["inst"]:PushEvent(b__u__g__)
end
function B_ug_:GetValue(__Bu_g__)
    if type(__Bu_g__) == "string" and self[__Bu_g__] and type(self[__Bu_g__]) == "table" then
        return __b_u__g__:HHCopyTable(self[__Bu_g__])
    end
    return self[__Bu_g__]
end
return B_ug_
