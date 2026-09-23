local bosses = {
    baihu = {name="Tàn Khu Bạch Hổ", food_name="Bạch Hổ Huyết Tủy", summon_name="Bạch Hổ Tàn Hồn", stat="trueDamageNum", gain=4, effect="criticalHitRate", effect_value=10},
    jfsn = {name="Kim Phượng Thần Niệm", food_name="Kim Phượng Tinh Huyết", summon_name="Kim Phượng Tàn Hồn", stat="health", gain=20, effect="immuneHot"},
    qlch = {name="Kỳ Lân Tàn Hồn", food_name="Kỳ Lân Linh Đan", summon_name="Kỳ Lân Tàn Hồn", stat="mana", gain=20, effect="immuneCold"},
    qxdx = {name="Thanh Tụ Đan Tiên", unique=true},
    futu = {name="Ma Tướng Phù Đồ", unique=true, blueprint="ttk_xshj_blueprint"},
    spiderqueen = {name="Tà Sát Thù Vương", food_name="Ma Thù Nội Đan", summon_name="Huyết Ngọc Tri Thù Noãn", stat="hunger", gain=20, effect="immunePoison"},
    ziyunboss = {name="Tử Vân Ma Quân", unique=true, blueprint="ttk_zcmj_blueprint"},
    stalke_fuben = {name="Thượng Cổ Hắc Ám", food_name="Hắc Ám Hồn Tinh", summon_name="Tâm Nhĩ Hắc Ám", summon_icon="shadowheart", stat="absorbDamage", gain=2, effect="immunitySleep"},
    deerclops_ziyun = {name="Hồn Phách Tinh Thể Hươu Một Mắt", food_name="Băng Phách Tinh Tủy", summon_name="Độc Nhãn Tàn Hồn", stat="sanity", gain=20, effect="immuneFreeze"},
}
local order={"baihu","jfsn","qlch","qxdx","futu","spiderqueen","ziyunboss","stalke_fuben","deerclops_ziyun"}
for key,def in pairs(bosses) do
    def.key=key
    def.prefab="ttk_"..key
    if not def.unique then
        def.food="ttk_boss_core_"..key
        def.summon="ttk_summon_"..key
    end
end
return {bosses=bosses,order=order,limit=10}
