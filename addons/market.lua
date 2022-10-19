local gui = require("mod-gui")
local tools = require("addons.tools")
local prodscore = require('production-score')
local flib_table = require('flib.table')
local group = require("addons.groups")

local M = {}

-- function M:new(o)
--     o = o or {}             -- this sets o to itself (if arg o is passed in) if not, create empty table called o
--     setmetatable(o, self)   -- set o's metatable to M's metatable
--     self.__index = self     -- sets passed in var's lookup to M
--     return o                -- return o
-- end

function M.init()
    local markets = {}
    local pre_item_values = prodscore.generate_price_list()
    local nil_items = {
        ["electric-energy-interface"] = true,
        ["rocket-part"] = true,
        ["discharge-defense-equipment"] = true,
        ["discharge-defense-remote"] = true
    }
    markets.item_values = {}
    for name, value in pairs(pre_item_values) do
        if not nil_items[name] and game.item_prototypes[name] then
            markets.item_values[name] = tools.round(value)
        end
    end
    return markets
end

M.upgrade_cost_table = {
    ["sell-speed"] = 2,
    ["ammo-damage"] = 0.2,
    ["turret-attack"] = 0.2,
    ["gun-speed"] = 0.2,
    ["mining-drill-productivity-bonus"] = 0.2,
    ["maximum-following-robot-count"] = 0.2,
    ["group-limit"] = 0.25
}

