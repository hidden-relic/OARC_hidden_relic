local function walk_tech(tech, t)
    local t = t or {tech}
    local tech = game.technology_prototypes[tech]
    if table_size(tech.prerequisites) > 0 then
    for name, data in pairs(tech.prerequisites) do
    table.insert(t, name)
end
for name, data in pairs(tech.prerequisites) do
    t = walk_tech(name, t)
end
end
if table_size(tech.prerequisites) == 0 then
    table.insert(t, tech.name)
end
return t
end
local t = walk_tech("stack-inserter")
local r = {}
for i=#t, 1, -1 do
    table.insert(r, t[i])
end
local nt = {}
for i=1, #r do
    nt[r[i]] = i
end
local nnt = {}
for k, v in pairs(nt) do
    table.insert(nnt, k)
end
game.player.force.research_queue = nnt

for _, tech in pairs(game.get_filtered_technology_prototypes{{filter="has-prerequisites", invert=true}}) do
    game.player.force.
end

/sc
for _, tech in pairs(game.get_filtered_technology_prototypes{
        {filter="research-unit-ingredient", ingredient="military-science-pack", invert=true},
        {filter="research-unit-ingredient", ingredient="space-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="production-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="utility-science-pack", invert=true, mode="and"},
        {filter="research-unit-ingredient", ingredient="chemical-science-pack", invert=true, mode="and"}
}) do
    game.player.force.add_research(tech.name)
end

-- make oarc circle

local spawn_center = {
    x=game.player.position.x-(game.player.position.x%32),
    y= game.player.position.y-(game.player.position.y%32)
}
local chunk_size = 32
local cfg = {
    gen_settings = {
        land_area_tiles = chunk_size*3,
        moat_choice_enabled = false,
        moat_size_modifier = 1,
        resources_circle_shape = false,
        force_grass = true,
        tree_circle = true,
        tree_octagon = false,
    },
    safe_area =
    {
        safe_radius = chunk_size*10,
        warn_radius = chunk_size*15,
        warn_reduction = 20,
        danger_radius = chunk_size*32,
        danger_reduction = 5,
    },
    water = {
        x_offset = -8,
        y_offset = -78,
        length = 16
    },
    resource_rand_pos_settings =
    {
        enabled = true,
        radius = 72,
        angle_offset = 2.285,
        angle_final = 4.57
    },
    resource_tiles =
    {
        ["iron-ore"] =
        {
            amount = 2500,
            size = 20,
            x_offset = -29,
            y_offset = 16
        },
        ["copper-ore"] =
        {
            amount = 2500,
            size = 20,
            x_offset = -28,
            y_offset = -3
        },
        ["stone"] =
        {
            amount = 2500,
            size = 20,
            x_offset = -27,
            y_offset = -34
        },
        ["coal"] =
        {
            amount = 2500,
            size = 20,
            x_offset = -27,
            y_offset = -20
        }
    },
    resource_patches =
    {
        ["crude-oil"] =
        {
            num_patches = 4,
            amount = 1080000,
            x_offset_start = -8,
            y_offset_start = 78,
            x_offset_next = 6,
            y_offset_next = 0
        }
    },
}

local function create_crop_circle(surface, centerPos, chunkArea, tileRadius, fillTile)
    local tileRadSqr = tileRadius ^ 2
    local dirtTiles = {}
    for i = chunkArea.left_top.x, chunkArea.right_bottom.x, 1 do
        for j = chunkArea.left_top.y, chunkArea.right_bottom.y, 1 do
            local distVar = math.floor(
            (centerPos.x - i) ^ 2 + (centerPos.y - j) ^ 2)
            if (distVar < tileRadSqr) then
                if (surface.get_tile(i, j).collides_with("water-tile") or
                cfg.gen_settings.force_grass or
                (game.active_mods["oarc-restricted-build"])) then
                    table.insert(dirtTiles, {name = fillTile, position = {i, j}})
                end
            end
            if ((distVar < tileRadSqr - 100) and (distVar > tileRadSqr - 500)) then
                surface.create_entity({
                    name = "tree-02",
                    amount = 1,
                    position = {i, j}
                })
            end
        end
    end
    surface.set_tiles(dirtTiles)
end

local my_chunk_area = 
{
    left_top =
    {
        x=spawn_center.x-(3*chunk_size),
        y=spawn_center.y-(3*chunk_size)
    },
    right_bottom =
    {
        x=spawn_center.x+(3*chunk_size),
        y=spawn_center.y+(3*chunk_size)
    }
}
create_crop_circle(game.player.surface, spawn_center, my_chunk_area, cfg.gen_settings
.land_area_tiles, "landfill")

local function create_water_strip(surface, leftPos, length)
    local waterTiles = {}
    for i = 0, length, 1 do
        table.insert(waterTiles,
        {name = "water", position = {leftPos.x + i, leftPos.y}})
    end
    surface.set_tiles(waterTiles)
end

for i = 0, 1, 1 do
    create_water_strip(game.player.surface, {
        x = spawn_center.x + cfg.water.x_offset,
        y = spawn_center.y + cfg.water.y_offset + i
    }, cfg.water.length)
