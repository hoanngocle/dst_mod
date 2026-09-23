local _B_u__G = GLOBAL["PCT"]
AddModRPCHandler(
    modname,
    "page",
    function(__B_uG_, __b__ug, BuG__, _b_u_g_, __BUG)
        if __b__ug and __b__ug["components"]["pageable"] then
            if GLOBAL["TheWorld"]["ismastersim"] then
                if BuG__ == "page" then
                    __b__ug["components"]["pageable"]:Page(_b_u_g_, __BUG)
                end
                if BuG__ == "move" then
                    __b__ug["components"]["pageable"]:Move(_b_u_g_, __BUG)
                end
            end
        end
    end
)
_B_u__G["SendRPC"] = function(_b_u__G, __b_u_g_, _bu__G__, B__U_g, _b__ug_)
    SendModRPCToServer(MOD_RPC[modname][_b_u__G], __b_u_g_, _bu__G__, B__U_g, _b__ug_)
end
