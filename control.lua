local console = {
    name = 'Console',
    admin = true,
    print = function(...) rcon.print(...) end,
    color = {1, 1, 1, 1}
}

local color = require("utils/color_presets")

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
local group = require("addons/groups")
local find_patch = require("addons/find_patch")
local deathmarkers = require("addons/death-marker")
-- local flying_tags = require("flying_tags")
local logger = require("scripts/logging")
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
-- require("lib/oarc_buy")
require("lib/auto_decon_miners")

local Profiler = require("scripts/profiler")

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
    Profiler.Start(true)
    game.write_file(tools.decon_filepath, "\n", false, 0)
    game.write_file(tools.shoot_filepath, "\n", false, 0)
    
    -- FIRST
    InitOarcConfig()
    
    -- Regrowth (always init so we can enable during play.)
    RegrowthInit()
    
    -- Create new game surface
    CreateGameSurface()
    
    -- MUST be before other stuff, but after surface creation.
    InitSpawnGlobalsAndForces()
    
    global.markets = market.init()
    if global.ocfg.enable_groups == true then
        global.groups = {}
    end
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
    
    -- -- oarcmapfeatureInitGlobalCounters()
    OarcAutoDeconOnInit()
    
    -- Display starting point text as a display of dominance.
    RenderPermanentGroundText(game.surfaces[GAME_SURFACE_NAME],
    {x = -32, y = -30}, 37, "Spawn",
    {0.9, 0.3, 0.3, 0.8})
    
    -- ###### FAGC ######
    
    -- clear the logging file every restart to keep it minimal size
    game.write_file("fagc-actions.txt", "", false, 0)
    
    logger.on_init()
    
end)

script.on_event(defines.events.on_player_banned, function(e)
    local text = "ban;" .. e.player_name .. ";" .. (e.by_player or "") .. ";" ..
    (e.reason or "") .. "\n"
    game.write_file("fagc-actions.txt", text, true, 0)
end)

script.on_event(defines.events.on_player_unbanned, function(e)
    local text = "unban;" .. e.player_name .. ";" .. (e.by_player or "") .. ";" ..
    (e.reason or "") .. "\n"
    game.write_file("fagc-actions.txt", text, true, 0)
end)

-- ###### END FAGC ######


script.on_load(function() Compat.handle_factoriomaps() end)

script.on_event(defines.events.on_player_deconstructed_area, function(event)
    if global.config.decon_triggers.decon_area then
        local player = game.get_player(event.player_index)
        tools.add_decon_log(tools.get_secs() .. "," .. player.name .. ",decon_area," .. tools.pos_tostring(event.area.left_top) .. "," .. tools.pos_tostring(event.area.right_bottom))
    end
end)

----------------------------------------

script.on_event(defines.events.on_force_created, function(event)
    event.force.max_successful_attempts_per_tick_per_construction_queue = 20
    event.force.max_failed_attempts_per_tick_per_construction_queue = 20
end)

----------------------------------------
script.on_event(defines.events.on_rocket_launched,
function(event) 
    logger.on_rocket_launched(event)
    RocketLaunchEvent(event)
end)

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
-- Decon logger
----------------------------------------
-- script.on_event(defines.events.on_marked_for_deconstruction, function(event)
-- DeconCheck(event)
-- end)
----------------------------------------
-- Gui Click
----------------------------------------
script.on_event(defines.events.on_gui_switch_state_changed, function(event)
    
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    
    if global.markets and global.markets[player.name] then
        if global.markets[player.name].followers_switch and event.element ==
        global.markets[player.name].followers_switch then
            market.check_followers_switch(player)
        end
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    
    -- Don't interfere with other mod related stuff.
    if (event.element.get_mod() ~= nil) then return end
    
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    
    if global.markets and global.markets[player.name] then
        if global.markets[player.name].market_button and event.element ==
        global.markets[player.name].market_button then
            market.toggle_market_gui(player)
        end
        if global.markets[player.name].stats_button and event.element ==
        global.markets[player.name].stats_button then
            market.toggle_stats_gui(player)
        end
        if global.markets[player.name].item_buttons and
        global.markets[player.name].item_buttons[event.element.name] then
            local button =
            global.markets[player.name].item_buttons[event.element.name]
            local click = event.button
            local shift = event.shift
            local ctrl = event.control
            market.purchase(player, button.name, click, shift, ctrl)
        end
        if global.markets[player.name].upgrade_buttons and
        global.markets[player.name].upgrade_buttons[event.element.name] then
            local button =
            global.markets[player.name].upgrade_buttons[event.element.name]
            market.upgrade(player, button.name)
        end
        if global.ocfg.enable_groups == true then
            if global.markets[player.name].follower_buttons and global.markets[player.name].follower_buttons[event.element.name] then
                local button =
                global.markets[player.name].follower_buttons[event.element.name]
                if group.add(player, button.name) then
                    market.withdraw(player, market.followers_table[button.name].cost)
                end
            end
        end
        if global.markets[player.name].shared_buttons and global.markets[player.name].shared_buttons[event.element.name] then
            local button =
            global.markets[player.name].shared_buttons[event.element.name]
            if market.shared_func_table[button.name](player) then
                market.upgrade_shared(player, button.name)
            end
        end
        if global.markets[player.name].special_buttons and global.markets[player.name].special_buttons[event.element.name] then
            local button =
            global.markets[player.name].special_buttons[event.element.name]
            if market.special_func_table[button.name](player) then
                if button.name == "special_offshore-pump" then
                    market.withdraw(player, global.markets[player.name].stats.waterfill_cost)
                    return
                else
                    market.withdraw(player, market.special_table[button.name].cost)
                end
            end
        end
        
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
        
        -- if global.ocfg.enable_coin_shop then ClickOarcStoreButton(event) end
        
        GameOptionsGuiClick(event)
        
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    SpawnOptsRadioSelect(event)
    SpawnCtrlGuiOptionsSelect(event)
end)

