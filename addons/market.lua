local tools = require('addons/tools')

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

function markets.formatPrices()
    local markets = markets
    for name, value in pairs(global.ocore.markets.item_values) do
        if game.item_prototypes[name] then
            if value < 65535 then
                global.ocore.markets.buy_offers[name] = {
                    price = {{"coin", value}},
                    offer = {type = "give-item", item = name, count = 1}
                }
                global.ocore.markets.sell_offers[name] = tools.round(value *
                                                                         0.75)
            elseif value > 65535 then
                local its = math.floor(value / 65535)
                global.ocore.markets.buy_offers[name] = {
                    price = {},
                    offer = {type = "give-item", item = name, count = 1}
                }
                for i = 1, its, 1 do
                    table.insert(global.ocore.markets.buy_offers[name].price,
                                 {"coin", 65535})
                end
                table.insert(global.ocore.markets.buy_offers[name].price,
                             {"coin", (value % 65535)})
            end
        end
    end
end

function markets.init()
    global.ocore.markets.item_values = tools.sortByValue(markets.getPrices())
    game.write_file("market/item_values.lua",
                    serpent.block(global.ocore.markets.item_values))
    markets.formatPrices()
end
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

function markets.create(player, position)
    local player = player
    local position = position
    local market = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "market",
        position = position,
        force = "neutral"
    }
    local chest = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "steel-chest",
        position = {x = position.x + 6, y = position.y},
        force = "neutral"
    }
    tools.protect_entity(market)
    tools.protect_entity(chest)

    global.ocore.markets[player.name].chest = chest
    global.ocore.markets[player.name].market = market

    TemporaryHelperText(
        "The market allows you to buy items and upgrades for coin.",
        {market.position.x, market.position.y + 1.5}, TICKS_PER_MINUTE * 2,
        {r = 1, g = 0, b = 1})
    TemporaryHelperText("Dump items to chest to sell for coin.",
                        {chest.position.x + 1.5, chest.position.y - 0.5},
                        TICKS_PER_MINUTE * 2, {r = 1, g = 0, b = 1})

    for __, item in pairs(markets.upgrade_offers) do
        market.add_market_item(item)
    end
    global.ocore.markets[player.name].sell_speed_lvl, global.ocore.markets[player.name]
        .sell_speed_offer, global.ocore.markets[player.name]
        .sell_speed_multiplier = 1, market.get_market_items()[20], 10
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
    local chest_inv, item, markets = chest_inv, item, markets
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
                            if item_name then -- if new item
                                player_market.current_item = item_name -- make current
                                player_market.tts = markets.getTTS(player)
                            else
                                player_market.current_item, player_market.tts =
                                    nil
                            end
                        else
                            getSale(chest_inv, player_market.current_item)
                            player_market.tts = markets.getTTS(player)

                        end
                    else
                        if item_name then -- if new item
                            player_market.current_item = item_name -- make current
                            player_market.tts = markets.getTTS(player)
                        end
                    end
                elseif not player_market.tts and item_name then
                    player_market.current_item = item_name -- make current
                    player_market.tts = markets.getTTS(player)
                end
            end
        end
    end
end

return markets
