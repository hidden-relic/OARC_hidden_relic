-- admin_commands.lua
-- May 2019
-- 
-- Yay, admin commands!
require("lib/oarc_utils")

-- name :: string: Name of the command.
-- tick :: uint: Tick the command was used.
-- player_index :: uint (optional): The player who used the command. It will be missing if run from the server console.
-- parameter :: string (optional): The parameter passed after the command, separated from the command by 1 space.

commands.add_command("reset", "reset a player by name", function(command)
    local player = game.players[command.player_index]
    if player.admin then ResetPlayer(command.parameter) end
end)

local function split(s, sep, pattern)
    sep = sep or "."
    sep = sep ~= "" and sep or "."
    sep = not pattern and string.gsub(sep, "([^%w])", "%%%1") or sep

    local fields = {}
    local start_idx, end_idx = string.find(s, sep)
    local last_find = 1
    while start_idx do
        local substr = string.sub(s, last_find, start_idx - 1)
        if string.len(substr) > 0 then
            table.insert(fields, string.sub(s, last_find, start_idx - 1))
        end
        last_find = end_idx + 1
        start_idx, end_idx = string.find(s, sep, end_idx + 1)
    end
    local substr = string.sub(s, last_find)
    if string.len(substr) > 0 then
        table.insert(fields, string.sub(s, last_find))
    end
    return fields
end


-- commands.add_command("addto", "adds something to shared pot", function(command)
--     local player = game.players[command.player_index]
--     if player.admin then
--         local name = ""
--         local count = 1
--         local args = split(command.parameter, " ")

--         if not args[1] then
--             player.print("supply an item name")
--             return
--         else
--             name = args[1]
--         end
--         if args[2] then
--             count = args[2]
--         end
--         if not game.item_prototypes[name] then
--             player.print("not a valid item")
--             return
--         else
--         SharedChestUploadItem(name, count)
--         end
--     end
-- end)

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

-- commands.add_command("evict", "removes nearby biters",
--                      function(command)

--                         local player = game.players[command.player_index]
--     if player ~= nil and player.admin then
--         local range = 10
--         local max_range = 100
--         if (command.parameter ~= nil) then
--             range = tonumber(command.parameter)
--         end
--         if not range or max_range and range > max_range then
--             player.print('Maximum Range is 100.')
--             return
--         end

--         for __, bug in pairs(player.surface.find_entities_filtered{force="enemy", position=player.position, radius=range}) do bug.damage(bug.health/2, player.force, "fire")
--         end
--     end
-- end)
