local G=GLOBAL
local containers=G.require("containers")
local params={
    widget={slotpos={},bgatlas="images/xd_back_xh_ui.xml",bgimage="xd_back_xh_ui.tex",
        pos=G.Vector3(-140,-140,0)},
    issidewidget=true,type="pack",openlimit=1,
}
for y=0,5 do
    for x=0,2 do
        table.insert(params.widget.slotpos,G.Vector3(75*x-75,190-75*y,0))
    end
end
containers.params.ttk_boss_back_xh=params
containers.MAXITEMSLOTS=math.max(containers.MAXITEMSLOTS,18)
table.insert(PrefabFiles,"ttk_boss_back_xh")
table.insert(Assets,G.Asset("ATLAS","images/xd_back_xh_ui.xml"))
table.insert(Assets,G.Asset("IMAGE","images/xd_back_xh_ui.tex"))
G.STRINGS.NAMES.TTK_BOSS_BACK_XH="Ba Lô Tiên Hà"
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TTK_BOSS_BACK_XH="Ba lô 18 ô (3 cột × 6 hàng). Đeo ở ô ba lô để chứa đồ."
RegisterInventoryItemAtlas("images/inventoryimages/xd_back_xh.xml","xd_back_xh.tex")