M.upgrade_func_table = {
    ["sell-speed"] = function(player) return end,
    ["ammo-damage"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        for _, effect in pairs(upgrades["ammo-damage"].t) do
            player.force.set_ammo_damage_modifier(effect.ammo_category,
                                                  player.force
                                                      .get_ammo_damage_modifier(
                                                      effect.ammo_category) +
                                                      effect.modifier)
        end
    end,
    ["turret-attack"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        for _, effect in pairs(upgrades["turret-attack"].t) do
            player.force.set_turret_attack_modifier(effect.turret_id,
                                                    player.force
                                                        .get_turret_attack_modifier(
                                                        effect.turret_id) +
                                                        effect.modifier)
        end
    end,
    ["gun-speed"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        for _, effect in pairs(upgrades["gun-speed"].t) do
            player.force.set_gun_speed_modifier(effect.ammo_category,
                                                player.force
                                                    .get_gun_speed_modifier(
                                                    effect.ammo_category) +
                                                    effect.modifier)
        end
    end,
    ["mining-drill-productivity-bonus"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        for _, effect in pairs(upgrades["mining-drill-productivity-bonus"].t) do
            player.force.mining_drill_productivity_bonus = player.force
                                                               .mining_drill_productivity_bonus +
                                                               effect.modifier
        end
    end,
    ["maximum-following-robot-count"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        for _, effect in pairs(upgrades["maximum-following-robot-count"].t) do
            player.force.maximum_following_robot_count = player.force
                                                             .maximum_following_robot_count +
                                                             effect.modifier
        end
    end,
    ["group-limit"] = function(player)
        local upgrades = global.markets[player.name].upgrades
        local player_group = global.groups[player.name]
        player_group.limit = player_group.limit + 1
    end
}

function M.increase(player, upgrade)
    local name = upgrade
    local upgrade = global.markets[player.name].upgrades[upgrade]
    if upgrade.lvl < upgrade.max_lvl then
        upgrade.lvl = upgrade.lvl + 1
        local current_cost = upgrade.cost
        upgrade.cost = upgrade.cost +
                           (upgrade.cost * M.upgrade_cost_table[name])
        M.withdraw(player, current_cost)
        local up_func = M.upgrade_func_table[name]
        up_func(player)
    else
        return
    end
end

function M.new(player)
    local player = player
    global.markets[player.name] = {
        player = player,
        balance = 0,
        stats = {
            total_coin_earned = 0,
            total_coin_spent = 0,
            items_purchased = {},
            item_most_purchased_total = "",
            item_most_purchased_coin = "",
            items_sold = {},
            item_most_sold_total = "",
            item_most_sold_coin = "",
            history = {}
        }
    }
    local market = global.markets[player.name]
    market.upgrades = {
        ["sell-speed"] = {
            name = "Sell Speed",
            lvl = 1,
            max_lvl = 10,
            cost = 10000,
            sprite = "utility/character_running_speed_modifier_constant",
            t = {5, 4.8, 4.5, 4.1, 3.6, 3, 2.4, 1.7, 0.6, 0.25},
            tooltip = "Shorten the time it takes to sell an item"
        },

        ["ammo-damage"] = {
            name = "Ammo Damage",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/physical-projectile-damage-7",
            t = {
                {type = "ammo-damage", ammo_category = "bullet", modifier = 0.1},
                {type = "ammo-damage", ammo_category = "rocket", modifier = 0.1},
                {
                    type = "ammo-damage",
                    ammo_category = "flamethrower",
                    modifier = 0.1
                },
                {type = "ammo-damage", ammo_category = "laser", modifier = 0.1}
            },
            tooltip = "+10% Damage [img=item/firearm-magazine] [img=item/piercing-rounds-magazine] [img=item/uranium-rounds-magazine] [img=item/rocket] [img=item/explosive-rocket] [img=item/flamethrower-ammo] [img=item/flamethrower-turret] [img=item/laser-turret] [img=item/personal-laser-defense-equipment]"
        },

        ["turret-attack"] = {
            name = "Turret Attack",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/energy-weapons-damage-4",
            t = {
                {
                    type = "turret-attack",
                    turret_id = "gun-turret",
                    modifier = 0.1
                },
                {
                    type = "turret-attack",
                    turret_id = "flamethrower-turret",
                    modifier = 0.1
                },
                {
                    type = "turret-attack",
                    turret_id = "laser-turret",
                    modifier = 0.1
                }
            },
            tooltip = "+10% Turret Attack [img=item/gun-turret] [img=item/flamethrower-turret] [img=item/laser-turret]"
        },

        ["gun-speed"] = {
            name = "Gun Speed",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/weapon-shooting-speed-4",
            t = {
                {type = "gun-speed", ammo_category = "bullet", modifier = 0.1},
                {type = "gun-speed", ammo_category = "rocket", modifier = 0.1},
                {type = "gun-speed", ammo_category = "laser", modifier = 0.1}
            },
            tooltip = "+10% Speed [img=item/firearm-magazine] [img=item/piercing-rounds-magazine] [img=item/uranium-rounds-magazine] [img=item/rocket] [img=item/explosive-rocket] [img=item/laser-turret] [img=item/personal-laser-defense-equipment]"
        },

        ["mining-drill-productivity-bonus"] = {
            name = "Mining Drill Productivity",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/mining-productivity-1",
            t = {{type = "mining-drill-productivity-bonus", modifier = 0.1}},
            tooltip = "+10% Productivity [img=technology/mining-productivity-1]"
        },

        ["maximum-following-robot-count"] = {
            name = "Follower Robot Count",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/follower-robot-count-1",
            t = {{type = "maximum-following-robots-count", modifier = 5}},
            tooltip = "+5 Robots [img=entity/distractor] [img=entity/destroyer] [img=entity/defender]"
        },

        ["group-limit"] = {
            name = "Pet Limit",
            lvl = 1,
            max_lvl = 50,
            cost = 10000,
            sprite = "entity/small-biter",
            t = {},
            tooltip = "+1 Pet [img=entity/small-biter] [img=entity/medium-biter] [img=entity/big-biter] [img=entity/behemoth-biter]"
        }
    }
    M.create_market_button(player)
    M.create_stats_button(player)
    M.create_market_gui(player)
    M.create_stats_gui(player)
end

function M.deposit(player, v)
    local player = player
    local market = global.markets[player.name]
    market.balance = market.balance + v
    market.stats.total_coin_earned = market.stats.total_coin_earned + v
    M.update(player)
end

function M.withdraw(player, v)
    local player = player
    local market = global.markets[player.name]
    if v > market.balance then
        player.print("Insufficient Funds")
    else
        market.balance = market.balance - v
        market.stats.total_coin_spent = market.stats.total_coin_spent + v
        M.update(player)
    end
end

function M.purchase(player, item, click, shift, ctrl)
    local player = player
    local market = global.markets[player.name]
    local item = item
    local value = global.markets.item_values[item]
    local i = nil
    if click == 2 then
        if not shift and not ctrl then
            i = 1
        elseif shift and ctrl then
            i = 1
        elseif shift and not ctrl then
            i = 100
        elseif ctrl and not shift then
            i = 1000
        end
    end
    if click == 4 then
        if not shift and not ctrl then
            i = 10
        elseif shift and ctrl then
            i = 10
        elseif shift and not ctrl then
            i = 50
        elseif ctrl and not shift then
            i = 500
        end
    end
    if i then
        if math.floor(market.balance / value) < i then
            player.print("You don't have the coin to buy " .. i)
            return
        end
        local insertable = player.get_main_inventory()
                               .get_insertable_count(item)
        if insertable == 0 then
            player.print("You don't have the inventory space")
            return
        end
        local inserted = 0
        if i <= insertable then
            inserted = i
        else
            inserted = insertable
        end
        M.withdraw(player, value * inserted)
        player.insert {name = item, count = inserted}
        if not market.stats.items_purchased[item] then
            market.stats.items_purchased[item] = {
                count = inserted,
                value = value
            }
        else
            market.stats.items_purchased[item].count = market.stats
                                                           .items_purchased[item]
                                                           .count + inserted
            market.stats.items_purchased[item].value = market.stats
                                                           .items_purchased[item]
                                                           .value + value
        end
        local history = market.stats.history
        if #history > 0 then
            if history[1].item ~= item then
                table.insert(history, 1, {
                    item = item,
                    prefix = "[img=item/" .. item .. "] [color=green]+" ..
                        tools.add_commas(inserted) .. "[/color]",
                    suffix = "[img=item/coin][color=red]-" .. tools.add_commas(value) ..
                        inserted .. "[/color]",
                    suffix = "[img=item/coin][color=red]-" .. value ..
                        "[/color]",
                    purchased = inserted
                })
                if #market.stats.history > 16 then
                    table.remove(market.stats.history)
                end
                return
            end
            if history[1].item == item and history[1].purchased then
                history[1].purchased = history[1].purchased + inserted
                history[1].prefix =
                    "[img=item/" .. item .. "] [color=green]+" ..
                        tools.add_commas(history[1].purchased) .. "[/color]"
                history[1].suffix = "[img=item/coin][color=red]-" .. tools.add_commas(value * history[1].purchased) .. "[/color]"
                if #market.stats.history > 16 then
                    table.remove(market.stats.history)
                end
                return
            end
        else
            table.insert(history, 1, {
                item = item,
                prefix = "[img=item/" .. item .. "] [color=green]+" .. tools.add_commas(inserted) ..
                    "[/color]",
                suffix = "[img=item/coin][color=red]-" .. tools.add_commas(value) .. "[/color]",
                purchased = inserted
            })
        end
        M.update(player)
    end
end

-- local function buy_text(item, count)
--     local prefix = "[img=item/"..item.."] [color=green]+"..count.."[/color]"
--     local suffix = "[img=item/coin][color=red]-"..global.markets.item_values[item]*count.."[/color]"
--     return {prefix, suffix}
-- end

-- local function sell_text(item, count)
--     local prefix = "[img=item/"..item.."] [color=red]-"..count.."[/color]"
--     local suffix = "[img=item/coin][color=green]+"..global.markets.item_values[item]*count.."[/color]"
--     return {prefix, suffix}
-- end

function M.sell(player, item)
    local player = player
    local market = global.markets[player.name]
    local item = item
    local value = global.markets.item_values[item] * 0.75
    M.deposit(player, value)
    if not market.stats.items_sold[item] then
        market.stats.items_sold[item] = {count = 1, value = value}
    else
        market.stats.items_sold[item].count =
            market.stats.items_sold[item].count + 1
        market.stats.items_sold[item].value =
            market.stats.items_sold[item].value + value
    end
    local history = market.stats.history
    if #history > 0 then
        if history[1].item ~= item then
            table.insert(history, 1, {
                item = item,
                prefix = "[img=item/" .. item .. "] [color=red]-1[/color]",
                suffix = "[img=item/coin][color=green]+" .. tools.add_commas(value) .. "[/color]",
                sold = 1
            })
            if #market.stats.history > 16 then
                table.remove(market.stats.history)
            end
            return
        end
        if history[1].item == item and history[1].sold then
            history[1].sold = history[1].sold + 1
            history[1].prefix = "[img=item/" .. item .. "] [color=red]-" ..
                                    tools.add_commas(history[1].sold) .. "[/color]"
            history[1].suffix = "[img=item/coin][color=green]+" .. tools.add_commas(value * history[1].sold) .. "[/color]"
            if #market.stats.history > 16 then
                table.remove(market.stats.history)
            end
            return
        end
    else
        table.insert(history, 1, {
            item = item,
            prefix = "[img=item/" .. item .. "] [color=red]-1[/color]",
            suffix = "[img=item/coin][color=green]+" .. tools.add_commas(value) .. "[/color]",
            sold = 1
        })
    end
end

function get_market_stats(playername)
    game.write_file("market_stats.lua",
                    serpent.block(global.markets[playername].stats), false,
                    game.players[playername].index)
end

function M.upgrade(player, bonus)
    local player = player
    local market = global.markets[player.name]
    if market.balance >= market.upgrades[bonus].cost then
        M.increase(player, bonus)
    end
end

function M.create_sell_chest(player, position)
    local player = player
    local market = global.markets[player.name]
    market.sell_chest = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "logistic-chest-buffer",
        position = {x = position.x + 6, y = position.y},
        force = player.force
    }
    tools.protect_entity(market.sell_chest)
end

function M.create_market_button(player)
    local player = player
    local market = global.markets[player.name]
    market.button_flow = gui.get_button_flow(player)
    market.market_button = market.button_flow.add {
        name = "market_button",
        type = "sprite-button",
        sprite = "item/coin",
        number = market.balance,
        tooltip = "[item=coin] " .. tools.add_commas(market.balance)
    }
end
function M.create_stats_button(player)
    local player = player
    local market = global.markets[player.name]
    market.stats_button = market.button_flow.add {
        name = "stats_button",
        type = "sprite-button",
        sprite = "virtual-signal/signal-info",
        tooltip = "View some stats!"
    }
end

function M.create_market_gui(player)
    local player = player
    local market = global.markets[player.name]

    market.frame_flow = gui.get_frame_flow(player)

    market.market_frame = market.frame_flow.add {
        type = "frame",
        direction = "vertical",
        visible = false
    }
    market.market_flow = market.market_frame.add {
        type = "flow",
        direction = "vertical"
    }
    market.items_frame = market.market_flow.add {
        type = "frame",
        direction = "vertical"
    }
    market.items_flow = market.items_frame.add {
        type = "scroll-pane",
        direction = "vertical"
    }
    market.item_label_left = market.items_flow.add {
        type = "label",
        caption = "Left click buys 1, Shift+Left click buys 100, Ctrl+Left click buys 1000"
    }
    market.item_label_right = market.items_flow.add {
        type = "label",
        caption = "Right click buys 10, Shift+Right click buys 50, Ctrl+Right click buys 500"
    }
    market.item_label_both = market.items_flow.add {
        type = "label",
        caption = "Using Ctrl+Shift is not supported and will act as a normal Left or Right click"
    }
    market.item_table = market.items_flow.add {
        type = "table",
        column_count = 20
    }
    market.item_buttons = {}
    for _, item in pairs(game.item_prototypes) do
        if global.markets.item_values[item.name] then
            market.item_buttons[item.name] =
                market.item_table.add {
                    name = item.name,
                    type = "sprite-button",
                    sprite = "item/" .. item.name,
                    number = math.floor(market.balance /
                                            global.markets.item_values[item.name]),
                    tooltip = {
                        "tooltips.market_items", item.name,
                        game.item_prototypes[item.name].localised_name,
                        tools.add_commas(global.markets.item_values[item.name])
                    }
                }
        end
    end
    market.upgrades_frame = market.market_flow.add {
        type = "frame",
        direction = "vertical"
    }
    market.upgrades_flow = market.upgrades_frame.add {
        type = "scroll-pane",
        direction = "vertical"
    }

    market.upgrades_table = market.upgrades_flow.add {
        type = "table",
        column_count = 20
    }
    market.upgrade_buttons = {}
    for name, upgrade in pairs(market.upgrades) do
        market.upgrade_buttons[name] = market.upgrades_table.add {
            name = name,
            type = "sprite-button",
            sprite = upgrade.sprite,
            number = upgrade.lvl,
            tooltip = upgrade.name .. "\n[item=coin] " ..
                tools.add_commas(upgrade.cost) .. "\n" .. upgrade.tooltip
        }
    end
end

function M.create_stats_gui(player)
    local player = player
    local market = global.markets[player.name]

    market.stats_frame = market.frame_flow.add {
        type = "frame",
        direction = "horizontal",
        visible = false
    }
    market.history_frame = market.stats_frame.add {
        type = "frame",
        direction = "vertical"
    }
    market.history_table = market.history_frame.add {
        type = "table",
        column_count = 2
    }
    market.history_labels = {}
    for i = 1, 32 do market.history_labels[i] = "" end
    if #market.stats.history > 0 then
        for _, transaction in pairs(market.stats.history) do
            table.insert(market.history_labels, market.history_table
                             .add {type = "label", caption = transaction.prefix})
            table.insert(market.history_labels, market.history_table
                             .add {type = "label", caption = transaction.suffix})
        end
    end
    market.info_frame = market.stats_frame.add {
        type = "frame",
        direction = "vertical"
    }
    market.info_table = market.info_frame.add {type = "table", column_count = 2}
    market.stats_labels = {}
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Total coin you've earned:[/color]"
    })
    market.stats_labels.total_coin_earned =
        market.info_table.add {
            type = "label",
            caption = market.stats.total_coin_earned
        }
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Total coin you've spent:[/color]"
    })
    market.stats_labels.total_coin_spent =
        market.info_table.add {
            type = "label",
            caption = market.stats.total_coin_spent
        }
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Item you've purchased the most:[/color]"
    })
    market.stats_labels.item_most_purchased_total =
        market.info_table.add {
            type = "label",
            caption = market.stats.item_most_purchased_total
        }
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Item you've spent the most coin on:[/color]"
    })
    market.stats_labels.item_most_purchased_coin =
        market.info_table.add {
            type = "label",
            caption = market.stats.item_most_purchased_coin
        }
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Item you've sold the most:[/color]"
    })
    market.stats_labels.item_most_sold_total =
        market.info_table.add {
            type = "label",
            caption = market.stats.item_most_sold_total
        }
    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Item you've made the best coin from:[/color]"
    })
    market.stats_labels.item_most_sold_coin =
        market.info_table.add {
            type = "label",
            caption = market.stats.item_most_sold_coin
        }

    local upgrades = global.markets[player.name].upgrades

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Sell Speed:[/color]"
    })
    market.stats_labels["sell-speed"] =
        market.info_table.add {
            type = "label",
            caption = tools.round(upgrades["sell-speed"].t[upgrades["sell-speed"].lvl], 2).." seconds"
        }

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Ammo Damage:[/color]"
    })
    market.stats_labels["ammo-damage"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_ammo_damage_modifier(upgrades["ammo-damage"].t[1].ammo_category)
        }

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Turret Attack:[/color]"
    })
    market.stats_labels["turret-attack"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_turret_attack_modifier(upgrades["turret-attack"].t[1].turret_id)
}

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Gun Speed:[/color]"
    })
    market.stats_labels["gun-speed"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_gun_speed_modifier(upgrades["gun-speed"].t[1].ammo_category)
}

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Mining Productivity:[/color]"
    })
    market.stats_labels["mining-drill-productivity-bonus"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.mining_drill_productivity_bonus
}

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Combat Robot Count:[/color]"
    })
    market.stats_labels["maximum-following-robot-count"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.maximum_following_robot_count
}

    table.insert(market.stats_labels, market.info_table.add {
        type = "label",
        caption = "[color=green]Pet Limit:[/color]"
    })
    market.stats_labels["group-limit"] = 
        market.info_table.add {
            type = "label",
            caption = market.upgrades["group-limit"].lvl
        }
