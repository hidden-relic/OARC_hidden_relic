-- __NAME__ Soft Module
-- __Description__
-- Uses locale __modulename__.cfg
-- @usage require('modules/__folder__/__modulename__')
-- @usage local ModuleName = require('modules/__folder__/__modulename__')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require("stdlib/GUI")
local research_gui = require("util/research-gui")

-- Constants --
-- ======================================================= --
local MENU_BTN_NAME = 'btn_menu_auto-research'
local MASTER_FRAME_NAME = 'frame_auto-research'

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their button_flow
-- Redraw this softmod's frame
-- @param event on_player_joined_game
function on_player_joined(event)
    local player = game.players[event.player_index]
    local config = getConfig(player.force) -- triggers initialization of force config
    startNextResearch(player.force, true)
    draw_menu_btn(player)
    -- draw_master_frame(player) -- dont draw yet, when btn clicked instead
end

-- When a player leaves clean up their GUI in case this mod gets removed next time
-- @param event on_player_left_game
function on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
end

-- Toggle gameinfo is called if gui element is gameinfo button
-- @param event on_gui_click
local function on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == MENU_BTN_NAME then
        -- Call toggle if frame has been created
        if(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME] ~= nil) then
            GUI.toggle_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
        else -- Call create if it hasnt
            draw_gameinfo_frame(player)
        end
    else
        gui.onClick(event)
    end
end

--
-- @param event on_force_created event
function on_force_created(event)
    getConfig(event.force) -- triggers initialization of force config
end

function on_research_finished(event)
    local force = event.research.force
    local config = getConfig(force)
    -- remove researched stuff from prioritized_techs and deprioritized_techs
    for i = #config.prioritized_techs, 1, -1 do
        local tech = force.technologies[config.prioritized_techs[i]]
        if not tech or tech.researched then
            table.remove(config.prioritized_techs, i)
        end
    end
    for i = #config.deprioritized_techs, 1, -1 do
        local tech = force.technologies[config.deprioritized_techs[i]]
        if not tech or tech.researched then
            table.remove(config.deprioritized_techs, i)
        end
    end
    -- announce completed research
    if config.announce_completed and config.no_announce_this_tick ~= game.tick then
        if config.last_research_finish_tick == game.tick then
            config.no_announce_this_tick = game.tick
            force.print{"auto_research.announce_multiple_completed"}
        else
            local level = ""
            if event.research.research_unit_count_formula then
                level = (event.research.researched and event.research.level) or (event.research.level - 1)
            end
            force.print{"auto_research.announce_completed", event.research.localised_name, level}
        end
    end

    startNextResearch(event.research.force)
end

--
-- @param event on_player_created event
function on_player_created(event)

end

--
-- @param event on_player_created event
function on_player_created(event)

end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_force_created, on_force_created)
Event.register(defines.events.on_research_finished, on_research_finished)
-- Event.register(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
-- Event.register(defines.events.on_gui_click, on_gui_click)
-- Event.register(defines.events.on_gui_text_changed, on_gui_text_changed)



script.on_event(defines.events.on_gui_checked_state_changed, research_gui.onClick)
script.on_event(defines.events.on_gui_click, research_gui.onClick)
script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name ~= "auto_research_search_text" then
        return
    end
    gui.updateSearchResult(game.players[event.player_index], event.element.text)
end)

-- Helper Functions --
-- ======================================================= --

--
-- @param player LuaPlayer
function draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = MENU_BTN_NAME,
                sprite = "item/lab",
                -- caption = 'Auto Infinite Research',
                tooltip = "Research Queue"
            }
        )
    end
end

















function getConfig(force, config_changed)
    if not global.auto_research_config then
        global.auto_research_config = {}

        -- Disable Research Queue popup
        if remote.interfaces.RQ and remote.interfaces.RQ["popup"] then
            remote.call("RQ", "popup", false)
        end
    end

    if not global.auto_research_config[force.name] then
        global.auto_research_config[force.name] = {
            prioritized_techs = {}, -- "prioritized" is "queued". kept for backwards compatability (because i'm lazy and don't want migration code)
            deprioritized_techs = {} -- "deprioritized" is "blacklisted". kept for backwards compatability (because i'm lazy and don't want migration code)
        }
        -- Enable Auto Research
        setAutoResearch(force, true)

        -- Disable queued only
        setQueuedOnly(force, false)

        -- Allow switching research
        setAllowSwitching(force, true)

        -- Print researched technology
        setAnnounceCompletedResearch(force, true)
    end

    -- set research strategy
    global.auto_research_config[force.name].research_strategy = global.auto_research_config[force.name].research_strategy or "balanced"

    if config_changed or not global.auto_research_config[force.name].allowed_ingredients or not global.auto_research_config[force.name].infinite_research then
        -- remember any old ingredients
        local old_ingredients = {}
        if global.auto_research_config[force.name].allowed_ingredients then
            for name, enabled in pairs(global.auto_research_config[force.name].allowed_ingredients) do
                old_ingredients[name] = enabled
            end
        end
        -- find all possible tech ingredients
        -- also scan for research that are infinite: techs that have no successor and tech.research_unit_count_formula is not nil
        global.auto_research_config[force.name].allowed_ingredients = {}
        global.auto_research_config[force.name].infinite_research = {}
        local finite_research = {}
        for _, tech in pairs(force.technologies) do
            for _, ingredient in pairs(tech.research_unit_ingredients) do
                global.auto_research_config[force.name].allowed_ingredients[ingredient.name] = (old_ingredients[ingredient.name] == nil or old_ingredients[ingredient.name])
            end
            if tech.research_unit_count_formula then
                global.auto_research_config[force.name].infinite_research[tech.name] = tech
            end
            for _, pretech in pairs(tech.prerequisites) do
                if pretech.enabled and not pretech.researched then
                    finite_research[pretech.name] = true
                end
            end
        end
        for techname, _ in pairs(finite_research) do
            global.auto_research_config[force.name].infinite_research[techname] = nil
        end
    end

    return global.auto_research_config[force.name]
