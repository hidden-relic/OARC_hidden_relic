-- character_crafting_speed_modifier
-- character_mining_speed_modifie9jjr
-- character_running_speed_modifier
-- character_build_distance_bonus
-- character_item_drop_distance_bonus
-- character_reach_distance_bonus
-- character_resource_reach_distance_bonus
-- character_item_pickup_distance_bonus
-- character_loot_pickup_distance_bonus
-- character_inventory_slots_bonus
-- character_trash_slot_count_bonus
-- character_maximum_following_robot_count_bonus
-- character_health_bonus
require("stdlib/table")

local function in_table(tbl, val)
    if type(tbl) == "table" then
        for index, value in pairs(tbl) do
            if value == val then return index end
        end
    else return end
end

local bonuses = {}

function bonuses.init(event)
    if not global.bonuses then
        global.bonuses = {
            template = {
                total = 0,
                crafting_speed = {
                    name = "Crafting Speed",
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                mining_speed = {
                    name = "Mining Speed",
                    action = actions.mining_speed,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                running_speed = {
                    name = "Running Speed",
                    action = actions.running_speed,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                build_distance = {
                    name = "Build Distance",
                    action = actions.build_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                reach_distance = {
                    name = "Reach Distance",
                    action = actions.reach_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                resource_reach_distance = {
                    name = "Resource Reach Distance",
                    action = actions.resource_reach_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                item_pickup_distance = {
                    name = "Item Pickup Distance",
                    action = actions.item_pickup_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                item_drop_distance = {
                    name = "Item Drop Distance",
                    action = actions.item_drop_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                loot_pickup_distance = {
                    name = "Loot Pickup Distance",
                    action = actions.loot_pickup_distance,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                inventory_slots = {
                    name = "Inventory Slots",
                    action = actions.inventory_slots,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                trash_slot_count = {
                    name = "Trash Slots",
                    action = actions.trash_slot_count,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                maximum_following_robot_count = {
                    name = "Maximum Following Robot Count",
                    action = actions.maximum_following_robot_count,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                },
                health = {
                    name = "Maximum Health",
                    action = actions.health,
                    bonus = 0,
                    lvl = 1,
                    xp = 0,
                    next_level = 32
                }
            }
        }
        for each, bonus in global.bonuses.template do
            if bonus.lvl then
                global.bonuses.template.total = global.bonuses.template.total + bonus.level
            end
        end
    end
end

local function get_player(event)
    local player_index = event.player_index
    local player = game.players[player_index]
    if player_index and player and player.character and player.character.valid then return player end
end

local actions = {
    crafting_speed = {"on_player_crafted_item"},
    mining_speed = {"on_player_mined_entity"},
    running_speed = {"on_player_changed_position"},
    build_distance = {"on_built_entity", "on_player_built_tile", "on_player_mined_entity"},
    reach_distance = {"on_built_entity", "on_player_built_tile", "on_player_mined_entity"},
resource_reach_distance = {"on_player_mined_entity"},
item_pickup_distance = {"on_player_mined_item"},
loot_pickup_distance = {"on_player_mined_item"},
item_drop_distance = {"on_player_dropped_item"},
inventory_slots = {"on_player_main_inventory_changed"},
trash_slot_count = {"on_player_trash_inventory_changed"},
maximum_following_robot_count = {"on_player_used_capsule"},
health = {"on_player_died", "on_entity_damaged"}
}

local function try_lvl(player, bonus)
    if bonus.xp >= bonus.next_level then
        bonus.next_level = bonus.next_level + (bonus.next_level * 1.35)
        bonus.lvl = bonus.lvl + 1
        global.bonuses[player].total = global.bonuses[player].total + 1
        player.print(bonus.name .. " > " .. lvl)
    end
end

local function on_player_crafted_item(event)
    local player = get_player(event)
    local xp_gained = event.item_stack.count * event.recipe.energy
    local crafting_speed = xpglobal.bonuses[player].crafting_speed
    crafting_speed = crafting_speed + xp_gained
    try_lvl(player, crafting_speed)
end

local function on_player_mined_entity(event)

end
local function on_player_changed_position(event)

end
local function on_built_entity(event)

end
local function on_player_built_tile(event)

end
local function on_player_mined_item(event)

end
local function on_player_dropped_item(event)

end
local function on_player_main_inventory_changed(event)

end
local function on_player_trash_inventory_changed(event)

end
local function on_player_used_capsule(event)

end
local function on_entity_damaged(event)

end
local function on_player_died(event)

end
local function get_bonuses(event)
    newtbl = {}
    for each, item in pairs(global.bonuses.template) do
        for __, action in pairs(item.action) do
            if action == bonus then
                table.insert(newtbl, item)
            end
        end
    end
return newtbl or false
end

-- local function getxp(event)
--     local bonuses = get_bonuses(event.name)
--        for each, bonus in pairs(bonuses) do
--         if bonus == "crafting_speed" then
--         local xp = event.item_stack.count * event.recipe.energy
--     end
-- end

--     if isbonus(event.name) == "m"
--     return xp
-- end

function bonuses.player_created(event)
    local player = getplayer(event)
    global.bonuses[player.name] = table.deepcopy(global.bonuses.template)
end

function bonuses.get_action(event)
    if get_bonuses(event.name) then
        local player = getplayer(event)
        local xp_earned = getxp(event)
        local playerbonuses = global.bonuses[player.name]
        local playerbonus = playerbonuses[isbonus(event.name)]
        local bonus = playerbonus.bonus
        local lvl = playerbonus.lvl
        local xp = playerbonus.xp
        local next_level = playerbonus.next_level

        xp = xp + xp_earned
        if xp >= next_level then
            next_level = next_level * 1.35
            lvl = lvl + 1
            playerbonuses.total = playerbonuses.total + 1
            player.print(bonus.name .. " > " .. lvl)
        end
    else
        return
    end
end

Event.register(defines.events.on_player_created, bonuses.player_created)
Event.register(defines.events.on_init, bonuses.init)
Event.register(defines.events.on_player_crafted_item, bonuses.get_action)
