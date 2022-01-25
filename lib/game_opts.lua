-- game_opts.lua
-- Jan 2018
-- Display current game options, maybe have some admin controls here

-- Main Configuration File
require("config")
require("lib/oarc_utils")
require("lib/separate_spawns")

function GameOptionsGuiClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    local name = event.element.name

    if (name == "ban_player") then
        local pIndex = event.element.parent.ban_players_dropdown.selected_index

        if (pIndex ~= 0) then
            local banPlayer = event.element.parent.ban_players_dropdown.get_item(pIndex)
            if (game.players[banPlayer]) then
                game.ban_player(banPlayer, "Banned from admin panel.")
                log("Banning " .. banPlayer)
            end
        end
    end

    if (name == "restart_player") then
        local pIndex = event.element.parent.ban_players_dropdown.selected_index

        if (pIndex ~= 0) then
            local resetPlayer = event.element.parent.ban_players_dropdown.get_item(pIndex)
            if (game.players[resetPlayer]) then
                RemoveOrResetPlayer(player, false, true, true, true)
                SeparateSpawnsPlayerCreated(resetPlayer, true)
                log("Resetting " .. resetPlayer)
            end
        end
    end
end

-- Used by AddOarcGuiTab
function CreateGameOptionsTab(tab_container, player)

    if global.oarc_announcements ~= nil then
        AddLabel(tab_container, "announcement_info_label", "Server announcements:", my_label_header_style)
        AddLabel(tab_container, "announcement_info_txt", global.oarc_announcements, my_longer_label_style)
        AddSpacerLine(tab_container)
    end

    -- General Server Info:
    AddLabel(tab_container, "info_1", global.ocfg.welcome_msg, my_longer_label_style)
    AddLabel(tab_container, "info_2", global.ocfg.server_rules, my_longer_label_style)
    AddLabel(tab_container, "info_3", global.ocfg.server_contact, my_longer_label_style)
    tab_container.add{type="textfield",
                            tooltip="Come join the discord (copy this invite)!",
                            text=DISCORD_INV}
    AddSpacerLine(tab_container)

    -- Enemy Settings:
    local enemy_expansion_txt = "disabled"
    if game.map_settings.enemy_expansion.enabled then enemy_expansion_txt = "enabled" end

    local enemy_text="Server Run Time: " .. formattime_hours_mins(game.tick) .. "\n" ..
    "Current Evolution: " .. string.format("%.4f", game.forces["enemy"].evolution_factor) .. "\n" ..
    "Enemy evolution time/pollution/destroy factors: " .. game.map_settings.enemy_evolution.time_factor .. "/" ..
    game.map_settings.enemy_evolution.pollution_factor .. "/" ..
    game.map_settings.enemy_evolution.destroy_factor .. "\n" ..
    "Enemy expansion is " .. enemy_expansion_txt

    AddLabel(tab_container, "enemy_info", enemy_text, my_longer_label_style)
    AddSpacerLine(tab_container)

    -- Soft Mods:
    local soft_mods_string = "Oarc Core"
    if (global.ocfg.enable_undecorator) then
        soft_mods_string = soft_mods_string .. ", Undecorator"
    end
    if (global.ocfg.enable_tags) then
        soft_mods_string = soft_mods_string .. ", Tags"
    end
    if (global.ocfg.enable_long_reach) then
        soft_mods_string = soft_mods_string .. ", Long Reach"
    end
    if (global.ocfg.enable_autofill) then
        soft_mods_string = soft_mods_string .. ", Auto Fill"
    end
    if (global.ocfg.enable_player_list) then
        soft_mods_string = soft_mods_string .. ", Player List"
    end
    if (global.ocfg.enable_regrowth) then
        soft_mods_string = soft_mods_string .. ", Regrowth"
    end
    if (global.ocfg.enable_chest_sharing) then
        soft_mods_string = soft_mods_string .. ", Item & Energy Sharing"
    end
    if (global.ocfg.enable_magic_factories) then
        soft_mods_string = soft_mods_string .. ", Special Map Chunks"
    end
    if (global.ocfg.enable_offline_protect) then
        soft_mods_string = soft_mods_string .. ", Offline Attack Inhibitor"
    end

    local game_info_str = "Soft Mods: " .. soft_mods_string

    -- Spawn options:
    if (global.ocfg.enable_separate_teams) then
        game_info_str = game_info_str.."\n".."You are allowed to spawn on your own team (have your own research tree). All teams are friendly!"
    end
    if (global.ocfg.enable_vanilla_spawns) then
        game_info_str = game_info_str.."\n".."You are spawned in a default style starting area."
    else
        game_info_str = game_info_str.."\n".."You are spawned with a fix set of starting resources."
        if (global.ocfg.enable_buddy_spawn) then
            game_info_str = game_info_str.."\n".."You can chose to spawn alongside a buddy if you spawn together at the same time."
        end
    end
    if (global.ocfg.enable_shared_spawns) then
        game_info_str = game_info_str.."\n".."Spawn hosts may choose to share their spawn and allow other players to join them."
    end
    if (global.ocfg.enable_separate_teams and global.ocfg.enable_shared_team_vision) then
        game_info_str = game_info_str.."\n".."Everyone (all teams) have shared vision."
    end
    if (global.ocfg.frontier_rocket_silo) then
        game_info_str = game_info_str.."\n".."Silos are only placeable in certain areas on the map!"
    end
    if (global.ocfg.enable_regrowth) then
        game_info_str = game_info_str.."\n".."Old parts of the map will slowly be deleted over time (chunks without any player buildings)."
    end
    if (global.ocfg.enable_power_armor_start or global.ocfg.enable_modular_armor_start) then
        game_info_str = game_info_str.."\n".."Quicker start enabled."
    end
    if (global.ocfg.lock_goodies_rocket_launch) then
        game_info_str = game_info_str.."\n".."Some technologies and recipes are locked until you launch a rocket!"
    end



    AddLabel(tab_container, "game_info_label", game_info_str, my_longer_label_style)

    if (global.ocfg.enable_abandoned_base_removal) then
        AddLabel(tab_container, "leave_warning_msg", "If you leave within " .. global.ocfg.minimum_online_time .. " minutes of joining, your base and character will be deleted.", my_longer_label_style)
        tab_container.leave_warning_msg.style.font_color=my_color_red
    end

    -- Ending Spacer
    AddSpacerLine(tab_container)

    -- ADMIN CONTROLS
    if (player.admin) then
        player_list = {}
        for _,player in pairs(game.connected_players) do
            table.insert(player_list, player.name)
        end
        tab_container.add{name = "ban_players_dropdown",
                        type = "drop-down",
                        items = player_list}
        tab_container.add{name="ban_player", type="button", caption="Ban Player"}
        tab_container.add{name="restart_player", type="button", caption="Restart Player"}
    end
