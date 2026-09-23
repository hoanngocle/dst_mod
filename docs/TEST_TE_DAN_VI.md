# Phàm Nhân Tu Tiên 2.0 — Lệnh và checklist test Tế Đàn

Ngày đối chiếu mã: 21/09/2026. Bản mod: `mods/PhamNhanTuTien`.

## 1. Chuẩn bị

Dùng world thử riêng vì các bước dưới tạo boss, đổi mùa, gây chết và kiểm tra mất công trình. Bật Phàm Nhân; Solo và HUD đã tích hợp, không bật thêm bản Solo Leveling riêng. Tế Đàn không có công tắc tắt boss Solo.

Bạn cần là host/admin. Trong game nhấn `~` để mở console; trên bàn phím khác có thể là phím dưới Esc. Nếu console đang ở Local, dùng Ctrl để chuyển Remote. Tất cả lệnh Lua dưới đây chạy ở **Remote/server**, trên shard có nhân vật đang test. Dán từng dòng, không dán dấu ```.

Kiểm tra đúng phía máy chủ và nhận diện nhân vật:

```lua
print("SERVER", TheWorld.ismastersim, "PLAYER", ConsoleCommandPlayer())
TTK_TEST_PLAYER = ConsoleCommandPlayer(); assert(TheWorld.ismastersim and TTK_TEST_PLAYER ~= nil, "Can chay Remote bang host/admin trong game")
```

Kỳ vọng `SERVER true` và player hợp lệ. Các biến `TTK_TEST_*` là biến console tạm, mất sau restart; cần khai báo lại sau khi vào world.

## 2. Bộ lệnh vào test nhanh

Đứng tại vùng đất rộng, xa căn cứ. Tạo đúng một Tế Đàn và một rương cách nhau 4 đơn vị:

```lua
assert(TTK_TEST_ALTAR == nil or not TTK_TEST_ALTAR:IsValid(), "Da co Te Dan test; dung lai hoac don truoc"); local x,y,z=TTK_TEST_PLAYER.Transform:GetWorldPosition(); TTK_TEST_ALTAR=SpawnPrefab("ttk_jitan"); assert(TTK_TEST_ALTAR); TTK_TEST_ALTAR.Transform:SetPosition(x+4,0,z)
assert(TTK_TEST_CHEST == nil or not TTK_TEST_CHEST:IsValid(), "Da co ruong test"); local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_CHEST=SpawnPrefab("ttk_llbx"); assert(TTK_TEST_CHEST); TTK_TEST_CHEST.Transform:SetPosition(x+4,0,z)
c_give("ttk_lingshi2", 10)
c_give("ttk_lingshi3", 10)
c_give("spear", 1)
c_give("armorwood", 1)
c_give("footballhat", 1)
c_give("hammer", 1)
c_give("twigs", 5)
```

Linh thạch trung phẩm/thượng phẩm là hai lễ vật hợp lệ. Cành cây dùng để thử từ chối lễ vật sai. Trang bị trên chỉ là đồ cơ bản; dùng trang bị Phàm Nhân bạn đang có để test boss mạnh.

Bật bất tử rõ trạng thái, phục vụ quan sát boss:

```lua
TTK_TEST_PLAYER.components.health:SetInvincible(true)
```

Tắt trước khi test chết, thoát vùng hoặc sát thương thật:

```lua
TTK_TEST_PLAYER.components.health:SetInvincible(false)
```

**Test luồng thật trước:** cầm một linh thạch và dâng bằng thao tác game. Không dùng lệnh chọn boss ở mục 5 cho bài test thu lễ vật. Đếm ngược 5 giây, giữ người dâng trong khoảng 32 đơn vị; khi đánh giữ trong 60 đơn vị.

## 3. Theo dõi lượt và tìm lại công trình

Xem trạng thái (idle/countdown/active/settling), boss, điểm, chủ lượt và số lần ra ngoài:

```lua
local q=TTK_TEST_ALTAR.components.ttk_jitan_trial; print("STATE",q.state,"RUN",q.run_id,"BOSS",q.boss_id,"SCORE",q.score,"OWNER",q.owner_userid,"OUTSIDE",q.outside_ticks)
```

In các thực thể thuộc lượt; boss nhiều pha có thể thay entity:

```lua
local q=TTK_TEST_ALTAR.components.ttk_jitan_trial; for e,r in pairs(q.tracked_entities) do print(e.prefab,e.GUID,"valid",e:IsValid(),"required",r.required,"defeated",r.defeated) end
```

Gắn log kết thúc **một lần** cho Tế Đàn đang chọn:

```lua
if not TTK_TEST_ALTAR._manual_test_log then TTK_TEST_ALTAR._manual_test_log=true; TTK_TEST_ALTAR:ListenForEvent("ttk_jitan_finished",function(inst,d) print("JITAN_RESULT",d.run_id,d.outcome,d.reason,d.userid,d.score) end) end
```

Sau load/reconnect: chạy lại khai báo player ở mục 1. Đưa chuột lên Tế Đàn, rồi chạy dòng đầu; sau đó đưa chuột lên rương và chạy dòng thứ hai:

```lua
TTK_TEST_ALTAR=c_select(); assert(TTK_TEST_ALTAR and TTK_TEST_ALTAR.components.ttk_jitan_trial, "Chua chon dung Te Dan")
TTK_TEST_CHEST=c_select(); assert(TTK_TEST_CHEST and TTK_TEST_CHEST.components.ttk_jitan_rewards, "Chua chon dung ruong")
```

## 4. Checklist luồng chơi thật

| Đạt | Chức năng | Cách test và kết quả mong đợi |
|---|---|---|
| [ ] | Công thức | Chế ở Máy Luyện Kim: Tế Đàn = 12 Đá Cắt + 6 Vàng + 2 Thượng Phẩm Linh Thạch; rương = 6 Ván + 4 Vàng + 1 Thượng Phẩm. Kiểm cả icon, tên, placer và tiêu nguyên liệu. |
| [ ] | Lễ vật hợp lệ | Dâng trung/thượng phẩm bằng game; đúng một món bị trừ, chỉ tạo một lượt. Thử cầm cả stack để kiểm tra không mất cả stack. |
| [ ] | Lễ vật sai | Dâng cành cây: bị từ chối, không mất đồ, không chạy lượt. |
| [ ] | Thiếu rương | Đặt rương ngoài 32 đơn vị khi altar idle: từ chối trước khi thu lễ. Đưa về gần để thử lại. |
| [ ] | Đếm ngược | Sau khi nhận lễ chờ 5 giây. Đi quá 32 đơn vị trong giai đoạn này: hủy, không sinh boss, không thưởng; không hoàn lễ theo thiết kế. |
| [ ] | Trùng lượt | Dâng thêm khi đang countdown/active: bị từ chối và không thu thêm lễ. |
| [ ] | Chồng vùng | Tế Đàn thứ hai cách dưới 128 đơn vị không mở được khi Tế Đàn đầu đang hoạt động. |
| [ ] | Vị trí bị cấm | Thử ở nội thất Thiên Cơ Ốc và dungeon Solo: từ chối trước lễ. Thử đất chật/sát mép: encounter không đủ vị trí không được chọn. |
| [ ] | Mùa/địa hình | Deerclops đúng mùa đông, Moose mùa xuân ngoài hang; boss biển cần vị trí phù hợp. Không bị thu lễ rồi chọn boss vốn không thể sinh tại đó. |
| [ ] | Thắng thật | Đánh hạ đủ mục tiêu, trạng thái về idle, chỉ một kết quả won và một lần thưởng; có thể mở lượt mới. |
| [ ] | Bỏ vùng | Trong active, ra ngoài 60 đơn vị đủ 11 lần kiểm tra, mỗi giây một lần: thua, dọn boss thuộc lượt, trừ 40% máu tối đa qua health API, không thưởng. Các lần ngoài vùng cộng dồn, quay lại không reset. |
| [ ] | Chết | Tắt bất tử và để boss giết: thua, dọn đúng boss/minion thuộc lượt, không thưởng. |
| [ ] | Rời server | Người dâng disconnect khi active: lượt thua khi kiểm tra không còn chủ; vào lại không được nhận thưởng thắng. |
| [ ] | An toàn thực thể khác | Đặt boss/quái tự nhiên bên cạnh; hủy lượt chỉ xóa thực thể thuộc lượt, không quét xóa quái khác. |
| [ ] | HUD/client | Tên, HP, sát thương, chuyển phase đúng trên host và client; rương 36 ô hiển thị đúng, không Lua error. |

Di chuyển rương ra xa/về gần (chỉ lúc idle):

```lua
local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_CHEST.Transform:SetPosition(x+40,0,z)
local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_CHEST.Transform:SetPosition(x+4,0,z)
```

Đi xa 70 đơn vị để test thoát vùng, rồi trở về. Chọn hướng có đất trước khi dùng:

```lua
local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_PLAYER.Transform:SetPosition(x+70,0,z)
local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_PLAYER.Transform:SetPosition(x+2,0,z)
```

## 5. Chọn chính xác từng encounter để test combat

Đây là **lối tắt debug**: vẫn gọi bộ khởi tạo/adapters của Tế Đàn, nhưng bỏ thu lễ vật và bỏ đếm ngược. Có thể sinh thưởng nếu thắng; không dùng kết quả này để kết luận Trader/chi phí đúng. Không `c_spawn` boss đơn lẻ để nghiệm thu Tế Đàn: cách đó không đăng ký boss vào lượt, không chạy đủ adapter/manager.

Khai báo helper sau khi đã có `TTK_TEST_PLAYER`, `TTK_TEST_ALTAR`, rương gần đó. Dán nguyên dòng:

```lua
TTK_TEST_START=function(id) local q=assert(TTK_TEST_ALTAR.components.ttk_jitan_trial); assert(q.state=="idle","Hay ket thuc luot truoc"); local B=require("ttk_jitan_bosses"); local S=require("ttk_jitan_encounter_setup"); local e=assert(B.GetEncounter(id),"Sai encounter id"); local ctx=B.BuildContext(q); local ready,why=S.IsAvailable(e,ctx); assert(ready,why); local pool=B.AvailableEncounters(e.group,ctx); local idx=nil; for i,v in ipairs(pool) do if v.id==id then idx=i end end; assert(idx,"Encounter khong o pool"); local ok,reason=q:Start(TTK_TEST_PLAYER,"ttk_lingshi3"); assert(ok,reason); q:CancelTasks(); q.boss_group=e.group; q.rng=function() q.rng=math.random; return (idx-0.5)/#pool end; local started,err=q:BeginActive(q.run_id); q.rng=math.random; print("DEBUG_START",id,started,err) end
```

Ví dụ, mỗi lần một trận:

```lua
TTK_TEST_START("bearger")
TTK_TEST_START("celestial_champion")
TTK_TEST_START("twins_of_terror")
TTK_TEST_START("solo_hh_igris_dungeon")
TTK_TEST_START("solo_hh_beru_dungeon")
```

Chỉ chạy dòng tiếp theo sau khi thắng/thua/hủy lượt trước. Đánh bằng nhân vật hoặc bóng thật để kiểm tra kill credit/EXP/loot; không giả event `death`/`killed` hay gọi thắng trực tiếp.

Hủy lượt đang test, không thưởng, không phạt thoát vùng:

```lua
local q=TTK_TEST_ALTAR.components.ttk_jitan_trial; if q.state~="idle" then q:Finish(q.run_id,"cancelled","manual_test") end
```

Đổi mùa trong world thử trước khi gọi helper:

```lua
TheWorld:PushEvent("ms_setseason","winter")
TheWorld:PushEvent("ms_setseason","spring")
TheWorld:PushEvent("ms_setseason","autumn")
```

Chạy một dòng mùa cần dùng và đợi khoảng 2 giây. Kiểm tra trạng thái:

```lua
print("SEASON",TheWorld.state.season,"WINTER",TheWorld.state.iswinter,"SPRING",TheWorld.state.isspring)
```

Với Crab King/Malbatross, đặt bộ Tế Đàn + rương trên đất cạnh bờ biển, không đặt altar ngoài biển. Di chuyển nhân vật ra bờ trước khi tạo bộ mới. Hủy lượt cũ trước khi đổi chỗ công trình.

In danh sách hiện có thể chọn và lý do bị loại:

```lua
local B=require("ttk_jitan_bosses"); local ctx=B.BuildContext(TTK_TEST_ALTAR.components.ttk_jitan_trial); for g=1,3 do local yes,no=B.AvailableEncounters(g,ctx); for _,e in ipairs(yes) do print("READY",g,e.id) end; for id,why in pairs(no) do print("BLOCKED",id,why) end end
```

### Danh sách đủ 51 encounter

Dùng ID cột thứ hai với `TTK_TEST_START("ID")`. Số nhóm là nhóm độ khó của catalog, không phải cấp nhân vật. Một encounter có thể gồm nhiều boss hoặc nhiều phase.

| Đạt | Encounter ID | Nhóm | Prefab khởi đầu | Điều kiện bổ sung |
|---|---|---|---|---|
| [ ] | `minotaur` | 1 | minotaur | Đất trống; đủ dependency |
| [ ] | `antlion` | 2 | antlion | Đất trống; đủ dependency |
| [ ] | `bearger` | 1 | bearger | Đất trống; đủ dependency |
| [ ] | `mutatedbearger` | 2 | mutatedbearger | Đất trống; đủ dependency |
| [ ] | `beequeen` | 2 | beequeen | Đất trống; đủ dependency |
| [ ] | `celestial_champion` | 3 | alterguardian_phase1 | Đất trống; đủ dependency |
| [ ] | `alterguardian_phase1_lunarrift` | 3 | alterguardian_phase1_lunarrift | Đất trống; đủ dependency |
| [ ] | `alterguardian_phase4_lunarrift` | 3 | alterguardian_phase4_lunarrift | Đất trống; đủ dependency |
| [ ] | `crabking` | 3 | crabking | Gần biển, đủ chỗ sinh boss trên biển |
| [ ] | `deerclops` | 1 | deerclops | Mùa đông |
| [ ] | `mutateddeerclops` | 2 | mutateddeerclops | Mùa đông |
| [ ] | `dragonfly` | 1 | dragonfly | Đất trống; đủ dependency |
| [ ] | `eyeofterror` | 2 | eyeofterror | Đất trống; đủ dependency |
| [ ] | `twins_of_terror` | 3 | twinmanager | Đất trống; đủ dependency |
| [ ] | `klaus` | 3 | klaus | Đất trống; đủ dependency |
| [ ] | `lordfruitfly` | 1 | lordfruitfly | Đất trống; đủ dependency |
| [ ] | `malbatross` | 2 | malbatross | Gần bờ nước |
| [ ] | `moose` | 1 | moose | Mùa xuân; Mặt đất |
| [ ] | `daywalker` | 2 | daywalker | Đất trống; đủ dependency |
| [ ] | `daywalker2` | 3 | daywalker2 | Đất trống; đủ dependency |
| [ ] | `shadow_chess` | 3 | shadow_knight, shadow_bishop, shadow_rook | Đất trống; đủ dependency |
| [ ] | `sharkboi` | 2 | sharkboi | Đất trống; đủ dependency |
| [ ] | `spiderqueen` | 1 | spiderqueen ×3 | Đất trống; đủ dependency |
| [ ] | `toadstool` | 2 | toadstool | Đất trống; đủ dependency |
| [ ] | `toadstool_dark` | 3 | toadstool_dark | Đất trống; đủ dependency |
| [ ] | `stalker` | 2 | stalker | Đất trống; đủ dependency |
| [ ] | `stalker_atrium` | 3 | stalker_atrium | Đất trống; đủ dependency |
| [ ] | `leif` | 1 | leif | Đất trống; đủ dependency |
| [ ] | `leif_sparse` | 1 | leif_sparse | Đất trống; đủ dependency |
| [ ] | `fruitdragon` | 1 | fruitdragon | Đất trống; đủ dependency |
| [ ] | `warg` | 1 | warg | Đất trống; đủ dependency |
| [ ] | `claywarg` | 1 | claywarg | Đất trống; đủ dependency |
| [ ] | `gingerbreadwarg` | 1 | gingerbreadwarg | Đất trống; đủ dependency |
| [ ] | `mutatedwarg` | 2 | mutatedwarg ×2 | Đất trống; đủ dependency |
| [ ] | `wagboss_robot` | 3 | wagboss_robot | Đất trống; đủ dependency |
| [ ] | `worm_boss` | 3 | worm_boss | Đất trống; đủ dependency |
| [ ] | `vault_pillar_guard` | 3 | vault_pillar_guard | Đất trống; đủ dependency |
| [ ] | `shadow_thralls` | 2 | shadowthrall_horns, shadowthrall_hands, shadowthrall_wings | Đất trống; đủ dependency |
| [ ] | `solo_minotau` | 3 | minotau | Đất trống; đủ dependency |
| [ ] | `solo_hh_sharkboi` | 3 | hh_sharkboi | Đất trống; đủ dependency |
| [ ] | `solo_hh_beetle_pig` | 2 | hh_beetle_pig | Đất trống; đủ dependency |
| [ ] | `solo_hh_dual_wield_pig` | 2 | hh_dual_wield_pig | Đất trống; đủ dependency |
| [ ] | `solo_hh_igris_dungeon` | 3 | hh_igris_dungeon | Đất trống; đủ dependency |
| [ ] | `solo_hh_beru_dungeon` | 3 | hh_beru_dungeon | Đất trống; đủ dependency |
| [ ] | `solo_mutateddeerclops_boss` | 3 | mutateddeerclops | Mùa đông |
| [ ] | `solo_mutatedbearger_boss` | 3 | mutatedbearger | Đất trống; đủ dependency |
| [ ] | `solo_mutatedwarg_boss` | 3 | mutatedwarg | Đất trống; đủ dependency |
| [ ] | `solo_hh_sharkboi_boss` | 3 | hh_sharkboi | Đất trống; đủ dependency |
| [ ] | `solo_walrus_adc` | 2 | walrus | Đất trống; đủ dependency |
| [ ] | `solo_treasure_kps` | 3 | krampus | Đất trống; đủ dependency |
| [ ] | `solo_treasure_cat_you` | 3 | catcoon | Đất trống; đủ dependency |

### Checklist riêng theo cơ chế boss

- [ ] Celestial Champion: phase 1 → 2 → 3, không thắng ở phase trung gian; một lần thưởng cuối. Không tạo dead-orb/tiến trình thắng boss thế giới từ trận thử luyện.
- [ ] Twins: hai mắt cùng lượt; hạ một mắt chưa thắng; loot cuối có shield/sketch theo cơ chế gốc.
- [ ] Klaus: đủ deer; phase bị xích không tính thắng; hoàn tất sau phase cuối.
- [ ] Daywalker, Daywalker2, Sharkboi: đi qua defeat/chuyển trạng thái đúng, không treo lượt do chờ death vốn không xảy ra.
- [ ] Lunar-rift: kiểm tra điều kiện kết thúc/capture thực tế của encounter, không đánh đồng minhealth với chết thường.
- [ ] Minotaur: bản DST không tự biến thành boss Solo qua construction callback giữa lượt; `solo_minotau` kiểm riêng.
- [ ] Crab King/Malbatross: boss ở vị trí hợp lệ, đánh được, không tự biến mất hoặc bỏ xa vùng; manager và helper được dọn khi hủy.
- [ ] Spider Queen ×3, Mutated Warg ×2, Shadow Chess/Thralls: hạ đủ mục tiêu mới thắng.
- [ ] Igris/Beru: đánh chết thật, đợi animation/timeline (Beru có thể cần vài giây); loot và thi thể chiêu mộ còn hoạt động sau thắng.
- [ ] Super Treasure: đúng biến thể/buff gốc, không cộng tăng sức mạnh lần hai; kiểm cả quái phụ của `solo_treasure_kps`.
- [ ] Boss có minion/bẫy: hủy giữa lúc đang có minion; không còn thực thể chiến đấu mồ côi thuộc lượt. Thi thể/loot hợp lệ sau thắng không phải lỗi dọn thiếu.

## 6. Rương, thưởng và Solo

| Đạt | Bài test | Kết quả cần thấy |
|---|---|---|
| [ ] | Chủ thưởng | A dâng lễ, B kết liễu: thưởng Tế Đàn thuộc A; EXP/quest theo luật kill credit của Solo. |
| [ ] | Bóng Solo kết liễu | Dùng bóng thật giết boss; lượt thắng bình thường, không lặp loot/EXP do Tế Đàn tự phát event. |
| [ ] | Hai người dùng rương | A và B lần lượt thắng rồi cùng mở một rương vật lý: mỗi người thấy kho riêng, không lấy được phần của nhau. Cần hai client thật. |
| [ ] | Mở lại | Nhận thưởng, đóng/mở nhiều lần: không sinh thêm bộ thưởng. |
| [ ] | Rương đầy | Làm đầy ngăn riêng rồi thắng thêm: phần chưa chứa được giữ trong queue; dọn ô rồi mở lại nhận phần còn lại, không rơi đồ ra đất/nhân đôi. |
| [ ] | Stack còn chỗ một phần | Để một stack gần đầy, các ô khác đầy; thưởng cùng loại chỉ ghép phần vừa đủ, phần dư còn trong queue. |
| [ ] | Giữ thuộc tính | Đồ có độ bền/cường hóa trong kho giữ thuộc tính sau save/load và phục hồi rương. |
| [ ] | Chèn đồ vào facade | Công trình rương ngoài không nhận đồ trực tiếp ngoài cơ chế kho riêng. |
| [ ] | Đập rương | Khi còn đồ hoặc pending: không phá được bằng búa. Khi rỗng: phá được. |
| [ ] | Đồ rơi gốc | Boss chết thật vẫn rơi loot gốc; hook linh thạch chung không trả thêm cho boss thử luyện. |
| [ ] | Scaling | So sánh boss cùng loại tự nhiên/thử luyện ở cùng World Rank và trạng thái buff; không suy ra nhân đôi chỉ từ HP hai boss có buff ngẫu nhiên khác nhau. |

Đếm pending của người đang test và số backup trên altar (đọc, không cấp thêm thưởng):

```lua
local r=TTK_TEST_CHEST.components.ttk_jitan_rewards; local uid=TTK_TEST_PLAYER.userid; local n=0; for _,batch in ipairs(r.pending_by_userid[uid] or {}) do n=n+#batch.items end; print("PENDING_RECORDS",uid,n,"ALTAR_BACKUPS",#TTK_TEST_ALTAR.components.ttk_jitan_trial.reward_backups)
```

Chuẩn bị ngăn riêng đầy để test queue: mở rương ít nhất một lần, lấy hết phần thưởng cần giữ ra trước, rồi chạy. Lệnh tạo tối đa 36 giáo vào **kho của người đang test**, không xóa đồ đang có:

```lua
local box=TTK_TEST_CHEST:GetRewardContainer(TTK_TEST_PLAYER,true); assert(box); for i=1,36 do if box.components.container:IsFull() then break end; local item=SpawnPrefab("spear"); if not box.components.container:GiveItem(item,nil,nil,false) then if item:IsValid() then item:Remove() end; break end end
```

Sau đó chơi thắng một lượt, kiểm pending, lấy bớt giáo bằng UI và mở lại rương. Không dùng lệnh phát thưởng trực tiếp để chứng minh thắng boss.

## 7. Lưu/tải và phục hồi

Lưu ở thời điểm cần test:

```lua
c_save()
```

Đợi lưu xong, thoát world/server theo cách bình thường rồi vào lại. Sau đó chọn lại player/altar/chest theo mục 1 và 3. Không dùng rollback để đánh giá lưu/tải vì rollback chủ động quay về snapshot cũ.

- [ ] Lưu trong countdown: load về idle, không boss và không thưởng/hoàn lễ.
- [ ] Lưu trong active: boss thử luyện không persist; load về idle, không boss/minion chiến đấu tồn lại, không thưởng/hoàn lễ.
- [ ] Thắng rồi chưa mở rương: lưu/tải, vẫn nhận đúng phần thưởng đã chốt.
- [ ] Nhận một phần vì đầy rương: lưu/tải, mở lại nhận đúng remainder, không roll lại.
- [ ] Hai chủ rương: lưu/tải vẫn tách đúng hai userid.
- [ ] Lượt mới sau load: có run id mới, không bị nhầm với lượt cũ.

Test phục hồi rương bị xóa cưỡng bức: thắng một lượt hoặc để đồ trong kho riêng, giữ Tế Đàn tồn tại; ghi lại món/số lượng. Lệnh này cố ý bỏ qua khóa búa để mô phỏng rương mất:

```lua
assert(TTK_TEST_ALTAR and TTK_TEST_ALTAR:IsValid()); TTK_TEST_CHEST:Remove(); TTK_TEST_CHEST=nil
```

Xây lại rương bằng game hoặc:

```lua
local x,y,z=TTK_TEST_ALTAR.Transform:GetWorldPosition(); TTK_TEST_CHEST=SpawnPrefab("ttk_llbx"); TTK_TEST_CHEST.Transform:SetPosition(x+4,0,z)
```

- [ ] Mở rương mới phục hồi phần thưởng/đồ riêng từ altar mà không cần dâng lễ mới; không nhân đôi.
- [ ] Thử lưu/tải sau khi mất rương, trước khi xây lại; backup vẫn phục hồi.
- [ ] Không xóa cả altar giữ backup lẫn rương trong bài test này: không còn authority để giữ dữ liệu.

## 8. Kết thúc test và ghi lỗi

Hủy lượt trước khi dọn. Các lệnh chỉ đụng hai công trình đang được gán vào biến test; không xóa theo bán kính:

```lua
if TTK_TEST_ALTAR and TTK_TEST_ALTAR:IsValid() then local q=TTK_TEST_ALTAR.components.ttk_jitan_trial; if q.state~="idle" then q:Finish(q.run_id,"cancelled","manual_test") end end
if TTK_TEST_PLAYER and TTK_TEST_PLAYER:IsValid() then TTK_TEST_PLAYER.components.health:SetInvincible(false) end
```

Nếu muốn bỏ hẳn bộ test, lấy hết đồ cần giữ trước; xóa rương rồi altar sẽ bỏ cả dữ liệu backup của bộ đó:

```lua
if TTK_TEST_CHEST and TTK_TEST_CHEST:IsValid() then TTK_TEST_CHEST:Remove() end; TTK_TEST_CHEST=nil
if TTK_TEST_ALTAR and TTK_TEST_ALTAR:IsValid() then TTK_TEST_ALTAR:Remove() end; TTK_TEST_ALTAR=nil
TTK_TEST_START=nil
```

Ghi lỗi theo mẫu:

```text
Encounter ID:
Thao tác thật hay DEBUG_START:
Host/client; Master/Caves:
Mùa, vị trí đất/biển, World Rank:
Người dâng / người hoặc bóng kết liễu:
STATE / RUN / OUTCOME / REASON:
Mong đợi:
Thực tế:
Ảnh/video và đoạn client_log.txt hoặc server_log.txt có lỗi:
```

Tài liệu này được đối chiếu API với mã mod và scripts DST cài trên máy; các khối Lua được kiểm tra cú pháp. Nó là hướng dẫn playtest, không phải tuyên bố đã chơi thử toàn bộ 51 trận bằng client thật.
