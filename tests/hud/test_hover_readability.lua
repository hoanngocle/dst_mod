-- Render the real hover widget into a minimal widget tree; verify its colours
-- survive legacy saved themes, semantic colours, child rows and rainbow ticks.
local Widget = Class(function(self)
    self.shown = true
    self.inst = {ListenForEvent=function() end, DoPeriodicTask=function(_, _, fn)
        self.tick=fn; return {Cancel=function()end}
    end}
end)
function Widget:AddChild(child) return child end
function Widget:SetPosition() end
function Widget:SetVAnchor() end
function Widget:SetHAnchor() end
function Widget:SetScaleMode() end
function Widget:SetRotation() end
function Widget:SetTexture() end
function Widget:StartUpdating() end
function Widget:SetSize(w,h) self.w=w;self.h=h end
function Widget:GetSize() return self.w or 0,self.h or 0 end
function Widget:SetString(text) self.text=text end
function Widget:GetRegionSize() return #(self.text or '')*8,22 end
function Widget:SetColour(c) self.color=c end
function Widget:SetTint(r,g,b,a) self.color={r,g,b,a} end
function Widget:Show() self.shown=true end
function Widget:Hide() self.shown=false end
for _,name in ipairs({'widget','text','image','imagebutton'}) do
    package.preload['widgets/'..name]=function()return Widget end
end
local utils={}
function utils:IsHHType(value,kind) return type(value)==kind end
function utils:HHCreateImageUi(parent,atlas,image,pos,w,h,color)
    local node=Widget();node:SetSize(w,h);node:SetColour(color);return node
end
function utils:HHCreateTextUi(parent,pos,text,color,size)
    local node=Widget();node:SetString(text);node:SetColour(color);return node
end
function utils:HHCompareTable() return false end
function utils:HHKillChild(parent,key) parent[key]=nil end
function utils:TableSortKeys(t) local keys={};for k in pairs(t)do keys[#keys+1]=k end;table.sort(keys);return keys end
function utils:HasReplica() return false end
function utils:StrToTable() return {back_ground_config={1,1},frame_config={1,1},icon_config={1,1,1,1}} end
package.preload['utils/hh_utils']=function()return utils end
package.preload['enums/hh_hoverer']=function()return {
    hh_01_name={name='',str_color={0,0,1,0.1}},
    hh_02_stat={name='Damage:',str_color={1,0,0,0.1}},
}end
TUNING={HH_COLOR_CONFIG={{color={255,255,255}}},HH_ICON_CONFIG={{}}}
function Vector3(x,y,z)return {x=x,y=y,z=z}end
function GetTime()return 2 end
local target={GUID=1,prefab='test',components={},HasTag=function()return false end}
TheInput={GetHUDEntityUnderMouse=function()end,GetWorldEntityUnderMouse=function()return target end,
    GetScreenPosition=function()return {x=500,y=500}end}
TheSim={GetScreenSize=function()return 1920,1080 end,
    GetPersistentString=function(_,_,fn)fn(true,'legacy theme')end}
local Hover=require('widgets/hh_hoverer')
local owner={hh_hoverer_list={
    hh_01_name={bool=true,str='Sword',rainbow=true},
    hh_02_stat={bool=true,str='50',child_ui={{desc='Special effect',desc_color={0,0,0,0.1}}}},
}}
local popup=Hover(owner);popup.hh_target_name='Sword';popup:UpdateHoverer()
local theme=require('ttk_hover_theme')
assert(popup.hh_main.color[4]==0.97,'legacy transparency must not wash out popup')
assert(popup.hh_main.hh_frame_up.color[3]==1)
assert(popup.hh_main.hh_icon_left_up.color[1]==theme.corner[1])
local function luminance(c)
    local function linear(x) return x<=0.04045 and x/12.92 or ((x+0.055)/1.055)^2.4 end
    return .2126*linear(c[1])+.7152*linear(c[2])+.0722*linear(c[3])
end
-- Worst case is the 97%-opaque panel composited over a white game scene.
local bg={};for i=1,3 do bg[i]=theme.background[i]*.97+.03 end
local function readable(c)
    assert(c[4]==1 and (luminance(c)+.05)/(luminance(bg)+.05)>=4.5,'text contrast below 4.5:1')
end
readable(popup.hh_main.hh_body_hh_02_stat.color)
readable(popup.hh_main.hh_body_hh_02_stat.hh_str.color)
readable(popup.hh_main.hh_body_hh_02_stat.hh_str.hh_child_ui.hh_text_1.color)
local title=popup.hh_main.hh_body_hh_01_name.hh_str
title.tick();readable(title.color)
for r=0,1,.25 do for g=0,1,.25 do for b=0,1,.25 do readable(theme.Readable({r,g,b,.1})) end end end
assert(popup.hh_main.w>0 and popup.hh_main.h>0)
print('PASS: actual hover widget, legacy theme override, label/value/child/rainbow contrast >= 4.5:1')