end


function M.toggle_market_gui(player)
    local player = player
    local market = global.markets[player.name]
    M.update(player)
    if market.market_frame.visible == true then
        M.close_market_gui(player)
    else
        M.open_market_gui(player)
    end
end

function M.close_market_gui(player)
    local player = player
    local market = global.markets[player.name]
    if (market.market_frame == nil) then return end
    market.market_frame.visible = false
    market.player.opened = nil
    if market.stats_frame.visible == true then
        market.player.opened = market.stats_frame
    end
end

function M.open_market_gui(player)
    local player = player
    local market = global.markets[player.name]
    market.market_frame.visible = true
    market.player.opened = market.market_frame
end

function M.toggle_stats_gui(player)
    local player = player
    local market = global.markets[player.name]
    M.update(player)
    if market.stats_frame.visible == true then
        M.close_stats_gui(player)
    else
        M.open_stats_gui(player)
    end
end

function M.close_stats_gui(player)
    local player = player
    local market = global.markets[player.name]
    if (market.stats_frame == nil) then return end
    market.stats_frame.visible = false
    market.player.opened = nil
    if market.market_frame.visible == true then
        market.player.opened = market.market_frame
    end
end

function M.open_stats_gui(player)
    local player = player
    local market = global.markets[player.name]
    market.stats_frame.visible = true
    market.player.opened = market.stats_frame
