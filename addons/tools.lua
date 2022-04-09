require('stdlib/string')
local Color = require('util/Colors')

local tools = {}

function tools.sortByValue(t)
    local keys = {}

    for key, _ in pairs(t) do table.insert(keys, key) end

    table.sort(keys, function(keyLhs, keyRhs) return t[keyLhs] < t[keyRhs] end)
    local r = {}
    for _, key in ipairs(keys) do r[key] = t[key] end
    return r
end

function tools.FlyingTime(this_tick)
    if not global.oarc_timers then global.oarc_timers = {} end
    local time = tools.formatTimeMinsSecs(this_tick)
    for __, player in pairs(global.oarc_timers) do
        FlyingText(time, player.position, {r = 1, g = 0, b = 0}, player.surface)
    end
end

function tools.error(player, error_message, play_sound)
    error_message = error_message or ''
    player.print({'error.msg', error_message})
    if play_sound ~= false then
        play_sound = play_sound or 'utility/wire_pickup'
        if player then player.play_sound {path = play_sound} end
    end
end

function tools.success(player, success_message, play_sound)
    success_message = success_message or ''
    player.print({'success.msg', success_message})
    if play_sound ~= false then
        play_sound = play_sound or 'utility/confirm'
        if player then player.play_sound {path = play_sound} end
    end
end

function tools.notify(player, notify_message, play_sound)
    notify_message = notify_message or ''
    player.print({'notification.msg', notify_message})
    if play_sound ~= false then
        play_sound = play_sound or 'utility/wire_connect_pole'
        if player then player.play_sound {path = play_sound} end
    end
end

function tools.formatTimeMinsSecs(ticks)
    local seconds = ticks / 60
    local minutes = math.floor((seconds) / 60)
    local seconds = math.floor(seconds - 60 * minutes)
    return string.format("%dm:%02ds", minutes, seconds)
end

-- Useful for displaying game time in mins:secs format
function tools.formatTimeHoursMins(ticks)
    local seconds = ticks / 60
    local minutes = math.floor((seconds) / 60)
    local hours = math.floor((minutes) / 60)
    local minutes = math.floor(minutes - 60 * hours)
    return string.format("%dh:%02dm", hours, minutes)
end

function tools.get_player(o)
    local o_type, p = type(o)
    if o_type == 'table' then
        p = o
    elseif o_type == 'string' or o_type == 'number' then
        p = game.players[o]
    end

    if p and p.valid and p.is_player() then return p end
end

function tools.getMarketBonuses(player)
    local player = tools.get_player(player)
    if player and global.ocore.markets.player_markets[player.name].stats then
        return global.ocore.markets.player_markets[player.name].stats
    end
end

function tools.formatMarketBonuses(player)
    local player = tools.get_player(player)
    if player then
        if global.ocore.markets and global.ocore.markets.player_markets and global.ocore.markets.player_markets[player.name] and global.ocore.markets.player_markets[player.name].stats then
            local stats = global.ocore.markets.player_markets[player.name].stats
            local str = "[color=blue]Bonuses for [/color][color=orange]"..player.name.."[/color][color=blue]:[/color]\n"
            for type, item in pairs(stats) do
                str = str.."[color=purple]["..type.."][/color]\n"
                for name, data in pairs(item) do
                    if type == "sell-speed" then
                        str = str.."[color=cyan]-- ["..name.."]:[/color] \t[color=orange]LVL: [/color][color=green]"..data.lvl.."[/color] \t[color=orange]SECONDS: [/color][color=green]"..data.formatted.."%[/color]\n"
                    else
                    str = str.."[color=cyan]-- ["..name.."]:[/color] \t[color=orange]LVL: [/color][color=green]"..data.lvl.."[/color] \t[color=orange]BONUS: [/color][color=green]"..data.formatted.."%[/color]\n"
                    end
                end
            end
            return str
        else
            return
        end
    end
end

