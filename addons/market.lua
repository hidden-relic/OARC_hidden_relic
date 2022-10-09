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
    for name, value in pairs(tools.sortByValue(pre_item_values)) do
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
    global.markets[player.name] = {player = player, balance = 0}
    local market = global.markets[player.name]
    market.upgrades = {
        ["sell-speed"] = {
            name = "Sell Speed",
            lvl = 1,
            max_lvl = 10,
            cost = 10000,
            sprite = "utility/character_running_speed_modifier_constant",
            t = {5, 4.8, 4.5, 4.1, 3.6, 3, 2.4, 1.7, 0.6, 0.25}
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
            }
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
            }
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
            }
        },

        ["mining-drill-productivity-bonus"] = {
            name = "Mining Drill Productivity",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/mining-productivity-1",
            t = {{type = "mining-drill-productivity-bonus", modifier = 0.1}}
        },

        ["maximum-following-robot-count"] = {
            name = "Follower Robot Count",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "technology/follower-robot-count-1",
            t = {{type = "maximum-following-robots-count", modifier = 5}}
        },

        ["group-limit"] = {
            name = "Pet Limit",
            lvl = 1,
            max_lvl = 50,
            cost = 10000,
            sprite = "entity/small-biter",
            t = {}
        }
    }
    M.create_market_button(player)
    M.create_market_gui(player)
end

function M.deposit(player, v)
    local player = player
    local market = global.markets[player.name]
    market.balance = market.balance + v
    M.update(player)
end

function M.withdraw(player, v)
    local player = player
    local market = global.markets[player.name]
    if v > market.balance then
        player.print("Insufficient Funds")
    else
        market.balance = market.balance - v
        M.update(player)
    end
end

function M.purchase(player, item, click, shift)
    local player = player
    local market = global.markets[player.name]
    local item = item
    local value = global.markets.item_values[item]
    local i = nil
    if click == 2 then i = 1 end
    if click == 4 then
        if not shift then
            i = 5
        else
            i = math.floor(market.balance / value)
        end
    end
    if i then
        for x = 1, i do
            if math.floor(market.balance / value) >= 1 and
                player.can_insert {name = item} then
                M.withdraw(player, value)
                player.insert {name = item}
            end
        end
    end
end

function M.sell(player, item)
    local player = player
    local market = global.markets[player.name]
    local item = item
    local value = global.markets.item_values[item] * 0.75
    M.deposit(player, value)
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
        tooltip = "[item=coin] " .. market.balance
    }
end

function M.create_market_gui(player)
    local player = player
    local market = global.markets[player.name]
    market.frame_flow = gui.get_frame_flow(player)
    market.main_frame = market.frame_flow.add {
        type = "frame",
        direction = "vertical",
        visible = false
    }
    market.main_flow = market.main_frame.add {
        type = "flow",
        direction = "vertical"
    }
    market.items_frame = market.main_flow.add {
        type = "frame",
        direction = "vertical"
    }
    market.items_flow = market.items_frame.add {
        type = "scroll-pane",
        direction = "vertical"
    }

    market.item_table = market.items_flow.add {
        type = "table",
        column_count = 20
    }
    market.item_buttons = {}
    for name, value in pairs(global.markets.item_values) do
        market.item_buttons[name] = market.item_table.add {
            name = name,
            type = "sprite-button",
            sprite = "item/" .. name,
            number = math.floor(market.balance / value),
            tooltip = {
                "tooltips.market_items", name,
                game.item_prototypes[name].localised_name, value
            }
        }
    end
    market.upgrades_frame = market.main_flow.add {
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
            tooltip = upgrade.name .. "\n[item=coin] " .. upgrade.cost
        }
    end
end

function M.toggle_market_gui(player)
    local player = player
    local market = global.markets[player.name]
    M.update(player)
    if market.main_frame.visible == true then
        M.close_gui(player)
    else
        M.open_gui(player)
    end
end

function M.close_gui(player)
    local player = player
    local market = global.markets[player.name]
    if (market.main_frame == nil) then return end
    market.main_frame.visible = false
    market.player.opened = nil
end

function M.open_gui(player)
    local player = player
    local market = global.markets[player.name]
    market.main_frame.visible = true
    market.player.opened = market.main_frame
end

function M.update(player)
    local player = player
    local market = global.markets[player.name]
    local balance = math.floor(market.balance)
    market.market_button.number = balance
    market.market_button.tooltip = "[item=coin] " .. balance
    for index, button in pairs(market.item_buttons) do
        local value = global.markets.item_values[index]
        button.number = math.floor(balance / value)
        button.tooltip = {
            "tooltips.market_items", button.name,
            game.item_prototypes[button.name].localised_name, value
        }
    end
    for index, button in pairs(market.upgrade_buttons) do
        button.number = market.upgrades[index].lvl
        button.tooltip = market.upgrades[index].name .. "\n[item=coin] " ..
                             math.ceil(market.upgrades[index].cost)
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
        for _, player in pairs(game.connected_players) do
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
