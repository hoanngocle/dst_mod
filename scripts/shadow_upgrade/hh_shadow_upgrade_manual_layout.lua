-- Shadow Legion upgrade screen manual layout overrides.
-- Chỉ cần sửa các giá trị x/y/width/height/font/size/icon trong file này.
-- Không cần sửa logic màn hình.
--
-- Ví dụ:
--   hh_igris_shadow = {
--       profile = {
--           name = { x = -300, y = 180, size = 40 },
--       },
--       talent_rows = {
--           [1] = {
--               row = { x = 250, y = 165 },
--               icon = {
--                   atlas = "images/my_skill_icons.xml",
--                   tex = "my_skill_01.tex",
--                   x = -140,
--                   y = 0,
--                   size = 60,
--                   scale = 1.0,
--               },
--               level = { x = -100, y = 20, font = NUMBERFONT, size = 18 },
--               name = { x = -20, y = 20, font = UIFONT, size = 20 },
--               status = { x = -20, y = -20, font = UIFONT, size = 16 },
--               desc = { x = 150, y = 0, width = 330, height = 62, size = 16 },
--           },
--       },
--   }

local MANUAL_LAYOUT = {
    -- Chỉ chỉnh các số x, y, width, height, size và scale.
    -- Mỗi tab có layout riêng, không ảnh hưởng các tab khác.
    hh_igris_shadow = {
        profile = {
            name = { x = -250, y = 170, width = 440, height = 44, font = TITLEFONT, size = 38 },
            role = { x = -250, y = -70, width = 430, height = 60, font = UIFONT, size = 25 },
            level = { x = -300, y = -95, width = 430, height = 34, font = UIFONT, size = 25 },
            exp = { x = -300, y = -120, width = 430, height = 30, font = UIFONT, size = 25 },
            progress = { x = -300, y = -145, width = 430, height = 32, font = UIFONT, size = 25 },
            stats = { x = -295, y = -185, width = 440, height = 120, font = UIFONT, size = 25 },
        },
        talent_rows = {
            [1] = {
                row = { x = 235, y = 165 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_thep_den.tex", x = -240, y = -15, size = 52, scale = 0.1 },
                level = { x = -170, y = -5, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = -5, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = -29, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = -3, width = 315, height = 62, font = UIFONT, size = 23 },
            },
            [2] = {
                row = { x = 235, y = 87 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_khieu_khich.tex", x = -240, y = 3, size = 52, scale = 0.1 },
                level = { x = -170, y = 12, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = 12, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = -10, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = 2, width = 315, height = 62, font = UIFONT, size = 23 },
            },
            [3] = {
                row = { x = 235, y = 9 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_kiem_thuat.tex", x = -240, y = 22, size = 52, scale = 0.1 },
                level = { x = -170, y = 30, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = 30, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = 10, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = 33, width = 315, height = 62, font = UIFONT, size = 23 },
            },
            [4] = {
                row = { x = 235, y = -69 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_ho_chu.tex", x = -240, y = 41, size = 52, scale = 0.1 },
                level = { x = -170, y = 49, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = 49, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = 28, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = 40, width = 315, height = 62, font = UIFONT, size = 23 },
            },
            [5] = {
                row = { x = 235, y = -147 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_bat_khuat.tex", x = -240, y = 58, size = 52, scale = 0.1 },
                level = { x = -170, y = 66, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = 66, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = 45, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = 58, width = 315, height = 62, font = UIFONT, size = 23 },
            },
            [6] = {
                row = { x = 235, y = -225 },
                icon = { atlas = "images/de_tu_skill_icon/hh_igris_skill_icon.xml", tex = "hh_igris_loi_the_ky_si.tex", x = -240, y = 76, size = 52, scale = 0.1 },
                level = { x = -170, y = 84, width = 70, height = 24, font = NUMBERFONT, size = 25 },
                name = { x = -75, y = 84, width = 170, height = 28, font = UIFONT, size = 32 },
                status = { x = -100, y = 63, width = 170, height = 24, font = UIFONT, size = 20 },
                desc = { x = 145, y = 76, width = 315, height = 62, font = UIFONT, size = 23 },
            },
        },
    },

    hh_beru_shadow = {
        profile = {
            name = { x = -250, y = 170, width = 440, height = 44, font = TITLEFONT, size = 38 },
            role = { x = -250, y = -70, width = 430, height = 60, font = UIFONT, size = 25 },
            level = { x = -300, y = -95, width = 430, height = 34, font = UIFONT, size = 25 },
            exp = { x = -300, y = -120, width = 430, height = 30, font = UIFONT, size = 25 },
            progress = { x = -300, y = -145, width = 430, height = 32, font = UIFONT, size = 25 },
            stats = { x = -295, y = -185, width = 440, height = 120, font = UIFONT, size = 25 },
        },
        talent_rows = {
            [1] = { row = { x = 235, y = 165 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_ke_san_moi.tex", x = -240, y = -15, size = 52, scale = 0.1 }, level = { x = -170, y = -5, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = -5, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -29, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = -15, width = 315, height = 62, font = UIFONT, size = 23 } },
            [2] = { row = { x = 235, y = 87 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_hap_thu.tex", x = -240, y = 3, size = 52, scale = 0.1 }, level = { x = -170, y = 12, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 12, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 13, width = 315, height = 62, font = UIFONT, size = 23 } },
            [3] = { row = { x = 235, y = 9 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_khong_kich.tex", x = -240, y = 22, size = 52, scale = 0.1 }, level = { x = -170, y = 30, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 30, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 33, width = 315, height = 62, font = UIFONT, size = 23 } },
            [4] = { row = { x = 235, y = -69 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_doc_an_mon.tex", x = -240, y = 41, size = 52, scale = 0.1 }, level = { x = -170, y = 49, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 49, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 28, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 40, width = 315, height = 62, font = UIFONT, size = 23 } },
            [5] = { row = { x = 235, y = -147 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_hanh_quyet.tex", x = -240, y = 58, size = 52, scale = 0.1 }, level = { x = -170, y = 66, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 66, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 45, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 58, width = 315, height = 62, font = UIFONT, size = 23 } },
            [6] = { row = { x = 235, y = -225 }, icon = { atlas = "images/de_tu_skill_icon/hh_beru_skill_icon.xml", tex = "hh_beru_vua_kien.tex", x = -240, y = 76, size = 52, scale = 0.1 }, level = { x = -170, y = 84, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 84, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 63, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 87, width = 315, height = 62, font = UIFONT, size = 23 } },
        },
    },

    hh_fruitfly_shadow = {
        profile = {
            name = { x = -250, y = 170, width = 440, height = 44, font = TITLEFONT, size = 38 },
            role = { x = -250, y = -70, width = 430, height = 60, font = UIFONT, size = 25 },
            level = { x = -300, y = -95, width = 430, height = 34, font = UIFONT, size = 25 },
            exp = { x = -300, y = -120, width = 430, height = 30, font = UIFONT, size = 25 },
            progress = { x = -300, y = -145, width = 430, height = 32, font = UIFONT, size = 25 },
            stats = { x = -295, y = -185, width = 440, height = 120, font = UIFONT, size = 25 },
        },
        talent_rows = {
            [1] = { row = { x = 235, y = 165 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_canh_tac.tex", x = -240, y = -15, size = 52, scale = 0.1 }, level = { x = -170, y = -5, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = -5, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -29, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = -4, width = 315, height = 62, font = UIFONT, size = 23 } },
            [2] = { row = { x = 235, y = 87 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_doi_canh.tex", x = -240, y = 3, size = 52, scale = 0.1 }, level = { x = -170, y = 12, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 12, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 13, width = 315, height = 62, font = UIFONT, size = 23 } },
            [3] = { row = { x = 235, y = 9 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_mat_tay.tex", x = -240, y = 22, size = 52, scale = 0.1 }, level = { x = -170, y = 30, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 30, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 33, width = 315, height = 62, font = UIFONT, size = 23 } },
            [4] = { row = { x = 235, y = -69 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_ben_bi.tex", x = -240, y = 41, size = 52, scale = 0.1 }, level = { x = -170, y = 49, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 49, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 28, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 51, width = 315, height = 62, font = UIFONT, size = 23 } },
            [5] = { row = { x = 235, y = -147 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_tiet_kiem.tex", x = -240, y = 58, size = 52, scale = 0.1 }, level = { x = -170, y = 66, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 66, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 45, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 69, width = 315, height = 62, font = UIFONT, size = 23 } },
            [6] = { row = { x = 235, y = -225 }, icon = { atlas = "images/de_tu_skill_icon/hh_fruitfly_skill_icon.xml", tex = "hh_fruitfly_ngu_vien.tex", x = -240, y = 76, size = 52, scale = 0.1 }, level = { x = -170, y = 84, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 84, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 63, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 87, width = 315, height = 62, font = UIFONT, size = 23 } },
        },
    },

    hh_macanh_shadow = {
        profile = {
            name = { x = -250, y = 170, width = 440, height = 44, font = TITLEFONT, size = 38 },
            role = { x = -250, y = -70, width = 430, height = 60, font = UIFONT, size = 25 },
            level = { x = -300, y = -95, width = 430, height = 34, font = UIFONT, size = 25 },
            exp = { x = -300, y = -120, width = 430, height = 30, font = UIFONT, size = 25 },
            progress = { x = -300, y = -145, width = 430, height = 32, font = UIFONT, size = 25 },
            stats = { x = -295, y = -185, width = 440, height = 120, font = UIFONT, size = 25 },
        },
        talent_rows = {
            [1] = { row = { x = 235, y = 165 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_chay_nhanh.tex", x = -240, y = -15, size = 52, scale = 0.1 }, level = { x = -170, y = -5, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = -5, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -29, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = -4, width = 315, height = 62, font = UIFONT, size = 23 } },
            [2] = { row = { x = 235, y = 87 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_thanh_thao.tex", x = -240, y = 3, size = 52, scale = 0.1 }, level = { x = -170, y = 12, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 12, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 13, width = 315, height = 62, font = UIFONT, size = 23 } },
            [3] = { row = { x = 235, y = 9 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_thu_gom.tex", x = -240, y = 22, size = 52, scale = 0.1 }, level = { x = -170, y = 30, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 30, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 33, width = 315, height = 62, font = UIFONT, size = 23 } },
            [4] = { row = { x = 235, y = -69 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_hieu_qua.tex", x = -240, y = 41, size = 52, scale = 0.1 }, level = { x = -170, y = 49, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 49, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 28, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 51, width = 315, height = 62, font = UIFONT, size = 23 } },
            [5] = { row = { x = 235, y = -147 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_tiet_kiem.tex", x = -240, y = 58, size = 52, scale = 0.1 }, level = { x = -170, y = 66, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 66, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 45, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 69, width = 315, height = 62, font = UIFONT, size = 23 } },
            [6] = { row = { x = 235, y = -225 }, icon = { atlas = "images/de_tu_skill_icon/hh_macanh_skill_icon.xml", tex = "hh_macanh_giao_nop.tex", x = -240, y = 76, size = 52, scale = 0.1 }, level = { x = -170, y = 84, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 84, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 63, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 77, width = 315, height = 62, font = UIFONT, size = 23 } },
        },
    },

    hh_hacanh_shadow = {
        profile = {
            name = { x = -250, y = 170, width = 440, height = 44, font = TITLEFONT, size = 38 },
            role = { x = -250, y = -70, width = 430, height = 60, font = UIFONT, size = 25 },
            level = { x = -300, y = -95, width = 430, height = 34, font = UIFONT, size = 25 },
            exp = { x = -300, y = -120, width = 430, height = 30, font = UIFONT, size = 25 },
            progress = { x = -300, y = -145, width = 430, height = 32, font = UIFONT, size = 25 },
            stats = { x = -295, y = -185, width = 440, height = 120, font = UIFONT, size = 25 },
        },
        talent_rows = {
            [1] = { row = { x = 235, y = 165 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_bo_phap.tex", x = -240, y = -15, size = 52, scale = 0.1 }, level = { x = -170, y = -5, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = -5, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -29, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = -4, width = 315, height = 62, font = UIFONT, size = 23 } },
            [2] = { row = { x = 235, y = 87 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_tiet_kiem.tex", x = -240, y = 3, size = 52, scale = 0.1 }, level = { x = -170, y = 12, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 12, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = -10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 13, width = 315, height = 62, font = UIFONT, size = 23 } },
            [3] = { row = { x = 235, y = 9 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_tram_anh.tex", x = -240, y = 22, size = 52, scale = 0.1 }, level = { x = -170, y = 30, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 30, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 10, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 33, width = 315, height = 62, font = UIFONT, size = 23 } },
            [4] = { row = { x = 235, y = -69 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_ne_bong.tex", x = -240, y = 41, size = 52, scale = 0.1 }, level = { x = -170, y = 49, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 49, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 28, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 51, width = 315, height = 62, font = UIFONT, size = 23 } },
            [5] = { row = { x = 235, y = -147 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_ho_ve.tex", x = -240, y = 58, size = 52, scale = 0.1 }, level = { x = -170, y = 66, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 66, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 45, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 69, width = 315, height = 62, font = UIFONT, size = 23 } },
            [6] = { row = { x = 235, y = -225 }, icon = { atlas = "images/de_tu_skill_icon/hh_hacanh_skill_icon.xml", tex = "hh_hacanh_tho_san_dem.tex", x = -240, y = 76, size = 52, scale = 0.1 }, level = { x = -170, y = 84, width = 70, height = 24, font = NUMBERFONT, size = 25 }, name = { x = -75, y = 84, width = 170, height = 28, font = UIFONT, size = 32 }, status = { x = -100, y = 63, width = 170, height = 24, font = UIFONT, size = 20 }, desc = { x = 145, y = 87, width = 315, height = 62, font = UIFONT, size = 23 } },
        },
    },

    hud = {
        title = { x = 0, y = 300, width = 900, height = 58, font = TITLEFONT, size = 48 },
        close = { x = 541, y = 287, width = 89, height = 38, font = UIFONT, size = 20 },
        tabs = {
            hh_igris_shadow = { x = -390, y = 236, width = 210, height = 48, font = UIFONT, size = 30 },
            hh_beru_shadow = { x = -200, y = 236, width = 210, height = 48, font = UIFONT, size = 30 },
            hh_fruitfly_shadow = { x = 0, y = 236, width = 210, height = 48, font = UIFONT, size = 30 },
            hh_macanh_shadow = { x = 200, y = 236, width = 210, height = 48, font = UIFONT, size = 30 },
            hh_hacanh_shadow = { x = 390, y = 236, width = 210, height = 48, font = UIFONT, size = 30 },
        },
    },
}

return MANUAL_LAYOUT