function tools.get_player_base_bonuses(player)
    local player = player
    local t = {
        ["run_bonus"] = player.character_running_speed_modifier,
        ["handcraft_bonus"] = player.character_crafting_speed_modifier,
        ["mining_bonus"] = player.character_mining_speed_modifier,
        ["reach_bonus"] = player.character_reach_distance_bonus,
        ["resource_reach_bonus"] = player.character_resource_reach_distance_bonus,
        ["build_bonus"] = player.character_build_distance_bonus,
        ["item_drop_bonus"] = player.character_item_drop_distance_bonus,
        ["loot_pickup_bonus"] = player.character_loot_pickup_distance_bonus,
        ["inventory_bonus"] = player.character_inventory_slots_bonus,
        ["trash_bonus"] = player.character_trash_slot_count_bonus,
        ["bot_speed_bonus"] = player.force.worker_robots_speed_modifier,
        ["bot_storage_bonus"] = player.force.worker_robots_storage_bonus,
        ["bot_battery_bonus"] = player.force.worker_robots_battery_modifier
    }
    return t
end

function tools.floating_text(surface, position, text, color)
    color = color or Color.white
    return surface.create_entity {
        name = 'tutorial-flying-text',
        color = color,
        text = text,
        position = position
    }
end

function tools.floating_text_on_player(player, text, color)
    tools.floating_text_on_player_offset(player, text, color, 0, -1.5)
end

function tools.floating_text_on_player_offset(player, text, color, x_offset,
                                              y_offset)
    player = tools.get_player(player)
    if not player or not player.valid then return end

    local position = player.position
    return tools.floating_text(player.surface, {
        x = position.x + x_offset,
        y = position.y + y_offset
    }, text, color)
end

function tools.protect_entity(entity)
    entity.minable = false
    entity.destructible = false
end

function tools.link_in_spawn(pos)
    local link_in = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "linked-belt",
        position = pos,
        force = game.forces["neutral"]
    }
    link_in.linked_belt_type = "input"
    return link_in
end

function tools.link_out_spawn(pos)
    local link_out = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "linked-belt",
        position = pos,
        force = game.forces["neutral"]
    }
    link_out.linked_belt_type = "output"
    return link_out
end

function tools.link_belts(player, inp, outp)
    local player = player
    if inp.valid and outp.valid then
        inp.connect_linked_belts(outp)
        if inp.linked_belt_neighbour == outp then
            tools.success(player, "Success")
            tools.protect_entity(inp)
            tools.protect_entity(outp)
            inp = nil
            outp = nil
        elseif inp.linked_belt_neighbour ~= outp then
            tools.error(player, "Couldn't make link")
            return
        end
    else
        tools.error(player, "Invalid")
    end
end

