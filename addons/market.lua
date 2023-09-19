local gui = require("mod-gui")
local tools = require("addons.tools")
local prodscore = require('production-score')

local group = require("addons.groups")

local flying_tag = require("flying_tags")

local M = {}

local config = {}
config.enable_groups = false
config.upgrades_column_count = 3
config.shared_column_count = 3
config.special_column_count = 3
if config.enable_groups then
    config.upgrades_column_count = 5
    config.followers_column_count = 4
    config.shared_column_count = 6
    config.special_column_count = 6
end
-- function M:new(o)
--     o = o or {}             -- this sets o to itself (if arg o is passed in) if not, create empty table called o
--     setmetatable(o, self)   -- set o's metatable to M's metatable
--     self.__index = self     -- sets passed in var's lookup to M
--     return o                -- return o
-- end

function M.init()
    local markets = {jackpot=0, autolvl_turrets={}}
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
--

if config.enable_groups == true then
    M.followers_table = {
        ["small-biter"] = {cost = 500, count = 1},
        ["medium-biter"] = {cost = 2000, count = 1},
        ["big-biter"] = {cost = 10000, count = 1},
        ["behemoth-biter"] = {cost = 60000, count = 1},
        ["small-spitter"] = {cost = 500, count = 1},
        ["medium-spitter"] = {cost = 3000, count = 1},
        ["big-spitter"] = {cost = 12000, count = 1},
        ["behemoth-spitter"] = {cost = 75000, count = 1}
    }
    
    M.followers_func_table = {
        ["small-biter"] = function(player) group.add(player, "small-biter") return end,
        ["medium-biter"] = function(player) group.add(player, "medium-biter") return end,
        ["big-biter"] = function(player) group.add(player, "big-biter") return end,
        ["behemoth-biter"] = function(player) group.add(player, "behemoth-biter") return end,
        ["small-spitter"] = function(player) group.add(player, "small-spitter") return end,
        ["medium-spitter"] = function(player) group.add(player, "medium-spitter") return end,
        ["big-spitter"] = function(player) group.add(player, "big-spitter") return end,
        ["behemoth-spitter"] = function(player) group.add(player, "behemoth-spitter") return end
    }
end

M.shared_func_table = {
    ["special_logistic-chest-storage"] = function(player)
        return ConvertWoodenChestToSharedChestInput(player)
    end,
    ["special_logistic-chest-requester"] = function(player)
        return ConvertWoodenChestToSharedChestOutput(player)
    end,
    ["special_constant-combinator"] = function(player)
        return ConvertWoodenChestToSharedChestCombinators(player)
    end,
    ["special_accumulator"] = function(player)
        return ConvertWoodenChestToShareEnergyInput(player)
    end,
    ["special_electric-energy-interface"] = function(player)
        return ConvertWoodenChestToShareEnergyOutput(player)
    end,
    ["special_deconstruction-planner"] = function(player) return DestroyClosestSharedChestEntity(player) end
}

M.shared_cost_table = {
    ["special_logistic-chest-storage"] = 1.02,
    ["special_logistic-chest-requester"] = 1.02,
    ["special_constant-combinator"] = 1.02,
    ["special_accumulator"] = 1.02,
    ["special_electric-energy-interface"] = 1.02,
    ["special_deconstruction-planner"] = 1.02
}
M.special_func_table = {
    ["special_electric-furnace"] = function(player) return RequestSpawnSpecialChunk(player, SpawnFurnaceChunk, "electric-furnace") end,
    ["special_oil-refinery"] = function(player) return RequestSpawnSpecialChunk(player, SpawnOilRefineryChunk, "oil-refinery") end,
    ["special_assembling-machine-3"] = function(player) return RequestSpawnSpecialChunk(player, SpawnAssemblyChunk, "assembling-machine-3") end,
    ["special_centrifuge"] = function(player) return RequestSpawnSpecialChunk(player, SpawnCentrifugeChunk, "centrifuge") end,
    ["special_assembling-machine-1"] = function(player) return SendPlayerToSpawn(player) end,
    ["special_offshore-pump"] = function(player)
        if ConvertWoodenChestToWaterFill(player) then
            global.markets[player.name].stats.waterfill_cost = math.floor(global.markets[player.name].stats.waterfill_cost * 1.01)
            return true
        end
    end
}

M.special_cost_table = {
    ["special_electric-furnace"] = 1.1,
    ["special_oil-refinery"] = 1.1,
    ["special_assembling-machine-3"] = 1.1,
    ["special_centrifuge"] = 1.1,
    ["special_assembling-machine-1"] = 1.1,
    ["special_offshore-pump"] = 1.1
}