script.on_event(defines.events.on_gui_selected_tab_changed, function(event)
    TabChangeOarcGui(event)
    
    -- if global.ocfg.enable_coin_shop then TabChangeOarcStore(event) end
end)

----------------------------------------
-- Player Events
----------------------------------------

script.on_event(defines.events.on_pre_player_died,
function(event)
    logger.on_pre_player_died(event)
    deathmarkers.playerDied(event)
end)

script.on_event(defines.events.on_player_used_capsule, function(event)
    if event.item.name == "artillery-targeting-remote" then
        tools.add_shoot_log(tools.get_secs() .. "," .. game.players[event.player_index].name .. ",manually_shot_artillery," .. tools.pos_tostring(event.position))
        for _, player in pairs(game.connected_players) do
            if player.admin then
                player.print({"", "[img=item/artillery-shell] ", game.players[event.player_index].name, " manually fired artillery [gps=", event.position.x, ",", event.position.y, ",", game.players[event.player_index].surface.name, "]"})
            end
        end
    elseif event.item.name == "grenade" then
        tools.add_shoot_log(tools.get_secs() .. "," .. game.players[event.player_index].name .. ",manually_shot_artillery," .. tools.pos_tostring(event.position))
    end
end)

-- script.on_event(defines.events.on_trigger_fired_artillery, function(event)
-- 	logger.on_trigger_fired_artillery(event)
--     game.print(tools.get_secs() .. "," .. event.source.name .. ",fired_artillery," .. event.entity.name)
--     -- tools.add_shoot_log(tools.get_secs() .. "," .. event.source.name .. ",fired_artillery," .. event.entity.name)
--     -- tools.add_shoot_logtools.get_secs() .. "," .. event.source.name .. ",fired_artillery," .. event.entity.name .. "," .. tools.pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
-- end)

