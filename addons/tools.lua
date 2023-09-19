-- require('stdlib/string')
local Color = require('util/Colors')

local tools = {}
tools.MAX_INT32 = 2147483647

function tools.format_time(ticks, options)
    -- Sets up the options
    options = options or {
        days=false,
        hours=true,
        minutes=true,
        seconds=false,
        long=false,
        time=false,
        string=false,
        null=false
    }
    -- Basic numbers that are used in calculations
    local max_days, max_hours, max_minutes, max_seconds = ticks/5184000, ticks/216000, ticks/3600, ticks/60
    local days, hours = max_days, max_hours-math.floor(max_days)*24
    local minutes, seconds = max_minutes-math.floor(max_hours)*60, max_seconds-math.floor(max_minutes)*60
    -- Handles overflow of disabled denominations
    local rtn_days, rtn_hours, rtn_minutes, rtn_seconds = math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds)
    if not options.days then
        rtn_hours = rtn_hours + rtn_days*24
    end
    if not options.hours then
        rtn_minutes = rtn_minutes + rtn_hours*60
    end
    if not options.minutes then
        rtn_seconds = rtn_seconds + rtn_minutes*60
    end
    -- Creates the null time format, does not work with long
    if options.null and not options.long then
        rtn_days='--'
        rtn_hours='--'
        rtn_minutes='--'
        rtn_seconds='--'
    end
    -- Format options
    local suffix = 'time-symbol-'
    local suffix_2 = '-short'
    if options.long then
        suffix = ''
        suffix_2 = ''
    end
    local div = options.string and ' ' or 'time-format.simple-format-tagged'
    if options.time then
        div = options.string and ':' or 'time-format.simple-format-div'
        suffix = false
    end
    -- Adds formatting
    if suffix ~= false then
        if options.string then
            -- format it as a string
            local long = suffix == ''
            rtn_days = long and rtn_days..' days' or rtn_days..'d'
            rtn_hours = long and rtn_hours..' hours' or rtn_hours..'h'
            rtn_minutes = long and rtn_minutes..' minutes' or rtn_minutes..'m'
            rtn_seconds = long and rtn_seconds..' seconds' or rtn_seconds..'s'
        else
            rtn_days = {suffix..'days'..suffix_2, rtn_days}
            rtn_hours = {suffix..'hours'..suffix_2, rtn_hours}
            rtn_minutes = {suffix..'minutes'..suffix_2, rtn_minutes}
            rtn_seconds = {suffix..'seconds'..suffix_2, rtn_seconds}
        end
    elseif not options.null then
        -- weather string or not it has same format
        rtn_days = string.format('%02d', rtn_days)
        rtn_hours = string.format('%02d', rtn_hours)
        rtn_minutes = string.format('%02d', rtn_minutes)
        rtn_seconds = string.format('%02d', rtn_seconds)
    end
    -- The final return is construed
    local rtn
    local append = function(dom, value)
        if dom and options.string then
            rtn = rtn and rtn..div..value or value
        elseif dom then
            rtn = rtn and {div, rtn, value} or value
        end
    end
    append(options.days, rtn_days)
    append(options.hours, rtn_hours)
    append(options.minutes, rtn_minutes)
    append(options.seconds, rtn_seconds)
    return rtn
end

tools.decon_filepath = "log/decon.log"
tools.shoot_filepath = "log/shoot.log"

function tools.add_decon_log(data)
    game.write_file(tools.decon_filepath, data .. "\n", true, 0) -- write data
end
function tools.add_shoot_log(data)
    game.write_file(tools.shoot_filepath, data .. "\n", true, 0) -- write data
end
function tools.get_secs ()
    return tools.format_time(game.tick, { hours = true, minutes = true, seconds = true, string = true })
end
function tools.pos_tostring (pos)
    return tostring(pos.x) .. "," .. tostring(pos.y)
end

