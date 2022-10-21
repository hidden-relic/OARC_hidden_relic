--[[

-- DEFAULT_ADMIN_GROUP = 'Admin'
-- DEFAULT_TRUSTED_GROUP = 'Trusted'
-- -- format: [name] = group
-- DEFAULT_LV4_GROUP = 'Lv4'
-- DEFAULT_LV3_GROUP = 'Lv3'
-- DEFAULT_LV2_GROUP = 'Lv2'
-- DEFAULT_LV1_GROUP = 'Lv1'
-- AUTO_PERMISSION_USERS = {}

-- helper functions
-- local function set_group_permissions(group, actions, treat_actions_as_blacklist)
--     actions = actions or {}
--     if treat_actions_as_blacklist then
--         -- enable all default permissions
--         for _, a in pairs(defines.input_action) do
--             group.set_allows_action(a, true)
--         end
--         -- disable selected actions
--         for _, a in pairs(actions) do group.set_allows_action(a, false) end
--     else
--         -- disable all default permissions
--         for _, a in pairs(defines.input_action) do
--             group.set_allows_action(a, false)
--         end
--         -- enable selected actions
--         for _, a in pairs(actions) do group.set_allows_action(a, true) end
--     end
-- end

-- function permissions_init()
--     -- This is for cheat/mod permissions, part of a big TODO and not used yet
--     global.permissions = global.permissions or {}

--     -- get and create permission groups
--     local Lv1 = game.permissions.get_group(DEFAULT_LV1_GROUP) or
--                     game.permissions.create_group(DEFAULT_LV1_GROUP)
--     local Lv2 = game.permissions.get_group(DEFAULT_LV2_GROUP) or
--                     game.permissions.create_group(DEFAULT_LV2_GROUP)
--     local Lv3 = game.permissions.get_group(DEFAULT_LV3_GROUP) or
--                     game.permissions.create_group(DEFAULT_LV3_GROUP)
--     local Lv4 = game.permissions.get_group(DEFAULT_LV4_GROUP) or
--                     game.permissions.create_group(DEFAULT_LV4_GROUP)
--     local default = game.permissions.get_group('Default')
--     local trusted = game.permissions.get_group(DEFAULT_TRUSTED_GROUP) or
--                         game.permissions.create_group(DEFAULT_TRUSTED_GROUP)
--     local admin = game.permissions.get_group(DEFAULT_ADMIN_GROUP) or
--                       game.permissions.create_group(DEFAULT_ADMIN_GROUP)
--     -- explicitly enable all actions for admins
--     -- seems that create_group enables all permissions in GUI, might be same for code?
--     -- so this might not be needed unless permissions want to be restricted for admins???
--     set_group_permissions(admin, nil, true)

--     -- handle hotpatching
--     for k, v in pairs(game.players) do
--         local group = AUTO_PERMISSION_USERS[v.name]
--         if v.admin and not group then
--             game.permissions.get_group(DEFAULT_ADMIN_GROUP).add_player(v)
--         else
--             game.permissions.get_group(group).add_player(v)
--         end
--     end

--     -- restrict trusted users from only these actions
--     -- Permissions require admin powers anyhow, but hey, why not be extra-super-sure
--     local trusted_actions_blacklist = {
--         defines.input_action.add_permission_group,
--         defines.input_action.edit_permission_group,
--         defines.input_action.delete_permission_group
--     }
--     set_group_permissions(trusted, trusted_actions_blacklist, true)
--     set_group_permissions(Lv1, trusted_actions_blacklist, true)
--     set_group_permissions(Lv2, trusted_actions_blacklist, true)
--     set_group_permissions(Lv3, trusted_actions_blacklist, true)
--     set_group_permissions(Lv4, trusted_actions_blacklist, true)
--     -- New joins can only use these actions
--     -- local actions = {
--     -- defines.input_action.start_walking
--     -- }

--     -- set_group_permissions(default, defines.input_action, true)
-- end

-- control.lua
-- Mar 2019
-- Oarc's Separated Spawn Scenario
--
-- I wanted to create a scenario that allows you to spawn in separate locations
-- From there, I ended up adding a bunch of other minor/major features
--
-- Credit:
--  Tags - Taken from WOGs scenario
--  Rocket Silo - Taken from Frontier as an idea
--
-- Feel free to re-use anything you want. It would be nice to give me credit
-- if you can.
-- To keep the scenario more manageable (for myself) I have done the stalkinging:
--      1. Keep all event calls in control.lua (here)
--      2. Put all config options in config.lua and provided an example-config.lua file too.
--      3. Put other stuff into their own files where possible.
--      4. Put all other files into lib folder
--      5. Provided an examples folder for example/recommended map gen settings
-- Generic Utility Includes
require("lib/oarc_utils")

local market = require("addons/market")
local tools = require("addons/tools")
local find_patch = require("addons/find_patch")
require("addons/bonuses_gui")
-- Other soft-mod type features.
require("lib/frontier_silo")
require("lib/tag")
require("lib/game_opts")
require("lib/player_list")
require("lib/rocket_launch")
require("lib/admin_commands")
require("lib/regrowth_map")
require("lib/shared_chests")
require("lib/notepad")
require("lib/map_features")
require("lib/oarc_buy")
require("lib/auto_decon_miners")

-- For Philip. I currently do not use this and need to add proper support for
-- commands like this in the future.
-- require("lib/rgcommand")
-- require("lib/helper_commands")

-- Main Configuration File
require("config")

-- Save all config settings to global table.
require("lib/oarc_global_cfg.lua")

-- Scenario Specific Includes
require("lib/separate_spawns")
require("lib/separate_spawns_guis")
require("lib/oarc_enemies")
require("lib/oarc_gui_tabs")

-- compatibility with mods
require("compat/factoriomaps")

-- Create a new surface so we can modify map settings at the start.
GAME_SURFACE_NAME = "oarc"

commands.add_command("trigger-map-cleanup",
                     "Force immediate removal of all expired chunks (unused chunk removal mod)",
                     RegrowthForceRemoveChunksCmd)

--------------------------------------------------------------------------------
-- ALL EVENT HANLDERS ARE HERE IN ONE PLACE!
--------------------------------------------------------------------------------

----------------------------------------
-- On Init - only runs once the first
--   time the game starts
----------------------------------------
script.on_init(function(event)

    -- permissions_init()

    -- FIRST
    InitOarcConfig()

    -- Regrowth (always init so we can enable during play.)
    RegrowthInit()

    -- Create new game surface
    CreateGameSurface()

    -- MUST be before other stuff, but after surface creation.
    InitSpawnGlobalsAndForces()

    -- Frontier Silo Area Generation
    if (global.ocfg.frontier_rocket_silo and
        not global.ocfg.enable_magic_factories) then
        SpawnSilosAndGenerateSiloAreas()
    end

    -- Everyone do the shuffle. Helps avoid always starting at the same location.
    -- Needs to be done after the silo spawning.
    if (global.ocfg.enable_vanilla_spawns) then
        global.vanillaSpawns = FYShuffle(global.vanillaSpawns)
        log("Vanilla spawns:")
        log(serpent.block(global.vanillaSpawns))
    end

    Compat.handle_factoriomaps()

    if (global.ocfg.enable_coin_shop and global.ocfg.enable_chest_sharing) then
        SharedChestInitItems()
    end

    if (global.ocfg.enable_coin_shop and global.ocfg.enable_magic_factories) then
        MagicFactoriesInit()
    end

    -- oarcmapfeatureInitGlobalCounters()
    OarcAutoDeconOnInit()

    -- Display starting point text as a display of dominance.
    RenderPermanentGroundText(game.surfaces[GAME_SURFACE_NAME],
                              {x = -32, y = -30}, 37, "Spawn",
                              {0.9, 0.3, 0.3, 0.8})

    market.init()
end)

script.on_load(function() Compat.handle_factoriomaps() end)

-- script.on_configuration_changed(function(e) permissions_init() end)

----------------------------------------
-- Rocket launch event
-- Used for end game win conditions / unlocking late game stuff
----------------------------------------
script.on_event(defines.events.on_rocket_launched,
                function(event) RocketLaunchEvent(event) end)

----------------------------------------
-- Surface Generation
----------------------------------------

----------------------------------------
-- Chunk Generation
----------------------------------------
script.on_event(defines.events.on_chunk_generated, function(event)

    if (event.surface.name ~= GAME_SURFACE_NAME) then return end

    if global.ocfg.enable_regrowth then RegrowthChunkGenerate(event) end

    if global.ocfg.enable_undecorator then UndecorateOnChunkGenerate(event) end

    SeparateSpawnsGenerateChunk(event)

    CreateHoldingPen(event.surface, event.area)
end)

----------------------------------------
-- Gui Click
----------------------------------------
script.on_event(defines.events.on_gui_click, function(event)

    -- Don't interfere with other mod related stuff.
    if (event.element.get_mod() ~= nil) then return end

    if global.ocfg.enable_tags then TagGuiClick(event) end

    WelcomeTextGuiClick(event)
    SpawnOptsGuiClick(event)
    SpawnCtrlGuiClick(event)
    SharedSpwnOptsGuiClick(event)
    BuddySpawnOptsGuiClick(event)
    BuddySpawnWaitMenuClick(event)
    BuddySpawnRequestMenuClick(event)
    SharedSpawnJoinWaitMenuClick(event)

    ClickOarcGuiButton(event)

    if global.ocfg.enable_coin_shop then ClickOarcStoreButton(event) end

    GameOptionsGuiClick(event)
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    SpawnOptsRadioSelect(event)
    SpawnCtrlGuiOptionsSelect(event)
end)

script.on_event(defines.events.on_gui_selected_tab_changed, function(event)
    TabChangeOarcGui(event)

    if global.ocfg.enable_coin_shop then TabChangeOarcStore(event) end
end)

----------------------------------------
-- Player Events
----------------------------------------

script.on_event(defines.events.on_player_joined_game, function(event)
    PlayerJoinedMessages(event)

    ServerWriteFile("player_events", game.players[event.player_index].name ..
                        " joined the game." .. "\n")
    -- this is part of a much larger TODO
    -- global.permissions[event.player_index] =
    -- global.permissions[event.player_index] or {}
    -- p_c.on_player_joined_game(event)

    -- Handle hot-patching into active games
    local player = game.players[event.player_index]
    -- local group = AUTO_PERMISSION_USERS[player.name]
    -- if player.admin and not group then
    -- game.permissions.get_group(DEFAULT_ADMIN_GROUP).add_player(player)
    -- elseif group then
    -- game.permissions.get_group(group).add_player(player)
    -- else
    -- game.permissions.get_group('Default').add_player(player)
    -- end
    if (global.oarc_players[player.name] == nil) then
        global.oarc_players[player.name] = {}
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    -- Handle local hosting auto-promote
    -- if game.players[event.player_index].admin then
    -- game.permissions.get_group(DEFAULT_ADMIN_GROUP).add_player(
    -- event.player_index);
    -- end

    -- Move the player to the game surface immediately.
    player.teleport({x = 0, y = 0}, GAME_SURFACE_NAME)

    if global.ocfg.enable_long_reach then GivePlayerLongReach(player) end

    if player.admin and DEBUG_MODE then
        local newSpawn = {x = 0, y = 0}
        newSpawn = FindUngeneratedCoordinates(global.ocfg.far_dist_start,
                                              global.ocfg.far_dist_end,
                                              player.surface)
        if ((newSpawn.x == 0) and (newSpawn.y == 0)) then
            newSpawn = FindMapEdge(GetRandomVector(), player.surface)
        end

        ChangePlayerSpawn(player, newSpawn)

        QueuePlayerForDelayedSpawn(player.name, newSpawn, false,
                                   global.ocfg.enable_vanilla_spawns)
                                   player.force = game.create_force(player.name)
        return
    end
    SeparateSpawnsPlayerCreated(event.player_index, true)

    InitOarcGuiTabs(player)

    if global.ocfg.enable_coin_shop then -- InitOarcStoreGuiTabs(player) end
end)

script.on_event(defines.events.on_player_respawned, function(event)
    SeparateSpawnsPlayerRespawned(event)

    PlayerRespawnItems(event)

    if global.ocfg.enable_long_reach then
        GivePlayerLongReach(game.players[event.player_index])
    end
end)

-- script.on_event(defines.events.on_player_promoted, function(e)
--     -- auto-elevate
--     local player = game.players[e.player_index]
--     local group = AUTO_PERMISSION_USERS[player.name]
--     if not group then
--         game.permissions.get_group(DEFAULT_ADMIN_GROUP).add_player(player)
--     elseif group then
--         game.permissions.get_group(group).add_player(player)
--     end
-- end)

-- script.on_event(defines.events.on_player_demoted, function(e)
--  auto-remove
-- game.permissions.get_group('Default').add_player(e.player_index);
-- end)

script.on_event(defines.events.on_player_left_game, function(event)
    ServerWriteFile("player_events", game.players[event.player_index].name ..
                        " left the game." .. "\n")
    local player = game.players[event.player_index]

    -- If players leave early, say goodbye.
    if (player and
        (player.online_time <
            (global.ocfg.minimum_online_time * TICKS_PER_MINUTE))) then
        log("Player left early: " .. player.name)
        SendBroadcastMsg(player.name ..
                             "'s base was marked for immediate clean up because they left within " ..
                             global.ocfg.minimum_online_time ..
                             " minutes of joining.")
        RemoveOrResetPlayer(player, true, true, true, true)
    end
end)

-- script.on_event(defines.events.on_pre_player_left_game, function(event)
--     local player = game.players[event.player_index]
--     spy.stop_stalking(player)
--     for _, data in pairs(global.ocore..stalking) do
--         if data[2] == player then
--             spy.stop_stalking(data[1])
--         end
--     end
-- end)

-- script.on_event(defines.events.on_player_deconstructed_area, function(event)
--     local player = game.get_player(event.player_index)
--     if (player.permission_group.name ~= DEFAULT_TRUSTED_GROUP) and
--         (player.permission_group.name ~= DEFAULT_ADMIN_GROUP) then
--         local count = 0
--         local surface = event.surface
--         local area = event.area

--         local entities = surface.find_entities_filtered {
--             area = area,
--             to_be_deconstructed = true
--         }
--         for each, entity in pairs(entities) do
--             if (entity.force.name ~= "neutral") then
--                 if entity.to_be_deconstructed() and (entity.last_user ~= player) then
--                     count = count + 1
--                     if (count == 1) then
--                         player.print(color.text.bold(color.text.red(
--                                                          "You are not trusted to deconstruct other's work.")))
--                         entity.last_user.print(
--                             color.text.bold(color.text.blue(player.name)) ..
--                                 color.text
--                                     .blue(
--                                     " attempted to deconstruct something of yours"))
--                     end
--                     entity.cancel_deconstruction(player.force)
--                 end
--             end
--         end
--     end
-- end)

-- script.on_event(defines.events.on_player_removed, function(event)
-- Player is already deleted when this is called.
-- end)

----------------------------------------
-- On tick events. Stuff that needs to happen at regular intervals.
-- Delayed events, delayed spawns, ...
----------------------------------------
script.on_event(defines.events.on_tick, function(event)
    if global.ocfg.enable_regrowth then
        RegrowthOnTick()
        RegrowthForceRemovalOnTick()
    end

    market.on_tick()

    DelayedSpawnOnTick()

    UpdatePlayerBuffsOnTick()

    ReportPlayerBuffsOnTick()

    if global.ocfg.enable_chest_sharing then SharedChestsOnTick() end

    if (global.ocfg.enable_chest_sharing and global.ocfg.enable_magic_factories) then
        MagicFactoriesOnTick()
    end

    TimeoutSpeechBubblesOnTick()
    FadeoutRenderOnTick()

    if global.ocfg.enable_miner_decon then OarcAutoDeconOnTick() end

    RechargePlayersOnTick()
    -- spy.update_all()
end)

script.on_event(defines.events.on_sector_scanned, function(event)
    if global.ocfg.enable_regrowth then RegrowthSectorScan(event) end
end)

----------------------------------------
-- Various on "built" events
----------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
    if global.ocfg.enable_autofill then Autofill(event) end

    if global.ocfg.enable_regrowth then
        if (event.created_entity.surface.name ~= GAME_SURFACE_NAME) then
            return
        end
        RegrowthMarkAreaSafeGivenTilePos(event.created_entity.position, 2, false)
    end

    if global.ocfg.enable_anti_grief then SetItemBlueprintTimeToLive(event) end

    if global.ocfg.frontier_rocket_silo then BuildSiloAttempt(event) end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)

    if global.ocfg.enable_regrowth then
        if (event.created_entity.surface.name ~= GAME_SURFACE_NAME) then
            return
        end
        RegrowthMarkAreaSafeGivenTilePos(event.created_entity.position, 2, false)
    end
    if global.ocfg.frontier_rocket_silo then BuildSiloAttempt(event) end
end)