end





-- -- game_opts.lua
-- -- Jan 2018
-- -- Display current game options, maybe have some admin controls here
-- -- Main Configuration File
-- require("config")
-- require("lib/oarc_utils")
-- require("lib/separate_spawns")

-- function GameOptionsGuiClick(event)
--     local targetplayer = ""
--     local targetp = ""
--     local color = {r=1, g=1, b=1}
--     if not (event and event.element and event.element.valid) then return end
--     local player = game.players[event.player_index]
--     local name = event.element.name

--     if (name == "ban_player") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             game.ban_player(targetplayer, "Banned from admin panel.")
--             log("Banning " .. targetplayer)
--         end
--     end

--     if (name == "restart_player") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             RemoveOrResetPlayer(targetplayer, false, true, true, true)
--             SeparateSpawnsPlayerCreated(event.player_index, true)
--             log("Resetting " .. targetplayer.name)
--         end
--     end

--     if (name == "flying_text") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             if (color_red_in and color_red_in.slider_value ~= nil) then
--         color.r = color_red_in.slider_value
--     end
--     if (color_green_in and color_green_in.slider_value ~= nil) then
--         color.g = color_green_in.slider_value
--     end
--     if (color_blue_in and color_blue_in.slider_value ~= nil) then
--         color.b = color_blue_in.slider_value
--     end
--             local msg = text_in.text
--             FlyingText(msg, targetplayer.position, color, targetplayer.surface)
--         end
--     end

--     if (name == "send_msg") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local msg = text_in.text
--             SendMsg(targetp, msg)
--         end
--     end

--     if (name == "get_distance") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local pos1 = player.position
--             local pos2 = targetplayer.position
--             game.player.print("Distance to " .. targetplayer.name .. ": " ..
--                                   getDistance(pos1, pos2))
--         end
--     end

