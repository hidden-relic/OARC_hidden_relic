local find_patch = {}

find_patch.MAX_INT32 = 2147483647

find_patch.range = 10000

local function round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function find_patch.getDistance(pos1, pos2)
    local pos1 = {x = pos1.x or pos1[1], y = pos1.y or pos1[2]}
    local pos2 = {x = pos2.x or pos2[1], y = pos2.y or pos2[2]}
    local a = math.abs(pos1.x - pos2.x)
    local b = math.abs(pos1.y - pos2.y)
    local c = math.sqrt(a ^ 2 + b ^ 2)
    return c
end

function find_patch.getClosest(pos, list)
    local x, y = pos.x or pos[1], pos.y or pos[2]
    local closest = find_patch.MAX_INT32
    for _, posenum in pairs(list) do
        local distance = find_patch.getDistance(pos, posenum)
        if distance < closest then
            x, y = posenum.x, posenum.y
            closest = distance
        end
    end
    if closest == find_patch.MAX_INT32 then
        return
    end
    return {position = {x, y}, distance = closest}
end

local colors = {
    iron_ore = {r = 137, g = 186, b = 211},
    copper_ore = {r = 252, g = 166, b = 102},
    stone = {r = 182, g = 150, b = 87},
    coal = {r = 55, g = 50, b = 40},
    uranium_ore = {r = 162, g = 249, b = 15},
    crude_oil = {r = 144, g = 144, b = 144}
}

function find_patch.findPatch(res_name, range, player)
    local patches = player.surface.find_entities_filtered {
        name = res_name,
        type = "resource",
        position = player.position,
        radius = range
    }
    local all = {}
    for each, patch in pairs(patches) do table.insert(all, patch.position) end
    local found = find_patch.getClosest(player.position, all)
    if not found then
        player.print("No " .. res_name .. " patch found")
        return
    end
    player.print(res_name .. " found " .. round(found.distance, 2) ..
                     " tiles away")
    res_name = res_name:gsub("-", "_")
    local line = rendering.draw_line {
        surface = player.surface,
        from = player.character,
        to = found.position,
        players = {player.index},
        color = colors[res_name],
        width = 3.2,
        gap_length = 5,
        dash_length = 8,
        time_to_live = 60 * 60
    }
    local circle = rendering.draw_circle {
        color = colors[res_name],
        radius = 4,
        width = 6.4,
        filled = false,
        target = found.position,
        players = {player.index},
        surface = player.surface,
        time_to_live = 60 * 60
    }
end

local resources = {
    ["i"] = "iron-ore",
    ["iron"] = "iron-ore",
    ["iron-ore"] = "iron-ore",
    ["iron_ore"] = "iron-ore",
    ["c"] = "copper-ore",
    ["copper"] = "copper-ore",
    ["copper-ore"] = "copper-ore",
    ["copper_ore"] = "copper-ore",
    ["s"] = "stone",
    ["stone"] = "stone",
    ["coal"] = "coal",
    ["u"] = "uranium-ore",
    ["uranium"] = "uranium-ore",
    ["uranium-ore"] = "uranium-ore",
    ["uranium_ore"] = "uranium-ore",
    ["o"] = "crude-oil",
    ["oil"] = "crude-oil",
    ["crude-oil"] = "crude-oil",
    ["crude_oil"] = "crude-oil"
}
commands.add_command('find', 'finds the nearest patch of given resource',
                     function(command)
    local player = game.players[command.player_index]
    local resource = command.parameter
    if resources[resource] then
        find_patch.findPatch(resources[resource], find_patch.range, player)
    end
end)

return find_patch