script.on_event(defines.events.on_player_built_tile, function(event)
    if global.ocfg.enable_regrowth then
        if (game.surfaces[event.surface_index].name ~= GAME_SURFACE_NAME) then
            return
        end

        for k, v in pairs(event.tiles) do
            RegrowthMarkAreaSafeGivenTilePos(v.position, 2, false)
        end
    end
end)

----------------------------------------
-- On script_raised_built. This should help catch mods that
-- place items that don't count as player_built and robot_built.
-- Specifically FARL.
----------------------------------------
script.on_event(defines.events.script_raised_built, function(event)
    if global.ocfg.enable_regrowth then
        if (event.entity.surface.name ~= GAME_SURFACE_NAME) then return end
        RegrowthMarkAreaSafeGivenTilePos(event.entity.position, 2, false)
    end
end)

----------------------------------------
-- Shared chat, so you don't have to type /s
-- But you do lose your player colors across forces.
----------------------------------------
script.on_event(defines.events.on_console_chat, function(event)
    if (event.player_index) then
        ServerWriteFile("server_chat", game.players[event.player_index].name ..
                            ": " .. event.message .. "\n")
    end
    if (global.ocfg.enable_shared_chat) then
        if (event.player_index ~= nil) then
            ShareChatBetweenForces(game.players[event.player_index],
                                   event.message)
        end
    end
end)

