-- admin_commands.lua
-- May 2019
-- 
-- Yay, admin commands!
require("lib/oarc_utils")
local Colors = require("util/Colors")
-- local spy = require("addons/spy")
local tools = require("addons.tools")
-- name :: string: Name of the command.
-- tick :: uint: Tick the command was used.
-- player_index :: uint (optional): The player who used the command. It will be missing if run from the server console.
-- parameter :: string (optional): The parameter passed after the command, separated from the command by 1 space.

commands.add_command("reset", "reset player", function(command)
    local player = game.players[command.player_index]
    local target = player.name
    if command.parameter and game.players[command.parameter] and player.admin then
        target = command.parameter
    end
    if target.valid then ResetPlayer(target) end
end)

local function format_chat_colour(message, color)
color = color or Colors.white
local color_tag = '[color='..tools.round(color.r, 3)..', '..tools.round(color.g, 3)..', '..tools.round(color.b, 3)..']'
return string.format('%s%s[/color]', color_tag, message)
end

local function step_component(c1, c2)
    if c1 < 0 then
        return 0, c2+c1
    elseif c1 > 1 then
        return 1, c2-c1+1
    else
        return c1, c2
    end
end

local function step_color(color)
    color.r, color.g = step_component(color.r, color.g)
    color.g, color.b = step_component(color.g, color.b)
    color.b, color.r = step_component(color.b, color.r)
    color.r = step_component(color.r, 0)
    return color
end

local function next_color(color, step)
    step = step  or 0.1
    local new_color = {r=0, g=0, b=0}
    if color.b == 0 and color.r ~= 0 then
        new_color.r = color.r-step
        new_color.g = color.g+step
    elseif color.r == 0 and color.g ~= 0 then
        new_color.g = color.g-step
        new_color.b = color.b+step
    elseif color.g == 0 and color.b ~= 0 then
        new_color.b = color.b-step
        new_color.r = color.r+step
    end
    return step_color(new_color)
end

commands.add_command("rainbow", "Rainbow chat", function(command)
    local player = game.players[command.player_index]
    if not command.parameter then
        player.print("Supply a message!")
        return
    end
    local message = command.parameter
    local player_name = player and player.name or '<Server>'
    local player_color = player and player.color or nil
    local color_step = 3/message:len()
    if color_step > 1 then color_step = 1 end
    local current_color = {r=1, g=0, b=0}
    local output = format_chat_colour(player_name..': ', player_color)
    output = output..message:gsub('%S', function(letter)
        local rtn = format_chat_colour(letter, current_color)
        current_color = next_color(current_color, color_step)
        return rtn
    end)
    game.print(output)
end)

commands.add_command("look", "Look at a player", function(command)
    local player = game.players[command.player_index]
    if not command.parameter then
        player.print("Supply a player name!")
        return
    end
    local target = command.parameter
    target = tools.get_player(target)
    if target.valid then
        player.zoom_to_world(target.position, 1.75)
    end
end)

-- commands.add_command('watch', 'Watch a player', function(command)
--     local player = game.players[command.player_index]
--     if not command.parameter then
--         player.print("Supply a player name!")
--         return
--     end
--     local target = tools.get_player(command.parameter)
--     if player == target then
--        return tools.error(player, "Cannot watch yourself")
--     else
--         spy.start_watching(player, action_player)
--     end
-- end)

commands.add_command("me", "Perform an 'action' in chat", function(command)
    local player = game.players[command.player_index]
    if not command.parameter then
        player.print("Supply an action!")
        return
    end
    local action = command.parameter
local player_name = player and player.name or '<Server>'
game.print(string.format('* %s %s *', player_name, action), player.chat_color)
end)
    
