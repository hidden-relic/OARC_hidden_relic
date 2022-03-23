local tools = require('addons/tools')
require 'util/Colors'

local markets = {}

markets.p_stats = require('production-score')

markets.upgrade_offers = {
    {
        price = {{"coin", 1000}},
        offer = {type = "gun-speed", ammo_category = "bullet", modifier = 0.01}
    }, {
        price = {{"coin", 1000}},
        offer = {
            type = "gun-speed",
            ammo_category = "shotgun-shell",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 1000}},
        offer = {
            type = "gun-speed",
            ammo_category = "landmine",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 1000}},
        offer = {type = "gun-speed", ammo_category = "grenade", modifier = 0.01}
    }, {
        price = {{"coin", 2500}},
        offer = {
            type = "gun-speed",
            ammo_category = "cannon-shell",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2500}},
        offer = {
            type = "gun-speed",
            ammo_category = "flamethrower",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 5000}},
        offer = {type = "gun-speed", ammo_category = "rocket", modifier = 0.01}
    }, {
        price = {{"coin", 10000}},
        offer = {type = "gun-speed", ammo_category = "laser", modifier = 0.01}
    }, {
        price = {{"coin", 2000}},
        offer = {
            type = "ammo-damage",
            ammo_category = "bullet",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2000}},
        offer = {
            type = "ammo-damage",
            ammo_category = "shotgun-shell",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2000}},
        offer = {
            type = "ammo-damage",
            ammo_category = "landmine",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2000}},
        offer = {
            type = "ammo-damage",
            ammo_category = "grenade",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2500}},
        offer = {
            type = "ammo-damage",
            ammo_category = "cannon-shell",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 2500}},
        offer = {
            type = "ammo-damage",
            ammo_category = "flamethrower",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 5000}},
        offer = {
            type = "ammo-damage",
            ammo_category = "rocket",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 10000}},
        offer = {type = "ammo-damage", ammo_category = "laser", modifier = 0.01}
    }, {
        price = {{"coin", 5000}},
        offer = {
            type = "turret-attack",
            turret_id = "gun-turret",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 30000}},
        offer = {
            type = "turret-attack",
            turret_id = "flamethrower-turret",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 50000}},
        offer = {
            type = "turret-attack",
            turret_id = "laser-turret",
            modifier = 0.01
        }
    }, {
        price = {{amount = 10000, name = "coin", type = "item"}},
        offer = {
            effect_description = {'market.sell_speed_desc'},
            type = "nothing"
        }
    }
}

function markets.getPrices()
    global.ocore.markets.buy_offers = {}
    global.ocore.markets.sell_offers = {}
    return markets.p_stats.generate_price_list()
end

function markets.formatPrice(n)
    local n = n or 0
    if n <= 65535 then
        return {{"coin", n}}
    elseif n > 65535 then
        local its = math.floor(n / 65535)
        local t = {}
        for i = 1, its, 1 do table.insert(t, {"coin", 65535}) end
        table.insert(t, {"coin", (n % 65535)})
        return t
    end
end

function markets.unFormatPrice(price)
    local price = price or {{amount = 0, name = "coin", type = "item"}}
    local uform = 0
    for __, single_amount in pairs(price) do
        uform = single_amount.amount and (uform + single_amount.amount) or
                    (uform + single_amount[2])
    end
    return uform
end

function markets.formatPrices()
    local markets = markets
    for name, value in pairs(global.ocore.markets.item_values) do
        if game.item_prototypes[name] then
            global.ocore.markets.buy_offers[name] = {
                price = markets.formatPrice(value),
                offer = {type = "give-item", item = name, count = 1}
            }
            global.ocore.markets.sell_offers[name] = tools.round(value * 0.75)
        end
    end
end

function markets.init()
    local nil_items = {
        ["electric-energy-interface"] = true,
        ["rocket-part"] = true
    }
    global.ocore.markets.item_values = tools.sortByValue(markets.getPrices())
    for name, price in pairs(global.ocore.markets.item_values) do
        global.ocore.markets.item_values[name] = math.ceil(price)
    end
    for name, _ in pairs(nil_items) do
        if global.ocore.markets.item_values[name] then
            global.ocore.markets.item_values[name] = nil
        end
    end
    game.write_file("market/item_values.lua",
                    serpent.block(global.ocore.markets.item_values))
    markets.formatPrices()
end