M.special_table = {
    ["special_electric-furnace"] = {cost = 100000, tooltip = "Turn a magic square into a Magic Furnace"},
    ["special_oil-refinery"] = {cost = 100000, tooltip = "Turn a magic square into a Magic Refinery"},
    ["special_assembling-machine-3"] = {cost = 100000, tooltip = "Turn a magic square into a Magic Assembler"},
    ["special_centrifuge"] = {cost = 100000, tooltip = "Turn a magic square into a Magic Centrifuge"},
    ["special_assembling-machine-1"] = {cost = 10, tooltip = "Instantly teleport to your spawn"},
    ["special_offshore-pump"] = {cost = 1000, tooltip = "Turn the nearest empty wooden chest into a water tile"}
}

M.upgrade_cost_table = {
    ["sell-speed"] = 1.12,
    ["character-health"] = 0.5,
    ["gun"] = 0.2,
    ["tank-flame"] = 0.2,
    ["rocketry"] = 0.2,
    ["laser"] = 0.2,
    ["mining-drill-productivity-bonus"] = 0.25,
    ["maximum-following-robot-count"] = 0.2,
    ["group-limit"] = 0.25,
    -- ["autofill-turret"] = 0,
    ["autolvl-turret"] = 0,
    -- ["coin-turret"] = 0,
}

M.upgrade_func_table = {
    ["sell-speed"] = function(player) return end,
    ["character-health"] = function(player)
        player.character_health_bonus = player.character_health_bonus + 25
    end,
    ["gun"] = function(player)
        player.force.set_ammo_damage_modifier("bullet", player.force.get_ammo_damage_modifier("bullet")+0.1)
        player.force.set_turret_attack_modifier("gun-turret", player.force.get_turret_attack_modifier("gun-turret")+0.1)
        player.force.set_gun_speed_modifier("bullet", player.force.get_gun_speed_modifier("bullet")+0.01)
    end,
    ["tank-flame"] = function(player)
        player.force.set_ammo_damage_modifier("flamethrower", player.force.get_ammo_damage_modifier("flamethrower")+0.1)
        player.force.set_ammo_damage_modifier("cannon-shell", player.force.get_ammo_damage_modifier("cannon-shell")+0.1)
        player.force.set_turret_attack_modifier("flamethrower-turret", player.force.get_turret_attack_modifier("flamethrower-turret")+0.1)
        player.force.set_gun_speed_modifier("cannon-shell", player.force.get_gun_speed_modifier("cannon-shell")+0.01)
    end,
    ["rocketry"] = function(player)
        player.force.set_ammo_damage_modifier("rocket", player.force.get_ammo_damage_modifier("rocket")+0.1)
        player.force.set_gun_speed_modifier("rocket", player.force.get_gun_speed_modifier("rocket")+0.01)
    end,
    ["laser"] = function(player)
        player.force.set_ammo_damage_modifier("laser", player.force.get_ammo_damage_modifier("laser")+0.1)
        player.force.set_ammo_damage_modifier("electric", player.force.get_ammo_damage_modifier("electric")+0.1)
        player.force.set_ammo_damage_modifier("beam", player.force.get_ammo_damage_modifier("beam")+0.1)
        player.force.set_turret_attack_modifier("laser-turret", player.force.get_turret_attack_modifier("laser-turret")+0.1)
        player.force.set_gun_speed_modifier("laser", player.force.get_gun_speed_modifier("laser")+0.01)
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
    end,
    ["autolvl-turret"] = function(player)
        global.markets.autolvl_turrets[player.name] = true
        M.update(player)
    end,
    -- ["coin-turret"] = function(player)
    --     global.markets.coin_turrets[player.name] = true
    --     if global.config.limit_turret_upgrades == true then
    --         global.markets[player.name].upgrades["autolvl-turret"].lvl = 1
    --         global.markets[player.name].upgrades["autofill-turret"].lvl = 1
    --     end
    --     M.update(player)
    -- end,
    -- ["autofill-turret"] = function(player)
    --     table.insert(global.markets.autofill_turrets, {name=player.name})
    --     if global.config.limit_turret_upgrades == true then
    --         global.markets[player.name].upgrades["coin-turret"].lvl = 1
    --         global.markets[player.name].upgrades["autolvl-turret"].lvl = 1
    --     end
    --     M.update(player)
    -- end,
}

function M.increase(player, upgrade)
    local name = upgrade
    local upgrade = global.markets[player.name].upgrades[upgrade]
    if upgrade.lvl < upgrade.max_lvl then
        upgrade.lvl = upgrade.lvl + 1
        local current_cost = upgrade.cost
        if name == "sell-speed" then
            upgrade.cost = math.floor(upgrade.cost^(M.upgrade_cost_table[name]^0.9^upgrade.lvl))
        else    
            upgrade.cost = upgrade.cost +
            (upgrade.cost * M.upgrade_cost_table[name])
        end
        M.withdraw(player, current_cost)
        global.markets.jackpot = tools.round(global.markets.jackpot + current_cost*0.25, 0)
        local up_func = M.upgrade_func_table[name]
        up_func(player)
    else
        return
    end
