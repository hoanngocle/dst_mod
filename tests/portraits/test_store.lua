local Store = dofile('mods/PhamNhanTuTien/scripts/ttk_eva_portraits.lua')
local saved, read_cb, write_cb
local sim = {
 GetPersistentString=function(_,key,cb) read_cb=cb end,
 SetPersistentString=function(_,key,value,encoded,cb) saved=value;write_cb=cb end,
}
local state=Store.New(sim)
state:Load(); read_cb(true,'eva_art_2'); assert(state:Get().id=='eva_art_2')
state:Step(1); assert(state:Get().id=='eva_art_3'); assert(saved==nil)
state:Save(); assert(saved=='eva_art_3' and state.saving); write_cb(true); assert(state:IsDefault())
state:Step(1); state:Save();write_cb(false); assert(not state:IsDefault() and state.error)
local reopened=Store.New(sim); reopened:Load();read_cb(true,'eva_art_3');assert(reopened:Get().id=='eva_art_3')
local invalid=Store.New(sim);invalid:Load();read_cb(true,'missing');assert(invalid:Get().id=='eva_original')
invalid:Step(-1);assert(invalid:Get().id=='eva_art_4'); invalid:Step(1);assert(invalid:Get().id=='eva_original')
local race=Store.New(sim);race:Load();race:Step(1);read_cb(true,'eva_art_3');assert(race:Get().id=='eva_art_1')
assert(#Store.entries==5)
print('Portrait persistence: load, save, failure, invalid id, wraparound and delayed load passed')
-- A delayed initial read must not undo a newer saved default.
local late=Store.New(sim);late:Load();local old_read=read_cb
late:Step(1);late:Save();write_cb(true);old_read(true,'eva_art_4')
assert(late.default=='eva_art_1' and late:IsDefault())
-- Browsing while a write is pending must save the clicked image, not the later preview.
late:Step(1);late:Save();late:Step(1);write_cb(true)
assert(late.default=='eva_art_2' and late:Get().id=='eva_art_3' and not late:IsDefault())
print('Asynchronous read/write race checks passed')