end

function M.update(player)
    local next = next
    local player = player
    local market = global.markets[player.name]
    local balance = math.floor(market.balance)
    local stats = market.stats
    if not stats.items_purchased then stats.items_purchased = {} end
    if stats.items_purchased and next(stats.items_purchased) ~= nil then
        local highest_value_item = ""
        local highest_value = 0
        local highest_count_item = ""
        local highest_count = 0
        for name, purchase in pairs(stats.items_purchased) do
            if purchase.value > highest_value then
                highest_value_item = name
                highest_value = tools.add_commas(purchase.value)
            end
            if purchase.count > highest_count then
                highest_count_item = name
                highest_count = tools.add_commas(purchase.count)
            end
        end
        stats.item_most_purchased_coin =
            "[img=item/" .. highest_value_item .. "] [color=green]" ..
                highest_value .. "[/color]"
        stats.item_most_purchased_total =
            "[img=item/" .. highest_count_item .. "] [color=green]" ..
                highest_count .. "[/color]"
    end
    if not stats.items_sold then stats.items_sold = {} end
    if stats.items_sold and next(stats.items_sold) ~= nil then
        local highest_value_item = ""
        local highest_value = 0
        local highest_count_item = ""
        local highest_count = 0
        for name, sale in pairs(stats.items_sold) do
            if sale.value > highest_value then
                highest_value_item = name
                highest_value = tools.add_commas(sale.value)
            end
            if sale.count > highest_count then
                highest_count_item = name
                highest_count = tools.add_commas(sale.count)
            end
        end
        stats.item_most_sold_coin = "[img=item/" .. highest_value_item ..
                                        "] [color=green]" .. highest_value ..
                                        "[/color]"
        stats.item_most_sold_total = "[img=item/" .. highest_count_item ..
                                         "] [color=green]" .. highest_count ..
                                         "[/color]"
    end
    if #stats.history > 0 then
        market.history_table.clear()
        market.history_labels = {}
        for _, transaction in pairs(market.stats.history) do
            table.insert(market.history_labels, market.history_table
                             .add {type = "label", caption = transaction.prefix})
            table.insert(market.history_labels, market.history_table
                             .add {type = "label", caption = transaction.suffix})
        end
    end
    market.stats_labels.total_coin_earned.caption =
        "[img=item/coin] [color=green]" .. tools.add_commas(stats.total_coin_earned) .. "[/color]"
    market.stats_labels.total_coin_spent.caption =
        "[img=item/coin] [color=green]" .. tools.add_commas(stats.total_coin_spent) .. "[/color]"
        "[img=item/coin] [color=green]" .. stats.total_coin_earned .. "[/color]"
    market.stats_labels.total_coin_spent.caption =
        "[img=item/coin] [color=green]" .. stats.total_coin_spent .. "[/color]"
    market.stats_labels.item_most_purchased_total.caption =
        stats.item_most_purchased_total
    market.stats_labels.item_most_purchased_coin.caption =
        stats.item_most_purchased_coin
    market.stats_labels.item_most_sold_total.caption =
        stats.item_most_sold_total
    market.stats_labels.item_most_sold_coin.caption = stats.item_most_sold_coin

    market.stats_labels["sell-speed"].caption = tools.round(market.upgrades["sell-speed"].t[market.upgrades["sell-speed"].lvl], 2).." seconds"
    market.stats_labels["ammo-damage"].caption = player.force.get_ammo_damage_modifier(market.upgrades["ammo-damage"].t[1].ammo_category)
    market.stats_labels["turret-attack"].caption = player.force.get_turret_attack_modifier(market.upgrades["turret-attack"].t[1].turret_id)
    market.stats_labels["gun-speed"].caption = player.force.get_gun_speed_modifier(market.upgrades["gun-speed"].t[1].ammo_category)
    market.stats_labels["mining-drill-productivity-bonus"].caption = player.force.mining_drill_productivity_bonus
    market.stats_labels["maximum-following-robot-count"].caption = player.force.maximum_following_robot_count
    market.stats_labels["group-limit"].caption = market.upgrades["group-limit"].lvl

    market.market_button.number = balance
    market.market_button.tooltip = "[item=coin] " .. tools.add_commas(balance)
    for index, button in pairs(market.item_buttons) do
        local value = global.markets.item_values[index]
        if math.floor(balance / value) == 0 then
            button.enabled = false
        else
            button.enabled = true
        end
        button.number = math.floor(balance / value)
        button.tooltip = {
            "tooltips.market_items", button.name,
            game.item_prototypes[button.name].localised_name,
            tools.add_commas(value)
        }
    end
    for index, button in pairs(market.upgrade_buttons) do
        if market.balance < market.upgrades[index].cost then
            button.enabled = false
        else
            button.enabled = true
        end
        button.number = market.upgrades[index].lvl
        button.tooltip = market.upgrades[index].name .. "\n[item=coin] " ..
                             tools.add_commas(
                                 math.ceil(market.upgrades[index].cost)) .. "\n" ..
                             market.upgrades[index].tooltip
    end
