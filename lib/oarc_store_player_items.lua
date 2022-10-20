-- oarc_store_player_items.lua
-- May 2020
-- Adding microtransactions.
local mod_gui = require("mod-gui")
local market = require("addons/market")
local tools = require("addons/tools")
local group = require("addons/groups")

OARC_STORE_PLAYER_ITEMS = {
    ["Followers"] = {
        ["small-biter"] = {cost = 1000, count = 1},
        ["medium-biter"] = {cost = 2500, count = 1},
        ["big-biter"] = {cost = 5000, count = 1},
        ["behemoth-biter"] = {cost = 10000, count = 1}
    }
}

function CreatePlayerStoreTab(tab_container, player)

    local player_inv = player.get_main_inventory()
    if (player_inv == nil) then return end

    local wallet = global.markets[player.name].balance
    AddLabel(tab_container, "player_store_wallet_lbl",
             "Coins Available: " .. tools.add_commas(wallet) .. "  [item=coin]",
             {top_margin = 5, bottom_margin = 5})

    local line = tab_container.add {type = "line", direction = "horizontal"}
    line.style.top_margin = 5
    line.style.bottom_margin = 5

    for category, section in pairs(OARC_STORE_PLAYER_ITEMS) do
        local flow = tab_container.add {
            name = category,
            type = "flow",
            direction = "horizontal"
        }
        for item_name, item in pairs(section) do
            local color = "[color=green]"
            if (item.cost > wallet) then color = "[color=red]" end
            local btn = {}
            btn = flow.add {
                name = item_name,
                type = "sprite-button",
                number = item.count,
                sprite = "entity/" .. item_name,
                tooltip = item_name .. " Cost: " .. color .. item.cost ..
                    "[/color] [item=coin]",
                style = mod_gui.button_style
            }
            group.get_count(player)
            if global.groups[player.name] and global.groups[player.name].total <
                global.groups[player.name].limit then
                btn.enabled = true
            else
                btn.enabled = false
            end
        end

        local line2 = tab_container.add {
            type = "line",
            direction = "horizontal"
        }
        line2.style.top_margin = 5
        line2.style.bottom_margin = 5
    end
end

function OarcPlayerStoreButton(event)
    local button = event.element
    local player = game.players[event.player_index]

    local player_inv = player.get_inventory(defines.inventory.character_main)
    if (player_inv == nil) then return end

    local wallet = global.markets[player.name].balance
    local category = button.parent.name

    local item = OARC_STORE_PLAYER_ITEMS[category][button.name]

    if (wallet >= item.cost) then
        if category == "Followers" then
            group.add(player, button.name)
            market.withdraw(player, item.cost)
            return
        end
        player_inv.insert({name = button.name, count = item.count})
        market.withdraw(player, item.cost)

        if (button.parent and button.parent.parent and
            button.parent.parent.player_store_wallet_lbl) then
            button.parent.parent.player_store_wallet_lbl.caption =
                "Coins Available: " .. wallet .. "  [item=coin]"
        end

    else
        player.print("You're broke! Go kill some enemies or beg for change...")
    end
end