script.on_event(defines.events.on_console_command, function(e)
    -- auto-remove kicked/banned players, except admins
    -- only run this if ran by admin
    -- Note: if anyone on the server can run code(and not just admins), they can raise an event and pretend to be the console and trigger this
    -- Another reason why you shouldn't give anyone but admins access to lua commands
    -- This only allows the Trusted group to remove Trusted status in any case, so its not severe.
    local caller = (e.player_index and game.players[e.player_index]) or console
    if caller.admin then
        if (e.command == 'kick') or (e.command == 'ban') then
            local player = game.players[e.parameters]

            -- if player and not player.admin then
            --     game.permissions.get_group('Default').add_player(player);
            -- end
        end
    end
end)

-- commands.add_command('reloadperms', 'Reload permissions', function(e)
--     -- this will rebuild permissions, if they get messed up somehow
--     local caller = (e.player_index and game.players[e.player_index]) or console
--     if caller.admin then
--         permissions_init()
--         caller.print('Permissions reloaded.');
--     else
--         caller.print('You must be an admin to run this command.');
--     end
-- end)

-- local function trust_player(caller, player)
--     if player then
--         if player.admin then
--             caller.print('Player is admin.');
--         else
--             game.permissions.get_group(DEFAULT_TRUSTED_GROUP).add_player(player);
--             AUTO_PERMISSION_USERS[player.name] = DEFAULT_TRUSTED_GROUP
--             caller.print('Player now trusted.');
--         end
--     else
--         caller.print('Player not found.');
--     end
-- end

