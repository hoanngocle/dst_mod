local b__UG__ =
    Class(
    function(self, Bu_G__)
        self["inst"] = Bu_G__
        self["_infos"] = net_string(Bu_G__["GUID"], "travelable._infos")
        self["screen"] = nil
        self["opentask"] = nil
        if TheWorld["ismastersim"] then
            self["classified"] = SpawnPrefab "travelable_classified"
            self["classified"]["entity"]:SetParent(Bu_G__["entity"])
        else
            if self["classified"] == nil and Bu_G__["travelable_classified"] ~= nil then
                self["classified"] = Bu_G__["travelable_classified"]
                Bu_G__["travelable_classified"]["OnRemoveEntity"] = nil
                Bu_G__["travelable_classified"] = nil
                self:AttachClassified(self["classified"])
            end
        end
    end
)
function b__UG__:OnRemoveFromEntity()
    if self["classified"] ~= nil then
        if TheWorld["ismastersim"] then
            self["classified"]:Remove()
            self["classified"] = nil
        else
            self["classified"]["_parent"] = nil
            self["inst"]:RemoveEventCallback("onremove", self["ondetachclassified"], self["classified"])
            self:DetachClassified()
        end
    end
end
b__UG__["OnRemoveEntity"] = b__UG__["OnRemoveFromEntity"]
local function __BU__g__(_B_Ug, self)
    self["opentask"] = nil
    self:BeginTravel(ThePlayer)
end
function b__UG__:AttachClassified(_b__u_G__)
    self["classified"] = _b__u_G__
    self["ondetachclassified"] = function()
        self:DetachClassified()
    end
    self["inst"]:ListenForEvent("onremove", self["ondetachclassified"], _b__u_G__)
    self["opentask"] = self["inst"]:DoTaskInTime(0, __BU__g__, self)
end
function b__UG__:DetachClassified()
    self["classified"] = nil
    self["ondetachclassified"] = nil
    self:EndTravel()
end
function b__UG__:BeginTravel(__B__UG_)
    if self["inst"]["components"]["travelable"] ~= nil then
        if self["opentask"] ~= nil then
            self["opentask"]:Cancel()
            self["opentask"] = nil
        end
        self["inst"]["components"]["travelable"]:BeginTravel(__B__UG_)
    elseif self["classified"] ~= nil and self["opentask"] == nil and __B__UG_ ~= nil and __B__UG_ == ThePlayer then
        if __B__UG_["HUD"] == nil then
        else
            self["screen"] = __B__UG_["HUD"]:ShowTravelScreen(self["inst"])
        end
    end
end
function b__UG__:Travel(__b__UG__, _B_uG_)
    if self["inst"]["components"]["travelable"] ~= nil then
        self["inst"]["components"]["travelable"]:Travel(__b__UG__, _B_uG_)
    elseif self["classified"] ~= nil and __b__UG__ == ThePlayer then
        SendModRPCToServer(MOD_RPC["FastTravel"]["Travel"], self["inst"], _B_uG_)
    end
end
function b__UG__:EndTravel()
    if self["opentask"] ~= nil then
        self["opentask"]:Cancel()
        self["opentask"] = nil
    end
    if self["inst"]["components"]["travelable"] ~= nil then
        self["inst"]["components"]["travelable"]:EndTravel()
    elseif self["screen"] ~= nil then
        if ThePlayer ~= nil and ThePlayer["HUD"] ~= nil then
            ThePlayer["HUD"]:CloseTravelScreen()
        elseif self["screen"]["inst"]:IsValid() then
            self["screen"]:Kill()
        end
        self["screen"] = nil
    end
end
function b__UG__:SetTraveller(b_u__g)
    self["classified"]["Network"]:SetClassifiedTarget(b_u__g or self["inst"])
    if self["inst"]["components"]["travelable"] == nil then
        assert(b_u__g == nil)
    end
end
function b__UG__:SetDestInfos(_B_ug_)
    self["_infos"]:set(_B_ug_)
end
function b__UG__:GetDestInfos()
    return self["_infos"]:value()
end
return b__UG__