script.on_event(defines.events.on_pre_player_mined_item,
function(event) deathmarkers.onMined(event) end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    if global.config.decon_triggers.mined_entity then
        local player = game.get_player(event.player_index)
        local ent = event.entity
        tools.add_decon_log(tools.get_secs() .. "," .. player.name .. ",mined_entity," .. ent.name .. "," .. tools.pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
    end
end)

script.on_event(defines.events.on_player_ammo_inventory_changed, function(event)
    local player = game.get_player(event.player_index)
    local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
    local item = ammo_inv[player.character.selected_gun_index]
    if not item or not item.valid or not item.valid_for_read then return end
    if item.name == "rocket" and global.config.decon_triggers.fired_rocket then
        tools.add_shoot_log(tools.get_secs() .. "," .. player.name .. ",shot-rocket," .. tools.pos_tostring(player.position) .. "," .. tools.pos_tostring(player.shooting_state.position))
    elseif item.name == "explosive-rocket" and global.config.decon_triggers.fired_explosive_rocket then
        tools.add_shoot_log(tools.get_secs() .. "," .. player.name .. ",shot-explosive-rocket," .. tools.pos_tostring(player.position) .. "," .. tools.pos_tostring(player.shooting_state.position))
    elseif item.name == "atomic-bomb" and global.config.decon_triggers.fired_nuke then
        tools.add_shoot_log(tools.get_secs() .. "," .. player.name .. ",shot-nuke," .. tools.pos_tostring(player.position) .. "," .. tools.pos_tostring(player.shooting_state.position))
    end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    logger.on_player_joined_game(event)
    PlayerJoinedMessages(event)
    
    ServerWriteFile("player_events", game.players[event.player_index].name ..
    " joined the game." .. "\n")
    local player = game.players[event.player_index]
    if (global.oarc_players[player.name] == nil) then
        global.oarc_players[player.name] = {}
    end
    
    deathmarkers.init(event)
end)

script.on_event(defines.events.on_player_created, function(event)
    
    local player = game.players[event.player_index]
    
    player.game_view_settings.show_entity_info = true
    
    -- Move the player to the game surface immediately.
    player.teleport({x = 0, y = 0}, GAME_SURFACE_NAME)
    
    if not global.markets then global.markets = {} end
    market.new(player)
    
    if global.ocfg.enable_groups == true then
        if not global.groups then global.groups = {} end
        group.new(player)
    end
    
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
    
    InitOarcGuiTabs(player)
    SeparateSpawnsPlayerCreated(event.player_index, true)
    
    -- if global.ocfg.enable_coin_shop then InitOarcStoreGuiTabs(player) end
    deathmarkers.init(event)
end)

script.on_event(defines.events.on_player_respawned, function(event)
    SeparateSpawnsPlayerRespawned(event)
    
    PlayerRespawnItems(event)
    
    if global.ocfg.enable_long_reach then
        GivePlayerLongReach(game.players[event.player_index])
    end
    deathmarkers.playerRespawned(event)
end)

script.on_event(defines.events.on_player_left_game, function(event)
    logger.on_player_left_game(event)
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

script.on_event(defines.events.on_trigger_fired_artillery, function(event)
    logger.on_trigger_fired_artillery(event)
end)

----------------------------------------
-- On tick events. Stuff that needs to happen at regular intervals.
-- Delayed events, delayed spawns, ...
----------------------------------------
script.on_event(defines.events.on_tick, function(event)
    if global.ocfg.enable_regrowth then
        RegrowthOnTick()
        RegrowthForceRemovalOnTick()
    end
    
    -- if game.tick % 60 == 0 then tools.FlyingTime(game.tick) end
    
    DelayedSpawnOnTick()
    
    UpdatePlayerBuffsOnTick(game.tick)
    
    ReportPlayerBuffsOnTick()
    
    -- if game.tick % game.surfaces[GAME_SURFACE_NAME].ticks_per_day == 1 then
    --     modify_night_color()
    -- end
    
    if game.tick % 216000 == 0 then
        tools.statistics_log()
    end
    
    market.on_tick()
    if global.ocfg.enable_groups == true then
        group.on_tick()
    end
    -- flying_tags.update()
    
    -- tools.stockUp()
    
    if global.ocfg.enable_chest_sharing then SharedChestsOnTick() end
    
    if (global.ocfg.enable_chest_sharing and global.ocfg.enable_magic_factories) then
        MagicFactoriesOnTick()
    end
    
    TimeoutSpeechBubblesOnTick()
    FadeoutRenderOnTick()
    
    if global.ocfg.enable_miner_decon then
        if game.tick % 300 == 1 then
            OarcAutoDeconOnTick()
        end
    end
    
    if game.tick % 60 == 1 then
        RechargePlayersOnTick()
    end
    
    if game.tick % 60*60*15 == 1 then
        logger.logStats()
    end
    if game.tick % 60*60 == 1 then
        logger.checkEvolution()
    end
end)

script.on_event(defines.events.on_sector_scanned, function(event)
    if global.ocfg.enable_regrowth then RegrowthSectorScan(event) end
end)

----------------------------------------
-- Various on "built" events
----------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
    logger.on_built_entity(event)
    if global.ocfg.enable_autofill then Autofill(event) end
    
    local player = game.players[event.player_index]
    
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
    local caller = (e.player_index and game.players[e.player_index]) or console
    if caller.admin then
        if (e.command == 'kick') or (e.command == 'ban') then
            local player = game.players[e.parameters]
        end
    end
end)

----------------------------------------
-- On Research Finished
-- This is where you can permanently remove researched techs
----------------------------------------
script.on_event(defines.events.on_research_finished, function(event)
    logger.on_research_finished(event)
    
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
script.on_event(defines.events.on_character_corpse_expired, function(event)
    DropGravestoneChestFromCorpse(event.corpse)
    deathmarkers.corpseExpired(event)
end)

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
    local player = game.players[event.player_index]
    if event.element then
        if event.element == global.markets[player.name].market_frame then
            market.close_market_gui(player)
        elseif event.element == global.markets[player.name].stats_frame then
            market.close_stats_gui(player)
        end
    end
    OarcGuiOnGuiClosedEvent(event)
    -- if global.ocfg.enable_coin_shop then OarcStoreOnGuiClosedEvent(event) end
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
    if cause and cause.name == "gun-turret" and cause.last_user and global.markets.autolvl_turrets[cause.last_user.name] then
        local player = cause.last_user
        player.force.set_ammo_damage_modifier("bullet", player.force.get_ammo_damage_modifier("bullet") + damage * 0.0000001)
    end
    
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

script.on_event(defines.events.on_entity_died, function(event)
    if global.ocfg.enable_coin_shop then
        CoinsFromEnemiesOnPostEntityDied(event)
    end
    if event.entity.name == "gun-turret" and event.entity.force == "enemy" then
        game.forces["enemy"].set_ammo_damage_modifier("bullet", game.forces["enemy"].get_ammo_damage_modifier("bullet")+0.1)
        game.forces["enemy"].set_turret_attack_modifier("gun-turret", game.forces["enemy"].get_turret_attack_modifier("gun-turret")+0.1)
        game.forces["enemy"].set_gun_speed_modifier("bullet", game.forces["enemy"].get_gun_speed_modifier("bullet")+0.01)
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
