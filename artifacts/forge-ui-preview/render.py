from pathlib import Path
from zipfile import ZipFile
import sys,xml.etree.ElementTree as ET
from functools import lru_cache
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];MOD=ROOT/'mods/PhamNhanTuTien';OUT=Path(__file__).parent
sys.path[:0]=[str(ROOT/'.superpowers/ttk-solo-integration/lua-runtime'),str(ROOT)]
from lupa.lua51 import LuaRuntime
from tools.extract.publish_solo_leveling_assets import decode_ktex
GAME=Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles")
images=ZipFile(GAME/'images.zip')
@lru_cache(None)
def font(size):return ImageFont.truetype('C:/Windows/Fonts/arial.ttf',max(1,int(size)))
def measure(text,size):
 text=str(text);f=font(size);lines=text.split('\n');return max(f.getlength(x) for x in lines)*.58,len(lines)*size*1.12
@lru_cache(None)
def texture(atlas,name):
 def read(path):
  p=MOD/path
  return p.read_bytes() if p.exists() else images.read(path)
 if atlas=='images/inventoryimages.xml':atlas='images/inventoryimages2.xml'
 xml=ET.fromstring(read(atlas));el=next(e for e in xml.iter('Element') if e.attrib['name']==name)
 tex=xml.find('Texture').attrib['filename'];path=str(Path(atlas).parent/tex).replace('\\','/')
 im=decode_ktex(read(path));a=el.attrib;w,h=im.size
 return im.crop((round(float(a['u1'])*w),round((1-float(a['v2']))*h),round(float(a['u2'])*w),round((1-float(a['v1']))*h)))
lua=LuaRuntime(unpack_returned_tuples=True);lua.globals().measure=measure
with ZipFile(GAME/'scripts.zip') as z:lua.execute(z.read('scripts/class.lua').decode())
lua.globals().package.path=str(MOD/'scripts/?.lua').replace('\\','/')+';'+lua.globals().package.path
lua.execute('''
ANCHOR_MIDDLE=0;ANCHOR_LEFT=1;SCALEMODE_PROPORTIONAL=0;BODYTEXTFONT='body'
function Vector3(x,y,z) return {x=x,y=y,z=z} end
Widget=Class(function(self,name) self.name=name;self.children={};self.pos={x=0,y=0};self.scale={x=1,y=1};self.inst={ListenForEvent=function() end} end)
function Widget:AddChild(child) table.insert(self.children,child);return child end
function Widget:SetPosition(x,y,z) self.pos=type(x)=='table' and x or {x=x,y=y} end
function Widget:SetScale(x,y,z) self.scale={x=x,y=y or x} end
function Widget:SetSize(w,h) self.w=w;self.h=h end
function Widget:SetTint(r,g,b,a) self.colour={r,g,b,a} end
function Widget:SetColour(c) self.colour=c end
function Widget:SetString(t) self.text=tostring(t) end
function Widget:SetHAlign(v) self.align=v end
function Widget:SetVAlign() end
function Widget:SetVAnchor() end
function Widget:SetHAnchor() end
function Widget:SetScaleMode() end
function Widget:SetOnClick(fn) self.onclick=fn end
function Widget:GetRegionSize() return measure(self.text or '',self.size or 20) end
function Widget:Kill() self.dead=true end
ImageWidget=Class(Widget,function(self,a,t) Widget._ctor(self,'image');self.atlas=a;self.tex=t end)
TextWidget=Class(Widget,function(self,f,s,t) Widget._ctor(self,'text');self.size=s;self.text=t or '' end)
Button=Class(Widget,function(self,a,t) Widget._ctor(self,'button');self.image=self:AddChild(ImageWidget(a,t)) end)
package.preload['widgets/widget']=function()return Widget end
package.preload['widgets/image']=function()return ImageWidget end
package.preload['widgets/text']=function()return TextWidget end
package.preload['widgets/imagebutton']=function()return Button end
for _,n in ipairs({'uianim','textbutton','truescrollarea'}) do package.preload['widgets/'..n]=function()return Widget end end
package.preload['enums/hh_enchant']=function()return {HH_EQUIP_BUFF_LIST={},HH_SUIT_RECIPE={},HH_SUIT_LIST={}} end
owner={components={hh_client={GetValue=function()return {} end,SetValue=function() end}}}
UI=require('widgets/hh_ui/hh_forge_ui')
''')
S=2
for tab,title in [(1,'Ngẫu Luyện'),(2,'Kế Thừa')]:
 ui=lua.eval('UI(owner)')
 if tab==2:ui.CreateTabUi(ui,2)
 canvas=Image.new('RGBA',(1440,1220),(32,35,33,255));draw=ImageDraw.Draw(canvas)
 def render(node,px=720,py=630,sx=S,sy=S):
  if node['dead']:return
  pos=node['pos'];scale=node['scale'];x=px+pos['x']*sx;y=py-pos['y']*sy
  sx*=scale['x'];sy*=scale['y']
  c=node['colour'];color=tuple(int(max(0,min(1,c[i]))*255) for i in range(1,5)) if c else (255,255,255,255)
  if node['atlas']:
   tile=texture(node['atlas'],node['tex']).copy();w=node['w'] or tile.width;h=node['h'] or tile.height
   tile=tile.resize((max(1,round(w*sx)),max(1,round(h*sy))),Image.Resampling.LANCZOS)
   if color!=(255,255,255,255):
    import numpy as np
    a=np.array(tile,dtype=float);a*=__import__('numpy').array(color)/255;tile=Image.fromarray(a.astype('uint8'))
   canvas.alpha_composite(tile,(round(x-tile.width/2),round(y-tile.height/2)))
  elif node['text'] is not None:
   text=node['text'];size=node['size'];w,h=measure(text,size)
   f=font(size*sx);lines=text.split('\n')
   for i,line in enumerate(lines):
    rawwidth=max(1,round(f.getlength(line)));width=rawwidth*.58
    left=x-w*sx/2 if node['align']==1 else x-width/2
    glyphs=Image.new('RGBA',(rawwidth+8,round(size*sy*1.3)),(0,0,0,0))
    ImageDraw.Draw(glyphs).text((0,0),line,font=f,fill=color)
    glyphs=glyphs.resize((max(1,round(glyphs.width*.58)),glyphs.height),Image.Resampling.LANCZOS)
    canvas.alpha_composite(glyphs,(round(left),round(y-h*sy/2+i*size*1.12*sy)))
  for child in node['children'].values():render(child,x,y,sx,sy)
 render(ui)
 # Container slots are overlaid by DST separately from the custom widget.
 slots=[(-250,150)]+([(-150,0),(-220,-75),(-150,-75),(-80,-75)] if tab==1 else [(-220,0),(-100,0),(-190,-75),(-130,-75)])
 slot=texture('images/hud.xml','inv_slot.tex').resize((96,96),Image.Resampling.LANCZOS)
 for x,y in slots:canvas.alpha_composite(slot,(round(720+x*S-48),round(630-y*S-48)))
 draw.text((70,30),'HỢP THÀNH ĐÀI · '+title,font=font(30),fill=(237,231,216))
 draw.text((70,1168),'Mã giao diện và texture gốc · Font thay thế · Không phải ảnh chụp trong game',font=font(21),fill=(180,183,174))
 path=OUT/('ngau-luyen.png' if tab==1 else 'ke-thua.png');canvas.convert('RGB').save(path)
 print(path)
