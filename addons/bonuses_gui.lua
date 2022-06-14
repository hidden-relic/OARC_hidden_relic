require("lib/oarc_utils")
require("lib/oarc_gui_utils")

function CreateBonusesGuiTab(tab_container, player)
    local player = player
    local tab_container = tab_container
    if global.oarc_bonuses == nil then global.oarc_bonuses = {} end

    global.oarc_bonuses[player.name] = getPlayerBonuses(player)
    local stats = global.ocore.markets.player_markets[player.name].stats

    local bonuses_flow = tab_container.add {
        type = "flow",
        direction = "horizontal"
    }
    local playtime_bonuses = bonuses_flow.add {
        type = "flow",
        direction = "vertical"
    }
    local stats_flow = bonuses_flow.add {type = "flow", direction = "vertical"}

    AddLabel(playtime_bonuses, "bonuses_info", "Playtime Bonuses:",
             my_longer_label_style)

    local bonustext = ""
    local bonuses = global.oarc_bonuses[player.name]
    for n, stat in pairs(bonuses["speed"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(playtime_bonuses, label_name, bonustext, my_speed_label_style)
    end
    AddSpacerLine(playtime_bonuses)
    for n, stat in pairs(bonuses["reach"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(playtime_bonuses, label_name, bonustext, my_reach_label_style)
    end
    AddSpacerLine(playtime_bonuses)
    for n, stat in pairs(bonuses["inv"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(playtime_bonuses, label_name, bonustext, my_inv_label_style)
    end
    AddSpacerLine(playtime_bonuses)
    for n, stat in pairs(bonuses["robot"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(playtime_bonuses, label_name, bonustext, my_robot_label_style)
    end

    AddLabel(stats_flow, "stats_info", "Market stats:", my_longer_label_style)

    local stat_text = ""
    local label_name_parent = "gun-speed_info"
    AddLabel(stats_flow, label_name_parent, "[gun speed]", my_robot_label_style)
    for name, stats in pairs(stats["gun-speed"]) do
        local label_name_child = label_name_parent .. name .. "_info"
        stat_text = name .. "\t::\t[LVL]: " .. stats.lvl .. "\t[BONUS]: " ..
                        stats.multiplier*100 .. "%"
        AddLabel(stats_flow, label_name_child, stat_text, my_speed_label_style)
    end
    AddSpacerLine(stats_flow)
    stat_text = ""
    label_name_parent = "ammo-damage_info"
    AddLabel(stats_flow, label_name_parent, "[ammo damage]",
             my_robot_label_style)
    for name, stats in pairs(stats["ammo-damage"]) do
        local label_name_child = label_name_parent .. name .. "_info"
        stat_text = name .. "\t::\t[LVL]: " .. stats.lvl .. "\t[BONUS]: " ..
                        stats.multiplier*100 .. "%"
        AddLabel(stats_flow, label_name_child, stat_text, my_reach_label_style)
    end
    AddSpacerLine(stats_flow)
    stat_text = ""
    label_name_parent = "turret-attack_info"
    AddLabel(stats_flow, label_name_parent, "[turret attack]",
             my_robot_label_style)
    for name, stats in pairs(stats["turret-attack"]) do
        local label_name_child = label_name_parent .. name .. "_info"
        stat_text = name .. "\t::\t[LVL]: " .. stats.lvl .. "\t[BONUS]: " ..
                        stats.multiplier*100 .. "%"
        AddLabel(stats_flow, label_name_child, stat_text, my_inv_label_style)
    end
    AddSpacerLine(stats_flow)
    stat_text = ""
    label_name_parent = "character-health_info"
    AddLabel(stats_flow, label_name_parent, "[character health]",
             my_robot_label_style)
    local label_name_child = label_name_parent .. "character-health_info"
    stat_text = "character-health\t::\t[LVL]: " ..
                    stats["character-health"].current.lvl .. "\t[BONUS]: +" ..
                    stats["character-health"].current.multiplier
    AddLabel(stats_flow, label_name_child, stat_text, my_longer_label_style)
    AddSpacerLine(stats_flow)
    stat_text = ""
    label_name_parent = "mining-productivity_info"
    AddLabel(stats_flow, label_name_parent, "[mining productivity]",
             my_robot_label_style)
    local label_name_child = label_name_parent .. "mining-productivity_info"
    stat_text = "mining-productivity\t::\t[LVL]: " ..
                    stats["mining-productivity"].current.lvl .. "\t[BONUS]: " ..
                    stats["mining-productivity"].current.multiplier*100 .. "%"
    AddLabel(stats_flow, label_name_child, stat_text, my_longer_label_style)
    AddSpacerLine(stats_flow)
    stat_text = ""
    label_name_parent = "sell-speed_info"
    AddLabel(stats_flow, label_name_parent, "[sell speed]", my_robot_label_style)
    local label_name_child = label_name_parent .. "sell-speed_info"
    stat_text = "sell-speed\t::\t[LVL]: " .. stats["sell-speed"].current.lvl ..
                    "\t[SECONDS]: " .. stats["sell-speed"].current.multiplier
    AddLabel(stats_flow, label_name_child, stat_text, my_longer_label_style)
end
