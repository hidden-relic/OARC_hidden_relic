local tools = require('addons/tools')
local flying_tag = require("flying_tags")

local groups = {}

function groups.init()
    global.ocore.groups = {
        config = {
            ["small-biter"] = {max_count = 7, price = 1000, color = {r=121, g=180, b=222}},
            ["medium-biter"] = {max_count = 5, price = 5000, color = {r=138, g=106, b=107}},
            ["big-biter"] = {max_count = 3, price = 25000, color = {r=98, g=92, b=129}},
            ["behemoth-biter"] = {max_count = 1, price = 100000, color = {r=94, g=192, b=136}}
        }
    }
end

function groups.createGroup(player)
    local player = tools.get_player(player)
    if player then
        if not global.ocore.groups.player_groups then
            global.ocore.groups.player_groups = {}
        end
        if not global.ocore.groups.player_groups[player.name] then
            global.ocore.groups.player_groups[player.name] = {}
        end
        if not global.ocore.groups.player_groups[player.name].group then
            global.ocore.groups.player_groups[player.name].group =
                player.surface.create_unit_group {
                    position = player.position,
                    force = player.force
                }
        end
        if not global.ocore.groups.player_groups[player.name].count then
            global.ocore.groups.player_groups[player.name].count = {
                small = 0,
                medium = 0,
                big = 0,
                behemoth = 0
            }
        end
    end
end

function groups.giveUnit(player, unit_name, count)
    local player = tools.get_player(player)
    if player then
        local unit_name = unit_name
        groups.createGroup(player)
        if global.ocore.groups.config[unit_name] then
            local bug = {}
            if global.ocore.groups.player_groups[player.name].group then
                if global.ocore.groups.player_groups[player.name].group.members[1] then
                    local count = global.ocore.groups.player_groups[player.name]
                                      .count
                    if unit_name == "small-biter" and count.small <
                        global.ocore.groups.config["small-biter"].max_count then
                        count.small = count.small + 1
                        bug = player.surface.create_entity {
                            name = "small-biter",
                            force = player.force,
                            position = player.surface
                                .find_non_colliding_position("small-biter",
                                                             player.position, 8,
                                                             1)
                        }
                        player.print("+1 small biter. You own " .. count.small)

                    elseif unit_name == "medium-biter" and count.medium <
                        global.ocore.groups.config["medium-biter"].max_count then
                        count.medium = count.medium + 1
                        bug = player.surface.create_entity {
                            name = "medium-biter",
                            force = player.force,
                            position = player.surface
                                .find_non_colliding_position("medium-biter",
                                                             player.position, 8,
                                                             1)
                        }
                        player.print("+1 medium biter. You own " .. count.medium)

                    elseif unit_name == "big-biter" and count.big <
                        global.ocore.groups.config["big-biter"].max_count then
                        count.big = count.big + 1
                        bug = player.surface.create_entity {
                            name = "big-biter",
                            force = player.force,
                            position = player.surface
                                .find_non_colliding_position("big-biter",
                                                             player.position, 8,
                                                             1)
                        }
                        player.print("+1 big biter. You own " .. count.big)

                    elseif unit_name == "behemoth-biter" and count.behemoth <
                        global.ocore.groups.config["behemoth-biter"].max_count then
                        count.behemoth = count.behemoth + 1
                        bug = player.surface.create_entity {
                            name = "behemoth-biter",
                            force = player.force,
                            position = player.surface
                                .find_non_colliding_position("behemoth-biter",
                                                             player.position, 8,
                                                             1)
                        }
                        player.print("+1 behemoth biter. You own " ..
                                         count.behemoth)
                    else
                        return
                    end
                else
                    local t = {
                        ["small-biter"] = "small",
                        ["medium-biter"] = "medium",
                        ["big-biter"] = "big",
                        ["behemoth-biter"] = "behemoth"
                    }
                    bug = player.surface.create_entity {
                        name = unit_name,
                        force = player.force,
                        position = player.surface.find_non_colliding_position(
                            unit_name, player.position, 8, 1)
                    }
                    local count = global.ocore.groups.player_groups[player.name]
                                      .count[t[unit_name]]
                    count = count + 1
                    player.print("+1 " .. t[unit_name] .. " biter. You own " ..
                                     count)
                end
                local l_name = {}
                for _, locale in pairs(bug.localised_name) do
                    l_name = {locale}
                end
                local tag = {
                    entity = bug,
                    offset = {
                      x = 0,
                      y = 1
                    },
                    text = {"", player.name, "'s ", bug.localised_name},
                    color = global.ocore.groups.config[bug.name].color
                  }
                global.ocore.groups.player_groups[player.name].group.add_member(
                    bug)
                flying_tag.create(tag)
            end
        end
    end
end

function groups.on_tick()
    if (game.tick % 60 == 0) then
        for _, player in pairs(game.connected_players) do
            if not player.character or not player.character.valid then
                return
            end
            if global.ocore.groups.player_groups and
                global.ocore.groups.player_groups[player.name] then
                if global.ocore.groups.player_groups[player.name].group then
                    local group = global.ocore.groups.player_groups[player.name]
                                      .group
                    if group.valid then
                        if group.members then
                            group.set_command({
                                type = defines.command.go_to_location,
                                destination_entity = player.character
                            })
                        end
                    end
                end
            else
                return
            end
        end
    end
end

return groups
