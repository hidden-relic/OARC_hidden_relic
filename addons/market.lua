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
    local nil_items = {
        ["electric-energy-interface"] = true,
        ["rocket-part"] = true
    }
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

    if not global.ocore.markets.player_markets then
        global.ocore.markets.player_markets = {}
    end
    if not global.ocore.markets.player_markets[player.name] then
        global.ocore.markets.player_markets[player.name] = {}
    end

    global.ocore.markets.player_markets[player.name].chest = chest
    global.ocore.markets.player_markets[player.name].market = market

    TemporaryHelperText(
        "The market allows you to buy items and upgrades for coin.",
        {market.position.x, market.position.y + 1.5}, TICKS_PER_MINUTE * 2,
        {r = 1, g = 0, b = 1})
    TemporaryHelperText("It seems this chest will sell items periodically, but holds other secrets..",
                        {chest.position.x + 1.5, chest.position.y - 0.5},
                        TICKS_PER_MINUTE * 2, {r = 1, g = 0, b = 1})

    for __, item in pairs(markets.upgrade_offers) do
        market.add_market_item(item)
    end
    global.ocore.markets.player_markets[player.name].sell_speed_lvl, global.ocore
        .markets.player_markets[player.name].sell_speed_offer, global.ocore
        .markets.player_markets[player.name].sell_speed_multiplier = 1,
                                                                     market.get_market_items()[20],
                                                                     10
    for __, item in pairs(global.ocore.markets.buy_offers) do
        if not nil_items[item.name] then   
        market.add_market_item(item)
    end
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
    end
end

function markets.getTTS(player_name)
    local player_market = global.ocore.markets.player_markets[player_name]
    local item = player_market.current_item
    local energy = 1
    if game.recipe_prototypes[item] then
        energy = game.recipe_prototypes[item].energy
    end
    local energy_ticks = (energy * 60)
    return (game.tick + energy_ticks * player_market.sell_speed_multiplier)
end

local function checkSacTier1(chest_inv)
    local ci = chest_inv
    local cc = ci.get_contents()
    if cc then
        local function checkForItem(item_name, n)
            local n = n or 1
            if (cc[item_name] and cc[item_name] >= n) then
                return true
            else
                return
            end
        end
        local cfi = checkForItem
        if (cfi("submachine-gun", 10) and cfi("coin", 10000)) and (cfi("gun-turret", 100) and cfi("speed-module-1")) then
            ci.remove({name = "submachine-gun", count = 10})
            ci.remove({name = "coin", count = 10000})
            ci.remove({name = "gun-turret", count = 100})
            ci.remove({name = "speed-module", count = 1})
            return true
        end
    end
    return false
end
local function checkSacTier2(chest_inv)
local ci = chest_inv
    local cc = ci.get_contents()
    if cc then
        local function checkForItem(item_name, n)
            local n = n or 1
            if (cc[item_name] and cc[item_name] >= n) then
                return true
            else
                return
            end
        end
        local cfi = checkForItem
        if (cfi("tank-machine-gun", 10) and cfi("coin", 100000)) and (cfi("tank") and cfi("explosives", 100)) then
            ci.remove({name = "tank-machine-gun", count = 10})
            ci.remove({name = "coin", count = 100000})
            ci.remove({name = "tank", count = 1})
            ci.remove({name = "explosives", count = 100})
            return true
        end
    end
    return false
end

function markets.checkSac(chest_inv)
    local chest_inv = chest_inv
    if chest_inv and chest_inv.valid then
        if checkSacTier1(chest_inv) then
            chest_inv.insert("tank-machine-gun")
            return 1
        elseif checkSacTier2(chest_inv) then
            chest_inv.insert("tank-cannon")
            return 2
        end
    else
    return false
    end
end

function markets.on_tick()
    local gp = game.print
    if (game.tick % 10 == 0) and global.ocore.markets.player_markets then
        for player_name, player_market in pairs(
                                              global.ocore.markets
                                                  .player_markets) do -- for each player market
            local chest_inv = markets.getChestInv(player_market.chest) -- get red chest
            local sac_ret = markets.checkSac(chest_inv)
            if sac_ret == 1 then
                gp("[color=red]" .. player_name ..
                               " [/color][color=purple]has received a blessing[/color]")
            elseif sac_ret == 2 then
                gp("[color=red]" .. player_name ..
                " [/color][color=purple]has received a [/color][color=acid]Greater[/color][color=purple] blessing[/color]")
 
                            end

            local item_name = getNthItemFromChest(chest_inv) -- get 1st item

            if player_market.tts and (game.tick >= player_market.tts) then -- if sale overdue
                getSale(chest_inv, player_market.current_item) -- get coin
                player_market.tts, player_market.current_item = nil

            elseif player_market.tts and (game.tick < player_market.tts) then
                return -- if sale ongoing

            elseif not player_market.tts and item_name then -- if no sale and item in chest
                player_market.current_item = item_name -- make it current item and remove and set the sale time
                chest_inv.remove({name = item_name, count = 1})
                player_market.tts = markets.getTTS(player_name)
            else
                return
            end
        end
    end
end
return markets