end

function M.increase_shared(player, upgrade)
    local name = upgrade
    local upgrade = global.markets[player.name].shared[upgrade]
    local current_cost = upgrade.cost
    if name == "special_deconstruction-planner" then
        upgrade.cost = upgrade.cost
    elseif upgrade.cost > 10000000 then
        upgrade.cost = 10000000
    else
        upgrade.cost = math.ceil(upgrade.cost^M.shared_cost_table[name])
    end
    M.withdraw(player, current_cost)
    global.markets.jackpot = tools.round(global.markets.jackpot + current_cost*0.25, 0)
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
            history = {},
            waterfill_cost = 1000
        }
    }
    local market = global.markets[player.name]
    market.upgrades = {
        ["sell-speed"] = {
            name = "Sell Speed",
            lvl = 1,
            max_lvl = 50,
            cost = 10000,
            sprite = "utility/character_running_speed_modifier_constant",
            -- potential future speeds for ups optimization
            -- 1-10 (10)
            -- 1-9 (9)
            -- 1-8 (8)
            -- 1-7 (7)
            -- 1-6 (6)
            -- 2-8 (4)
            -- 2-7 (3.5)
            -- 2-6 (3)
            -- 2-5 (2.5)
            -- 3-6 (2)
            -- 3-5 (1.66)
            -- 3-4 (1.25)
            -- 4-4 (1)
            -- 4-3 (0.75)
            -- 4-2 (0.5)
            -- 5-2 (0.4)
            -- 5-1 (0.2)
            t = {},
            tooltip = "Increase the amount of items you sell every 10 seconds\nnumber of items = level^1.1"
        },
        ["character-health"] = {
            name = "Character Health",
            lvl = 1,
            max_lvl = 100,
            cost = 1000,
            sprite = "utility/rail_planner_indication_arrow",
            t = {},
            tooltip = "+25 to character health"
        },
        ["gun"] = {
            name = "Weaponry",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "item/submachine-gun",
            hovered_sprite = "item/gun-turret",
            t = {},
            tooltip = "+10% Bullet Damage\n+10% Gun Turret Attack\n %10% Bullet Speed\n[img=item/firearm-magazine] [img=item/piercing-rounds-magazine] [img=item/uranium-rounds-magazine] [img=item/gun-turret]"
        },
        ["tank-flame"] = {
            name = "Hot & Heavy",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "item/flamethrower",
            hovered_sprite = "item/tank",
            t = {},
            tooltip = "+10% Tank Shell Damage\n+10%Tank Shell Speed\n+10% Flamethrower Damage\n+10% Flamethrower Turret Attack\n [img=item/flamethrower-ammo] [img=item/flamethrower-turret] [img=item/cannon-shell]"
        },
        ["rocketry"] = {
            name = "Rocketry",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "item/rocket",
            hovered_sprite = "item/explosive-rocket",
            t = {},
            tooltip = "+10% Rocket Damage\n+10% Rocket Speed\n[img=item/rocket] [img=item/explosive-rocket]"
        },
        ["laser"] = {
            name = "Lasers",
            lvl = 1,
            max_lvl = 100,
            cost = 10000,
            sprite = "item/laser-turret",
            hovered_sprite = "item/personal-laser-defense-equipment",
            t = {},
            tooltip = "+10% Laser Damage\n+10% Laser Speed\n+10% Laser Turret Attack\n+10% Electric+Beam Attack\n[img=item/laser-turret] [img=item/personal-laser-defense-equipment] [img=entity/destroyer] [img=entity/distractor] [img=item/discharge-defense-equipment]"
        },
        ["autolvl-turret"] = {
            name = "Gun Turret Combat Training",
            lvl = 0,
            max_lvl = 1,
            cost = 1000000,
            sprite = "item/gun-turret",
            hovered_sprite = "utility/turret_attack_modifier_constant",
            t = {},
            tooltip = "Enable Combat Training on your gun turrets.\nThe more damage they deal, the more damage they do.\nAffects entire team"
            },
            ["mining-drill-productivity-bonus"] = {
                name = "Mining Drill Productivity",
                lvl = 1,
                max_lvl = 100,
                cost = 1000000,
                sprite = "technology/mining-productivity-1",
                t = {{type = "mining-drill-productivity-bonus", modifier = 0.05}},
                tooltip = "+5% Productivity [img=technology/mining-productivity-1]"
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
        }
        market.shared = {
                ["special_logistic-chest-storage"] = {cost = 20000, tooltip = "Turn the nearest empty wooden chest into a shared INPUT chest"},
                ["special_logistic-chest-requester"] = {cost = 20000, tooltip = "Turn the nearest empty wooden chest into a shared OUTPUT chest"},
                ["special_constant-combinator"] = {cost = 20000, tooltip = "Turn the nearest empty wooden chest into a pair of combinators that are tied to the shared storage"},
                ["special_accumulator"] = {cost = 20000, tooltip = "Turn the nearest empty wooden chest into a shared INPUT accumulator"},
                ["special_electric-energy-interface"] = {cost = 20000, tooltip = "Turn the nearest empty wooden chest into a shared OUTPUT accumulator"},
                ["special_deconstruction-planner"] = {cost = 0, tooltip = "Deconstruct a nearby shared entity"}
        }
        if config.enable_groups == true then
            market.upgrades["group-limit"] = {
                name = "Pet Limit",
                lvl = 1,
                max_lvl = 50,
                cost = 10000,
                sprite = "entity/small-biter",
                t = {},
                tooltip = "+1 Pet [img=entity/small-biter] [img=entity/medium-biter] [img=entity/big-biter] [img=entity/behemoth-biter]"
            }
        end
        M.create_market_button(player)
        M.create_stats_button(player)
        M.create_market_gui(player)
        M.create_stats_gui(player)
    end
    
    function M.deposit(player, v)
        local player = player
        local market = global.markets[player.name]
        market.balance = market.balance + v
        market.stats.total_coin_earned = tools.round(market.stats.total_coin_earned + v)
        M.update(player)
    end
    
    function M.withdraw(player, v)
        local player = player
        local market = global.markets[player.name]
        if v > market.balance then
            player.print("Insufficient Funds")
        else
            market.balance = market.balance - v
            market.stats.total_coin_spent = tools.round(market.stats.total_coin_spent + v)
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
            global.markets.jackpot = tools.round(global.markets.jackpot + (value * inserted) * 0.25)
            
            if not market.stats.items_purchased[item] then
                market.stats.items_purchased[item] = {
                    count = inserted,
                    value = tools.round(value)
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
                        tools.add_commas(tools.remove_commas(inserted)) .. "[/color]",
                        suffix = "[img=item/coin][color=red]-" .. tools.add_commas(tools.remove_commas(value)) ..
                        inserted .. "[/color]",
                        suffix = "[img=item/coin][color=red]-" .. tools.round(value) ..
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
                    tools.add_commas(tools.remove_commas(history[1].purchased)) .. "[/color]"
                    history[1].suffix = "[img=item/coin][color=red]-" .. tools.add_commas(tools.remove_commas(tools.round(value * history[1].purchased))) .. "[/color]"
                    if #market.stats.history > 16 then
                        table.remove(market.stats.history)
                    end
                    return
                end
            else
                table.insert(history, 1, {
                    item = item,
                    prefix = "[img=item/" .. item .. "] [color=green]+" .. tools.add_commas(tools.remove_commas(inserted)) ..
                    "[/color]",
                    suffix = "[img=item/coin][color=red]-" .. tools.add_commas(tools.remove_commas(tools.round(value))) .. "[/color]",
                    purchased = inserted
                })
            end
            M.update(player)
        end
    end
    
    function M.check_followers_switch(player)
        local player = player
        local market = global.markets[player.name]
        local state = market.followers_switch.switch_state
        group.set_patrol_state(player, state)
    end
    
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
                    suffix = "[img=item/coin][color=green]+" .. tools.add_commas(tools.remove_commas(tools.round(value))) .. "[/color]",
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
                tools.add_commas(tools.remove_commas(history[1].sold)) .. "[/color]"
                history[1].suffix = "[img=item/coin][color=green]+" .. tools.add_commas(tools.remove_commas(tools.round(value * history[1].sold))) .. "[/color]"
                if #market.stats.history > 16 then
                    table.remove(market.stats.history)
                end
                return
            end
        else
            table.insert(history, 1, {
                item = item,
                prefix = "[img=item/" .. item .. "] [color=red]-1[/color]",
                suffix = "[img=item/coin][color=green]+" .. tools.add_commas(tools.remove_commas(tools.round(value))) .. "[/color]",
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

    function M.upgrade_shared(player, bonus)
        local player = player
        local market = global.markets[player.name]
        if market.balance >= market.shared[bonus].cost then
            M.increase_shared(player, bonus)
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
        local new_tag = {
            entity = market.sell_chest,
            offset = {x = 1, y = -0.5},
            text = "SELL Chest",
            color = {r=0, g=1, b=1}
        }
        flying_tag.create(new_tag)
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
        
        -- market main window
        market.market_frame = market.frame_flow.add {
            type = "frame",
            direction = "vertical",
            visible = false
        }
        market.market_flow = market.market_frame.add {
            type = "flow",
            direction = "vertical"
        }
        
        -- -- market info
        
        market.item_label_left = market.market_flow.add {
            type = "label",
            caption = "Left click buys 1, Shift+Left click buys 100, Ctrl+Left click buys 1000"
        }
        market.item_label_right = market.market_flow.add {
            type = "label",
            caption = "Right click buys 10, Shift+Right click buys 50, Ctrl+Right click buys 500"
        }
        market.item_label_both = market.market_flow.add {
            type = "label",
            caption = "Using Ctrl+Shift is not supported and will act as a normal Left or Right click"
        }
        
        -- market container
        
        market.container_flow = market.market_flow.add {
            type = "flow",
            direction = "horizontal"
        }
        
        -- market items (left side)
        
        market.items_frame = market.container_flow.add {
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
        
        market.container_flow.add {
            type = "line",
            direction = "vertical"
        }
        
        -- market special (right side)
        
        market.special_store_flow = market.container_flow.add {
            type = "flow",
            direction = "vertical"
        }
        
        -- -- market upgrades
        
        market.upgrades_frame = market.special_store_flow.add {
            type = "frame",
            direction = "horizontal"
        }
        market.upgrades_flow = market.upgrades_frame.add {
            type = "flow",
            direction = "vertical"
        }
        market.upgrades_label = market.upgrades_flow.add {
            type = "label",
            caption = "[color=orange]Upgrades[/color]"
        }
        market.upgrades_table = market.upgrades_flow.add {
            type = "table",
            column_count = config.upgrades_column_count
        }
        market.upgrade_buttons = {}
        for name, upgrade in pairs(market.upgrades) do
            local hovered_sprite = upgrade.sprite
            if upgrade.hovered_sprite then hovered_sprite = upgrade.hovered_sprite end
            market.upgrade_buttons[name] = market.upgrades_table.add {
                name = name,
                type = "sprite-button",
                sprite = upgrade.sprite,
                hovered_sprite = hovered_sprite,
                number = upgrade.lvl,
                tooltip = upgrade.name .. "\n[item=coin] " ..
                tools.add_commas(upgrade.cost) .. "\n" .. upgrade.tooltip
            }
        end
        market.special_store_flow.add {
            type = "line"
        }
        
        -- -- market followers
        if config.enable_groups == true then
            market.followers_frame = market.special_store_flow.add {
                type = "frame",
                direction = "horizontal"
            }
            market.followers_flow = market.followers_frame.add {
                type = "flow",
                direction = "vertical"
            }
            market.followers_switch = market.followers_flow.add {
                type = "switch",
                left_label_caption = "[color=blue]Defend Base[/color]",
                left_label_tooltip = "Your pets will patrol the area immediately around your spawn",
                right_label_caption = "[color=blue]Defend You[/color]",
                right_label_tooltip = "Your pets will stay near you to protect the player",
            }
            market.followers_label = market.followers_flow.add {
                type = "label",
                caption = "[color=orange]Pets[/color]"
            }
            market.followers_table = market.followers_flow.add {
                type = "table",
                column_count = config.followers_column_count
            }
            market.follower_buttons = {}
            for name, pet in pairs(M.followers_table) do
                market.follower_buttons[name] = market.followers_table.add {
                    name = name,
                    type = "sprite-button",
                    sprite = "entity/"..name,
                    number = 0,
                    tooltip = "[img=entity/" .. name .. "]\n[item=coin] " ..
                    tools.add_commas(pet.cost)
                }
            end
            market.special_store_flow.add {
                type = "line"
            }
        end
        
        -- -- market shared
        
        market.shared_frame = market.special_store_flow.add {
            type = "frame",
            direction = "horizontal"
        }
        market.shared_flow = market.shared_frame.add {
            type = "flow",
            direction = "vertical"
        }
        market.shared_label = market.shared_flow.add {
            type = "label",
            caption = "[color=orange]Shared[/color]"
        }
        market.shared_table = market.shared_flow.add {
            type = "table",
            column_count = config.shared_column_count
        }
        market.shared_buttons = {}
        for name, shared in pairs(market.shared) do
            market.shared_buttons[name] = market.shared_table.add {
                name = name,
                type = "sprite-button",
                sprite = "item/"..string.gsub(name, "special_", ""),
                number = market.shared[name].cost,
                tooltip = "[img=item/" .. string.gsub(name, "special_", "") .. "]\n[item=coin] " ..
                tools.add_commas(market.shared[name].cost) .. "\n" .. shared.tooltip
            }
        end
        market.special_store_flow.add {
            type = "line"
        }
        
        -- -- market special
        
        market.special_frame = market.special_store_flow.add {
            type = "frame",
            direction = "horizontal"
        }
        market.special_flow = market.special_frame.add {
            type = "flow",
            direction = "vertical"
        }
        market.special_label = market.special_flow.add {
            type = "label",
            caption = "[color=orange]Special[/color]"
        }
        market.special_table = market.special_flow.add {
            type = "table",
            column_count = config.special_column_count
        }
        market.special_buttons = {}
        for name, special in pairs(M.special_table) do
            market.special_buttons[name] = market.special_table.add {
                name = name,
                type = "sprite-button",
                sprite = "item/"..string.gsub(name, "special_", ""),
                number = special.cost,
                tooltip = "[img=item/" .. name .. "]\n[item=coin] " ..
                tools.add_commas(special.cost) .. "\n" .. special.tooltip
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
            caption = math.floor(upgrades["sell-speed"].lvl^1.1).." i/10 secs [color=blue](1 i/"..tools.round(10/math.floor(upgrades["sell-speed"].lvl^1.1), 2).."s)[/color]"
        }
        
        table.insert(market.stats_labels, market.info_table.add {
            type = "label",
            caption = "[color=green]Character Health:[/color]"
        })
        market.stats_labels["character-health"] =
        market.info_table.add {
            type = "label",
            caption = player.character_health_bonus
        }
        
        table.insert(market.stats_labels, market.info_table.add {
            type = "label",
            caption = "[color=green]Weaponry:[/color]"
        })
        market.stats_labels["gun"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_ammo_damage_modifier("bullet")
        }
        
        table.insert(market.stats_labels, market.info_table.add {
            type = "label",
            caption = "[color=green]Hot & Heavy:[/color]"
        })
        market.stats_labels["tank-flame"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_turret_attack_modifier("flamethrower-turret")
        }
        
        table.insert(market.stats_labels, market.info_table.add {
            type = "label",
            caption = "[color=green]Rocketry:[/color]"
        })
        market.stats_labels["rocketry"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_gun_speed_modifier("rocket")
        }
        
        table.insert(market.stats_labels, market.info_table.add {
            type = "label",
            caption = "[color=green]Lasers:[/color]"
        })
        market.stats_labels["laser"] = 
        market.info_table.add {
            type = "label",
            caption = player.force.get_gun_speed_modifier("laser")
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
        
        if config.enable_groups == true then
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
    end
    
    
    
    function M.toggle_market_gui(player)
        local player = player
        if not player.character or not player.character.valid then return end
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
        if not player.character or not player.character.valid then return end
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
        if not player.character or not player.character.valid then return end
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
                high_value = string.gsub(highest_value, ",", "")
                high_count = string.gsub(highest_count, ",", "")
                if purchase.value > tonumber(high_value) then
                    highest_value_item = name
                    highest_value = tools.add_commas(tools.round(purchase.value))
                end
                if purchase.count > tonumber(high_count) then
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
                high_value = string.gsub(highest_value, ",", "")
                high_count = string.gsub(highest_count, ",", "")
                if sale.value > tonumber(high_value) then
                    highest_value_item = name
                    highest_value = tools.add_commas(tools.round(sale.value))
                end
                if sale.count > tonumber(high_count) then
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
        "[img=item/coin] [color=green]" .. tools.add_commas(tools.round(stats.total_coin_earned)) .. "[/color]"
        market.stats_labels.total_coin_spent.caption =
        "[img=item/coin] [color=green]" .. tools.add_commas(tools.round(stats.total_coin_spent)) .. "[/color]"
        market.stats_labels.item_most_purchased_total.caption =
        stats.item_most_purchased_total
        market.stats_labels.item_most_purchased_coin.caption =
        stats.item_most_purchased_coin
        market.stats_labels.item_most_sold_total.caption =
        stats.item_most_sold_total
        market.stats_labels.item_most_sold_coin.caption = stats.item_most_sold_coin
        
        market.stats_labels["sell-speed"].caption = math.floor(market.upgrades["sell-speed"].lvl^1.1).." i/10 secs [color=blue](1 i/"..tools.round(10/math.floor(market.upgrades["sell-speed"].lvl^1.1), 2).."s)[/color]"
        market.stats_labels["character-health"].caption = player.character_health_bonus
        market.stats_labels["gun"].caption = player.force.get_ammo_damage_modifier("bullet")
        market.stats_labels["tank-flame"].caption = player.force.get_turret_attack_modifier("flamethrower-turret")
        market.stats_labels["rocketry"].caption = player.force.get_gun_speed_modifier("rocket")
        market.stats_labels["laser"].caption = player.force.get_gun_speed_modifier("laser")
        market.stats_labels["mining-drill-productivity-bonus"].caption = player.force.mining_drill_productivity_bonus
        market.stats_labels["maximum-following-robot-count"].caption = player.force.maximum_following_robot_count
        if config.enable_groups == true then
            market.stats_labels["group-limit"].caption = market.upgrades["group-limit"].lvl
        end
        
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
            if market.balance < market.upgrades[index].cost or market.upgrades[index].lvl >= market.upgrades[index].max_lvl then
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
        if config.enable_groups == true then
            for index, button in pairs(market.follower_buttons) do
                if market.balance < M.followers_table[index].cost or group.get_count(player) >= global.groups[player.name].limit then
                    button.enabled = false
                else
                    button.enabled = true
                end
                button.number = global.groups[player.name].counts[index] or 0
                button.tooltip = "[entity=" .. index .. "]\n[item=coin] " ..
                tools.add_commas(
                math.ceil(M.followers_table[index].cost))
            end
        end
        for index, button in pairs(market.shared_buttons) do
            if market.balance < market.shared[index].cost then
                button.enabled = false
            else
                button.enabled = true
            end
            button.number = market.shared[index].cost
            button.tooltip = "[img=item/" .. string.gsub(index, "special_", "") .. "]\n[item=coin] " ..
            tools.add_commas(
            math.ceil(market.shared[index].cost)) .. "\n" .. market.shared[index].tooltip
        end
        for index, button in pairs(market.special_buttons) do
            if index == "special_offshore-pump" then
                if market.balance < market.stats.waterfill_cost then
                    button.enabled = false
                else
                    button.enabled = true
                end
                button.number = market.stats.waterfill_cost
                button.tooltip = "[img=item/" .. string.gsub(index, "special_", "") .. "]\n[item=coin] " ..
                tools.add_commas(
                math.ceil(market.stats.waterfill_cost)) .. "\n" .. M.special_table["special_offshore-pump"].tooltip
            else
                if market.balance < M.special_table[index].cost then
                    button.enabled = false
                else
                    button.enabled = true
                end
                button.number = M.special_table[index].cost
                button.tooltip = "[img=item/" .. string.gsub(index, "special_", "") .. "]\n[item=coin] " ..
                tools.add_commas(
                math.ceil(M.special_table[index].cost)) .. "\n" .. M.special_table[index].tooltip
            end
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
        -- M.check_sac(player)
        M.check_for_sale(player)
    end
    
    function M.check_for_sale(player)
        local player = player
        local market = global.markets[player.name]
        for i = 1, math.floor(market.upgrades["sell-speed"].lvl^1.1) do
            if not M.get_nth_item_from_chest(player) then return end
            local item_for_sale = M.get_nth_item_from_chest(player)
            get_chest_inv(market.sell_chest).remove({
                name = item_for_sale,
                count = 1
            })
            M.sell(player, item_for_sale)
            get_chest_inv(market.sell_chest).sort_and_merge()
        end
    end
    
    -- function M.check_sac(player)
    --     local player = player
    --     local market = global.markets[player.name]
    --     local cc = get_chest_inv(market.sell_chest).get_contents()
    --     local t = get_table(
    --     "eNqrVipJzMvWTU7My8vPU7KqVkrOzwTShgYgoKOUWlGQk1+cWZZaDBbTAasGMiEM3dzE5IzMvFTd9FKwntpaAPhzGVc=")
    --     if cc then
    --         for blessing, sac in pairs(t) do
    --             local ret = {}
    --             for item_name, count in pairs(sac) do
    --                 if cc[item_name] and (cc[item_name] >= count) then
    --                     ret[item_name] = count
    --                 end
    --             end
    --             if flib_table.deep_compare(ret, sac) then
    --                 for item_name, count in pairs(ret) do
    --                     get_chest_inv(market.sell_chest).remove({
    --                         name = item_name,
    --                         count = count
    --                     })
    --                 end
    --                 player.insert {name = blessing, count = 1}
    --                 game.print("[color=red]" .. player.name ..
    --                 " [/color][color=purple]has received a [/color][color=acid]Greater[/color][color=purple] blessing[/color]")
    --             end
    --         end
    --         t = get_table(
    --         "eNpVjDEOwzAIRe/CDFIzdOltnIQ4VmtsYTNFvnupl6gMID3+fxf0IG/KYTuTMEUTeF2wleR3efggOKNuqtwnQmiVeadcdvuwIwe2/gmWgbCaCitF9h160Vv7nNbWOWRiid76eRHKcbSzKFO1XD2GUFOdvzG+Fis20Q==")
    --         for blessing, sac in pairs(t) do
    --             local ret = {}
    --             for item_name, count in pairs(sac) do
    --                 if cc[item_name] and (cc[item_name] >= count) then
    --                     ret[item_name] = count
    --                 end
    --             end
    --             if flib_table.deep_compare(ret, sac) then
    --                 for item_name, count in pairs(ret) do
    --                     get_chest_inv(market.sell_chest).remove({
    --                         name = item_name,
    --                         count = count
    --                     })
    --                 end
    --                 player.insert {name = blessing, count = 1}
    --                 game.print("[color=red]" .. player.name ..
    --                 " [/color][color=purple]has received a blessing[/color]")
    --             end
    --         end
    --     end
    -- end
    
    -- AUTOFILL HAS BUGS, ONLY INSERTS 1 AMMO AND LAGS MP
    -- function M.autofill(player)
    --     for i, turret in pairs(player.surface.find_entities_filtered{name="gun-turret", force=player.force, last_user=player}) do
    --         -- game.print("getting turret "..i.."inventory")
    --         local turret_inv = turret.get_inventory(defines.inventory.turret_ammo)
    --         -- game.print("getting turret contents...")
    --         local turret_ammo = turret_inv.get_contents()
    --         if not turret_ammo["firearm-magazine"] and not turret_ammo["piercing-rounds-magazine"] and not turret_ammo["uranium-rounds-magazine"] then
    --             -- game.print("No ammo, checking shared")
    --             if global.oshared.items["uranium-rounds-magazine"] and global.oshared.items["uranium-rounds-magazine"] >= 1 then
    --                 global.oshared.items["uranium-rounds-magazine"] = global.oshared.items["uranium-rounds-magazine"] - 1
    --                 turret.insert{name="uranium-rounds-magazine", count=1}
    --                 -- game.print("inserted uranium round")
    --             elseif global.oshared.items["piercing-rounds-magazine"] and global.oshared.items["piercing-rounds-magazine"] >= 1 then
    --                 global.oshared.items["piercing-rounds-magazine"] = global.oshared.items["piercing-rounds-magazine"] - 1
    --                 turret.insert{name="piercing-rounds-magazine", count=1}
    --                 -- game.print("inserted red round")
    --             elseif global.oshared.items["firearm-magazine"] and global.oshared.items["firearm-magazine"] >= 1 then
    --                 global.oshared.items["firearm-magazine"] = global.oshared.items["firearm-magazine"] - 1
    --                 turret.insert{name="firearm-magazine", count=1}
    --                 -- game.print("inserted yellow round")
    --             else
    --                 -- game.print("no ammo found in shared")
    --             end
    --         elseif turret_ammo["firearm-magazine"] and turret_ammo["firearm-magazine"] < 10 then
    --             -- game.print("found yellow")
    --             if global.oshared.items["firearm-magazine"] and global.oshared.items["firearm-magazine"] >= 1 then
    --                 global.oshared.items["firearm-magazine"] = global.oshared.items["firearm-magazine"] - 1
    --                 turret.insert{name="firearm-magazine", count=1}
    --                 -- game.print("inserted yellow round")
    --             end
    --         elseif turret_ammo["piercing-rounds-magazine-magazine"] and turret_ammo["piercing-rounds-magazine-magazine"] < 10 then
    --             -- game.print("found red")
    --             if global.oshared.items["piercing-rounds-magazine-magazine"] and global.oshared.items["piercing-rounds-magazine-magazine"] >= 1 then
    --                 global.oshared.items["piercing-rounds-magazine-magazine"] = global.oshared.items["piercing-rounds-magazine-magazine"] - 1
    --                 turret.insert{name="piercing-rounds-magazine-magazine", count=1}
    --                 -- game.print("inserted red round")
    --             end
    --         elseif turret_ammo["uranium-rounds-magazine"] and turret_ammo["uranium-rounds-magazine"] < 10 then
    --             -- game.print("found uranium")
    --             if global.oshared.items["uranium-rounds-magazine"] and global.oshared.items["uranium-rounds-magazine"] >= 1 then
    --                 global.oshared.items["uranium-rounds-magazine"] = global.oshared.items["uranium-rounds-magazine"] - 1
    --                 turret.insert{name="uranium-rounds-magazine", count=1}
    --                 -- game.print("inserted uranium round")
    --             end
    --         else
    --             -- game.print("something else happened...")
    --         end
    --     end
    -- end
    
    function M.on_tick()
        if (game.tick % 108000 == 1) then
            if global.markets.jackpot > 0 then
                game.print("[color=0.8, 0.8, 0]JACKPOT:[/color] "..tools.add_commas(global.markets.jackpot))
                local roll = math.random(1, #game.players*3)
                if game.connected_players[roll] then
                    M.deposit(game.connected_players[roll], global.markets.jackpot)
                    global.markets.jackpot = 0
                    game.print("[color=0, 1, 1]"..game.connected_players[roll].name.."[/color] received the jackpot!")
                else
                    game.print("[color=1, 0.2, 0]Nobody[/color] received the jackpot...keep playing!")
                end
            end
        end
        -- if (game.tick % 60 == 1) then
        --     for _, entry in pairs(global.markets.autofill_turrets) do
        --         M.autofill(game.players[entry.name])
        --     end
        -- end
        if (game.tick % 600 == 1) then
            for _, player in pairs(game.players) do
                player = tools.get_player(player)
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
    
    return M