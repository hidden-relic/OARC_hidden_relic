local tools = require('addons/tools')
local flying_tag = require("flying_tags")

local Group = {}

-- function Group:new(o)
--     o = o or {}
--     setmetatable(o, self)
--     self.__index = self
--     return o
-- end

Group.pet_data = {
    ["small-biter"] = {cost = 1000, color = {121, 180, 222}},
    ["medium-biter"] = {cost = 2000, color = {138, 106, 107}},
    ["big-biter"] = {cost = 4000, color = {98, 92, 129}},
    ["behemoth-biter"] = {cost = 10000, color = {94, 192, 136}},
    ["small-spitter"] = {cost = 1500, color = {121, 180, 222}},
    ["medium-spitter"] = {cost = 3000, color = {138, 106, 107}},
    ["big-spitter"] = {cost = 6000, color = {98, 92, 129}},
    ["behemoth-spitter"] = {cost = 12000, color = {94, 192, 136}}
}

function Group.new(player)
    local player = player
    global.groups[player.name] = {
        pets = {
            ["small-biter"] = {},
            ["medium-biter"] = {},
            ["big-biter"] = {},
            ["behemoth-biter"] = {},
            ["small-spitter"] = {},
            ["medium-spitter"] = {},
            ["big-spitter"] = {},
            ["behemoth-spitter"] = {}
        },
        tags = {},
        max = 50,
        limit = 1,
        total = 0,
        pet_group = {},
        counts = {
            ["small-biter"] = 0,
            ["medium-biter"] = 0,
            ["big-biter"] = 0,
            ["behemoth-biter"] = 0,
            ["small-spitter"] = 0,
            ["medium-spitter"] = 0,
            ["big-spitter"] = 0,
            ["behemoth-spitter"] = 0
        },
        state = "left",
    }
end

local cooldown = {
    ["left"] = 60*60*10,
    ["right"] = 60*60*1
}

function Group.create(player)
    local player = player
    global.groups[player.name].pet_group =
    player.surface.create_unit_group {
        position = player.position,
        force = player.force
    }
end

function Group.check(player)
    local player = player
    if global.groups[player.name] then
        local group = global.groups[player.name]
        if group.pet_group then
            if not group.pet_group or not group.pet_group.valid then Group.create(player) end
        end
    end
end


function Group.get_count(player)
    local player = player
    local group = global.groups[player.name]
    group.total = 0
    group.counts = {
        ["small-biter"] = 0,
        ["medium-biter"] = 0,
        ["big-biter"] = 0,
        ["behemoth-biter"] = 0,
        ["small-spitter"] = 0,
        ["medium-spitter"] = 0,
        ["big-spitter"] = 0,
        ["behemoth-spitter"] = 0
    }
    Group.check(player)
    for name, pets in pairs(group.pets) do
        for index, entry in pairs(pets) do
            if entry.valid then
                group.pet_group.add_member(entry)
                group.total = group.total + 1
                group.counts[entry.name] = group.counts[entry.name] + 1
            else
                entry = nil
            end
        end
    end
    return group.total
end

function Group.add(player, pet)
    local player = player
    local group = global.groups[player.name]
    if not group.pet_group or not group.pet_group.valid then
        Group.create(player)
    end
    if (group.limit > Group.get_count(player)) and
    (Group.get_count(player) < group.max) then
        if Group.pet_data[pet] then
            if not group.pets[pet] then group.pets[pet] = {} end
            
            local new_pet = player.surface.create_entity {
                name = pet,
                force = player.force,
                position = player.surface.find_non_colliding_position(pet,
                player.position,
                8, 1)
            }
            
            local new_tag = {
                entity = new_pet,
                offset = {x = 0, y = 1},
                text = {"", player.name, "'s ", new_pet.localised_name},
                color = Group.pet_data[pet].color
            }
            
            if Group.get_count(player) < group.max then
                table.insert(group.pets[pet], new_pet)
                table.insert(group.tags, new_tag)
                
                group.pet_group.add_member(new_pet)
                new_pet.ai_settings.allow_destroy_when_commands_fail = false
                new_pet.ai_settings.allow_try_return_to_spawner = false
                flying_tag.create(new_tag)
                player.print({
                    "groups.pet_added",
                    Group.pet_data[pet].color[1] .. ", " ..
                    Group.pet_data[pet].color[2] .. ", " ..
                    Group.pet_data[pet].color[3], new_pet.localised_name,
                    Group.get_count(player)
                })
            end
            return true
        else
            return false
        end
    else
        player.print("Max buddies allowed")
        return falses
    end
end

-- command functions

function Group.go_to_position(position)
    return {
        type = defines.command.go_to_location,
        destination = position
    }
                        end
function Group.go_to_entity(entity)
    if entity.valid then
        return {
            type = defines.command.go_to_location,
            destination_entity = entity
        }
    end
end
function Group.attack_entity(entity)
    if entity.valid then
        return {
                                                    type = defines.command.attack,
            target = entity
        }
    end