function tools.make(player, sharedobject, flow)
    local player = player
    local shared_objects = {
        ["chest"] = true,
        ["belt"] = true,
        ["belts"] = true,
        ["power"] = true,
        ["energy"] = true,
        ["accumulator"] = true
    }
    local flows = {["in"] = true, ["out"] = true}

    if not player.admin then
        tools.error(player, "You're not admin!")
        return
    end
    if sharedobject == "link" then
        local link_in = global.oarc_players[player.name].link_in or nil
        local link_out = global.oarc_players[player.name].link_out or nil
        if link_in and link_out then
            if link_in == link_out then
                tools.notify(
                    "Last logged input belt is the same as last logged output belt. Specify a new belt with /make mode <in/out>")
                return false
            else
                tools.link_belts(player, link_in, link_out)
            end
        else
            tools.error(player, "Missing a link")
            return false
        end
    elseif sharedobject == "mode" then
        local sel = player.selected
        if not sel then
            tools.error(player, "Place your cursor over the target linked belt.")
            return false
        end
        if sel.name == "linked-belt" then
            if flow == "in" then
                global.oarc_players[player.name].link_in = sel
                local link_in = global.oarc_players[player.name].link_in
                if link_in.linked_belt_type == "input" then
                    tools.notify(
                        "MODE already set to INPUT. '/make mode output' to link an OUTPUT belt. '/make link' to connect.")
                    return link_in
                else
                    link_in.linked_belt_type = "input"
                    tools.notify(
                        "MODE set to INPUT. '/make mode output' to link an OUTPUT belt. '/make link' to connect.")
                    return link_in
                end
            elseif flow == "out" then
                global.oarc_players[player.name].link_out = sel
                local link_out = global.oarc_players[player.name].link_out
                if link_out.linked_belt_type == "output" then
                    tools.notify(
                        "MODE already set to OUTPUT. '/make mode input' to link an INPUT belt. '/make link' to connect.")
                    return link_out
                else
                    link_out.linked_belt_type = "output"
                    tools.notify(
                        "MODE set to OUTPUT. '/make mode input' to link an INPUT belt. '/make link' to connect.")
                    return link_out
                end
            end
        else
            tools.error(player, "Not a linked belt type.")
            return false
        end
    elseif sharedobject == "water" then
        local pos = GetWoodenChestFromCursor(player)
        if pos and (getDistance(pos, player.position) > 2) then
            player.surface.set_tiles({[1] = {name = "water", position = pos}})
            return true
        else
            tools.error(player,
                        "Failed to place waterfill. Don't stand so close!")
            return false
        end
    elseif sharedobject == "combinator" or sharedobject == "combinators" then
        local pos = GetWoodenChestFromCursor(player)
        if pos and (player.surface.can_place_entity {
            name = "constant-combinator",
            position = {pos.x, pos.y - 1}
        }) and (player.surface.can_place_entity {
            name = "constant-combinator",
            position = {pos.x, pos.y + 1}
        }) then
            SharedChestsSpawnCombinators(player, {x = pos.x, y = pos.y - 1},
                                         {x = pos.x, y = pos.y + 1})
            return true
        end
    elseif shared_objects[sharedobject] then
        if flows[flow] then
            local pos = GetWoodenChestFromCursor(player)
            if pos then
                if sharedobject == "chest" then
                    if flow == "in" then
                        SharedChestsSpawnInput(player, pos)
                        return true
                    elseif flow == "out" then
                        SharedChestsSpawnOutput(player, pos)
                        return true
                    end
                elseif sharedobject == "belt" or sharedobject == "belts" then
                    if flow == "in" then
                        local link_in = tools.link_in_spawn(pos)
                        global.oarc_players[player.name].link_in = link_in
                        return link_in
                    elseif flow == "out" then
                        local link_out = tools.link_out_spawn(pos)
                        global.oarc_players[player.name].link_out = link_out
                        return link_out
                    end
                elseif sharedobject == "power" or sharedobject == "energy" or
                    sharedobject == "accumulator" then
                    if flow == "in" then
                        if (player.surface.can_place_entity {
                            name = "electric-energy-interface",
                            position = pos
                        }) and (player.surface.can_place_entity {
                            name = "constant-combinator",
                            position = {x = pos.x + 1, y = pos.y}
                        }) then
                            SharedEnergySpawnInput(player, pos)
                            return true
                        end
                    elseif flow == "out" then
                        if (player.surface.can_place_entity {
                            name = "electric-energy-interface",
                            position = pos
                        }) and (player.surface.can_place_entity {
                            name = "constant-combinator",
                            position = {x = pos.x + 1, y = pos.y}
                        }) then
                            SharedEnergySpawnOutput(player, pos)
                            return true
                        end
                    end
                end
            else
                return false
            end
        else
            tools.error(player, "Looking for 'in/out'")
            return
        end
    elseif sharedobject == "help" or sharedobject == "h" then
        tools.notify(player, "/make <entity/command> <'in' or 'out'>")
        tools.notify(player,
                     "entities: 'belt', 'chest', 'power', 'combinators', 'water'")
        tools.notify(player, "commands: 'link', 'mode', 'help'")
    else
        tools.error(player, "Invalid magic entity.. try /make help")
        return
    end
end