function markets.getInfo(player_name)
    if game.players[player_name] then
        local player = game.players[player_name]
    end
    local omarket = global.ocore.markets[player_name]
    local str = "[color=green]Market Info for [/color][color=blue]" ..
                    player_name .. "[/color][color=orange]:[/color]\n"
    local upgrades = {}
    str = str .. "\t[color=purple]Upgrades[/color][color=orange]:[/color]\n"
    str = str .. "\t\t[color=yellow]Speed[/color][color=orange]:[/color]\n"
    for ammo, upgrade in pairs(omarket.upgrades["gun-speed"]) do
        local t = {
            name = ammo,
            level = upgrade.level,
            onus = upgrade.bonus,
            modifier = upgrade.modifier,
            price = upgrade.price
        }
        str = str .. "\t\t\t[color=grey]" .. t.name ..
                  "[/color][color=orange]:[/color]\t[color=green]Lvl [/color][color=red]" ..
                  t.level ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Bonus [/color][color=red]" ..
                  t.bonus ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Modifier [/color][color=red]" ..
                  t.modifier ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Current Price [/color][color=red]" ..
                  t.price .. "[/color]\n"
    end
    str = str .. "\n\t\t[color=yellow]Damage[/color][color=orange]:[/color]\n"
    for ammo, upgrade in pairs(omarket.upgrades["ammo-damage"]) do
        local t = {
            name = ammo,
            level = upgrade.level,
            bonus = upgrade.bonus,
            modifier = upgrade.modifier,
            price = upgrade.price
        }
        str = str .. "\t\t\t[color=grey]" .. t.name ..
                  "[/color][color=orange]:[/color]\t[color=green]Lvl [/color][color=red]" ..
                  t.level ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Bonus [/color][color=red]" ..
                  t.bonus ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Modifier [/color][color=red]" ..
                  t.modifier ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Current Price [/color][color=red]" ..
                  t.price .. "[/color]\n"
    end
    str = str .. "\n\t\t[color=yellow]Turret[/color][color=orange]:[/color]\n"
    for ammo, upgrade in pairs(omarket.upgrades["turret-attack"]) do
        local t = {
            name = ammo,
            level = upgrade.level,
            bonus = upgrade.bonus,
            modifier = upgrade.modifier,
            price = upgrade.price
        }
        str = str .. "\t\t\t[color=grey]" .. t.name ..
                  "[/color][color=orange]:[/color]\t[color=green]Lvl [/color][color=red]" ..
                  t.level ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Bonus [/color][color=red]" ..
                  t.bonus ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Modifier [/color][color=red]" ..
                  t.modifier ..
                  "[/color]\t[color=grey]::[/color]\t[color=green]Current Price [/color][color=red]" ..
                  t.price .. "[/color]\n"
    end
    str = str ..
              "\n\t\t[color=yellow]Sell Speed[/color][color=orange]:[/color]\n\t\t\t[color=green]Lvl [/color][color=red]" ..
              omarket.sell_speed_lvl ..
              "[/color]\t[color=grey]::[/color]\t[color=green]Time Multiplier [/color][color=red]" ..
              omarket.sell_speed_multiplier .. "[/color]"
    return str
end

function markets.create(player, position)
    local player = player
    local omarket = global.ocore.markets[player.name]
    local position = position
    local market = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "market",
        position = position,
        force = "neutral"
    }
    local chest = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "red-chest",
        position = {x = position.x + 6, y = position.y},
        force = "neutral"
    }
    tools.protect_entity(market)
    tools.protect_entity(chest)

    omarket.chest = chest
    omarket.market = market
    omarket.upgrades = {}

    TemporaryHelperText(
        "The market allows you to buy items and upgrades for coin.",
        {market.position.x, market.position.y + 1.5}, TICKS_PER_MINUTE * 2,
        {r = 1, g = 0, b = 1})
    TemporaryHelperText("Dump items to chest to sell for coin.",
                        {chest.position.x + 1.5, chest.position.y - 0.5},
                        TICKS_PER_MINUTE * 2, {r = 1, g = 0, b = 1})

    for __, item in pairs(markets.upgrade_offers) do
        market.add_market_item(item)

        local t = {}
        t.type = item.offer.type

        if item.offer.ammo_category then
            t.ammo = item.offer.ammo_category
        end

        if item.offer.turret_id then t.ammo = item.offer.turret_id end

        t.price = markets.unFormatPrice(item.price)
        t.modifier = item.offer.modifier
        if t.type == "nothing" then
            t.ammo = "sell-speed"
            t.modifier = 1
        end

        if not omarket.upgrades then omarket.upgrades = {} end
        omarket.upgrades[t.type] = {}
        local the_type
        omarket.upgrades[t.type][t.ammo] = {
            level = 0,
            bonus = 0,
            modifier = t.modifier
        }
    end
    omarket.sell_speed_lvl, omarket.sell_speed_offer, omarket.sell_speed_multiplier =
        1, market.get_market_items()[20], 10
    for __, item in pairs(global.ocore.markets.buy_offers) do
        market.add_market_item(item)
    end
    return market
end

function markets.getChestInv(chest)
    local chest = chest
    return chest.get_inventory(defines.inventory.chest)
end

local function getNthItemFromChest(chest_inv, n)
    if (chest_inv == nil) then return end
    if (chest_inv.is_empty()) then return end
    local t, item_values, n, contents = {}, global.ocore.markets.item_values,
                                        n or 1, chest_inv.get_contents()
    for name, count in pairs(contents) do
        if item_values[name] then table.insert(t, name) end
        if #t == n then break end
    end
    return t[n]
