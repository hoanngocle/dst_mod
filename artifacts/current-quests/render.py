from pathlib import Path
base=Path('artifacts/bang-tong-hop/render.py').read_text(encoding='utf-8')
prefix=base.split("lua.execute('\\nfunction Widget:GetSize")[0]
ns={'__file__':str(Path('artifacts/bang-tong-hop/render.py').resolve())};exec(prefix,ns)
lua=ns['lua']
lua.execute('''
UIFONT='ui';TITLEFONT='title'; TUNING={TOTAL_DAY_TIME=480}; TheWorld={state={cycles=20,phase='day'}}
function Widget:EnableWordWrap() end; TextWidget.EnableWordWrap=Widget.EnableWordWrap
function Widget:ResetRegionSize() end; TextWidget.ResetRegionSize=Widget.ResetRegionSize
function Button:SetTextSelectedColour() end
function TextWidget:SetSize(s) self.size=s end
local ctor=Widget._ctor
Widget._ctor=function(self,...) ctor(self,...); self.inst.DoPeriodicTask=function()return {Cancel=function()end}end end
package.preload['widgets/screen']=function()return Widget end
package.preload['widgets/button']=function()return Button end
package.preload['widgets/textbutton']=function()return Button end
owner={}
Guild=require('widgets/hh_guild_ui')
ui=Guild(owner)
''')
render=base[base.index('S=1.8'):base.index("canvas=Image.new('RGBA',(1500,1100)")]
exec(render,ns)
ns['canvas']=ns['Image'].new('RGBA',(1500,1100),(20,20,25,255))
ns['render'](lua.globals().ui,750,510,2.8,2.8)
ns['ImageDraw'].Draw(ns['canvas']).text((50,1010),'Giao diện Hiệp Hội hiện tại · Dựng từ Lua và texture · Trạng thái mặc định',font=ns['font'](23),fill=(215,210,225))
ns['ImageDraw'].Draw(ns['canvas']).text((50,1048),'Font thay thế; không phải ảnh chụp trong game.',font=ns['font'](23),fill=(185,180,195))
ns['canvas'].convert('RGB').save('artifacts/current-quests/hiep-hoi-hien-tai.png')

