-- source: https://www.rapidtables.com/web/color/RGB_Color.html
local colors = {
    maroon = {r = 128, g = 0, b = 0},
    dark_red = {r = 139, g = 0, b = 0},
    brown = {r = 165, g = 42, b = 42},
    firebrick = {r = 178, g = 34, b = 34},
    crimson = {r = 220, g = 20, b = 60},
    red = {r = 255, g = 0, b = 0},
    tomato = {r = 255, g = 99, b = 71},
    coral = {r = 255, g = 127, b = 80},
    indian_red = {r = 205, g = 92, b = 92},
    light_coral = {r = 240, g = 128, b = 128},
    dark_salmon = {r = 233, g = 150, b = 122},
    salmon = {r = 250, g = 128, b = 114},
    light_salmon = {r = 255, g = 160, b = 122},
    orange_red = {r = 255, g = 69, b = 0},
    dark_orange = {r = 255, g = 140, b = 0},
    orange = {r = 255, g = 165, b = 0},
    gold = {r = 255, g = 215, b = 0},
    dark_golden_rod = {r = 184, g = 134, b = 11},
    golden_rod = {r = 218, g = 165, b = 32},
    pale_golden_rod = {r = 238, g = 232, b = 170},
    dark_khaki = {r = 189, g = 183, b = 107},
    khaki = {r = 240, g = 230, b = 140},
    olive = {r = 128, g = 128, b = 0},
    yellow = {r = 255, g = 255, b = 0},
    yellow_green = {r = 154, g = 205, b = 50},
    dark_olive_green = {r = 85, g = 107, b = 47},
    olive_drab = {r = 107, g = 142, b = 35},
    lawn_green = {r = 124, g = 252, b = 0},
    chart_reuse = {r = 127, g = 255, b = 0},
    green_yellow = {r = 173, g = 255, b = 47},
    dark_green = {r = 0, g = 100, b = 0},
    green = {r = 0, g = 128, b = 0},
    forest_green = {r = 34, g = 139, b = 34},
    lime = {r = 0, g = 255, b = 0},
    lime_green = {r = 50, g = 205, b = 50},
    light_green = {r = 144, g = 238, b = 144},
    pale_green = {r = 152, g = 251, b = 152},
    dark_sea_green = {r = 143, g = 188, b = 143},
    medium_spring_green = {r = 0, g = 250, b = 154},
    spring_green = {r = 0, g = 255, b = 127},
    sea_green = {r = 46, g = 139, b = 87},
    medium_aqua_marine = {r = 102, g = 205, b = 170},
    medium_sea_green = {r = 60, g = 179, b = 113},
    light_sea_green = {r = 32, g = 178, b = 170},
    dark_slate_gray = {r = 47, g = 79, b = 79},
    teal = {r = 0, g = 128, b = 128},
    dark_cyan = {r = 0, g = 139, b = 139},
    aqua = {r = 0, g = 255, b = 255},
    cyan = {r = 0, g = 255, b = 255},
    light_cyan = {r = 224, g = 255, b = 255},
    dark_turquoise = {r = 0, g = 206, b = 209},
    turquoise = {r = 64, g = 224, b = 208},
    medium_turquoise = {r = 72, g = 209, b = 204},
    pale_turquoise = {r = 175, g = 238, b = 238},
    aqua_marine = {r = 127, g = 255, b = 212},
    powder_blue = {r = 176, g = 224, b = 230},
    cadet_blue = {r = 95, g = 158, b = 160},
    steel_blue = {r = 70, g = 130, b = 180},
    corn_flower_blue = {r = 100, g = 149, b = 237},
    deep_sky_blue = {r = 0, g = 191, b = 255},
    dodger_blue = {r = 30, g = 144, b = 255},
    light_blue = {r = 173, g = 216, b = 230},
    sky_blue = {r = 135, g = 206, b = 235},
    light_sky_blue = {r = 135, g = 206, b = 250},
    midnight_blue = {r = 25, g = 25, b = 112},
    navy = {r = 0, g = 0, b = 128},
    dark_blue = {r = 0, g = 0, b = 139},
    medium_blue = {r = 0, g = 0, b = 205},
    blue = {r = 0, g = 0, b = 255},
    royal_blue = {r = 65, g = 105, b = 225},
    blue_violet = {r = 138, g = 43, b = 226},
    indigo = {r = 75, g = 0, b = 130},
    dark_slate_blue = {r = 72, g = 61, b = 139},
    slate_blue = {r = 106, g = 90, b = 205},
    medium_slate_blue = {r = 123, g = 104, b = 238},
    medium_purple = {r = 147, g = 112, b = 219},
    dark_magenta = {r = 139, g = 0, b = 139},
    dark_violet = {r = 148, g = 0, b = 211},
    dark_orchid = {r = 153, g = 50, b = 204},
    medium_orchid = {r = 186, g = 85, b = 211},
    purple = {r = 128, g = 0, b = 128},
    thistle = {r = 216, g = 191, b = 216},
    plum = {r = 221, g = 160, b = 221},
    violet = {r = 238, g = 130, b = 238},
    magenta = {r = 255, g = 0, b = 255},
    fuchsia = {r = 255, g = 0, b = 255},
    orchid = {r = 218, g = 112, b = 214},
    medium_violet_red = {r = 199, g = 21, b = 133},
    pale_violet_red = {r = 219, g = 112, b = 147},
    deep_pink = {r = 255, g = 20, b = 147},
    hot_pink = {r = 255, g = 105, b = 180},
    light_pink = {r = 255, g = 182, b = 193},
    pink = {r = 255, g = 192, b = 203},
    antique_white = {r = 250, g = 235, b = 215},
    beige = {r = 245, g = 245, b = 220},
    bisque = {r = 255, g = 228, b = 196},
    blanched_almond = {r = 255, g = 235, b = 205},
    wheat = {r = 245, g = 222, b = 179},
    corn_silk = {r = 255, g = 248, b = 220},
    lemon_chiffon = {r = 255, g = 250, b = 205},
    light_golden_rod_yellow = {r = 250, g = 250, b = 210},
    light_yellow = {r = 255, g = 255, b = 224},
    saddle_brown = {r = 139, g = 69, b = 19},
    sienna = {r = 160, g = 82, b = 45},
    chocolate = {r = 210, g = 105, b = 30},
    peru = {r = 205, g = 133, b = 63},
    sandy_brown = {r = 244, g = 164, b = 96},
    burly_wood = {r = 222, g = 184, b = 135},
    tan = {r = 210, g = 180, b = 140},
    rosy_brown = {r = 188, g = 143, b = 143},
    moccasin = {r = 255, g = 228, b = 181},
    navajo_white = {r = 255, g = 222, b = 173},
    peach_puff = {r = 255, g = 218, b = 185},
    misty_rose = {r = 255, g = 228, b = 225},
    lavender_blush = {r = 255, g = 240, b = 245},
    linen = {r = 250, g = 240, b = 230},
    old_lace = {r = 253, g = 245, b = 230},
    papaya_whip = {r = 255, g = 239, b = 213},
    sea_shell = {r = 255, g = 245, b = 238},
    mint_cream = {r = 245, g = 255, b = 250},
    slate_gray = {r = 112, g = 128, b = 144},
    light_slate_gray = {r = 119, g = 136, b = 153},
    light_steel_blue = {r = 176, g = 196, b = 222},
    lavender = {r = 230, g = 230, b = 250},
    floral_white = {r = 255, g = 250, b = 240},
    alice_blue = {r = 240, g = 248, b = 255},
    ghost_white = {r = 248, g = 248, b = 255},
    honeydew = {r = 240, g = 255, b = 240},
    ivory = {r = 255, g = 255, b = 240},
    azure = {r = 240, g = 255, b = 255},
    snow = {r = 255, g = 250, b = 250},
    black = {r = 0, g = 0, b = 0},
    silver = {r = 192, g = 192, b = 192},
    dim_grey = {r = 105, g = 105, b = 105},
    dim_gray = {r = 105, g = 105, b = 105},
    grey = {r = 128, g = 128, b = 128},
    gray = {r = 128, g = 128, b = 128},
    dark_grey = {r = 169, g = 169, b = 169},
    dark_gray = {r = 169, g = 169, b = 169},
    light_grey = {r = 211, g = 211, b = 211},
    light_gray = {r = 211, g = 211, b = 211},
    gainsboro = {r = 220, g = 220, b = 220},
    white_smoke = {r = 245, g = 245, b = 245},
    white = {r = 255, g = 255, b = 255},
    wbtc = {r = 0.98, g = 0.66, b = 0.22},
    jailed = {r = 255, g = 255, b = 255},
    trusted = {r = 192, g = 192, b = 192},
    regular = {r = 0.155, g = 0.540, b = 0.898},
    admin = {r = 0.093, g = 0.768, b = 0.172},
    success = {r = 0, g = 255, b = 0},
    warning = {r = 255, g = 255, b = 0},
    fail = {r = 255, g = 51, b = 51},
    info = {r = 255, g = 255, b = 255}
}
return {
    maroon = {r = 128, g = 0, b = 0},
    dark_red = {r = 139, g = 0, b = 0},
    brown = {r = 165, g = 42, b = 42},
    firebrick = {r = 178, g = 34, b = 34},
    crimson = {r = 220, g = 20, b = 60},
    red = {r = 255, g = 0, b = 0},
    tomato = {r = 255, g = 99, b = 71},
    coral = {r = 255, g = 127, b = 80},
    indian_red = {r = 205, g = 92, b = 92},
    light_coral = {r = 240, g = 128, b = 128},
    dark_salmon = {r = 233, g = 150, b = 122},
    salmon = {r = 250, g = 128, b = 114},
    light_salmon = {r = 255, g = 160, b = 122},
    orange_red = {r = 255, g = 69, b = 0},
    dark_orange = {r = 255, g = 140, b = 0},
    orange = {r = 255, g = 165, b = 0},
    gold = {r = 255, g = 215, b = 0},
    dark_golden_rod = {r = 184, g = 134, b = 11},
    golden_rod = {r = 218, g = 165, b = 32},
    pale_golden_rod = {r = 238, g = 232, b = 170},
    dark_khaki = {r = 189, g = 183, b = 107},
    khaki = {r = 240, g = 230, b = 140},
    olive = {r = 128, g = 128, b = 0},
    yellow = {r = 255, g = 255, b = 0},
    yellow_green = {r = 154, g = 205, b = 50},
    dark_olive_green = {r = 85, g = 107, b = 47},
    olive_drab = {r = 107, g = 142, b = 35},
    lawn_green = {r = 124, g = 252, b = 0},
    chart_reuse = {r = 127, g = 255, b = 0},
    green_yellow = {r = 173, g = 255, b = 47},
    dark_green = {r = 0, g = 100, b = 0},
    green = {r = 0, g = 128, b = 0},
    forest_green = {r = 34, g = 139, b = 34},
    lime = {r = 0, g = 255, b = 0},
    lime_green = {r = 50, g = 205, b = 50},
    light_green = {r = 144, g = 238, b = 144},
    pale_green = {r = 152, g = 251, b = 152},
    dark_sea_green = {r = 143, g = 188, b = 143},
    medium_spring_green = {r = 0, g = 250, b = 154},
    spring_green = {r = 0, g = 255, b = 127},
    sea_green = {r = 46, g = 139, b = 87},
    medium_aqua_marine = {r = 102, g = 205, b = 170},
    medium_sea_green = {r = 60, g = 179, b = 113},
    light_sea_green = {r = 32, g = 178, b = 170},
    dark_slate_gray = {r = 47, g = 79, b = 79},
    teal = {r = 0, g = 128, b = 128},
    dark_cyan = {r = 0, g = 139, b = 139},
    aqua = {r = 0, g = 255, b = 255},
    cyan = {r = 0, g = 255, b = 255},
    light_cyan = {r = 224, g = 255, b = 255},
    dark_turquoise = {r = 0, g = 206, b = 209},
    turquoise = {r = 64, g = 224, b = 208},
    medium_turquoise = {r = 72, g = 209, b = 204},
    pale_turquoise = {r = 175, g = 238, b = 238},
    aqua_marine = {r = 127, g = 255, b = 212},
    powder_blue = {r = 176, g = 224, b = 230},
    cadet_blue = {r = 95, g = 158, b = 160},
    steel_blue = {r = 70, g = 130, b = 180},
    corn_flower_blue = {r = 100, g = 149, b = 237},
    deep_sky_blue = {r = 0, g = 191, b = 255},
    dodger_blue = {r = 30, g = 144, b = 255},
    light_blue = {r = 173, g = 216, b = 230},
    sky_blue = {r = 135, g = 206, b = 235},
    light_sky_blue = {r = 135, g = 206, b = 250},
    midnight_blue = {r = 25, g = 25, b = 112},
    navy = {r = 0, g = 0, b = 128},
    dark_blue = {r = 0, g = 0, b = 139},
    medium_blue = {r = 0, g = 0, b = 205},
    blue = {r = 0, g = 0, b = 255},
    royal_blue = {r = 65, g = 105, b = 225},
    blue_violet = {r = 138, g = 43, b = 226},
    indigo = {r = 75, g = 0, b = 130},
    dark_slate_blue = {r = 72, g = 61, b = 139},
    slate_blue = {r = 106, g = 90, b = 205},
    medium_slate_blue = {r = 123, g = 104, b = 238},
    medium_purple = {r = 147, g = 112, b = 219},
    dark_magenta = {r = 139, g = 0, b = 139},
    dark_violet = {r = 148, g = 0, b = 211},
    dark_orchid = {r = 153, g = 50, b = 204},
    medium_orchid = {r = 186, g = 85, b = 211},
    purple = {r = 128, g = 0, b = 128},
    thistle = {r = 216, g = 191, b = 216},
    plum = {r = 221, g = 160, b = 221},
    violet = {r = 238, g = 130, b = 238},
    magenta = {r = 255, g = 0, b = 255},
    fuchsia = {r = 255, g = 0, b = 255},
    orchid = {r = 218, g = 112, b = 214},
    medium_violet_red = {r = 199, g = 21, b = 133},
    pale_violet_red = {r = 219, g = 112, b = 147},
    deep_pink = {r = 255, g = 20, b = 147},
    hot_pink = {r = 255, g = 105, b = 180},
    light_pink = {r = 255, g = 182, b = 193},
    pink = {r = 255, g = 192, b = 203},
    antique_white = {r = 250, g = 235, b = 215},
    beige = {r = 245, g = 245, b = 220},
    bisque = {r = 255, g = 228, b = 196},
    blanched_almond = {r = 255, g = 235, b = 205},
    wheat = {r = 245, g = 222, b = 179},
    corn_silk = {r = 255, g = 248, b = 220},
    lemon_chiffon = {r = 255, g = 250, b = 205},
    light_golden_rod_yellow = {r = 250, g = 250, b = 210},
    light_yellow = {r = 255, g = 255, b = 224},
    saddle_brown = {r = 139, g = 69, b = 19},
    sienna = {r = 160, g = 82, b = 45},
    chocolate = {r = 210, g = 105, b = 30},
    peru = {r = 205, g = 133, b = 63},
    sandy_brown = {r = 244, g = 164, b = 96},
    burly_wood = {r = 222, g = 184, b = 135},
    tan = {r = 210, g = 180, b = 140},
    rosy_brown = {r = 188, g = 143, b = 143},
    moccasin = {r = 255, g = 228, b = 181},
    navajo_white = {r = 255, g = 222, b = 173},
    peach_puff = {r = 255, g = 218, b = 185},
    misty_rose = {r = 255, g = 228, b = 225},
    lavender_blush = {r = 255, g = 240, b = 245},
    linen = {r = 250, g = 240, b = 230},
    old_lace = {r = 253, g = 245, b = 230},
    papaya_whip = {r = 255, g = 239, b = 213},
    sea_shell = {r = 255, g = 245, b = 238},
    mint_cream = {r = 245, g = 255, b = 250},
    slate_gray = {r = 112, g = 128, b = 144},
    light_slate_gray = {r = 119, g = 136, b = 153},
    light_steel_blue = {r = 176, g = 196, b = 222},
    lavender = {r = 230, g = 230, b = 250},
    floral_white = {r = 255, g = 250, b = 240},
    alice_blue = {r = 240, g = 248, b = 255},
    ghost_white = {r = 248, g = 248, b = 255},
    honeydew = {r = 240, g = 255, b = 240},
    ivory = {r = 255, g = 255, b = 240},
    azure = {r = 240, g = 255, b = 255},
    snow = {r = 255, g = 250, b = 250},
    black = {r = 0, g = 0, b = 0},
    silver = {r = 192, g = 192, b = 192},
    dim_grey = {r = 105, g = 105, b = 105},
    dim_gray = {r = 105, g = 105, b = 105},
    grey = {r = 128, g = 128, b = 128},
    gray = {r = 128, g = 128, b = 128},
    dark_grey = {r = 169, g = 169, b = 169},
    dark_gray = {r = 169, g = 169, b = 169},
    light_grey = {r = 211, g = 211, b = 211},
    light_gray = {r = 211, g = 211, b = 211},
    gainsboro = {r = 220, g = 220, b = 220},
    white_smoke = {r = 245, g = 245, b = 245},
    white = {r = 255, g = 255, b = 255},
    wbtc = {r = 0.98, g = 0.66, b = 0.22},
    jailed = {r = 255, g = 255, b = 255},
    trusted = {r = 192, g = 192, b = 192},
    regular = {r = 0.155, g = 0.540, b = 0.898},
    admin = {r = 0.093, g = 0.768, b = 0.172},
    success = {r = 0, g = 255, b = 0},
    warning = {r = 255, g = 255, b = 0},
    fail = {r = 255, g = 51, b = 51},
    info = {r = 255, g = 255, b = 255},
    text = {
        bold = function(message)
            local msg = "[font=default-bold]" .. message .. "[/font]"
            return msg
        end,
        default = function(message)
            local msg = "[color=default]" .. message .. "[/color]"
            return msg
        end,
        acid = function(message)
            local msg = "[color=acid]" .. message .. "[/color]"
            return msg
        end,
        maroon = function(message)
            local msg = "[color=" .. colors.maroon.r .. ", " .. colors.maroon.g .. ", " .. colors.maroon.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_red = function(message)
            local msg = "[color=" .. colors.dark_red.r .. ", " .. colors.dark_red.g .. ", " .. colors.dark_red.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        brown = function(message)
            local msg = "[color=" .. colors.brown.r .. ", " .. colors.brown.g .. ", " .. colors.brown.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        firebrick = function(message)
            local msg = "[color=" .. colors.firebrick.r .. ", " .. colors.firebrick.g .. ", " .. colors.firebrick.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        crimson = function(message)
            local msg = "[color=" .. colors.crimson.r .. ", " .. colors.crimson.g .. ", " .. colors.crimson.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        red = function(message)
            local msg = "[color=" .. colors.red.r .. ", " .. colors.red.g .. ", " .. colors.red.b .. "]" .. message .. "[/color]"
            return msg
        end,
        tomato = function(message)
            local msg = "[color=" .. colors.tomato.r .. ", " .. colors.tomato.g .. ", " .. colors.tomato.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        coral = function(message)
            local msg = "[color=" .. colors.coral.r .. ", " .. colors.coral.g .. ", " .. colors.coral.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        indian_red = function(message)
            local msg = "[color=" .. colors.indian_red.r .. ", " .. colors.indian_red.g .. ", " .. colors.indian_red.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_coral = function(message)
            local msg = "[color=" .. colors.light_coral.r .. ", " .. colors.light_coral.g .. ", " .. colors.light_coral.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_salmon = function(message)
            local msg = "[color=" .. colors.dark_salmon.r .. ", " .. colors.dark_salmon.g .. ", " .. colors.dark_salmon.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        salmon = function(message)
            local msg = "[color=" .. colors.salmon.r .. ", " .. colors.salmon.g .. ", " .. colors.salmon.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_salmon = function(message)
            local msg = "[color=" .. colors.light_salmon.r .. ", " .. colors.light_salmon.g .. ", " .. colors.light_salmon.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        orange_red = function(message)
            local msg = "[color=" .. colors.orange_red.r .. ", " .. colors.orange_red.g .. ", " .. colors.orange_red.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_orange = function(message)
            local msg = "[color=" .. colors.dark_orange.r .. ", " .. colors.dark_orange.g .. ", " .. colors.dark_orange.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        orange = function(message)
            local msg = "[color=" .. colors.orange.r .. ", " .. colors.orange.g .. ", " .. colors.orange.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        gold = function(message)
            local msg = "[color=" .. colors.gold.r .. ", " .. colors.gold.g .. ", " .. colors.gold.b .. "]" .. message .. "[/color]"
            return msg
        end,
        dark_golden_rod = function(message)
            local msg = "[color=" .. colors.dark_golden_rod.r .. ", " .. colors.dark_golden_rod.g .. ", " .. colors.dark_golden_rod.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        golden_rod = function(message)
            local msg = "[color=" .. colors.golden_rod.r .. ", " .. colors.golden_rod.g .. ", " .. colors.golden_rod.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        pale_golden_rod = function(message)
            local msg = "[color=" .. colors.pale_golden_rod.r .. ", " .. colors.pale_golden_rod.g .. ", " .. colors.pale_golden_rod.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_khaki = function(message)
            local msg = "[color=" .. colors.dark_khaki.r .. ", " .. colors.dark_khaki.g .. ", " .. colors.dark_khaki.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        khaki = function(message)
            local msg = "[color=" .. colors.khaki.r .. ", " .. colors.khaki.g .. ", " .. colors.khaki.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        olive = function(message)
            local msg = "[color=" .. colors.olive.r .. ", " .. colors.olive.g .. ", " .. colors.olive.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        yellow = function(message)
            local msg = "[color=" .. colors.yellow.r .. ", " .. colors.yellow.g .. ", " .. colors.yellow.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        yellow_green = function(message)
            local msg = "[color=" .. colors.yellow_green.r .. ", " .. colors.yellow_green.g .. ", " .. colors.yellow_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_olive_green = function(message)
            local msg = "[color=" .. colors.dark_olive_green.r .. ", " .. colors.dark_olive_green.g .. ", " .. colors.dark_olive_green.b .. "]" .. message .. "[/color]"
            return msg
        end,
        olive_drab = function(message)
            local msg = "[color=" .. colors.olive_drab.r .. ", " .. colors.olive_drab.g .. ", " .. colors.olive_drab.b .. "]" .. message .. "[/color]"
            return msg
        end,
        lawn_green = function(message)
            local msg = "[color=" .. colors.lawn_green.r .. ", " .. colors.lawn_green.g .. ", " .. colors.lawn_green.b .. "]" .. message .. "[/color]"
            return msg
        end,
        chart_reuse = function(message)
            local msg = "[color=" .. colors.chart_reuse.r .. ", " .. colors.chart_reuse.g .. ", " .. colors.chart_reuse.b .. "]" .. message .. "[/color]"
            return msg
        end,
        green_yellow = function(message)
            local msg = "[color=" .. colors.green_yellow.r .. ", " .. colors.green_yellow.g .. ", " .. colors.green_yellow.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_green = function(message)
            local msg = "[color=" .. colors.dark_green.r .. ", " .. colors.dark_green.g .. ", " .. colors.dark_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        green = function(message)
            local msg = "[color=" .. colors.green.r .. ", " .. colors.green.g .. ", " .. colors.green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        forest_green = function(message)
            local msg = "[color=" .. colors.forest_green.r .. ", " .. colors.forest_green.g .. ", " .. colors.forest_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        lime = function(message)
            local msg = "[color=" .. colors.lime.r .. ", " .. colors.lime.g .. ", " .. colors.lime.b .. "]" .. message .. "[/color]"
            return msg
        end,
        lime_green = function(message)
            local msg = "[color=" .. colors.lime_green.r .. ", " .. colors.lime_green.g .. ", " .. colors.lime_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_green = function(message)
            local msg = "[color=" .. colors.light_green.r .. ", " .. colors.light_green.g .. ", " .. colors.light_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        pale_green = function(message)
            local msg = "[color=" .. colors.pale_green.r .. ", " .. colors.pale_green.g .. ", " .. colors.pale_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_sea_green = function(message)
            local msg = "[color=" .. colors.dark_sea_green.r .. ", " .. colors.dark_sea_green.g .. ", " .. colors.dark_sea_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_spring_green = function(message)
            local msg = "[color=" .. colors.medium_spring_green.r .. ", " .. colors.medium_spring_green.g .. ", " .. colors.medium_spring_green.b .. "]" ..
message .. "[/color]"
            return msg
        end,
        spring_green = function(message)
            local msg = "[color=" .. colors.spring_green.r .. ", " .. colors.spring_green.g .. ", " .. colors.spring_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        sea_green = function(message)
            local msg = "[color=" .. colors.sea_green.r .. ", " .. colors.sea_green.g .. ", " .. colors.sea_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_aqua_marine = function(message)
            local msg =
                "[color=" .. colors.medium_aqua_marine.r .. ", " .. colors.medium_aqua_marine.g .. ", " .. colors.medium_aqua_marine.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        medium_sea_green = function(message)
            local msg =
                "[color=" .. colors.medium_sea_green.r .. ", " .. colors.medium_sea_green.g .. ", " .. colors.medium_sea_green.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        light_sea_green = function(message)
            local msg = "[color=" .. colors.light_sea_green.r .. ", " .. colors.light_sea_green.g .. ", " .. colors.light_sea_green.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_slate_gray = function(message)
            local msg = "[color=" .. colors.dark_slate_gray.r .. ", " .. colors.dark_slate_gray.g .. ", " .. colors.dark_slate_gray.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        teal = function(message)
            local msg = "[color=" .. colors.teal.r .. ", " .. colors.teal.g .. ", " .. colors.teal.b .. "]" .. message .. "[/color]"
            return msg
        end,
        dark_cyan = function(message)
            local msg = "[color=" .. colors.dark_cyan.r .. ", " .. colors.dark_cyan.g .. ", " .. colors.dark_cyan.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        aqua = function(message)
            local msg = "[color=" .. colors.aqua.r .. ", " .. colors.aqua.g .. ", " .. colors.aqua.b .. "]" .. message .. "[/color]"
            return msg
        end,
        cyan = function(message)
            local msg = "[color=" .. colors.cyan.r .. ", " .. colors.cyan.g .. ", " .. colors.cyan.b .. "]" .. message .. "[/color]"
            return msg
        end,
        light_cyan = function(message)
            local msg = "[color=" .. colors.light_cyan.r .. ", " .. colors.light_cyan.g .. ", " .. colors.light_cyan.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_turquoise = function(message)
            local msg = "[color=" .. colors.dark_turquoise.r .. ", " .. colors.dark_turquoise.g .. ", " .. colors.dark_turquoise.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        turquoise = function(message)
            local msg = "[color=" .. colors.turquoise.r .. ", " .. colors.turquoise.g .. ", " .. colors.turquoise.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_turquoise = function(message)
            local msg =
                "[color=" .. colors.medium_turquoise.r .. ", " .. colors.medium_turquoise.g .. ", " .. colors.medium_turquoise.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        pale_turquoise = function(message)
            local msg = "[color=" .. colors.pale_turquoise.r .. ", " .. colors.pale_turquoise.g .. ", " .. colors.pale_turquoise.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        aqua_marine = function(message)
            local msg = "[color=" .. colors.aqua_marine.r .. ", " .. colors.aqua_marine.g .. ", " .. colors.aqua_marine.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        powder_blue = function(message)
            local msg = "[color=" .. colors.powder_blue.r .. ", " .. colors.powder_blue.g .. ", " .. colors.powder_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        cadet_blue = function(message)
            local msg = "[color=" .. colors.cadet_blue.r .. ", " .. colors.cadet_blue.g .. ", " .. colors.cadet_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        steel_blue = function(message)
            local msg = "[color=" .. colors.steel_blue.r .. ", " .. colors.steel_blue.g .. ", " .. colors.steel_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        corn_flower_blue = function(message)
            local msg =
                "[color=" .. colors.corn_flower_blue.r .. ", " .. colors.corn_flower_blue.g .. ", " .. colors.corn_flower_blue.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        deep_sky_blue = function(message)
            local msg = "[color=" .. colors.deep_sky_blue.r .. ", " .. colors.deep_sky_blue.g .. ", " .. colors.deep_sky_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dodger_blue = function(message)
            local msg = "[color=" .. colors.dodger_blue.r .. ", " .. colors.dodger_blue.g .. ", " .. colors.dodger_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_blue = function(message)
            local msg = "[color=" .. colors.light_blue.r .. ", " .. colors.light_blue.g .. ", " .. colors.light_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        sky_blue = function(message)
            local msg = "[color=" .. colors.sky_blue.r .. ", " .. colors.sky_blue.g .. ", " .. colors.sky_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_sky_blue = function(message)
            local msg = "[color=" .. colors.light_sky_blue.r .. ", " .. colors.light_sky_blue.g .. ", " .. colors.light_sky_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        midnight_blue = function(message)
            local msg = "[color=" .. colors.midnight_blue.r .. ", " .. colors.midnight_blue.g .. ", " .. colors.midnight_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        navy = function(message)
            local msg = "[color=" .. colors.navy.r .. ", " .. colors.navy.g .. ", " .. colors.navy.b .. "]" .. message .. "[/color]"
            return msg
        end,
        dark_blue = function(message)
            local msg = "[color=" .. colors.dark_blue.r .. ", " .. colors.dark_blue.g .. ", " .. colors.dark_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_blue = function(message)
            local msg = "[color=" .. colors.medium_blue.r .. ", " .. colors.medium_blue.g .. ", " .. colors.medium_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        blue = function(message)
            local msg = "[color=" .. colors.blue.r .. ", " .. colors.blue.g .. ", " .. colors.blue.b .. "]" .. message .. "[/color]"
            return msg
        end,
        royal_blue = function(message)
            local msg = "[color=" .. colors.royal_blue.r .. ", " .. colors.royal_blue.g .. ", " .. colors.royal_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        blue_violet = function(message)
            local msg = "[color=" .. colors.blue_violet.r .. ", " .. colors.blue_violet.g .. ", " .. colors.blue_violet.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        indigo = function(message)
            local msg = "[color=" .. colors.indigo.r .. ", " .. colors.indigo.g .. ", " .. colors.indigo.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_slate_blue = function(message)
            local msg = "[color=" .. colors.dark_slate_blue.r .. ", " .. colors.dark_slate_blue.g .. ", " .. colors.dark_slate_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        slate_blue = function(message)
            local msg = "[color=" .. colors.slate_blue.r .. ", " .. colors.slate_blue.g .. ", " .. colors.slate_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_slate_blue = function(message)
            local msg =
                "[color=" .. colors.medium_slate_blue.r .. ", " .. colors.medium_slate_blue.g .. ", " .. colors.medium_slate_blue.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        medium_purple = function(message)
            local msg = "[color=" .. colors.medium_purple.r .. ", " .. colors.medium_purple.g .. ", " .. colors.medium_purple.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_magenta = function(message)
            local msg = "[color=" .. colors.dark_magenta.r .. ", " .. colors.dark_magenta.g .. ", " .. colors.dark_magenta.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_violet = function(message)
            local msg = "[color=" .. colors.dark_violet.r .. ", " .. colors.dark_violet.g .. ", " .. colors.dark_violet.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_orchid = function(message)
            local msg = "[color=" .. colors.dark_orchid.r .. ", " .. colors.dark_orchid.g .. ", " .. colors.dark_orchid.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_orchid = function(message)
            local msg = "[color=" .. colors.medium_orchid.r .. ", " .. colors.medium_orchid.g .. ", " .. colors.medium_orchid.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        purple = function(message)
            local msg = "[color=" .. colors.purple.r .. ", " .. colors.purple.g .. ", " .. colors.purple.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        thistle = function(message)
            local msg = "[color=" .. colors.thistle.r .. ", " .. colors.thistle.g .. ", " .. colors.thistle.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        plum = function(message)
            local msg = "[color=" .. colors.plum.r .. ", " .. colors.plum.g .. ", " .. colors.plum.b .. "]" .. message .. "[/color]"
            return msg
        end,
        violet = function(message)
            local msg = "[color=" .. colors.violet.r .. ", " .. colors.violet.g .. ", " .. colors.violet.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        magenta = function(message)
            local msg = "[color=" .. colors.magenta.r .. ", " .. colors.magenta.g .. ", " .. colors.magenta.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        fuchsia = function(message)
            local msg = "[color=" .. colors.fuchsia.r .. ", " .. colors.fuchsia.g .. ", " .. colors.fuchsia.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        orchid = function(message)
            local msg = "[color=" .. colors.orchid.r .. ", " .. colors.orchid.g .. ", " .. colors.orchid.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        medium_violet_red = function(message)
            local msg =
                "[color=" .. colors.medium_violet_red.r .. ", " .. colors.medium_violet_red.g .. ", " .. colors.medium_violet_red.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        pale_violet_red = function(message)
            local msg = "[color=" .. colors.pale_violet_red.r .. ", " .. colors.pale_violet_red.g .. ", " .. colors.pale_violet_red.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        deep_pink = function(message)
            local msg = "[color=" .. colors.deep_pink.r .. ", " .. colors.deep_pink.g .. ", " .. colors.deep_pink.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        hot_pink = function(message)
            local msg = "[color=" .. colors.hot_pink.r .. ", " .. colors.hot_pink.g .. ", " .. colors.hot_pink.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_pink = function(message)
            local msg = "[color=" .. colors.light_pink.r .. ", " .. colors.light_pink.g .. ", " .. colors.light_pink.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        pink = function(message)
            local msg = "[color=" .. colors.pink.r .. ", " .. colors.pink.g .. ", " .. colors.pink.b .. "]" .. message .. "[/color]"
            return msg
        end,
        antique_white = function(message)
            local msg = "[color=" .. colors.antique_white.r .. ", " .. colors.antique_white.g .. ", " .. colors.antique_white.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        beige = function(message)
            local msg = "[color=" .. colors.beige.r .. ", " .. colors.beige.g .. ", " .. colors.beige.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        bisque = function(message)
            local msg = "[color=" .. colors.bisque.r .. ", " .. colors.bisque.g .. ", " .. colors.bisque.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        blanched_almond = function(message)
            local msg = "[color=" .. colors.blanched_almond.r .. ", " .. colors.blanched_almond.g .. ", " .. colors.blanched_almond.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        wheat = function(message)
            local msg = "[color=" .. colors.wheat.r .. ", " .. colors.wheat.g .. ", " .. colors.wheat.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        corn_silk = function(message)
            local msg = "[color=" .. colors.corn_silk.r .. ", " .. colors.corn_silk.g .. ", " .. colors.corn_silk.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        lemon_chiffon = function(message)
            local msg = "[color=" .. colors.lemon_chiffon.r .. ", " .. colors.lemon_chiffon.g .. ", " .. colors.lemon_chiffon.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_golden_rod_yellow = function(message)
            local msg = "[color=" .. colors.light_golden_rod_yellow.r .. ", " .. colors.light_golden_rod_yellow.g .. ", " .. colors.light_golden_rod_yellow.b .. "]" ..
message .. "[/color]"
            return msg
        end,
        light_yellow = function(message)
            local msg = "[color=" .. colors.light_yellow.r .. ", " .. colors.light_yellow.g .. ", " .. colors.light_yellow.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        saddle_brown = function(message)
            local msg = "[color=" .. colors.saddle_brown.r .. ", " .. colors.saddle_brown.g .. ", " .. colors.saddle_brown.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        sienna = function(message)
            local msg = "[color=" .. colors.sienna.r .. ", " .. colors.sienna.g .. ", " .. colors.sienna.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        chocolate = function(message)
            local msg = "[color=" .. colors.chocolate.r .. ", " .. colors.chocolate.g .. ", " .. colors.chocolate.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        peru = function(message)
            local msg = "[color=" .. colors.peru.r .. ", " .. colors.peru.g .. ", " .. colors.peru.b .. "]" .. message .. "[/color]"
            return msg
        end,
        sandy_brown = function(message)
            local msg = "[color=" .. colors.sandy_brown.r .. ", " .. colors.sandy_brown.g .. ", " .. colors.sandy_brown.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        burly_wood = function(message)
            local msg = "[color=" .. colors.burly_wood.r .. ", " .. colors.burly_wood.g .. ", " .. colors.burly_wood.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        tan = function(message)
            local msg = "[color=" .. colors.tan.r .. ", " .. colors.tan.g .. ", " .. colors.tan.b .. "]" .. message .. "[/color]"
            return msg
        end,
        rosy_brown = function(message)
            local msg = "[color=" .. colors.rosy_brown.r .. ", " .. colors.rosy_brown.g .. ", " .. colors.rosy_brown.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        moccasin = function(message)
            local msg = "[color=" .. colors.moccasin.r .. ", " .. colors.moccasin.g .. ", " .. colors.moccasin.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        navajo_white = function(message)
            local msg = "[color=" .. colors.navajo_white.r .. ", " .. colors.navajo_white.g .. ", " .. colors.navajo_white.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        peach_puff = function(message)
            local msg = "[color=" .. colors.peach_puff.r .. ", " .. colors.peach_puff.g .. ", " .. colors.peach_puff.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        misty_rose = function(message)
            local msg = "[color=" .. colors.misty_rose.r .. ", " .. colors.misty_rose.g .. ", " .. colors.misty_rose.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        lavender_blush = function(message)
            local msg = "[color=" .. colors.lavender_blush.r .. ", " .. colors.lavender_blush.g .. ", " .. colors.lavender_blush.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        linen = function(message)
            local msg = "[color=" .. colors.linen.r .. ", " .. colors.linen.g .. ", " .. colors.linen.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        old_lace = function(message)
            local msg = "[color=" .. colors.old_lace.r .. ", " .. colors.old_lace.g .. ", " .. colors.old_lace.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        papaya_whip = function(message)
            local msg = "[color=" .. colors.papaya_whip.r .. ", " .. colors.papaya_whip.g .. ", " .. colors.papaya_whip.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        sea_shell = function(message)
            local msg = "[color=" .. colors.sea_shell.r .. ", " .. colors.sea_shell.g .. ", " .. colors.sea_shell.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        mint_cream = function(message)
            local msg = "[color=" .. colors.mint_cream.r .. ", " .. colors.mint_cream.g .. ", " .. colors.mint_cream.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        slate_gray = function(message)
            local msg = "[color=" .. colors.slate_gray.r .. ", " .. colors.slate_gray.g .. ", " .. colors.slate_gray.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_slate_gray = function(message)
            local msg =
                "[color=" .. colors.light_slate_gray.r .. ", " .. colors.light_slate_gray.g .. ", " .. colors.light_slate_gray.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        light_steel_blue = function(message)
            local msg =
                "[color=" .. colors.light_steel_blue.r .. ", " .. colors.light_steel_blue.g .. ", " .. colors.light_steel_blue.b .. "]" .. message ..
                    "[/color]"
            return msg
        end,
        lavender = function(message)
            local msg = "[color=" .. colors.lavender.r .. ", " .. colors.lavender.g .. ", " .. colors.lavender.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        floral_white = function(message)
            local msg = "[color=" .. colors.floral_white.r .. ", " .. colors.floral_white.g .. ", " .. colors.floral_white.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        alice_blue = function(message)
            local msg = "[color=" .. colors.alice_blue.r .. ", " .. colors.alice_blue.g .. ", " .. colors.alice_blue.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        ghost_white = function(message)
            local msg = "[color=" .. colors.ghost_white.r .. ", " .. colors.ghost_white.g .. ", " .. colors.ghost_white.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        honeydew = function(message)
            local msg = "[color=" .. colors.honeydew.r .. ", " .. colors.honeydew.g .. ", " .. colors.honeydew.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        ivory = function(message)
            local msg = "[color=" .. colors.ivory.r .. ", " .. colors.ivory.g .. ", " .. colors.ivory.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        azure = function(message)
            local msg = "[color=" .. colors.azure.r .. ", " .. colors.azure.g .. ", " .. colors.azure.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        snow = function(message)
            local msg = "[color=" .. colors.snow.r .. ", " .. colors.snow.g .. ", " .. colors.snow.b .. "]" .. message .. "[/color]"
            return msg
        end,
        black = function(message)
            local msg = "[color=" .. colors.black.r .. ", " .. colors.black.g .. ", " .. colors.black.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        silver = function(message)
            local msg = "[color=" .. colors.silver.r .. ", " .. colors.silver.g .. ", " .. colors.silver.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dim_grey = function(message)
            local msg = "[color=" .. colors.dim_grey.r .. ", " .. colors.dim_grey.g .. ", " .. colors.dim_grey.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dim_gray = function(message)
            local msg = "[color=" .. colors.dim_gray.r .. ", " .. colors.dim_gray.g .. ", " .. colors.dim_gray.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        grey = function(message)
            local msg = "[color=" .. colors.grey.r .. ", " .. colors.grey.g .. ", " .. colors.grey.b .. "]" .. message .. "[/color]"
            return msg
        end,
        gray = function(message)
            local msg = "[color=" .. colors.gray.r .. ", " .. colors.gray.g .. ", " .. colors.gray.b .. "]" .. message .. "[/color]"
            return msg
        end,
        dark_grey = function(message)
            local msg = "[color=" .. colors.dark_grey.r .. ", " .. colors.dark_grey.g .. ", " .. colors.dark_grey.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        dark_gray = function(message)
            local msg = "[color=" .. colors.dark_gray.r .. ", " .. colors.dark_gray.g .. ", " .. colors.dark_gray.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_grey = function(message)
            local msg = "[color=" .. colors.light_grey.r .. ", " .. colors.light_grey.g .. ", " .. colors.light_grey.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        light_gray = function(message)
            local msg = "[color=" .. colors.light_gray.r .. ", " .. colors.light_gray.g .. ", " .. colors.light_gray.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        gainsboro = function(message)
            local msg = "[color=" .. colors.gainsboro.r .. ", " .. colors.gainsboro.g .. ", " .. colors.gainsboro.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        white_smoke = function(message)
            local msg = "[color=" .. colors.white_smoke.r .. ", " .. colors.white_smoke.g .. ", " .. colors.white_smoke.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        white = function(message)
            local msg = "[color=" .. colors.white.r .. ", " .. colors.white.g .. ", " .. colors.white.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        wbtc = function(message)
            local msg = "[color=" .. colors.wbtc.r .. ", " .. colors.wbtc.g .. ", " .. colors.wbtc.b .. "]" .. message .. "[/color]"
            return msg
        end,
        jailed = function(message)
            local msg = "[color=" .. colors.jailed.r .. ", " .. colors.jailed.g .. ", " .. colors.jailed.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        trusted = function(message)
            local msg = "[color=" .. colors.trusted.r .. ", " .. colors.trusted.g .. ", " .. colors.trusted.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        regular = function(message)
            local msg = "[color=" .. colors.regular.r .. ", " .. colors.regular.g .. ", " .. colors.regular.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        admin = function(message)
            local msg = "[color=" .. colors.admin.r .. ", " .. colors.admin.g .. ", " .. colors.admin.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        success = function(message)
            local msg = "[color=" .. colors.success.r .. ", " .. colors.success.g .. ", " .. colors.success.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        warning = function(message)
            local msg = "[color=" .. colors.warning.r .. ", " .. colors.warning.g .. ", " .. colors.warning.b .. "]" .. message ..
"[/color]"
            return msg
        end,
        fail = function(message)
            local msg = "[color=" .. colors.fail.r .. ", " .. colors.fail.g .. ", " .. colors.fail.b .. "]" .. message .. "[/color]"
            return msg
        end,
        info = function(message)
            local msg = "[color=" .. colors.info.r .. ", " .. colors.info.g .. ", " .. colors.info.b .. "]" .. message .. "[/color]"
            return msg
        end
    }
}