end

local function getSale(chest_inv, item)
    local chest_inv, item = chest_inv, item
    if chest_inv.can_insert {
        name = "coin",
        count = global.ocore.markets.sell_offers[item]
    } then
        chest_inv.insert {
            name = "coin",
            count = global.ocore.markets.sell_offers[item]
        }
        chest_inv.remove({name = item, count = 1})
    end
end

function markets.getTTS(player)
    local player = player
    local player_market = global.ocore.markets[player.name]
    local item = player_market.current_item
    local energy = 1
    if game.recipe_prototypes[item] then
        energy = game.recipe_prototypes[item].energy
    end
    local energy_ticks = (energy * 60)
    return (game.tick + energy_ticks * player_market.sell_speed_multiplier)
end

-- if not player_market.sold then
--     player_market.sold = {}
-- end
-- if player_market.sold["submachine-gun"] and
--     player_market.sold["submachine-gun"] >= 100 and
--     not player_market.acquired["tank-machine-gun"] then
--     if player.main_inventory.can_insert {
--         name = "tank-machine-gun"
--     } then
--         player.insert {name = "tank-machine-gun"}
--         player_market.acquired["tank-machine-gun"] = true
--     else
--         if game.tick % TICKS_PER_MINUTE == 1 then
--             tools.notify(player,
--                          "Couldn't put reward in your inventory, trying chest instead..")
--         end
--         if chest_inv.can_insert {name = "tank-machine-gun"} then
--             chest_inv.insert {name = "tank-machine-gun"}
--             player_market.acquired["tank-machine-gun"] = true
--         else
--             if game.tick % TICKS_PER_MINUTE == 1 then
--                 tools.notify(player,
--                              "Make space in your inventory for your reward")
--             end
--         end
--     end
-- elseif player_market.sold["submachine-gun"] and
--     player_market.sold["submachine-gun"] >= 1000 and
--     not player_market.acquired["tank-cannon"] then
--     if player.main_inventory.can_insert {name = "tank-cannon"} then
--         player.insert {name = "tank-cannon"}
--         player_market.acquired["tank-cannon"] = true
--     else
--         if game.tick % TICKS_PER_MINUTE == 1 then
--             tools.notify(player,
--                          "Couldn't put reward in your inventory, trying chest instead..")
--         end
--         if chest_inv.can_insert {name = "tank-cannon"} then
--             chest_inv.insert {name = "tank-cannon"}
--             player_market.acquired["tank-cannon"] = true
--         else
--             if game.tick % TICKS_PER_MINUTE == 1 then
--                 tools.notify(player,
--                              "Make space in your inventory for your reward")
--             end
--         end
--     end
-- end

function markets.on_tick()
    if game.tick % 10 == 0 then
        for index, player in pairs(game.connected_players) do -- for each online player
            if global.ocore.markets[player.name] and player.character and
                player.character.valid then
                local player_market = global.ocore.markets[player.name] -- get market data
                local chest_inv = markets.getChestInv(player_market.chest)
                local item_name = getNthItemFromChest(chest_inv) -- get 1st item
                if player_market.tts and (game.tick >= player_market.tts) then -- if over timer
                    if player_market.current_item then -- if current item
                        if player_market.current_item ~= item_name then -- is different
                            getSale(chest_inv, player_market.current_item) -- get coin
                            draw_flying_text(player_market.chest,
                                             Colors.golden_rod, "+ " ..
                                                 global.ocore.markets
                                                     .sell_offers[player_market.current_item])
                            if item_name then -- if new item
                                player_market.current_item = item_name -- make current
                                player_market.tts = markets.getTTS(player)
                            else
                                player_market.current_item, player_market.tts =
                                    nil, nil
                            end
                        else
                            getSale(chest_inv, player_market.current_item)
                            draw_flying_text(player_market.chest,
                                             Colors.golden_rod, "+ " ..
                                                 global.ocore.markets
                                                     .sell_offers[player_market.current_item])
                            player_market.tts = markets.getTTS(player)

                        end
                    else
                        if item_name then -- if new item
                            chest_inv.remove{name=item_name}
                            player_market.current_item = item_name -- make current
                            player_market.tts = markets.getTTS(player)
                        end
                    end
                elseif not player_market.tts and item_name then
                    chest_inv.remove{name=item_name}
                    player_market.current_item = item_name -- make current
                    player_market.tts = markets.getTTS(player)
                end
            end
        end
    end
end

commands.add_command("marketinfo", "print a player's market info",
                     function(command)
    local player = game.players[command.player_index]
    if command.parameter and game.players[command.parameter] then
        player.print(market.getInfo(command.parameter))
    else
        player.print(market.getInfo(player.name))
    end
end)

return markets
