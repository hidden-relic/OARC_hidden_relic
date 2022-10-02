local tools = require('addons/tools')
local flying_tag = require("flying_tags")

local Group = {pets = {}, tags = {}, max = 50, limit = 1, total = 0}

function Group:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

Group.pet_data = {
    ["small-biter"] = {cost = 1000, color = {121, 180, 222}},
    ["medium-biter"] = {cost = 5000, color = {138, 106, 107}},
    ["big-biter"] = {cost = 25000, color = {98, 92, 129}},
    ["behemoth-biter"] = {cost = 100000, color = {94, 192, 136}}
}

function Group:create()
    self.group = self.player.surface.create_unit_group {
        position = self.player.position,
        force = self.player.force
    }
end

function Group:get_count()
    self.total = 0
    for name, pets in pairs(self.pets) do
        for index, entry in pairs(pets) do
            if entry.valid then
                self.total = self.total + 1
            end
        end
    end
    return self.total
end

function Group:add(pet)
    if not self.group then self:create() end
    if (self.limit > self:get_count()) and (self:get_count() < self.max) then
        if self.pet_data[pet] then
            if not self.pets[pet] then self.pets[pet] = {} end

            local new_pet = self.player.surface.create_entity {
                name = pet,
                force = self.player.force,
                position = self.player.surface.find_non_colliding_position(pet,
                                                                           self.player
                                                                               .position,
                                                                           8, 1)
            }

            local new_tag = {
                entity = new_pet,
                offset = {x = 0, y = 1},
                text = {"", self.player.name, "'s ", new_pet.localised_name},
                color = self.pet_data[pet].color
            }

            if self:get_count() < self.max then
                table.insert(self.pets[pet], new_pet)
                table.insert(self.tags, new_tag)

                self.group.add_member(new_pet)
                flying_tag.create(new_tag)
                self.player.print({
                    "groups.pet_added", self.pet_data[pet].color,
                    new_pet.localised_name, self:get_count()
                })
            end
        end
    else
        self.player.print("Max buddies allowed")
    end
end

function Group.on_tick()
    if (game.tick % 60 == 0) and groups then
        for index, entry in pairs(groups) do
            if not entry or not entry.group or not entry.group.valid or
                not game.players[index].character or not game.players[index].character.valid then
                return
            end
            if entry.group.members then
                entry.group.set_command({
                    type = defines.command.go_to_location,
                    destination_entity = game.players[index].character
                })
            end
        end
    end
end

return Group