--     if (name == "clear_nearby_enemies") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local dist = 32
--             ClearNearbyEnemies(targetplayer.position, dist, targetplayer.surface)
--         end
--     end

--     if (name == "display_speech_bubble") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local msg = text_in.text
--             local secs = secs_in.text
--             DisplaySpeechBubble(targetplayer, msg, secs)
--         end
--     end

--     if (name == "send_broadcast_msg") then
--         local msg = text_in.text
--         SendBroadcastMsg(msg)
--     end

--     if (name == "get_center") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local pos1 = player.position
--             local pos2 = targetplayer.position
--             game.player.print("Center to " .. targetplayer.name .. ": " ..
--                                   getCenter(pos1, pos2))
--         end
--     end

--     if (name == "give_player_starter_items") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             GivePlayerStarterItems(targetplayer)
--         end
--     end

--     if (name == "temporary_helper_text") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             if (color_red_in and color_red_in.slider_value ~= nil) then
--         color.r = color_red_in.slider_value
--     end
--     if (color_green_in and color_green_in.slider_value ~= nil) then
--         color.g = color_green_in.slider_value
--     end
--     if (color_blue_in and color_blue_in.slider_value ~= nil) then
--         color.b = color_blue_in.slider_value
--     end
--             local msg = text_in.text
--             local secs = secs_in.text
--             TemporaryHelperText(msg, targetplayer.position, secs * TICKS_PER_SECOND, color)
--         end
--     end

--     if (name == "render_path") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local pos1 = player.position
--             local pos2 = targetplayer.position
--             local secs = secs_in.text
--             RenderPath{{pos1, pos2}, secs, {player}}
--         end
--     end

--     if (name == "repair") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             local distance = 32
--             if (secs_in.text ~= nil) then
--                 distance = secs_in.text
--             end
--             repair(targetplayer, distance, player)
--         end
--     end

--     if (name == "safe_teleport_to_player") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             SafeTeleport(player, targetplayer.surface, targetplayer.position)
--         end
--     end

--     if (name == "safe_teleport_player_to") then
--             if (target_player) then
--         if (target_player.selected_index ~= 0) then   
--             local pIndex = target_player.selected_index
--             if pIndex ~= nil then
--                 targetp = target_player.get_item(pIndex)
--                 targetplayer = game.get_player(targetp)
--             end
--         end
--     end
--         if (targetplayer ~= nil) then
--             SafeTeleport(targetplayer, player.surface, player.position)
--         end
--     end
-- end

-- -- Used by AddOarcGuiTab
-- function CreateGameOptionsTab(tab_container, player)

--     if global.oarc_announcements ~= nil then
--         AddLabel(tab_container, "announcement_info_label",
--                  "Server announcements:", my_label_header_style)
--         AddLabel(tab_container, "announcement_info_txt",
--                  global.oarc_announcements, my_longer_label_style)
--         AddSpacerLine(tab_container)
--     end

--     -- General Server Info:
--     AddLabel(tab_container, "info_1", global.ocfg.welcome_msg,
--              my_longer_label_style)
--     AddLabel(tab_container, "info_2", global.ocfg.server_rules,
--              my_longer_label_style)
--     AddLabel(tab_container, "info_3", global.ocfg.server_contact,
--              my_longer_label_style)
--     tab_container.add {
--         type = "textfield",
--         tooltip = "Come join the discord (copy this invite)!",
--         text = DISCORD_INV
--     }
--     AddSpacerLine(tab_container)

--     -- Enemy Settings:
--     local enemy_expansion_txt = "disabled"
--     if game.map_settings.enemy_expansion.enabled then
--         enemy_expansion_txt = "enabled"
--     end

--     local enemy_text =
--         "Server Run Time: " .. formattime_hours_mins(game.tick) .. "\n" ..
--             "Current Evolution: " ..
--             string.format("%.4f", game.forces["enemy"].evolution_factor) .. "\n" ..
--             "Enemy evolution time/pollution/destroy factors: " ..
--             game.map_settings.enemy_evolution.time_factor .. "/" ..
--             game.map_settings.enemy_evolution.pollution_factor .. "/" ..
--             game.map_settings.enemy_evolution.destroy_factor .. "\n" ..
--             "Enemy expansion is " .. enemy_expansion_txt

--     AddLabel(tab_container, "enemy_info", enemy_text, my_longer_label_style)
--     AddSpacerLine(tab_container)

