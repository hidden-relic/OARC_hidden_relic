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
    
    if not global.force_spm_table then global.force_spm_table = {} end
    
    -- local frame = tab_container.add{type="frame", name="science-panel", caption="Satellites Launched:", direction = "vertical"}
    
    AddLabel(tab_container, nil, "SPM:", my_label_header_style)
    AddLabel(tab_container, nil, "'Current' is the average over the last minute. 'Highest' is your highest recorded SPM sustained for 1 hour. 'Total' is total bottles consumed.", my_label_style)
    
    local spm_table = tab_container.add {
        name = 'spm_table',
        type = 'table',
        column_count = 4
    }
    
    local headers = {
        'force',
        'current',
        'highest',
        'total'
    }
    for _, name in pairs(headers) do
        spm_table.add {
            type = 'label',
            caption = name
        }
    end
    
    local nil_forces = {
        ['player'] = true,
        ['enemy'] = true,
        ['neutral'] = true,
        ['_ABANDONED_'] = true,
        ['_DESTROYED_'] = true,
        ['shared'] = true
    }
    
    local force_table = {}
    local current_table = {}
    
    for _, force in pairs(game.forces) do
        if not nil_forces[force.name] then
            force_table[force.name] = {
                current = tools.round(tools.get_spm_last_minute(force), 2),
                highest = tools.round(global.spm_tracker[force.name], 2),
                total = tools.get_total_science_consumed(force)
            }
        end
    end
    for force, _ in pairs(force_table) do
        current_table[force] = force_table[force].current
    end
    current_table = tools.sort_table_highest_value(current_table)
    for i, val in pairs(current_table) do
        for name, _ in pairs(force_table) do
            if force_table[name].current == val then
                game.print(i .. ': ' .. name .. ' @ ' .. val)
                spm_table.add {
                    type = 'label',
                    caption = name
                }
                if not global.force_spm_table[name] then global.force_spm_table[name] = 0 end
                if global.ocfg.spm_colors == true then
                    if force_table[name].current > global.force_spm_table[name] then
                        AddLabel(spm_table, nil, force_table[name].current, my_green_label_style)
                    else
                        AddLabel(spm_table, nil, force_table[name].current, my_red_label_style)
                    end
                else
                    spm_table.add {
                        type = 'label',
                        caption = force_table[name].current
                    }
                end
                spm_table.add {
                    type = 'label',
                    caption = force_table[name].highest
                }
                spm_table.add {
                    type = 'label',
                    caption = force_table[name].total
                }   
                global.force_spm_table[name] = force_table[name].current
                force_table[name] = nil
                break
            end
        end
    end
    -- for name, _ in pairs(force_table) do
    --     if force_table[name].current == 0 then
    --         spm_table.add {
    --             type = 'label',
    --             caption = name
    --         }
    --         spm_table.add {
    --             type = 'label',
    --             caption = force_table[name].current
    --         }
    --         spm_table.add {
    --             type = 'label',
    --             caption = force_table[name].highest
    --         }
    --         spm_table.add {
    --             type = 'label',
    --             caption = force_table[name].total
    --         }
    --     end
    -- end
    
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

