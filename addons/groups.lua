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
        }
    }
end

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

function Group.on_tick()
    if (game.tick % 300 == 0) and global.groups then
        for index, entry in pairs(global.groups) do
            if not game.players[index] then return end
            total = Group.get_count(game.players[index])
            if global.groups[game.players[index].name].pet_group.members then
                if total > 0 then
                    target_enemy = game.players[index].surface.find_nearest_enemy{position=global.ocore.playerSpawns[game.players[index].name], max_distance=1000, game.players[index].force}
                    if target_enemy then
                        -- game.players[index].print({"", total, " pets attacking ", target_enemy.localised_name, " @ [gps=", target_enemy.position.x, ",", target_enemy.position.y, ",oarc]"})
                        if game.players[index].character and game.players[index].character.valid then
                            global.groups[game.players[index].name].pet_group.set_command{
                                type=defines.command.compound,
                                structure_type=defines.compound_command.logical_or,
                                commands={
                                    {
                                        type=defines.command.compound,
                                        structure_type=defines.compound_command.return_last,
                                        commands={
                                            {
                                                type = defines.command.attack,
                                                target = target_enemy
                                            },
                                            {
                                                type = defines.command.wander,
                                                ticks_to_wait = 60
                                            }
                                        }
                                    },
                                    {
                                        type=defines.command.compound,
                                        structure_type=defines.compound_command.return_last,
                                        commands={
                                            {
                                                type = defines.command.attack,
                                                target = target_enemy
                                            },
                                            {
                                                type = defines.command.wander,
                                                ticks_to_wait = 60
                                            }
                                        }
                                    }
                                }
                            }
                        end
                    end
                end
            end
        end
    end
end

return Group