commands.add_command("repair",
                     "Repairs all destroyed and damaged entities in an area",
                     function(command)

    local player = game.players[command.player_index]
    if player ~= nil and player.admin then
        local range = 10
        local max_range = 100
        if (command.parameter ~= nil) then
            range = tonumber(command.parameter)
        end
        if not range or max_range and range > max_range then
            player.print('Maximum Range is 100.')
            return
        end

        local revive_count = 0
        local heal_count = 0
        local range2 = range ^ 2
        local surface = player.surface
        local center = player.position
        local area = {
            {x = center.x - range, y = center.y - range},
            {x = center.x + range, y = center.y + range}
        }

        local ghosts = surface.find_entities_filtered({
            area = area,
            type = 'entity-ghost',
            force = player.force
        })
        for _, ghost in pairs(ghosts) do
            if ghost.valid then
                local x = ghost.position.x - center.x
                local y = ghost.position.y - center.y
                if x ^ 2 + y ^ 2 <= range2 then
                    revive_count = revive_count + 1
                    ghost.silent_revive()
                end
            end
        end

        local entities = surface.find_entities_filtered({
            area = area,
            force = player.force
        })
        for _, entity in pairs(entities) do
            if entity.valid then
                local x = entity.position.x - center.x
                local y = entity.position.y - center.y
                if entity.health and entity.get_health_ratio() ~= 1 and x ^ 2 +
                    y ^ 2 <= range2 then
                    heal_count = heal_count + 1
                    entity.health = 100000
                end
            end
        end
        player.print(
            revive_count .. " ghosts were revived and " .. heal_count ..
                " entities were healed.")
    end
end)

local function Modules(moduleInventory) -- returns the multiplier of the modules
    local effect1 = moduleInventory.get_item_count("productivity-module") -- type 1
    local effect2 = moduleInventory.get_item_count("productivity-module-2") -- type 2
    local effect3 = moduleInventory.get_item_count("productivity-module-3") -- type 3

    local multi = effect1 * 4 + effect2 * 6 + effect3 * 10
    return multi / 100 + 1
end

local function AmountOfMachines(itemsPerSecond, output)
    if (itemsPerSecond) then return itemsPerSecond / output end
end

commands.add_command("ratio",
                     "gives ratio info on the selected machine and its recipe. provide a number for items/sec",
                     function(command)
    local player = game.players[command.player_index]
    local machine = player.selected -- selected machine
    local itemsPerSecond
    if not machine then -- nil check
        return player.print("[color=red]No valid machine selected..[/color]")
    end

    if machine.type ~= "assembling-machine" and machine.type ~= "furnace" then
        return player.print("[color=red]Invalid machine..[/color]")
    end
    local recipe = machine.get_recipe() -- recipe

    if not recipe then -- nil check
        return player.print("[color=red]No recipe set..[/color]")
    end

    local items = recipe.ingredients -- items in that recipe
    local products = recipe.products -- output items
    local amountOfMachines
    local moduleInventory = machine.get_module_inventory() -- the module Inventory of the machine
    local multi = Modules(moduleInventory) -- function for the productively modules
    if (command.parameter ~= nil) then
        itemsPerSecond = tonumber(command.parameter)
    end
    if itemsPerSecond then
        amountOfMachines = math.ceil(AmountOfMachines(itemsPerSecond, 1 /
                                                          recipe.energy *
                                                          machine.crafting_speed *
                                                          products[1].amount *
                                                          multi)) -- amount of machines
    end
    if not amountOfMachines then
        amountOfMachines = 1 -- set to 1 to make it not nil
    end
    ----------------------------items----------------------------
    for i, item in ipairs(items) do
        local sprite -- string to make the icon work either fluid ore item

        if item.type == "item" then
            sprite = 'ratio.item-in'
        else
            sprite = 'ratio.fluid-in'
        end

        local ips = item.amount / recipe.energy * machine.crafting_speed *
                        amountOfMachines -- math on the items/fluids per second
        player.print {sprite, round(ips, 3), item.name} -- full string
    end
    ----------------------------products----------------------------

    for i, product in ipairs(products) do
        local sprite -- string to make the icon work either fluid ore item

        if product.type == "item" then
            sprite = 'ratio.item-out'
        else
            sprite = 'ratio.fluid-out'
        end

        local output = 1 / recipe.energy * machine.crafting_speed *
                           product.amount * multi -- math on the outputs per second
        player.print {sprite, round(output * amountOfMachines, 3), product.name} -- full string

    end

    if amountOfMachines ~= 1 then
        player.print {'ratio.machines', amountOfMachines}
    end

end)

