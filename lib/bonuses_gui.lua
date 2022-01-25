require("lib/oarc_utils")
require("lib/oarc_gui_utils")

function CreateBonusesGuiTab(tab_container, player)

    if global.oarc_bonuses == nil then global.oarc_bonuses = {} end

        global.oarc_bonuses[player.name] = getPlayerBonuses(player)

    AddLabel(tab_container, "bonuses_info", "Bonuses:", my_longer_label_style)

    local bonustext = ""
    local bonuses = global.oarc_bonuses[player.name]
    for n, stat in pairs(bonuses["speed"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(tab_container, label_name, bonustext, my_speed_label_style)
    end
    AddSpacerLine(tab_container)
    for n, stat in pairs(bonuses["reach"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(tab_container, label_name, bonustext, my_reach_label_style)
    end
    AddSpacerLine(tab_container)
    for n, stat in pairs(bonuses["inv"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(tab_container, label_name, bonustext, my_inv_label_style)
    end
    AddSpacerLine(tab_container)
    for n, stat in pairs(bonuses["robot"]) do
        local label_name = n .. "_info"
        bonustext = n .. "\t::\t+" .. stat
        AddLabel(tab_container, label_name, bonustext, my_robot_label_style)
    end
end