-- commands.add_command('trust', 'Trust a player', function(e)
--     -- Convenience command to add a player to the trusted group without opening the permissions GUI
--     local caller = (e.player_index and game.players[e.player_index]) or console
--     if caller.admin or (caller.permission_group.name == DEFAULT_TRUSTED_GROUP) then
--         local player = e.parameter and game.players[e.parameter]

--         trust_player(caller, player)
--     else
--         caller.print('You must be trusted to run this command.');
--     end
-- end)

-- commands.add_command('trustid', 'Trust a player ID', function(e)
--     -- Convenience command to add a playerid to the trusted group without opening the permissions GUI
--     local caller = (e.player_index and game.players[e.player_index]) or console
--     if caller.admin or (caller.permission_group.name == DEFAULT_TRUSTED_GROUP) then
--         local playerid = tonumber(e.parameter)
--         local player = playerid and game.players[playerid]

--         trust_player(caller, player)
--     else
--         caller.print('You must be trusted to run this command.');
--     end
-- end)

-- -- This is also part of a big TODO
-- local remote_interface = {}

-- remote_interface['trust'] = function(name)
--     local caller = game.player or console
--     if caller.admin or (caller.permission_group.name == DEFAULT_TRUSTED_GROUP) then
--         local group = game.permissions.get_group(DEFAULT_TRUSTED_GROUP)
--         local player = name and game.players[name]

