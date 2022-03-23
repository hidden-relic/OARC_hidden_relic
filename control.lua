local color = require 'utils.color_presets'
-- Generic Utility Includes
require("lib/oarc_utils")

local market = require("addons/market")
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

require("lib/bonuses_gui")
local find_patch = require("lib/find_patch")
local tools = require("addons/tools")

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

    OarcMapFeatureInitGlobalCounters()
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

    SeparateSpawnsPlayerCreated(event.player_index, true)

    InitOarcGuiTabs(player)

    if global.ocfg.enable_coin_shop then InitOarcStoreGuiTabs(player) end
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

----------------------------------------
-- On Research Finished
-- This is where you can permanently remove researched techs
----------------------------------------
script.on_event(defines.events.on_research_finished, function(event)

    -- Never allows players to build rocket-silos in "frontier" mode.
    if global.ocfg.frontier_rocket_silo and not global.ocfg.frontier_allow_build then
        RemoveRecipe(event.research.force, "rocket-silo")
    end

    if global.ocfg.lock_goodies_rocket_launch and
        (not global.ocore.satellite_sent or
            not global.ocore.satellite_sent[event.research.force.name]) then
        for _, v in ipairs(LOCKED_RECIPES) do
            RemoveRecipe(event.research.force, v.r)
        end
    end

    if global.ocfg.enable_loaders then EnableLoaders(event) end
end)

----------------------------------------
-- On Entity Spawned and On Biter Base Built
-- This is where I modify biter spawning based on location and other factors.
----------------------------------------
script.on_event(defines.events.on_entity_spawned, function(event)
    if (global.ocfg.modified_enemy_spawning) then
        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)

script.on_event(defines.events.on_biter_base_built, function(event)
    if (global.ocfg.modified_enemy_spawning) then
        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)

----------------------------------------
-- On unit group finished gathering
-- This is where I remove biter waves on offline players
----------------------------------------
script.on_event(defines.events.on_unit_group_finished_gathering, function(event)
    if (global.ocfg.enable_offline_protect) then
        OarcModifyEnemyGroup(event.group)
    end
end)

----------------------------------------
-- On Corpse Timed Out
-- Save player's stuff so they don't lose it if they can't get to the corpse fast enough.
----------------------------------------
script.on_event(defines.events.on_character_corpse_expired,
                function(event) DropGravestoneChestFromCorpse(event.corpse) end)

----------------------------------------
-- On Gui Text Change
-- For capturing text entry.
----------------------------------------
script.on_event(defines.events.on_gui_text_changed,
                function(event) NotepadOnGuiTextChange(event) end)

----------------------------------------
-- On Gui Closed
-- For capturing player escaping custom GUI so we can close it using ESC key.
----------------------------------------
script.on_event(defines.events.on_gui_closed, function(event)
    OarcGuiOnGuiClosedEvent(event)
    if global.ocfg.enable_coin_shop then OarcStoreOnGuiClosedEvent(event) end
    WelcomeTextGuiClosedEvent(event)
end)

----------------------------------------
-- On enemies killed
-- For coin generation and stuff
----------------------------------------
script.on_event(defines.events.on_entity_damaged, function(event)
    local entity = event.entity
    local cause = event.cause
    local damage = math.floor(event.original_damage_amount)
    local health = math.floor(entity.health)
    local health_percentage = entity.get_health_ratio()
    local text_color = {r = 1 - health_percentage, g = health_percentage, b = 0}

    -- Gets the location of the text
    local size = entity.get_radius()
    if size < 1 then size = 1 end
    local r = (math.random() - 0.5) * size * 0.75
    local p = entity.position
    local position = {x = p.x + r, y = p.y - size}

    local message
    if entity.name == 'character' then
        message = {'damage-popup.player-health', health}
    elseif entity.name ~= 'character' and cause and cause.name == 'character' then
        message = {'damage-popup.player-damage', damage}
    end

    -- Outputs the message as floating text
    if message then
        tools.floating_text(entity.surface, position, message, text_color)
    end

end)

script.on_event(defines.events.on_post_entity_died, function(event)
    if (game.surfaces[event.surface_index].name ~= GAME_SURFACE_NAME) then
        return
    end
    if global.ocfg.enable_coin_shop then
        CoinsFromEnemiesOnPostEntityDied(event)
    end
end, {
    {filter = "type", type = "unit"}, {filter = "type", type = "unit-spawner"},
    {filter = "type", type = "turret"}
})

----------------------------------------
-- Scripted auto decon for miners...
----------------------------------------
script.on_event(defines.events.on_resource_depleted, function(event)
    if global.ocfg.enable_miner_decon then
        OarcAutoDeconOnResourceDepleted(event)
    end
end)

--------------------------------------------
script.on_event(defines.events.on_market_item_purchased, function(event)
    local player = game.players[event.player_index]
    local player_market = global.ocore.markets[player.name]
    local count = event.count
    local t = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0.75, 0.5, 0.25}

    local offers = player_market.market.get_market_items()
    local offer = offers[event.offer_index]
    if event.offer_index <= 20 then

        local price = 0
        for _, single_price in pairs(offer.price) do
            price = price + single_price.amount
        end
        if count > 1 then
            local refund = 0
            refund = price * (count - 1)
            player.insert {name = "coin", count = refund}
        end
        local ammo = ""
        if (offer.offer.type == "gun-speed") or (offer.offer.type == "ammo-damage") then
            ammo = offer.offer.ammo_category
        elseif (offer.offer.type == "turret-attack") then
            ammo = offer.offer.turret_id
        else
            ammo = "sell_speed"
        end
        -- local types = player_market.upgrades[offer.offer.type]
                -- local offer_info = types[ammo]
        -- offer_info.level = offer_info.level + 1
        -- offer_info.bonus = offer_info.bonus + offer_info.modifier

        for i, item in ipairs(offers) do
            if i == event.offer_index then
                if event.offer_index <= 19 then
                    item.price = market.formatPrice(math.ceil(price * 1.2))
                else
                    if global.ocore.done_with_speed[player.name] ~= nil then
                        return
                    end
                    player_market.sell_speed_lvl =
                        player_market.sell_speed_lvl + 1
                        if player_market.sell_speed_lvl == 10 then
                            table.insert(global.ocore.done_with_speed, {[player.name] = true})
                            item = nil
                        end
                    item.price = market.formatPrice(tools.round(price * 1.7))
                    player_market.sell_speed_multiplier = global.ocore.markets.sell_upgrade_table[player_market.sell_speed_lvl]
                end
            end
        end
        -- offer_info.price = market.unFormatPrice(offer.price)
        player_market.market.clear_market_items()
        for __, item in pairs(offers) do
            player_market.market.add_market_item(item)
        end
    end
end)