-- Give yourself or another player, power armor
commands.add_command("give-power-armor-kit", "give a start kit",
                     function(command)

    local player = game.players[command.player_index]
    local target = player

    if player ~= nil and player.admin then
        if (command.parameter ~= nil) then
            if game.players[command.parameter] ~= nil then
                target = game.players[command.parameter]
            else
                target.print(
                    "Invalid player target. Double check the player name?")
                return
            end
        end

        GiveQuickStartPowerArmor(target)
        player.print("Gave a powerstart kit to " .. target.name)
        target.print("You have been given a power armor starting kit!")
    end
end)
commands.add_command("give-power-armor-mk2", "give an mk2 kit",
                     function(command)

    local player = game.players[command.player_index]
    local target = player

    if player ~= nil and player.admin then
        if (command.parameter ~= nil) then
            if game.players[command.parameter] ~= nil then
                target = game.players[command.parameter]
            else
                target.print(
                    "Invalid player target. Double check the player name?")
                return
            end
        end

        GivePowerArmorMK2(target)
        player.print("Gave a powerarmor MK2 kit to " .. target.name)
        target.print("You have been given a power armor Mk2 kit!")
    end
end)

commands.add_command("give-test-kit", "give a start kit", function(command)

    local player = game.players[command.player_index]
    local target = player

    if player ~= nil and player.admin then
        if (command.parameter ~= nil) then
            if game.players[command.parameter] ~= nil then
                target = game.players[command.parameter]
            else
                target.print(
                    "Invalid player target. Double check the player name?")
                return
            end
        end

        GiveTestKit(target)
        player.print("Gave a test kit to " .. target.name)
        target.print("You have been given a test kit!")
    end
end)

commands.add_command("load-quickbar", "Pre-load quickbar shortcuts",
                     function(command)

    local p = game.players[command.player_index]

    -- 1st Row
    p.set_quick_bar_slot(1, "transport-belt");
    p.set_quick_bar_slot(2, "splitter");
    p.set_quick_bar_slot(3, "underground-belt");
    p.set_quick_bar_slot(4, "inserter");
    p.set_quick_bar_slot(5, "small-electric-pole");

    p.set_quick_bar_slot(6, "assembling-machine-1");
    p.set_quick_bar_slot(7, "electric-mining-drill");
    p.set_quick_bar_slot(8, "stone-wall");
    p.set_quick_bar_slot(9, "gun-turret");
    p.set_quick_bar_slot(10, "radar");

    -- 2nd Row
    p.set_quick_bar_slot(11, "fast-transport-belt");
    p.set_quick_bar_slot(12, "fast-splitter");
    p.set_quick_bar_slot(13, "fast-underground-belt");
    p.set_quick_bar_slot(14, "fast-inserter");
    p.set_quick_bar_slot(15, "medium-electric-pole");

    p.set_quick_bar_slot(16, "assembling-machine-2");
    p.set_quick_bar_slot(17, nil);
    p.set_quick_bar_slot(18, nil);
    p.set_quick_bar_slot(19, nil);
    p.set_quick_bar_slot(20, nil);

    -- 3rd Row
    p.set_quick_bar_slot(21, "express-transport-belt");
    p.set_quick_bar_slot(22, "express-splitter");
    p.set_quick_bar_slot(23, "express-underground-belt");
    p.set_quick_bar_slot(24, "stack-inserter");
    p.set_quick_bar_slot(25, "substation");

    p.set_quick_bar_slot(26, "assembling-machine-3");
    p.set_quick_bar_slot(27, "beacon");
    p.set_quick_bar_slot(28, nil);
    p.set_quick_bar_slot(29, nil);
    p.set_quick_bar_slot(30, nil);
    --[[
        -- 4th Row
        p.set_quick_bar_slot(31, "fast-transport-belt");
        p.set_quick_bar_slot(32, "medium-electric-pole");
        p.set_quick_bar_slot(33, "fast-inserter");
        p.set_quick_bar_slot(34, "fast-underground-belt");
        p.set_quick_bar_slot(35, "fast-splitter");
        
        p.set_quick_bar_slot(36, "stone-wall");
        p.set_quick_bar_slot(37, "repair-pack");
        p.set_quick_bar_slot(38, "gun-turret");
        p.set_quick_bar_slot(39, "laser-turret");
        p.set_quick_bar_slot(40, "radar");
        
        -- 5th Row
        p.set_quick_bar_slot(41, "train-stop");
        p.set_quick_bar_slot(42, "rail-signal");
        p.set_quick_bar_slot(43, "rail-chain-signal");
        p.set_quick_bar_slot(44, "rail");
        p.set_quick_bar_slot(45, "big-electric-pole");
        
        p.set_quick_bar_slot(46, "locomotive");
        p.set_quick_bar_slot(47, "cargo-wagon");
        p.set_quick_bar_slot(48, "fluid-wagon");
        p.set_quick_bar_slot(49, "pump");
        p.set_quick_bar_slot(50, "storage-tank");
        
        -- 6th Row
        p.set_quick_bar_slot(51, "oil-refinery");
        p.set_quick_bar_slot(52, "chemical-plant");
        p.set_quick_bar_slot(53, "storage-tank");
        p.set_quick_bar_slot(54, "pump");
        p.set_quick_bar_slot(55, nil);
        
        p.set_quick_bar_slot(56, "pipe");
        p.set_quick_bar_slot(57, "pipe-to-ground");
        p.set_quick_bar_slot(58, "assembling-machine-2");
        p.set_quick_bar_slot(59, "pump");
        p.set_quick_bar_slot(60, nil);
        
        -- 7th Row
        p.set_quick_bar_slot(61, "roboport");
        p.set_quick_bar_slot(62, "logistic-chest-storage");
        p.set_quick_bar_slot(63, "logistic-chest-passive-provider");
        p.set_quick_bar_slot(64, "logistic-chest-requester");
        p.set_quick_bar_slot(65, "logistic-chest-buffer");
        
        p.set_quick_bar_slot(66, "logistic-chest-active-provider");
        p.set_quick_bar_slot(67, "logistic-robot");
        p.set_quick_bar_slot(68, "construction-robot");
        p.set_quick_bar_slot(69, nil);
        p.set_quick_bar_slot(70, nil); ]] --
end)

