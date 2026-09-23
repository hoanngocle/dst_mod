from pathlib import Path
base=Path('artifacts/bang-tong-hop/render.py').read_text(encoding='utf-8')
prefix=base.split("lua.execute('\\nfunction Widget:GetSize")[0]
ns={'__file__':str(Path('artifacts/bang-tong-hop/render.py').resolve())};exec(prefix,ns)
lua=ns['lua']
lua.execute('''
UIFONT='ui';TITLEFONT='title';TUNING={HH_SHADOW_PROGRESSION={GROWTH={hh_igris_shadow={HEALTH_PER_LEVEL=.025,DAMAGE_PER_LEVEL=.015,ABSORB_PER_LEVEL=.0035,ABSORB_CAP=.10}}}};FACING_DOWN=0
function TextWidget:EnableWordWrap(v) self.wrap=v end
function TextWidget:SetFont(f) self.font=f end
function TextWidget:SetSize(s) self.size=s end
function TextWidget:GetRegionSize() return measure(self.text or '',self.size or 20) end
local ctor=Widget._ctor
Widget._ctor=function(self,...) ctor(self,...);self.inst.DoPeriodicTask=function()return {Cancel=function()end}end end
package.preload['widgets/screen']=function()return Widget end
package.preload['widgets/textbutton']=function()return Button end
local Anim=Class(Widget,function(self)Widget._ctor(self,'animation');self.state=setmetatable({},{__index=function()return function()end end})end)
function Anim:GetAnimState() return self.state end
function Anim:SetFacing()end
package.preload['widgets/uianim']=function()return Anim end
owner={}
function net(v)return {value=function()return v end}end
owner.hh_shadow_igris_level=net(10);owner.hh_shadow_igris_exp=net(250);owner.hh_shadow_igris_talents=net(3)
ui=require('screens/hh_shadow_upgrade_screen')(owner)
''')
render=base[base.index('S=1.8'):base.index("canvas=Image.new('RGBA',(1500,1100)")]
render=render.replace("f=font(size*sx);lines=text.split('\\n')", "f=ImageFont.truetype('C:/Windows/Fonts/seguisym.ttf',max(1,int(size*sx))) if '★' in text else font(size*sx);lines=text.split('\\n')")
exec(render,ns)
ns['canvas']=ns['Image'].new('RGBA',(1600,1080),(20,20,25,255))
ns['render'](lua.globals().ui,800,490,1.85,1.85)
draw=ns['ImageDraw'].Draw(ns['canvas'])
draw.text((55,985),'Quân Đoàn hiện tại · Dựng từ Lua và texture · Ví dụ Igris cấp 10',font=ns['font'](24),fill=(215,210,225))
draw.text((55,1025),'Font thay thế; chưa hiển thị mô hình động đệ tử. Không phải ảnh chụp trong game.',font=ns['font'](22),fill=(185,180,195))
ns['canvas'].convert('RGB').save('artifacts/current-army/quan-doan-hien-tai.png')
