require('stdlib/string')

local tools = {}
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
    local p = player.print
    if inp.valid and outp.valid then
        inp.connect_linked_belts(outp)
        if inp.linked_belt_neighbour == out then
            p("Success")
            tools.protect_entity(inp)
            tools.protect_entity(outp)
        elseif inp.linked_belt_neighbour ~= outp then
            p("Couldn't make link")
            return
        end
    else
        p("Invalid")
    end
end

commands.add_command("make", "magic", function(command)
    local player = game.players[command.player_index]
    local args = string.split(command.parameter, " ")

    if not args[1] then args[1] = false end
    if not args[2] then args[2] = false end
    tools.make(player, args[1], args[2])
end)

commands.add_command("replace",
                     "attempts to replace entities in the held blueprint",
                     function(command)
    local player = game.players[command.player_index]
    local args = string.split(command.parameter, " ")

    args[1], args[2] = args[1] or false, args[2] or false
    if not args[1] or not args[2] then
        player.print("No source and/or replacement entity given.")
        return
    end
    tools.replace(player, args[1], args[2])
end)

--[[
commands.add_command("layout", "save entity layout to file", function(command)
    local player = game.players[command.player_index]
    local area = command.parameter
    tools.save_layout(player, area)
end)

function tools.save_layout(player, area)
    local p = player.print
    if not player.admin then
        p("[ERROR] You're not admin!")
        return
    end
    local surface = player.surface
    game.write_file('layout.lua', '', false, player.index)
    if not area.left_top then
        local l_t = {x = area[1].x or area[1][1], y = area[1].y or area[1][2]}
    end
    if not area.right_bottom then
        local r_b = {x = area[2].x or area[2][1], y = area[2].y or area[2][2]}
    end
    local area = area or {left_top = l_t, right_bottom = r_b}

    local entities = surface.find_entities_filtered {area = area}

    local data = {position = {}, name = {}, direction = {}, force = {}}
    for _, e in pairs(entities) do
        if e.name ~= 'character' then
            table.insert(data.position, e.position)
            table.insert(data.name, e.name)
            table.insert(data.direction, tostring(e.direction))
            table.insert(data.force, player.force.name)
        end
    end
    game.write_file('layout.lua', "layout = " .. serpent.block(data) .. '\n',
                    false, player.index)
    p("Done.\n" .. data.name.count() ..
          " entities logged to \\script-output\\layout.lua")
end
--]]

function tools.make(player, sharedobject, flow)
    local p = player.print
    if not player.admin then
        p("[ERROR] You're not admin!")
        return
    end
    if sharedobject == "link" then
        local link_in = global.oarc_players[player.name].link_in or nil
        local link_out = global.oarc_players[player.name].link_out or nil
        if link_in == link_out then
            p(
                "[ERROR] Last logged input belt is the same as last logged output belt. Specify a new belt with /make mode <in/out>")
            return false
        end
        tools.link_belts(player, link_in, link_out)
    end
    if sharedobject == "mode" then
        local sel = player.selected
        if not sel then
            p("[ERROR] Place your cursor over the target linked belt.")
            return false
        end
        if sel.name == "linked-belt" then
            if flow == "in" then
                global.oarc_players[player.name].link_in = sel
                local link_in = global.oarc_players[player.name].link_in
                if link_in.linked_belt_type == "input" then
                    p(
                        "MODE already set to INPUT. '/make mode output' to link an OUTPUT belt. '/make link' to connect.")
                    return link_in
                else
                    link_in.linked_belt_type = "input"
                    p(
                        "MODE set to INPUT. '/make mode output' to link an OUTPUT belt. '/make link' to connect.")
                    return link_in
                end
            elseif flow == "out" then
                global.oarc_players[player.name].link_out = sel
                local link_out = global.oarc_players[player.name].link_out
                if link_out.linked_belt_type == "output" then
                    p(
                        "MODE already set to OUTPUT. '/make mode input' to link an INPUT belt. '/make link' to connect.")
                    return link_out
                else
                    link_out.linked_belt_type = "output"
                    p(
                        "MODE set to OUTPUT. '/make mode input' to link an INPUT belt. '/make link' to connect.")
                    return link_out
                end
            else
                p("[ERROR] Invalid argument. Looking for 'in' or 'out'")
                return false
            end
        else
            p("[ERROR] Not a linked belt type.")
            return false
        end
    else
        local pos = GetWoodenChestFromCursor(player)
        pos = pos or FindClosestWoodenChestAndDestroy(player)
        if pos then
            if sharedobject == "chest" then
                if flow == "in" then
                    SharedChestsSpawnInput(player, pos)
                    return true
                end
                if flow == "out" then
                    SharedChestsSpawnOutput(player, pos)
                    return true
                end
            end
            if sharedobject == "belt" or "belts" then
                if flow == "in" then
                    local link_in = tools.link_in_spawn(pos)
                    global.oarc_players[player.name].link_in = link_in
                    return link_in
                end
                if flow == "out" then
                    local link_out = tools.link_out_spawn(pos)
                    global.oarc_players[player.name].link_out = link_out
                    return link_out
                end
            end
            if sharedobject == "power" or "energy" or "accumulator" then
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
                end
                if flow == "out" then
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
            if sharedobject == "combinator" or sharedobject == "combinators" then
                if (player.surface.can_place_entity {
                    name = "constant-combinator",
                    position = {pos.x, pos.y - 1}
                }) and (player.surface.can_place_entity {
                    name = "constant-combinator",
                    position = {pos.x, pos.y + 1}
                }) then
                    SharedChestsSpawnCombinators(player,
                                                 {x = pos.x, y = pos.y - 1},
                                                 {x = pos.x, y = pos.y + 1})
                    return true
                else
                    p(
                        "Failed to place the special combinators. Please check there is enough space in the surrounding tiles!")
                end
            end
            if sharedobject == "water" then
                if (getDistance(pos, player.position) > 2) then
                    player.surface.set_tiles({
                        [1] = {name = "water", position = pos}
                    })
                    return true
                else
                    p("Failed to place waterfill. Don't stand so close FOOL!")
                end
            end
        end
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
                            tests.truthy.close .. " " ..
                            tests.truthy.name ..
                            tests.name[index] ..
                            tests.truthy.close .. " " .. tests.truthy.funcs .. tostring(test) ..
                            tests.truthy.close
            p(msg)
            msg = tests.parent[index] .. " " .. tests.name[index] .. " " .. tostring(test)
            log(msg)
        end
    end
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