--         trust_player(caller, player)
--     end
-- end

-- remote_interface['trustid'] = function(id)
--     local caller = game.player or console
--     if caller.admin or (caller.permission_group.name == DEFAULT_TRUSTED_GROUP) then
--         local group = game.permissions.get_group(DEFAULT_TRUSTED_GROUP)
--         local playerid = tonumber(id)
--         local player = playerid and game.players[playerid]

--         trust_player(caller, player)
--     end
-- end

-- remote_interface['add_group'] = function(name, actions,
--                                          treat_actions_as_blacklist)
--     local caller = game.player or console
--     if caller.admin then
--         local group = game.permissions.get_group(name) or
--                           game.permissions.create_group(name)
--         set_group_permissions(group, actions, treat_actions_as_blacklist)
--     end
-- end

-- remote_interface['set_auto_permission_user_list'] = function(list)
--     -- format: [name] = group
--     -- TODO: optimize to eliminate redundant calls, large numbers of users will be slow in a dumb way
--     local caller = game.player or console
--     if caller.admin then
--         for k, v in pairs(list) do
--             if not game.permissions.get_group(v) then
--                 -- error, list contains a group that doesn't exist
--             end
--         end
--         AUTO_PERMISSION_USERS = list
--     end
-- end

-- remote.add_interface('permissions', remote_interface)

]]