function tools.add_commas(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

function tools.remove_commas(amount)
    return string.gsub(amount, ",", "")
end

local function sort_table_highest_value(t)
    local r = {}
    for _, val in pairs(t) do
        table.insert(r, val)
    end
    table.sort(r, function(a, b)
        return a > b
    end)
    return r
end

local function get_item_last_hour(force, item)
    return force.item_production_statistics.get_flow_count{
        name=item,
        input=false,
        precision_index = defines.flow_precision_index.one_hour
    }
end

local function get_total_last_hour(force)
    local t = {
        ["automation-science-pack"] = 0,
        ["logistic-science-pack"] = 0,
        ["chemical-science-pack"] = 0,
        ["production-science-pack"] = 0,
        ["utility-science-pack"] = 0,
        ["space-science-pack"] = 0,
        ["military-science-pack"] = 0
    }
    for science, _ in pairs(t) do
        t[science] = get_item_last_hour(force, science)
    end
    local r = sort_table_highest_value(t)
    local total = 0
    for i = 1, 5, 1 do
        total = total + r[i]
    end
    return total
end

local function get_avg_last_hour(force) 
    local total = get_total_last_hour(force)
    return total/5
end

function tools.statistics_log()
    if not global.highest_spm then
        global.highest_spm = {
            amount = 0,
            force = "",
            hour = 0
        }
    end
    global.highest_spm.hour = global.highest_spm.hour + 1
    local old_highest = global.highest_spm.amount
    for _, force in pairs(game.forces) do
        local spm = get_avg_last_hour(force)
        if spm > global.highest_spm.amount then
            global.highest_spm.amount = spm
            global.highest_spm.force = force.name
        end
    end
    if global.highest_spm.amount > old_highest then
        local playernames = {}
        local players = game.forces[global.highest_spm.force].players
        for _, player in pairs(players) do
            table.insert(playernames, player.name)
        end
        game.write_file("statistics/SPM.txt",
        "Hour "..global.highest_spm.hour..
        ":\nForce name: "..global.highest_spm.force..
        "\nSPM: "..global.highest_spm.amount..
        "\nPlayers on force: "..table.concat(playernames, ", ").."\n")
    end
end

function tools.get_keys_sorted_by_value(tbl)
    local function sort_func(a, b)
        return a < b
    end
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    
    table.sort(keys, function(a, b)
        return sort_func(tbl[a], tbl[b])
    end)
    
    return keys
end

-- for _, key in ipairs(sortedKeys) do
--     print(key, items[key])
--   end


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
    player.print({'notify.msg', notify_message})
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

function tools.get_player(o) -- pass in table, string, or int
    local o_type, p = type(o) -- get it's type
    if o_type == 'table' then -- if its already a table (object)
        p = o -- just keep it
    elseif o_type == 'string' or o_type == 'number' then -- if its a string or int
        p = game.players[o] -- get the player by game.players[string or int]
    end
    
    if p and p.valid and p.is_player() then return p end -- do all validity checks and return valid player object
end

function matChest()
    local player = game.player
    local target = player.selected
    if target and target.valid then
        if target.type == "container" or target.type == "logistic-container" then
            material_chest = target
        end
    end
end

function tools.stockUp()
    if (game.tick % 1800 == 0) then
        if material_chest and material_chest.valid then
            local chest_inv = material_chest.get_inventory(defines.inventory
            .chest)
            chest_inv.clear()
            local list = game.surfaces[GAME_SURFACE_NAME]
            .find_entities_filtered {
                type = "entity-ghost",
                force = material_chest.force
            }
            if chest_inv.can_insert("landfill") then
                chest_inv.insert {name = "landfill", count = 100}
            end
            if chest_inv.can_insert("cliff-explosives") then
                chest_inv.insert {name = "cliff-explosives", count = 10}
            end
            for _, ghost in pairs(list) do
                if ghost.ghost_name == "curved-rail" or ghost.ghost_name ==
                "straight-rail" then
                    if chest_inv.can_insert("rail") then
                        chest_inv.insert {name = "rail", count = 1}
                    end
                else
                    if chest_inv.can_insert(ghost.ghost_name) then
                        chest_inv.insert {name = ghost.ghost_name, count = 1}
                    end
                end
            end
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
        if pos and (get_distance(pos, player.position) > 2) then
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

function swap_ore()
    local function find(player, res)
        return player.surface.find_entities_filtered{name=res, position=player.position, radius=100}
    end
    local function get_keys_sorted_by_value(tbl)
        local function sort_func(a, b)
            return a < b
        end
        local keys = {}
        for key in pairs(tbl) do
            table.insert(keys, key)
        end
        
        table.sort(keys, function(a, b)
            return sort_func(tbl[a], tbl[b])
        end)
        
        return keys
    end
    
    local p = game.player
    local t = {}
    t["iron-ore"] = find(p, "iron-ore")
    t["copper-ore"] = find(p, "copper-ore")
    t["stone"] = find(p, "stone")
    t["coal"] = find(p, "coal")
    local sorted_names = {}
    sorted_names["iron-ore"] = t["iron-ore"][1].position.y
    sorted_names["copper-ore"] = t["copper-ore"][1].position.y
    sorted_names["coal"] = t["coal"][1].position.y
    sorted_names["stone"] = t["stone"][1].position.y
    
    sorted_names = get_keys_sorted_by_value(sorted_names)
    
    local desired = {"coal", "iron-ore", "copper-ore", "stone"}
    for i, name in pairs(sorted_names) do
        for _, ore in pairs(t[name]) do
            game.player.surface.create_entity{name=desired[i], position=ore.position, amount=ore.amount}
            ore.destroy()
        end
    end
end

function grow(playername)
    local playername = playername or game.player.name
    if game.players[playername] then
        local player = game.players[playername]
        local diff = 0
        for i, res in pairs(player.surface.find_entities_filtered{type="resource"}) do
            if i == 1 then diff = res.amount end
            res.amount = res.amount + (res.amount * 0.1)
            if i == 1 then diff = res.amount - diff end
        end
        if diff > 0 then
            game.player.print("Grew by [color=green]" .. diff .. "[/color]")
        end
    end
end



function dg(playername, radius, chance)
    local playerpos = game.players[playername].position
    local zone_size = radius / 3
    local chance = chance or 2
    local bug_table = {
        ["small-biter"] = false,
        ["medium-biter"] = "small-biter",
        ["big-biter"] = "medium-biter",
        ["behemoth-biter"] = "big-biter",
        ["small-spitter"] = false,
        ["medium-spitter"] = "small-spitter",
        ["big-spitter"] = "medium-spitter",
        ["behemoth-spitter"] = "big-spitter",
        ["medium-worm-turret"] = "small-worm-turret",
        ["big-worm-turret"] = "medium-worm-turret",
        ["behemoth-worm-turret"] = "big-worm-turret",
        ["biter-spawner"] = false,
        ["spitter-spawner"] = false
    }
    while radius > 0 do
        for current, downgrade in pairs(bug_table) do
            for i, bug in pairs(game.players[playername].surface.find_entities_filtered{name=current, force="enemy", position=playerpos, radius=radius}) do
                if bug and bug.valid then
                    local bug_pos = bug.position
                    if current == "biter-spawner" or current == "spitter-spawner" then
                        if math.random(1, chance) == 1 then bug.destroy() end
                    else bug.destroy() end
                    if downgrade then
                        game.players[playername].surface.create_entity{name=downgrade, position=bug_pos, force="enemy"}
                    end
                end
            end
        end
        radius = radius - zone_size
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
    if not item_name then
        if game.player.selected then
            item_name = game.player.selected.name
            if item_name == "curved-rail" or item_name == "straight-rail" then
                item_name = "rail"
            end
        end
    end
    if not item_name then
        tools.error("You are not admin my friend")
        return
    end
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
    
    -- tools.run_tests(player, cs)
    
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

function tools.get_distance(pos1, pos2)
    local pos1 = {x = pos1.x or pos1[1], y = pos1.y or pos1[2]}
    local pos2 = {x = pos2.x or pos2[1], y = pos2.y or pos2[2]}
    local a = math.abs(pos1.x - pos2.x)
    local b = math.abs(pos1.y - pos2.y)
    local c = math.sqrt(a ^ 2 + b ^ 2)
    return c
end

function tools.get_closest(pos, list)
    local x, y = pos.x or pos[1], pos.y or pos[2]
    local closest = tools.MAX_INT32
    for _, posenum in pairs(list) do
        local distance = tools.get_distance(pos, posenum)
        if distance < closest then
            x, y = posenum.x, posenum.y
            closest = distance
        end
    end
    if closest == tools.MAX_INT32 then return end
    return {position = {x, y}, distance = closest}
end

return tools