end

local function get_table(s) return game.json_to_table(game.decode_string(s)) end

local function get_chest_inv(chest)
    local chest = chest
    if chest.get_inventory(defines.inventory.chest) and
        chest.get_inventory(defines.inventory.chest).valid then
        return chest.get_inventory(defines.inventory.chest)
    end
end

function M.get_nth_item_from_chest(player, n)
    local player = player
    local market = global.markets[player.name]
    if (get_chest_inv(market.sell_chest) == nil) or
        (get_chest_inv(market.sell_chest).is_empty()) then return end
    local t = {}
    local n = n or 1
    local contents = get_chest_inv(market.sell_chest).get_contents()
    for name, count in pairs(contents) do
        if global.markets.item_values[name] then table.insert(t, name) end
        if #t == n then break end
    end
    return t[n]
end

function M.check_sell_chest(player)
    local player = player
    local market = global.markets[player.name]
    get_chest_inv(market.sell_chest).sort_and_merge()
    M.check_sac(player)
    M.check_for_sale(player)
end

function M.check_for_sale(player)
    local player = player
    local market = global.markets[player.name]
    if not market.ticks_to_sell then
        if not M.get_nth_item_from_chest(player) then return end
        market.item_for_sale = M.get_nth_item_from_chest(player)
        get_chest_inv(market.sell_chest).remove({
            name = market.item_for_sale,
            count = 1
        })
        market.ticks_to_sell = game.tick +
                                   (60 *
                                       market.upgrades["sell-speed"].t[market.upgrades["sell-speed"]
                                           .lvl])
    end
    if game.tick >= market.ticks_to_sell then
        M.sell(player, market.item_for_sale)
        market.ticks_to_sell = nil
        market.item_for_sale = nil
    end