end
function Group.find_enemies(position)
    local enemies = game.surfaces["oarc"].find_entities_filtered{type="unit", force="enemy", position=position, radius=32*5, limit=100}
    if #enemies > 0 then
        local command = {}
        for i, enemy in pairs(enemies) do
            command[i] = Group.attack_entity(enemy)
        end
        return {
            type = defines.command.compound,
            structure_type = defines.compound_command.return_last,
            commands = command
        }
    end
end
local function random_coords(area)
    local area = area
    local x = math.random(area[1].x, area[2].x)
    local y = math.random(area[1].y, area[2].y)
    return {x=x, y=y}
end

function Group.follow_player(player)
    local player = player
    local character = player.character
    if character and character.valid then
        local group = global.groups[player.name].pet_group
        local patrol_distance = 32*5
        if group.valid then
            local enemies = Group.find_enemies(player.position)
            if enemies then
                group.set_command{
                    type = defines.command.compound,
                    structure_type = defines.compound_command.return_last,
                    commands = {
                        Group.go_to_entity(character),
                        enemies
                                            }
                                        }
            else
                group.set_command(Group.go_to_entity(character))
            end
        end
    end
end

function Group.patrol_spawn(player)
    local player = player
    local group = global.groups[player.name].pet_group
    local spawn = global.ocore.playerSpawns[player.name]
    local patrol_distance = 32*10
    local area = {{x=spawn.x-patrol_distance, y=spawn.y-patrol_distance}, {x=spawn.x+patrol_distance, y=spawn.y+patrol_distance}}
    local pos = random_coords(area)
    while tools.get_distance(spawn, pos) > patrol_distance do
        pos = random_coords(area)
    end
    if group.valid then
        local enemies = Group.find_enemies(pos)
        if enemies then
            group.set_command{
                type = defines.command.compound,
                structure_type = defines.compound_command.return_last,
                commands = {
                    Group.go_to_position(pos),
                    enemies
                                    }
                                }
        else
            group.set_command(Group.go_to_position(pos))
                            end
                        end
                    end

function Group.set_patrol_state(player, state)
    local player = player
    local state = state
    global.groups[player.name].state = state
                end

function Group.get_patrol_state(player)
    local player = player
    local state = global.groups[player.name].state
    return state
            end

function Group.on_tick()
    if (game.tick % cooldown["right"] == 0) and (game.tick > cooldown["left"]) and global.groups then
        for index, entry in pairs(global.groups) do
            if not game.players[index] then return end
            local player = game.players[index]
            if (game.tick % cooldown[Group.get_patrol_state(player)] == 0) then
                Group.get_count(player)
                
                if not global.groups[player.name].pet_group then return end
                if not global.groups[player.name].pet_group.valid then return end
                if not global.groups[player.name].pet_group.members then return end
                if global.groups[player.name].pet_group.command == nil then
                    if Group.get_patrol_state(player) == "left" then Group.patrol_spawn(player)
                    elseif Group.get_patrol_state(player) == "right" then Group.follow_player(player)
        end
    end
end
        end
    end
end

-- function Group.on_tick()
--     if (game.tick % 300 == 0) and global.groups then
--         for index, entry in pairs(global.groups) do
--             if not game.players[index] then return end
--             total = Group.get_count(game.players[index])
--             if not global.groups[game.players[index].name].pet_group.command then
--                 if global.groups[game.players[index].name].pet_group.members then
--                     if total > 0 then
--                         target_enemy = game.players[index].surface.find_nearest_enemy{position=global.ocore.playerSpawns[game.players[index].name], max_distance=32*10, game.players[index].force}
--                         if not target_enemy then
--                             target_enemy = game.players[index].surface.find_nearest_enemy{position=game.players[index].position, max_distance=32*10, game.players[index].force}
--                         end
--                         if target_enemy then
--                             -- game.players[index].print({"", total, " pets attacking ", target_enemy.localised_name, " @ [gps=", target_enemy.position.x, ",", target_enemy.position.y, ",oarc]"})
--                             if game.players[index].character and game.players[index].character.valid then
--                                 global.groups[game.players[index].name].pet_group.set_command{
--                                     type=defines.command.compound,
--                                     structure_type=defines.compound_command.logical_or,
--                                     commands={
--                                         {
--                                             type=defines.command.compound,
--                                             structure_type=defines.compound_command.return_last,
--                                             commands={
--                                                 {
--                                                     type = defines.command.attack,
--                                                     target = target_enemy
--                                                 },
--                                                 -- {
--                                                 --     type = defines.command.wander,
--                                                 --     ticks_to_wait = 60
--                                                 -- }
--                                             }
--                                         }
--                                     }
--                                 }
--                                 -- game.players[index].print({"", "State: ", serpent.line(global.groups[game.players[index].name].pet_group.state), "\nCommand: ", serpent.line(global.groups[game.players[index].name].pet_group.command)})
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end

return Group