--     -- Soft Mods:
--     local soft_mods_string = "Oarc Core"
--     if (global.ocfg.enable_undecorator) then
--         soft_mods_string = soft_mods_string .. ", Undecorator"
--     end
--     if (global.ocfg.enable_tags) then
--         soft_mods_string = soft_mods_string .. ", Tags"
--     end
--     if (global.ocfg.enable_long_reach) then
--         soft_mods_string = soft_mods_string .. ", Long Reach"
--     end
--     if (global.ocfg.enable_autofill) then
--         soft_mods_string = soft_mods_string .. ", Auto Fill"
--     end
--     if (global.ocfg.enable_player_list) then
--         soft_mods_string = soft_mods_string .. ", Player List"
--     end
--     if (global.ocfg.enable_regrowth) then
--         soft_mods_string = soft_mods_string .. ", Regrowth"
--     end
--     if (global.ocfg.enable_chest_sharing) then
--         soft_mods_string = soft_mods_string .. ", Item & Energy Sharing"
--     end
--     if (global.ocfg.enable_magic_factories) then
--         soft_mods_string = soft_mods_string .. ", Special Map Chunks"
--     end
--     if (global.ocfg.enable_offline_protect) then
--         soft_mods_string = soft_mods_string .. ", Offline Attack Inhibitor"
--     end

--     local game_info_str = "Soft Mods: " .. soft_mods_string

--     -- Spawn options:
--     if (global.ocfg.enable_separate_teams) then
--         game_info_str = game_info_str .. "\n" ..
--                             "You are allowed to spawn on your own team (have your own research tree). All teams are friendly!"
--     end
--     if (global.ocfg.enable_vanilla_spawns) then
--         game_info_str = game_info_str .. "\n" ..
--                             "You are spawned in a default style starting area."
--     else
--         game_info_str = game_info_str .. "\n" ..
--                             "You are spawned with a fix set of starting resources."
--         if (global.ocfg.enable_buddy_spawn) then
--             game_info_str = game_info_str .. "\n" ..
--                                 "You can chose to spawn alongside a buddy if you spawn together at the same time."
--         end
--     end
--     if (global.ocfg.enable_shared_spawns) then
--         game_info_str = game_info_str .. "\n" ..
--                             "Spawn hosts may choose to share their spawn and allow other players to join them."
--     end
--     if (global.ocfg.enable_separate_teams and
--         global.ocfg.enable_shared_team_vision) then
--         game_info_str = game_info_str .. "\n" ..
--                             "Everyone (all teams) have shared vision."
--     end
--     if (global.ocfg.frontier_rocket_silo) then
--         game_info_str = game_info_str .. "\n" ..
--                             "Silos are only placeable in certain areas on the map!"
--     end
--     if (global.ocfg.enable_regrowth) then
--         game_info_str = game_info_str .. "\n" ..
--                             "Old parts of the map will slowly be deleted over time (chunks without any player buildings)."
--     end
--     if (global.ocfg.enable_power_armor_start or
--         global.ocfg.enable_modular_armor_start) then
--         game_info_str = game_info_str .. "\n" .. "Quicker start enabled."
--     end
--     if (global.ocfg.lock_goodies_rocket_launch) then
--         game_info_str = game_info_str .. "\n" ..
--                             "Some technologies and recipes are locked until you launch a rocket!"
--     end

--     AddLabel(tab_container, "game_info_label", game_info_str,
--              my_longer_label_style)

--     if (global.ocfg.enable_abandoned_base_removal) then
--         AddLabel(tab_container, "leave_warning_msg",
--                  "If you leave within " .. global.ocfg.minimum_online_time ..
--                      " minutes of joining, your base and character will be deleted.",
--                  my_longer_label_style)
--         tab_container.leave_warning_msg.style.font_color = my_color_red
--     end

--     -- Ending Spacer
--     AddSpacerLine(tab_container)

--     -- ADMIN CONTROLS
--     if (player.admin) then
--         player_list = {}
--         for _, player in pairs(game.connected_players) do
--             table.insert(player_list, player.name)
--         end

