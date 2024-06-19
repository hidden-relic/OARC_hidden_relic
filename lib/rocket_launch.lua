-- rocket_launch.lua
-- May 2019
-- This is meant to extract out any rocket launch related logic to support my oarc scenario designs.
require("lib/oarc_utils")
require("config")
local tools = require('addons/tools')

-- JAPC message handler
local function log_message(event, msg)
    print("[JAPC-EVENT-HANDLE] " .. msg)
    -- game.write_file("server.log", msg .. "\n", true)
end

--------------------------------------------------------------------------------
-- Rocket Launch Event Code
-- Controls the "win condition"
--------------------------------------------------------------------------------
function RocketLaunchEvent(event)
    local force = event.rocket.force
    
    -- Notify players on force if rocket was launched without sat.
    if event.rocket.get_item_count("satellite") == 0 then
        for index, player in pairs(force.players) do
            player.print(
            "You launched the rocket, but you didn't put a satellite inside.")
        end
        return
    end
    
    -- First ever sat launch
    if not global.ocore.satellite_sent then
        global.ocore.satellite_sent = {}
        SendBroadcastMsg("Team " .. force.name ..
        " was the first to launch a rocket!")
        ServerWriteFile("rocket_events", "Team " .. force.name ..
        " was the first to launch a rocket!" .. "\n")
        log_message(event, "Team " .. event.rocket.force.name ..
        " was the first to launch a rocket!")
        
        for name, player in pairs(game.players) do
            SetOarcGuiTabEnabled(player, OARC_SCIENCE_GUI_TAB_NAME, true)
        end
    end
    
    -- Track additional satellites launched by this force
    local announcement_milestones = {
        [5] = true,
        [10] = true,
        [25] = true,
        [50] = true,
        [100] = true,
        [250] = true,
        [500] = true,
        [1000] = true,
        [2500] = true,
        [5000] = true
    }
    if global.ocore.satellite_sent[force.name] then
        global.ocore.satellite_sent[force.name] =
        global.ocore.satellite_sent[force.name] + 1
        if announcement_milestones[global.ocore.satellite_sent[force.name]] then
            SendBroadcastMsg("Team " .. force.name ..
            " launched another rocket. Total " ..
            global.ocore.satellite_sent[force.name])
            ServerWriteFile("rocket_events",
            "Team " .. force.name ..
            " launched another rocket. Total " ..
            global.ocore.satellite_sent[force.name] .. "\n")
        end
        -- Lets only send server notifications every 25 rockets after first 25 launched.
        if global.ocore.satellite_sent[force.name] < 25 or
        global.ocore.satellite_sent[force.name] % 25 == 0 then
            log_message(event,
            "Team " .. event.rocket.force.name ..
            " launched another rocket. Total " ..
            global.ocore.satellite_sent[force.name])
        end
        
        -- First sat launch for this force.
    else
        -- game.set_game_state{game_finished=true, player_won=true, can_continue=true}
        global.ocore.satellite_sent[force.name] = 1
        SendBroadcastMsg("Team " .. force.name ..
        " launched their first rocket!")
        ServerWriteFile("rocket_events", "Team " .. force.name ..
        " launched their first rocket!" .. "\n")
        log_message(event, "Team " .. event.rocket.force.name ..
        " launched their first rocket!")
        -- Unlock research and recipes
        if global.ocfg.lock_goodies_rocket_launch then
            for _, v in ipairs(LOCKED_TECHNOLOGIES) do
                EnableTech(force, v.t)
            end
            for _, v in ipairs(LOCKED_RECIPES) do
                if (force.technologies[v.r].researched) then
                    AddRecipe(force, v.r)
                end
            end
        end
    end
end

function CreateScienceGuiTab(tab_container, player)
    -- local frame = tab_container.add{type="frame", name="science-panel", caption="Satellites Launched:", direction = "vertical"}
    
    AddLabel(tab_container, nil, "SPM:", my_label_header_style)
    
    local spm_table = tab_container.add {
        name = 'spm_table',
        type = 'table',
        column_count = 2
    }
    
    local nil_forces = {
        ['player'] = true,
        ['enemy'] = true,
        ['neutral'] = true,
        ['_ABANDONED_'] = true,
        ['_DESTROYED_'] = true,
        ['shared'] = true
    }
    
    for _, force in pairs(game.forces) do
        if not nil_forces[force.name] then
            spm_table.add {
                type = 'label',
                caption = force.name
            }
            spm_table.add {
                type = 'label',
                caption = tools.round(tools.get_spm(force), 2)
            }
        end
    end
    
    AddLabel(tab_container, nil, "Satellites Launched:", my_label_header_style)
    
    if (global.ocore.satellite_sent == nil) then
        AddLabel(tab_container, nil, "No launches yet.", my_label_style)
    else
        for force_name, sat_count in pairs(global.ocore.satellite_sent) do
            AddLabel(tab_container, "rc_" .. force_name,
            "Team " .. force_name .. ": " .. tostring(sat_count),
            my_label_style)
        end
    end
end