function tools.run_tests(player, cursor_stack)
    local p = player.print
    local log = print
    local tests = {
        parent = {
            "[cursor stack]", "[cursor stack]", "[cursor stack]",
            "[cursor stack] ", "[player]", "[cursor stack]", "[cursor stack]",
            "[cursor stack]", "[cursor stack]", "[cursor stack]",
            "[cursor stack]"
        },
        name = {
            "oName:", "valid:", "is_blueprint:", "is_blueprint_book:",
            "is_cursor_blueprint:", "[cursor stack] is_module:", "is_tool:",
            "[cursor stack] is_mining_tool:", "is_armor:",
            "[cursor stack] is_repair_tool:", "is_item_with_label:",
            "is_item_with_inventory:", "is_item_with_entity_data:",
            "is_upgrade_item:"
        },
        funcs = {
            cursor_stack.object_name, cursor_stack.valid,
            cursor_stack.is_blueprint, cursor_stack.is_blueprint_book,
            player.is_cursor_blueprint(), cursor_stack.is_module,
            cursor_stack.is_tool, cursor_stack.is_mining_tool,
            cursor_stack.is_armor, cursor_stack.is_repair_tool,
            cursor_stack.is_item_with_label,
            cursor_stack.is_item_with_inventory,
            cursor_stack.is_item_with_entity_data, cursor_stack.is_upgrade_item
        },
        truthy = {
            parent = "[color=blue]",
            name = "[color=green]",
            funcs = "[color=orange]",
            close = "[/color]"
        }
    }

    for index, test in pairs(tests.funcs) do
        if test then
            local msg = tests.truthy.parent .. tests.parent[index] ..
                            tests.truthy.close .. " " .. tests.truthy.name ..
                            tests.name[index] .. tests.truthy.close .. " " ..
                            tests.truthy.funcs .. tostring(test) ..
                            tests.truthy.close
            p(msg)
            msg = tests.parent[index] .. " " .. tests.name[index] .. " " ..
                      tostring(test)
            log(msg)
        end
    end
end

function tools.safeTeleport(player, surface, target_pos)
    local safe_pos = surface.find_non_colliding_position("character",
                                                         target_pos, 15, 1)
    if (not safe_pos) then
        player.teleport(target_pos, surface)
    else
        player.teleport(safe_pos, surface)
    end
end

function tools.getItem(player, item_name, count)
    local items = game.item_prototypes
    local player = player
    if items[item_name] then
        local count = count or items[item_name].stack_size
        player.insert {name = item_name, count = count}
    else
        return
    end
end

function tools.round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function tools.replace(player, e1, e2)
    if not player.admin then
        player.print("[ERROR] You're not admin!")
        return
    end
    local p, cs, bp_ent_count, bp_tile_count = player.print,
                                               player.cursor_stack, 0, 0

    tools.run_tests(player, cs)

    if game.entity_prototypes[e1] or game.tile_prototypes[e1] then
        local bp, bp_ents, bp_tiles = {}, {}, {}
        if not player.is_cursor_blueprint() then
            bp_ents = cs.get_blueprint_entities()
            bp_tiles = cs.get_blueprint_tiles()
        else
            bp_ents = player.get_blueprint_entities()
            bp_tiles = player.cursor_stack.import_stack(tostring(
                                                            player.cursor_stack
                                                                .export_stack()))
                           .get_blueprint_tiles()
        end
        if game.entity_prototypes[e1] then
            p(e1 .. " is an entity prototype.")
            for each, ent in pairs(bp_ents) do
                if ent.name == e1 then
                    ent.name = e2
                    bp_ent_count = bp_ent_count + 1
                end
            end
        elseif game.tile_prototypes[e1] then
            p(e1 .. " is a tile prototype.")
            for each, tile in pairs(bp_tiles) do
                if tile.name == e1 then
                    tile.name = e2
                    bp_tile_count = bp_tile_count + 1
                end
            end
        end
        cs.clear()
        cs.set_stack {name = "blueprint"}
        bp = cs
        bp.set_blueprint_entities(bp_ents)
        bp.set_blueprint_tiles(bp_tiles)
        -- bp.clear()
        -- bp.
        -- if not player.is_cursor_blueprint() then
        -- else
        -- end
        -- bp.clear_blueprint()
    end

    p("entity replacements: " .. bp_ent_count)
    p("tile replacements: " .. bp_tile_count)
    -- else
    --     player.print("Not a valid blueprint")
end

return tools
