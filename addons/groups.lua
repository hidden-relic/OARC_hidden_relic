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
    ["medium-biter"] = {cost = 2500, color = {138, 106, 107}},
    ["big-biter"] = {cost = 5000, color = {98, 92, 129}},
    ["behemoth-biter"] = {cost = 10000, color = {94, 192, 136}}
}

function Group.new(player)
    local player = player
    global.groups[player.name] = {
        pets = {},
        tags = {},
        max = 50,
        limit = 1,
        total = 0,
        pet_group = {}
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

-- function Group.check(player)
--     local player = player
--     if global.groups[player.name] then
--         local group = global.groups[player.name]
--         if group.pet_group then
--             if not group.pet_group.valid then pcall(group.pet_group.destroy()) return end
            

function Group.get_count(player)
    local player = player
    local group = global.groups[player.name]
    group.total = 0
    for name, pets in pairs(group.pets) do
        for index, entry in pairs(pets) do
            if entry.valid then group.total = group.total + 1 end
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
        end
    else
        player.print("Max buddies allowed")
    end
end

group_logging = false

function Group.on_tick()
    if (game.tick % 30 == 0) and global.groups then
        for index, entry in pairs(global.groups) do
            if group_logging == true then game.print("index: "..index) end
            if not entry then return end
            if group_logging == true then game.print("entry found") end
            if not entry.pet_group then return end
            if group_logging == true then game.print("pet group found") end
            if not entry.pet_group.valid then return end
            if group_logging == true then game.print("pet group valid") end
            if not game.players[index] then return end
            if group_logging == true then game.print("player: "..game.players[index].name) end
            if group_logging == true then game.print("player position: "..serpent.line(game.players[index].position)) end
            if not game.players[index].character then return end
            if group_logging == true then game.print("character found") end
            if not game.players[index].character.valid then return end
            if group_logging == true then game.print("character valid") end
            if group_logging == true then game.print("group count: "..Group.get_count(game.players[index])) end
            if entry.pet_group.members then
                if group_logging == true then game.print("group has members") end
                if game.tick % 60 == 0 then
                    entry.pet_group.set_command({
                        type = defines.command.attack_area,
                        destination = game.players[index].position,
                        radius = 16,
                        use_group_distraction=false
                    })
                    if group_logging == true then game.print("command sent: attack_area 16 radius @ "..serpent.line(game.players[index].position)) end
                elseif game.tick % 60 == 30 then
                    entry.pet_group.set_command({
                        type = defines.command.go_to_location,
                        destination_entity = game.players[index].character,
                        use_group_distraction = false
                    })
                    if group_logging == true then game.print("command sent: go_to_location @ "..game.players[index].name.."'s character: "..serpent.line(game.players[index].position)) end
                end
            end
        end
    end
end

return Group
