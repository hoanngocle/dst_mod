# Phàm Nhân Tu Tiên 2.0 — achievement perk runtime audit

Task 10 implements the available gameplay adapters, but **does not complete all 39 approved perks**. The catalog, prices, seven 25-level caps, 945-Star maximum and all 50 inheritance source IDs remain intact. Missing upstream content is not replaced by a similarly named weapon or empty unlock.

The exported availability is **29 implemented, 5 partial, 5 unavailable**. This describes current source coverage; it is not a live multiplayer certification.

## Implemented integration

- Seven stats use one idempotent provider. Crit/lifesteal contributions are separate from the existing `hh_player` effect table; planar bonuses use native named sources; scale uses `AnimState` only. Kill EXP multiplies the rank, dungeon, level, sharing and perk factors before one final rounding. The dungeon multiplier clamp is removed. Daily reward and seasonal EXP tuning are unchanged.
- Twelve abilities have scoped adapters: fast pick/build, instant eligible mining/chopping, immediate pond-fishing bite, instant successful stewing, Warly cookware access, doubled healing, successful pick yield, eligible dead-monster loot, native ingredient discount, protected cages and enhanced fertilizer.
- Mining/chopping preserve native recoil/tool eligibility. Healing preserves other efficient-user modifiers. Pick callbacks and kill victims are deduplicated. Loading/reapplying does not add listeners twice.
- Cage protection applies after the perk owner successfully builds or stores a bird in that cage, and persists on that cage. It does not change `PERISH_CAGE_MULT` globally.
- Easy Farm adds one additional native fertilizer nutrient dose to the exact successfully fertilized farm-soil tile. Native nutrient caps remain. This improves later nutrient-stress checks instead of changing all farms' growth rules globally.
- Eleven original craft packages register native technology-family aliases and retained source ingredient costs. Christmas/Pokeball structure recipes have 13 native-art placers. Existing open recipes remain open. Perk aliases use the catalog's EVA-only tags and refresh crafting immediately.
- Native recipes requiring a character skill (`builder_skill`) are excluded from every alias-cloning path. For example, Walter's `slingshotammo_moonglass` and `slingshot_frame_gems` cannot be granted to EVA by a lunar technology unlock. Purchase preflight also rejects skill-gated aliases.
- Four inheritance packages register eight exact source recipe names producing their audited current equivalents (table below). Their remaining source entries are not registered.

## Safe inheritance mappings

| Source recipe | Current product |
|---|---|
| `xd_luoshen_huazhong` | `ttk_luoshen_huazhong` |
| `xd_yunxiao_fysz` | `thanhiquangtruong` |
| `xd_yunxiao_ymsz` | `ttk_yunxiao_ymsz` |
| `xd_yunxiao_portable_spicer` | `ttk_yunxiao_portable_spicer` |
| `xd_sj_kls` | `ttk_sj_kls` |
| `xd_sudaji_redlantern` | `ttk_ngulongdang` |
| `xd_sudaji_ywfh` | `nhatvuphuonghoa` |
| `xd_qwsk` | `ttk_qwsk` |

## Unavailable content

Purchasing `trinket_owner` fails without the missing `trinketowner` component. Purchasing `icy_weed` fails without `chasni_icyweed`. No Star is spent on these failed applications. The catalog entries are retained.

Antique Shop currently supplies the native `trinket_1..NUM_TRINKETS` recipes. Its 21 source-specific products are absent: `trinket_chasni_3`, `4`, `5`, `7`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `15`, `16`, `17`, `18a`, `18b`, `19`, `20`, `21`, `23`, `24` (all with the same `trinket_chasni_` prefix). Those prefab/assets and equipment-effect dependencies need a separate port; this package is partial.

The 42 unavailable inheritance recipes are:

- Lạc Thần (9): `fence_gate_luoshen_item`, `xd_luoshen_jihuaze`, `xd_luoshen_jiangren`, `xd_luoshen_liuguanghuafen`, `xd_luoshen_yin`, `xd_luoshen_huaxia`, `fence_luoshen_item`, `wall_luoshen_item`, `xd_luoshen_dinghunxianglu`.
- Tam Tiêu (4): `xd_yunxiao_hyjditem`, `xd_yunxiao_fgfq`, `xd_yunxiao_fls`, `xd_yunxiao_hyjdyqd`.
- Thạch Cơ (7): `xd_sj_bglxp`, `xd_sj_bgygp`, `xd_sj_by_builder`, `xd_sj_tlsq`, `xd_sj_cy_builder`, `xd_sj_sxz`, `xd_sj_xsydz`.
- Tinh Vệ (7): `xd_xuanyu`, `xd_jingwei_blowdart`, `xd_jingwei_fenice_builder`, `xd_jingwei_fan`, `xd_jingwei_hat`, `turf_jingweitile`, `xd_qianyu`.
- Tô Đát Kỷ (2): `xd_sudaji_sjpn`, `xd_sudaji_tsmd`.
- Hàn Thiên Tôn (3): `xd_htz_xyzzl`, `xd_htz_sjcx`, `xd_htz_tlz`.
- Vương Ma Tử (10): `xd_wmz_kjb`, `xd_wmz_slxj`, `xd_wmz_md1..8`.

Tinh Vệ, Hàn Thiên Tôn and Vương Ma Tử therefore reject purchase completely. Wang Mazi's eight forms have no registered EVA-safe prefab/component implementation; related art and existing weapons are not proof of compatible source spell state. The runtime exposes `UnavailableInheritance()` for this exact dependency list.

## Verification limits

`no_deconstruction` on an alias is recipe metadata, not a guarantee on the spawned product. DST's green staff reads `AllRecipes[target.prefab]`, so a product with an existing native recipe retains that native recipe's deconstruction behavior. Native product recipes have not been modified globally, and no anti-arbitrage safeguard is claimed. Ingredient discounts still use DST's positive-ingredient minimum of one; that minimum does not prove deconstruction-loop safety.

The Task 18 acceptance audit runs Python 3.14 with Lupa Lua 5.1, executes shipped achievement components/adapters and selected installed DST `scripts.zip` components, and maps all 40 active tracker types to executed producer scenarios and client rejection tests. Task 19 resolved the historical alchemy ingredient defect through explicit generation-time renames and approved repeatable boss-core substitutions. All 26 recipes now pass real Lua exact matching, reject their historical-input forms, and resolve every emitted ingredient to a loaded mod factory or native DST provider. Stage 15 uses the two registered first-grade buffs. These checks do not establish live acquisition timing or combat balance.

The focused achievement/alchemy/cultivation/rank/seasonal suites, strengthening and slot regressions pass. The canonical wiki export includes the corrected achievement rows and all 26 repaired alchemy recipes. Seasonal claim XP intentionally remains unavailable until external calibration supplies a finite positive value; the missing perk source dependencies listed above remain explicit. Broad mod discovery still has ten pre-existing standalone-argument/missing-extraction-fixture import errors; Lupa and Vitest are available. No live DST host/client, multiplayer or dedicated-server session was run. Native recipe asset rendering and server/client synchronization remain unverified.