local function stack_size(item)
    if game.item_prototypes[item] then
        return game.item_prototypes[item].stack_size
    end
end

commands.add_command("load-logistics", "Pre-load logistic requests",
                     function(command)
    local p = game.players[command.player_index]

    local list = {
        "electric-mining-drill", "gun-turret", "radar", "transport-belt",
        "underground-belt", "splitter", "fast-underground-belt",
        "fast-transport-belt", "fast-splitter", "express-underground-belt",
        "express-transport-belt", "express-splitter", "fast-inserter",
        "stack-inserter", "filter-inserter", "long-handed-inserter",
        "medium-electric-pole", "substation", "big-electric-pole",
        "assembling-machine-1", "assembling-machine-2", "assembling-machine-3",
        "firearm-magazine", "piercing-rounds-magazine"
    }
    local limitlist = {"stone", "coal", "wood"}
    local antilist = {"iron-ore", "copper-ore"}
    local items = {}

    for i = 1, #list do
        table.insert(items, {
            name = list[i],
            min = stack_size(list[i]),
            max = stack_size(list[i]) * 2
        })
    end
    for i = 1, #limitlist do
        table.insert(items, {
            name = limitlist[i],
            min = 0,
            max = stack_size(limitlist[i])
        })
    end
    for i = 1, #antilist do
        table.insert(items, {name = antilist[i], min = 0, max = 0})
    end
    for i, item in pairs(items) do p.set_personal_logistic_slot(i, item) end
    items = ""
end)

commands.add_command("make", "magic", function(command)
    local player = game.players[command.player_index]
    if not command.parameter then
        tools.error(player, "You're gonna need more than that..try /help make")
        return
    end
    local args = string.split(command.parameter, " ")

    if not args[1] then args[1] = false end
    if not args[2] then args[2] = false end
    tools.make(player, args[1], args[2])
end)   

-- commands.add_command("replace",
--                      "attempts to replace entities in the held blueprint",
--                      function(command)
--     local player = game.players[command.player_index]
--     local args = string.split(command.parameter, " ")

--     args[1], args[2] = args[1] or false, args[2] or false
--     if not args[1] or not args[2] then
--         player.print("No source and/or replacement entity given.")
--         return
--     end
--     tools.replace(player, args[1], args[2])
-- end)