require "behaviours/standandattack"
local _b__U__G =
    Class(
    Brain,
    function(self, __B__u_G)
        Brain["_ctor"](self, __B__u_G)
    end
)
function _b__U__G:OnStart()
    local bu__G_ = PriorityNode({StandAndAttack(self["inst"])}, .25)
    self["bt"] = BT(self["inst"], bu__G_)
end
return _b__U__G