end

function setAutoResearch(force, enabled)
    if not force then
        return
    end
    local config = getConfig(force)
    config.enabled = enabled

    -- start new research
    startNextResearch(force)
end

function setQueuedOnly(force, enabled)
    if not force then
        return
    end
    getConfig(force).prioritized_only = enabled

    -- start new research
    startNextResearch(force)
end

function setAllowSwitching(force, enabled)
    if not force then
        return
    end
    getConfig(force).allow_switching = enabled

    -- start new research
    startNextResearch(force)
end

function setAnnounceCompletedResearch(force, enabled)
    if not force then
        return
    end
    getConfig(force).announce_completed = enabled
end

function setDeprioritizeInfiniteTech(force, enabled)
    if not force then
        return
    end
    getConfig(force).deprioritize_infinite_tech = enabled

    -- start new research
    startNextResearch(force)
end

function getPretechs(tech)
    local pretechs = {}
    pretechs[#pretechs + 1] = tech
    local index = 1
    while (index <= #pretechs) do
        for _, pretech in pairs(pretechs[index].prerequisites) do
            if pretech.enabled and not pretech.researched then
                pretechs[#pretechs + 1]  = pretech
            end
        end
        index = index + 1
    end
    return pretechs
end

function canResearch(force, tech, config)
    if not tech or tech.researched or not tech.enabled then
        return false
    end
    for _, pretech in pairs(tech.prerequisites) do
        if not pretech.researched then
            return false
        end
    end
    for _, ingredient in pairs(tech.research_unit_ingredients) do
        if not config.allowed_ingredients[ingredient.name] then
            return false
        end
    end
    for _, deprioritized in pairs(config.deprioritized_techs) do
        if tech.name == deprioritized then
            return false
        end
    end
    return true
end

function startNextResearch(force, override_spam_detection)
    local config = getConfig(force)
    if not config.enabled or (force.current_research and not config.allow_switching) or (not override_spam_detection and config.last_research_finish_tick == game.tick) then
        return
    end
    config.last_research_finish_tick = game.tick -- if multiple research finish same tick for same force, the user probably enabled all techs

    -- function for calculating tech effort
    local calcEffort = function(tech)
        local ingredientCount = function(ingredients)
            local tech_ingredients = 0
            for _, ingredient in pairs(tech.research_unit_ingredients) do
                tech_ingredients = tech_ingredients + ingredient.amount
            end
            return tech_ingredients
        end
        local effort = 0
        if config.research_strategy == "fast" then
            effort = math.max(tech.research_unit_energy, 1) * math.max(tech.research_unit_count, 1)
        elseif config.research_strategy == "slow" then
            effort = math.max(tech.research_unit_energy, 1) * math.max(tech.research_unit_count, 1) * -1
        elseif config.research_strategy == "cheap" then
            effort = math.max(ingredientCount(tech.research_unit_ingredients), 1) * math.max(tech.research_unit_count, 1)
        elseif config.research_strategy == "expensive" then
            effort = math.max(ingredientCount(tech.research_unit_ingredients), 1) * math.max(tech.research_unit_count, 1) * -1
        elseif config.research_strategy == "balanced" then
            effort = math.max(tech.research_unit_count, 1) * math.max(tech.research_unit_energy, 1) * math.max(ingredientCount(tech.research_unit_ingredients), 1)
        else
            effort = math.random(1, 999)
        end
        if (config.deprioritize_infinite_tech and config.infinite_research[tech.name]) then
            return effort * (effort > 0 and 1000 or -1000)
        else
            return effort
        end
    end

    -- see if there are some techs we should research first
    local next_research = nil
    local least_effort = nil
    for _, techname in pairs(config.prioritized_techs) do
        local tech = force.technologies[techname]
        if tech and not next_research then
            local pretechs = getPretechs(tech)
            for _, pretech in pairs(pretechs) do
                local effort = calcEffort(pretech)
                if (not least_effort or effort < least_effort) and canResearch(force, pretech, config) then
                    next_research = pretech.name
                    least_effort = effort
                end
            end
        end
    end

    -- if no queued tech should be researched then research the "least effort" tech not researched yet
    if not config.prioritized_only and not next_research then
        for techname, tech in pairs(force.technologies) do
            if tech.enabled and not tech.researched then
                local effort = calcEffort(tech)
                if (not least_effort or effort < least_effort) and canResearch(force, tech, config) then
                    next_research = techname
                    least_effort = effort
                end
            end
        end
    end

    force.current_research = next_research
end