end

local function generate_resource_patch(surface, resource_name, diameter, pos, amount)
    local midPoint = math.floor(diameter / 2)
    if (diameter == 0) then return end
    for y = -midPoint, midPoint do
        for x = -midPoint, midPoint do
            if (not cfg.gen_settings.resources_circle_shape or
            ((x) ^ 2 + (y) ^ 2 < midPoint ^ 2)) then
                surface.create_entity({
                    name = resource_name,
                    amount = amount,
                    position = {pos.x + x, pos.y + y}
                })
            end
        end
    end
end

local function fy_shuffle(t_input)
    local t_return = {}
    for i = #t_input, 1, -1 do
        local j = math.random(i)
        t_input[i], t_input[j] = t_input[j], t_input[i]
        table.insert(t_return, t_input[i])
    end
    return t_return
end

local function generate_starting_resources(surface, pos)
    local rand_settings = cfg.resource_rand_pos_settings
    if (not rand_settings.enabled) then
        for t_name, t_data in pairs(cfg.resource_tiles) do
            local pos = {
                x = pos.x + t_data.x_offset,
                y = pos.y + t_data.y_offset
            }
            generate_resource_patch(surface, t_name, t_data.size, pos, t_data.amount)
        end
    else
        local r_list = {}
        for k, _ in pairs(cfg.resource_tiles) do
            if (k ~= "") then table.insert(r_list, k) end
        end
        local shuffled_list = fy_shuffle(r_list)
        
        local angle_offset = rand_settings.angle_offset
        local num_resources = table_size(
        cfg.resource_tiles)
        local theta =
        ((rand_settings.angle_final - rand_settings.angle_offset) /
        num_resources);
        local count = 0
        
        for _, k_name in pairs(shuffled_list) do
            local angle = (theta * count) + angle_offset;
            
            local tx = (rand_settings.radius * math.cos(angle)) + pos.x
            local ty = (rand_settings.radius * math.sin(angle)) + pos.y
            
            local pos = {x = math.floor(tx), y = math.floor(ty)}
            generate_resource_patch(surface, k_name, cfg
            .resource_tiles[k_name].size, pos,
            cfg.resource_tiles[k_name]
            .amount)
            count = count + 1
        end
    end
    for p_name, p_data in pairs(cfg.resource_patches) do
        local oil_patch_x = pos.x + p_data.x_offset_start
        local oil_patch_y = pos.y + p_data.y_offset_start
        for i = 1, p_data.num_patches do
            surface.create_entity({
                name = p_name,
                amount = p_data.amount,
                position = {oil_patch_x, oil_patch_y}
            })
            oil_patch_x = oil_patch_x + p_data.x_offset_next
            oil_patch_y = oil_patch_y + p_data.y_offset_next
        end
    end
end

local function protect_entity(entity)
    entity.minable = false
    entity.operable = false
    entity.destructible = false
end

local function shared_energy_spawn_input(pos)
    protect_entity(game.player.surface.create_entity{name="accumulator", force=game.forces["shared"], position=pos})
end
local function shared_energy_spawn_output(pos)
    protect_entity(game.player.surface.create_entity{name="accumulator", force=game.forces["shared"], position=pos})
end
local function shared_chests_spawn_input(pos)
    protect_entity(game.player.surface.create_entity{name="logistic-chest-storage", force=game.forces["shared"], position=pos})
end
local function shared_chests_spawn_output(pos)
    protect_entity(game.player.surface.create_entity{name="logistic-chest-requester", force=game.forces["shared"], position=pos})
end
local function shared_chests_spawn_combinators(pos1, pos2)
    protect_entity(game.player.surface.create_entity{name="constant-combinator", force=game.forces["shared"], position=pos1})
    protect_entity(game.player.surface.create_entity{name="constant-combinator", force=game.forces["shared"], position=pos2})
end
local function create_sell_chest(pos)
    protect_entity(game.player.surface.create_entity{name="logistic-chest-buffer", force=game.forces["shared"], position=pos})
end

generate_starting_resources(game.player.surface, spawn_center)
local x_dist = cfg.resource_rand_pos_settings.radius
shared_energy_spawn_input({
    x = spawn_center.x + x_dist,
    y = spawn_center.y - 11
})
shared_energy_spawn_output({
    x = spawn_center.x + x_dist,
    y = spawn_center.y + 10
})
shared_chests_spawn_input({
    x = spawn_center.x + x_dist,
    y = spawn_center.y - 7
})
shared_chests_spawn_input({
    x = spawn_center.x + x_dist,
    y = spawn_center.y - 6
})
shared_chests_spawn_combinators({
    x = spawn_center.x + x_dist,
    y = spawn_center.y - 2
},
{x = spawn_center.x + x_dist, y = spawn_center.y})

create_sell_chest({
    x = spawn_center.x + x_dist + 3,
    y = spawn_center.y - 1
})

shared_chests_spawn_output({
    x = spawn_center.x + x_dist,
    y = spawn_center.y + 4
})
shared_chests_spawn_output({
    x = spawn_center.x + x_dist,
    y = spawn_center.y + 5
})