--         -- top row - player dropdown, msg label and input, seconds label and input, color label
--         local input_flow = tab_container.add {
--             name = "admin_inputs",
--             type = "flow",
--             direction = "horizontal"
--         }
--         target_player = input_flow.add {
--             name = "ban_players_dropdown",
--             type = "drop-down",
--             items = player_list,
--             selected_index = 1
--         }
--         input_flow.add {type = "label", name = "text_label", caption = "Msg: "}
--         text_in = input_flow.add {name = "text_input", type = "textfield"}
--         input_flow.add {
--             type = "label",
--             name = "seconds_label",
--             caption = "Time/Distance: "
--         }
--         secs_in = input_flow.add {
--             name = "seconds_input",
--             type = "textfield",
--             numeric = true
--         }
--         -- container for buttons
--         local buttons_flow = tab_container.add {
--             name = "admin_buttons",
--             type = "flow",
--             direction = "horizontal"
--         }
--         -- first column - ban, restart, start kit
--         local flow = buttons_flow.add {
--             name = "admin_functions",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow.add {name = "ban_player", type = "button", caption = "Ban Player"}
--         flow.add {
--             name = "restart_player",
--             type = "button",
--             caption = "Restart Player"
--         }
--         flow.add {
--             name = "give_player_starter_items",
--             type = "button",
--             caption = "Starter Kit"
--         }
--         -- second column - flying text, speech bubble, helper text
--         local flow2 = buttons_flow.add {
--             name = "admin_functions2",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow2.add {
--             name = "flying_text",
--             type = "button",
--             caption = "Flying Text"
--         }
--         flow2.add {
--             name = "display_speech_bubble",
--             type = "button",
--             caption = "Speech Bubble"
--         }
--         flow2.add {
--             name = "temporary_helper_text",
--             type = "button",
--             caption = "Helper Text"
--         }
--         -- third column - game msg, announcement, draw path
--         local flow3 = buttons_flow.add {
--             name = "admin_functions3",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow3.add {
--             name = "send_broadcast_msg",
--             type = "button",
--             caption = "Announcement"
--         }
--         flow3.add {name = "send_msg", type = "button", caption = "Game Message"}
--         flow3.add {name = "render_path", type = "button", caption = "Draw Path"}
--         -- fourth column - distance, center, tele to
--         local flow4 = buttons_flow.add {
--             name = "admin_functions4",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow4.add {
--             name = "get_distance",
--             type = "button",
--             caption = "Get Distance"
--         }
--         flow4.add {name = "get_center", type = "button", caption = "Get Center"}
--         flow4.add {
--             name = "safe_teleport_to_player",
--             type = "button",
--             caption = "Tele to Player"
--         }
--         -- fifth column - clear bugs, repair, tele player
--         local flow5 = buttons_flow.add {
--             name = "admin_functions5",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow5.add {
--             name = "clear_nearby_enemies",
--             type = "button",
--             caption = "Evict Biters"
--         }
--         flow5.add {name = "repair", type = "button", caption = "Repair"}
--         flow5.add {
--             name = "safe_teleport_player_to",
--             type = "button",
--             caption = "Tele Player to"
--         }
--         local flow6 = buttons_flow.add {
--             name = "admin_functions6",
--             type = "flow",
--             direction = "vertical"
--         }
--         flow6.add {
--             type = "label",
--             name = "color_label",
--             caption = "Color: "
--         }
--         local flow6red = flow6.add {
--             name = "red_input",
--             type = "flow",
--             direction = "horizontal"
--         }
--         flow6red.add {type = "label", name = "color_red_label", caption = "R: "}
--         color_red_in = flow6red.add {
--             name = "color_red_input",
--             type = "slider",
--             maximum_value = 1,
--             value = 1,
--             value_step = 0.05
--         }

--         local flow6green = flow6.add {
--             name = "green_input",
--             type = "flow",
--             direction = "horizontal"
--         }
--         flow6green.add {
--             type = "label",
--             name = "color_green_label",
--             caption = "G: "
--         }
--         color_green_in = flow6green.add {
--             name = "color_green_input",
--             type = "slider",
--             maximum_value = 1,
--             value = 1,
--             value_step = 0.05
--         }

--         local flow6blue = flow6.add {
--             name = "blue_input",
--             type = "flow",
--             direction = "horizontal"
--         }
--         flow6blue.add {
--             type = "label",
--             name = "color_blue_label",
--             caption = "B: "
--         }
--         color_blue_in = flow6blue.add {
--             name = "color_blue_input",
--             type = "slider",
--             maximum_value = 1,
--             value = 1,
--             value_step = 0.05
--         }
--     end
-- end
