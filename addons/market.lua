local tools = require('addons/tools')
local flib_table = require('flib/table')
local market_surface_tiles = require('addons/market_surface_tiles')
local markets = {}

markets.p_stats = require('production-score')

markets.upgrade_offers = {
    {
        price = {{"coin", 50000}},
        offer = {type = "gun-speed", ammo_category = "bullet", modifier = 0.01}
    }, -- {
    --     price = {{"coin", 1000}},
    --     offer = {
    --         type = "gun-speed",
    --         ammo_category = "shotgun-shell",
    --         modifier = 0.01
    --     }
    -- },
    -- {
    --     price = {{"coin", 1000}},
    --     offer = {
    --         type = "gun-speed",
    --         ammo_category = "landmine",
    --         modifier = 0.01
    --     }
    -- },
    -- {
    --     price = {{"coin", 1000}},
    --     offer = {type = "gun-speed", ammo_category = "grenade", modifier = 0.01}
    -- },
    -- {
    --     price = {{"coin", 2500}},
    --     offer = {
    --         type = "gun-speed",
    --         ammo_category = "cannon-shell",
    --         modifier = 0.01
    --     }
    -- },
    {
        price = {{"coin", 50000}},
        offer = {
            type = "gun-speed",
            ammo_category = "flamethrower",
            modifier = 0.01
        }
    }, {
        price = {{"coin", 50000}},
        offer = {type = "gun-speed", ammo_category = "rocket", modifier = 0.01}
    }, {
        price = {{"coin", 50000}},
        offer = {type = "gun-speed", ammo_category = "laser", modifier = 0.01}
    }, {
        price = {{"coin", 50000}},

        offer = {
            type = "ammo-damage",
            ammo_category = "bullet",
            modifier = 0.01
        }
    }, -- {
    --     price = {{"coin", 2000}},
    --     offer = {
    --         type = "ammo-damage",
    --         ammo_category = "shotgun-shell",
    --         modifier = 0.01
    --     }
    -- },
    -- {
    --     price = {{"coin", 2000}},
    --     offer = {
    --         type = "ammo-damage",
    --         ammo_category = "landmine",
    --         modifier = 0.01
    --     }
    -- },
    -- {
    --     price = {{"coin", 2000}},
    --     offer = {
    --         type = "ammo-damage",
    --         ammo_category = "grenade",
    --         modifier = 0.01
    --     }
    -- },
    -- {
    --     price = {{"coin", 2500}},
    --     offer = {
    --         type = "ammo-damage",
    --         ammo_category = "cannon-shell",
    --         modifier = 0.01
    --     }
    -- },
    {

        price = {{"coin", 50000}},

        offer = {
            type = "ammo-damage",
            ammo_category = "flamethrower",
            modifier = 0.01
        }
    }, {

        price = {{"coin", 50000}},

        offer = {
            type = "ammo-damage",
            ammo_category = "rocket",
            modifier = 0.01
        }
    }, {

        price = {{"coin", 50000}},
        offer = {type = "ammo-damage", ammo_category = "laser", modifier = 0.01}
    }, {
        price = {{"coin", 50000}},

        offer = {
            type = "turret-attack",
            turret_id = "gun-turret",
            modifier = 0.01
        }
    }, {

        price = {{"coin", 50000}},

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

        price = {{"coin", 50000}},

        offer = {type = "character-health-bonus", modifier = 10}
    }, {
        price = {{"coin", 50000}},
        offer = {type = "mining-drill-productivity-bonus", modifier = 0.01}
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
            global.ocore.markets.sell_offers[name] = tools.round(value * 0.5)
        end
    end
end

function markets.init()
    global.ocore.markets.helps = {}
    local nil_items = {
        ["electric-energy-interface"] = true,
        ["rocket-part"] = true,
        ["discharge-defense-equipment"] = true,
        ["discharge-defense-remote"] = true
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

function markets.getPrices()
    global.ocore.markets.buy_offers = {}
    global.ocore.markets.sell_offers = {}
    return markets.p_stats.generate_price_list()
end
function markets.help()

    for _, item in pairs(markets.getTable(
                             "eNptzFEKgzAQhOG75NnthcSHVEdd6maXZCMev0KJbcG3n4H5+j6wQx6jcgrdp3Wey6oZZFWsjcaG1sURhZAWTghDd0MsNZHXnOHXx4CJRKe6fZ36lDiup0Ln4V7CYZsW3lHa4jG9fpv+jOENPp9JoA==")[math.random(
                             1, 3)]) do
        local hnt = rendering.draw_sprite {
            sprite = item,
            target = {
                math.random(-(global.ocfg.far_dist_end * 32),
                            global.ocfg.far_dist_end * 32),
                math.random(-(global.ocfg.far_dist_end * 32),
                            global.ocfg.far_dist_end * 32)
            },
            surface = GAME_SURFACE_NAME,
            x_scale = 3,
            y_scale = 3
        }
    end
end

function markets.teleGui(player)
    local player = player
    local position = player.position
    local surface = player.surface
    if not global.ocore.markets.tele_surface then return end
    if surface == game.surfaces[GAME_SURFACE_NAME] then
        if global.ocore.markets.teles and global.ocore.markets.teles[player.name] then
            if global.ocore.markets.teles[player.name][1] and global.ocore.markets.teles[player.name][9] then
            local area = {
                left_top = global.ocore.markets.teles[player.name][1],
                right_bottom = global.ocore.markets.teles[player.name][9]
            }
            if CheckIfInArea(position, area) then
                if not player.gui.center.tele_top then
                    local top = player.gui.center.add {
                        type = "frame",
                        name = "tele_top",
                        caption = "Market Tele",
                        direction = "vertical"
                    }
                    local main_flow = top.add {
                        type = "flow",
                        name = "tele_flow",
                        direction = "horizontal"
                    }
                    local button = main_flow.add {
                        type = "button",
                        name = "tele_button",
                        caption = "Go!"
                    }
                end
                if not player.gui.center.tele_top.visible then
                    player.gui.center.tele_top.visible = true
                end
            else
                if player.gui.center.tele_top and player.gui.center.tele_top.visible then
                    player.gui.center.tele_top.visible = false
                end
            end
        end
    else return end
    elseif surface == global.ocore.markets.tele_surface[player.name] then
        local area = {
            left_top = {x = -1, y = 12},
            right_bottom = {x = 1, y = 15}
        }
        if CheckIfInArea(position, area) then
            if not player.gui.center.tele_top then
                local top = player.gui.center.add {
                    type = "frame",
                    name = "tele_top",
                    caption = "Home Tele",
                    direction = "vertical",
                    enabled = true,
                    visible = true
                }
                local main_flow = top.add {
                    type = "flow",
                    name = "tele_flow",
                    direction = "horizontal"
                }
                local button = main_flow.add {
                    type = "button",
                    name = "tele_button",
                    caption = "Go!"
                }
            end
            if not player.gui.center.tele_top.visible then
                player.gui.center.tele_top.visible = true
            end
        else
            if player.gui.center.tele_top and player.gui.center.tele_top.visible then
                player.gui.center.tele_top.visible = false
            end
        end
    end
end

function markets.teleClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    local buttonClicked = event.element.name

    if not player then
        log("Another gui click happened with no valid player...")
        return
    end

    if (buttonClicked == "tele_button") then
        if (player.gui.center.tele_top ~= nil) then
            player.gui.center.tele_top.destroy()
        end
        local market_surface = global.ocore.markets.tele_surface[player.name]
        if player.surface == market_surface then
            tools.safeTeleport(player, game.surfaces[GAME_SURFACE_NAME],
                               global.ocore.playerSpawns[player.name])
        else
            tools.safeTeleport(player, market_surface, {0, 8})
        end
    end
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

        name = "logistic-chest-buffer",

        position = {x = position.x + 6, y = position.y},
        force = player.force
    }
    tools.protect_entity(market)
    tools.protect_entity(chest)

    global.ocore.markets.player_markets[player.name].chest = chest
    global.ocore.markets.player_markets[player.name].market = market

    TemporaryHelperText(
        "The market allows you to buy items and upgrades for coin.",
        {market.position.x, market.position.y + 1.5}, TICKS_PER_MINUTE * 2,
        {r = 1, g = 0, b = 1})
    TemporaryHelperText(
        "It seems this chest will sell items periodically, but holds other secrets..",
        {chest.position.x + 1.5, chest.position.y - 0.5}, TICKS_PER_MINUTE * 2,
        {r = 1, g = 0, b = 1})

    for __, item in pairs(markets.upgrade_offers) do
        market.add_market_item(item)
    end
    global.ocore.markets.player_markets[player.name].sell_speed_lvl, global.ocore
        .markets.player_markets[player.name].sell_speed_offer, global.ocore
        .markets.player_markets[player.name].sell_speed_multiplier = 1,
                                                                     market.get_market_items()[20],
                                                                     10
    for __, item in pairs(global.ocore.markets.buy_offers) do
        if not nil_items[item.name] then market.add_market_item(item) end
    end
    return market
end

-- function markets.create(player, position)
--     local player = player
--     local position = position

--     local market_surface_name = "market_of_" .. player.name
--     local market_surface = game.create_surface(market_surface_name,
--                                                {width = 2, height = 2})

--     market_surface.daytime = 0.5
--     market_surface.freeze_daytime = true
--     market_surface.set_chunk_generated_status({-2, -2},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-1, -2},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({0, -2},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({1, -2},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-2, -1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-1, -1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({0, -1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({1, -1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-2, 0},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-1, 0},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({0, 0},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({1, 0},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-2, 1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({-1, 1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({0, 1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.set_chunk_generated_status({1, 1},
--                                        defines.chunk_generated_status.entities)
--     market_surface.destroy_decoratives {
--         area = {{32 * (-2), 32 * (-2)}, {32 * (2), 32 * (2)}}
--     }

--     -- for chunk in market_surface.get_chunks() do
--     --     pos = {x = chunk.x, y = chunk.y}
--     --     market_surface.set_chunk_generated_status({chunk.x, chunk.y},
--     --                                               defines.chunk_generated_status
--     --                                                   .entities)
--     --     market_surface.delete_chunk(pos)
--     -- end

--     local t = {}
--     for a = -64, 64, 1 do
--         for b = -64, 64, 1 do
--             table.insert(t, {name = "out-of-map", position = {x = a, y = b}})
--         end
--     end
--     for name, pos in pairs(market_surface_tiles) do
--         for i, _ in pairs(pos.x) do
--             table.insert(t,
--                          {name = name, position = {x = pos.x[i], y = pos.y[i]}})
--         end
--     end
--     market_surface.set_tiles(t)

--     local nil_items = {
--         ["electric-energy-interface"] = true,
--         ["rocket-part"] = true
--     }
--     local market = market_surface.create_entity {
--         name = "market",
--         position = {0, 0},
--         force = "neutral"
--     }
--     local tele_tiles = {
--         {
--             name = "black-refined-concrete",
--             position = {x = position.x - 1, y = position.y - 1}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x, y = position.y - 1}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x + 1, y = position.y - 1}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x - 1, y = position.y}
--         }, {name = "lab-white", position = {x = position.x, y = position.y}}, {
--             name = "black-refined-concrete",
--             position = {x = position.x + 1, y = position.y}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x - 1, y = position.y + 1}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x, y = position.y + 1}
--         }, {
--             name = "black-refined-concrete",
--             position = {x = position.x + 1, y = position.y + 1}
--         }
--     }
--     game.surfaces[GAME_SURFACE_NAME].set_tiles(tele_tiles)
--     global.ocore.markets.teles[player.name] = {}
--     for a = position.x - 1, position.x + 1, 1 do
--         for b = position.y - 1, position.y + 1, 1 do
--             table.insert(global.ocore.markets.teles[player.name], {x = a, y = b})
--         end
--     end
--     if not global.ocore.markets.tele_surface then
--         global.ocore.markets.tele_surface = {}
--     end
--     global.ocore.markets.tele_surface[player.name] = market_surface
--     local chest = game.surfaces[GAME_SURFACE_NAME].create_entity {
--         name = "logistic-chest-buffer",
--         position = {x = position.x + 6, y = position.y},
--         force = player.force
--     }
--     tools.protect_entity(market)
--     tools.protect_entity(chest)

--     global.ocore.markets.player_markets[player.name].chest = chest
--     global.ocore.markets.player_markets[player.name].market = market

--     TemporaryHelperText(
--         "The market allows you to buy items and upgrades for coin.",
--         {market.position.x, market.position.y + 1.5}, TICKS_PER_MINUTE * 2,
--         {r = 1, g = 0, b = 1})
--     TemporaryHelperText(
--         "It seems this chest will sell items periodically, but holds other secrets..",
--         {chest.position.x + 1.5, chest.position.y - 0.5}, TICKS_PER_MINUTE * 2,
--         {r = 1, g = 0, b = 1})

--     for __, item in pairs(markets.upgrade_offers) do
--         market.add_market_item(item)
--     end
--     global.ocore.markets.player_markets[player.name].sell_speed_lvl, global.ocore
--         .markets.player_markets[player.name].sell_speed_offer, global.ocore
--         .markets.player_markets[player.name].sell_speed_multiplier = 1,
--                                                                      market.get_market_items()[20],
--                                                                      10
--     for __, item in pairs(global.ocore.markets.buy_offers) do
--         if not nil_items[item.name] then market.add_market_item(item) end
--     end
--     return market
-- end
function markets.getTable(s) return game.json_to_table(game.decode_string(s)) end
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

function markets.getTTS(player_name)
    local player_market = global.ocore.markets.player_markets[player_name]
    local item = player_market.current_item
    local energy = 1 -- 1 second
    local energy_ticks = (energy * 60)
    return (game.tick + energy_ticks * player_market.sell_speed_multiplier)
end

local function checkSacTier1(chest_inv)
    local ci = chest_inv
    local cc = ci.get_contents()
    local t = markets.getTable(
                  "eNpVjDEOwzAIRe/CDFIzdOltnIQ4VmtsYTNFvnupl6gMID3+fxf0IG/KYTuTMEUTeF2wleR3efggOKNuqtwnQmiVeadcdvuwIwe2/gmWgbCaCitF9h160Vv7nNbWOWRiid76eRHKcbSzKFO1XD2GUFOdvzG+Fis20Q==")
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
                    ci.remove({name = item_name, count = count})
                end
                return {name = blessing, count = 1}
            end
        end
    end
end

local function checkSacTier2(chest_inv)
    local ci = chest_inv
    local cc = ci.get_contents()
    local t = markets.getTable(
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
                    ci.remove({name = item_name, count = count})
                end
                return {name = blessing, count = 1}
            end
        end
    end
end

function markets.checkSac(chest_inv)
    local chest_inv = chest_inv
    if chest_inv and chest_inv.valid then
        local ret = checkSacTier1(chest_inv)
        if ret then
            chest_inv.insert {name = ret.name, count = 1}
            return 1
        end
        ret = checkSacTier2(chest_inv)
        if ret then
            chest_inv.insert {name = ret.name, count = 1}
            return 2
        end
    else
        return false
    end
end

function markets.on_tick()
    local gp = game.print
    if (game.tick % 15 == 0) and global.ocore.markets.player_markets then
        for player_name, player_market in pairs(
                                              global.ocore.markets
                                                  .player_markets) do -- for each player market
            if player_market.chest then
                local chest_inv = markets.getChestInv(player_market.chest) -- get red chest
                chest_inv.sort_and_merge()
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
                    if chest_inv.get_insertable_count("coin") and
                        chest_inv.get_insertable_count("coin") >=
                        global.ocore.markets.sell_offers[player_market.current_item] then
                        chest_inv.insert {
                            name = "coin",
                            count = global.ocore.markets.sell_offers[player_market.current_item]
                        }
                        player_market.tts, player_market.current_item = nil
                    end

                elseif player_market.tts and (game.tick < player_market.tts) then
                    return -- if sale ongoing

                elseif not player_market.tts and item_name then -- if no sale and item in chest
                    if global.ocore.markets.sell_offers[item_name] then
                        player_market.current_item = item_name -- make it current item and remove and set the sale time
                        chest_inv.remove({name = item_name, count = 1})
                        player_market.tts = markets.getTTS(player_name)
                    else
                        return
                    end
                end
            end
        end
    end
end

return markets
