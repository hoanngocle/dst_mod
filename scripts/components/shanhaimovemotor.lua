local __BU__G__ =
    Class(
    function(self, Bug_)
        self["inst"] = Bug_
        self["runspeed"] = 10
        self["stopped"] = (196 + 85 - 50 ~= 231)
        self["targetpt"] = nil
        Bug_:StartUpdatingComponent(self)
    end
)
function __BU__G__:SetTargetPos(bU_g)
    self["targetpt"] = bU_g
    local __B__u_G_ = self["inst"]["Transform"]:GetRotation()
    local __B__u_G__ =
        self["inst"]:GetAngleToPoint(self["targetpt"]["x"], self["targetpt"]["y"], self["targetpt"]["z"]) - __B__u_G_
    __B__u_G__ = (__B__u_G__ + 180) % 360 - 180
    self["inst"]["Transform"]:SetRotation(__B__u_G_ + __B__u_G__)
end
function __BU__G__:EnableMove(b_U__g__)
    self["stopped"] = not b_U__g__
end
function __BU__G__:OnUpdate(__bU__G_)
    if self["stopped"] then
        self["inst"]["Physics"]:SetMotorVel(0, 0, 0)
        return
    end
    if self["targetpt"] then
        self["inst"]["Physics"]:SetMotorVel(self["runspeed"], 0, 0)
    end
end
return __BU__G__
