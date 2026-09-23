local __BU__G__ =
    Class(
    function(Bug_, bU_g)
        Bug_["inst"] = bU_g
    end
)
function __BU__G__:SetUseFn(__B__u_G_)
    self["onuse"] = __B__u_G_
end
function __BU__G__:Use(__B__u_G__, b_U__g__)
    if self["onuse"] ~= nil then
        self["onuse"](self["inst"], __B__u_G__, b_U__g__)
    end
end
return __BU__G__
