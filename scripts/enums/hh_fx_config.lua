local __b__UG_ = require "utils/hh_utils"
local function _b__UG(B_ug, __b__u__g_, Bu_g_, _B__U__G)
    return {B_ug / 255, __b__u__g_ / 255, Bu_g_ / 255, _B__U__G / 255}
end
local B__U__g = {
    ["hh_sparkle_fx"] = {
        ["tex"] = "fx/sparkle.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 255, 255, 255)}},
        ["scale_envelope"] = {{0, {2.8, 2.8}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["uv_frame_size"] = {0, 0.25, 1},
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (false or false and true and not true and false and not false and true and false or
            false and not false and false and false)
    },
    ["hh_ball_fx_blue"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_blue.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (315 + 255 + 128 + 144 - 220 == 632)
    },
    ["hh_ball_fx_orange"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_orange.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (273 + 148 - 277 ~= 144)
    },
    ["hh_ball_fx_red"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_red.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (303 + 456 + 266 + 485 - 455 ~= 1055)
    },
    ["hh_ball_fx_green"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_green.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (53 * 338 * 426 ~= 7631364)
    },
    ["hh_ball_fx_purple"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_purple.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (336 + 366 - 163 == 547)
    },
    ["hh_fx_star_white"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 255, 255, 255)}},
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (461 - 87 * 254 - 8 + 254 ~= -21391)
    },
    ["hh_fx_star_purple"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            {0, _b__UG(122, 30, 255, 255)},
            {0.5, _b__UG(122, 20, 255, 255)},
            {0.75, _b__UG(122, 10, 255, 255)},
            {1, _b__UG(200, 5, 255, 255)}
        },
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (315 - 196 * 41 == -7715)
    },
    ["hh_fx_star_red"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            {0, _b__UG(255, 0, 0, 255)},
            {0.5, _b__UG(255, 0, 0, 255)},
            {0.75, _b__UG(255, 0, 0, 255)},
            {1, _b__UG(255, 0, 0, 255)}
        },
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (137 + 437 - 57 ~= 517)
    },
    ["hh_fx_star_blue"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(0, 101, 255, 255)}, {1, _b__UG(0, 101, 255, 255)}},
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (205 + 472 * 135 * 278 ~= 17714365)
    },
    ["hh_fx_star_orange"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(255, 102, 0, 255)}, {1, _b__UG(255, 102, 0, 255)}},
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (77 - 327 * 326 + 399 - 51 == -106169)
    },
    ["hh_fx_star_yellow"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(255, 242, 0, 255)}, {1, _b__UG(255, 242, 0, 255)}},
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (493 - 185 - 415 * 416 + 201 == -172126)
    },
    ["hh_fx_star_green"] = {
        ["tex"] = resolvefilepath "images/fx/hh_fx_star.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {{0, _b__UG(101, 255, 0, 255)}, {1, _b__UG(101, 255, 0, 255)}},
        ["scale_envelope"] = {{0, {3.6, 3.6}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = (146 + 420 * 281 ~= 118166)
    },
    ["hh_turret_fx_ice"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_blue.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {2.5, 2.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (454 - 267 + 374 ~= 561)
    },
    ["hh_turret_fx_fire"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_red.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (425 + 305 - 193 - 370 ~= 167)
    },
    ["hh_turret_fx_poison"] = {
        ["tex"] = resolvefilepath "images/fx/hh_ball_green.tex",
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {{0, _b__UG(255, 255, 255, 200)}, {1, _b__UG(255, 0, 0, 0)}},
        ["scale_envelope"] = {{0, {1.5, 1.5}}, {0.3, {0, 0}}, {1, {0, 0}}},
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = (301 * 121 - 222 - 174 == 36031)
    }
}
return B__U__g