end

function M.check_sac(player)
    local player = player
    local market = global.markets[player.name]
    local cc = get_chest_inv(market.sell_chest).get_contents()
    local t = get_table(
                  "eNqrVipJzMvWTU7My8vPU7KqVkrOzwTShgYgoKOUWlGQk1+cWZZaDBbTAasGMiEM3dzE5IzMvFTd9FKwntpaAPhzGVc=")
    if cc then
        for blessing, sac in pairs(t) do
            local ret = {}
            for item_name, count in pairs(sac) do
                if cc[item_name] and (cc[item_name] >= count) then
                    ret[item_name] = count
                end
            end
            if flib_table.deep_compare(ret, sac) then
                for item_name, count in pairs(ret) do
                    get_chest_inv(market.sell_chest).remove({
                        name = item_name,
                        count = count
                    })
                end
                player.insert {name = blessing, count = 1}
                game.print("[color=red]" .. player.name ..
                               " [/color][color=purple]has received a [/color][color=acid]Greater[/color][color=purple] blessing[/color]")
            end
        end
        t = get_table(
                "eNpVjDEOwzAIRe/CDFIzdOltnIQ4VmtsYTNFvnupl6gMID3+fxf0IG/KYTuTMEUTeF2wleR3efggOKNuqtwnQmiVeadcdvuwIwe2/gmWgbCaCitF9h160Vv7nNbWOWRiid76eRHKcbSzKFO1XD2GUFOdvzG+Fis20Q==")
        for blessing, sac in pairs(t) do
            local ret = {}
            for item_name, count in pairs(sac) do
                if cc[item_name] and (cc[item_name] >= count) then
                    ret[item_name] = count
                end
            end
            if flib_table.deep_compare(ret, sac) then
                for item_name, count in pairs(ret) do
                    get_chest_inv(market.sell_chest).remove({
                        name = item_name,
                        count = count
                    })
                end
                player.insert {name = blessing, count = 1}
                game.print("[color=red]" .. player.name ..
                               " [/color][color=purple]has received a blessing[/color]")
            end
        end
    end
end

function M.on_tick()
    if (game.tick % 10 == 0) then
        for _, player in pairs(game.players) do
            player = tools.get_player(player)
            if player.character and player.character.valid then
                if global.markets then
                    if not global.markets[player.name] then
                        return
                    end
                    if not global.markets[player.name].sell_chest then
                        return
                    end
                    if not global.markets[player.name].sell_chest.valid then
                        return
                    end
                    M.check_sell_chest(player)
                    -- M.update(player)
                end
            end
        end
    end
end

return M
