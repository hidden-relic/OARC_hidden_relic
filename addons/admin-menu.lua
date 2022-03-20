-- Admin Open Player Inventory Soft Module
-- Displays a table of all players with and button to open their inventory
-- Uses locale __modulename__.cfg
-- @usage require('modules/dddgamer/admin/admin-open-player-inventory')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --
-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require("stdlib/GUI")
local Colors = require("util/Colors")
local Sprites = require("util/Sprites")
local Position = require("stdlib/area/position")
local find_patch = require('addons/find_patch')
local tools = require("addons/tools")

-- Constants --
-- ======================================================= --
local MENU_BTN_NAME = 'btn_menu_admin_menu'
local MASTER_FRAME_NAME = 'frame_admin_menu'
local LABEL_FIND_ORE = 'label_find_ore'
local LABEL_MAKE = 'label_make'
local BTN_FIND_IRON = 'btn_find_iron'
local BTN_FIND_COPPER = 'btn_find_copper'
local BTN_FIND_STONE = 'btn_find_stone'
local BTN_FIND_COAL = 'btn_find_coal'
local BTN_FIND_URANIUM = 'btn_find_uranium'
local BTN_FIND_OIL = 'btn_find_oil'
local BTN_MAKE_BELT_IN = 'btn_make_belt_in'
local BTN_MAKE_BELT_OUT = 'btn_make_belt_out'
local BTN_MAKE_LINK = 'btn_make_link'
local OWNER = 'hidden_relic'
local OWNER_ONLY = true
local SPRITE_NAMES = {
    menu = Sprites.laser_turret,
    find_iron = Sprites.iron_ore,
    find_copper = Sprites.copper_ore,
    find_stone = Sprites.stone,
    find_coal = Sprites.coal,
    find_uranium = Sprites.uranium_ore,
    find_oil = Sprites.crude_oil,
    make_belt = Sprites.linked_belt,
    make_link = Sprites.fluid_indication_arrow_both_ways
}
local range = 1000

local admin_menu = {}
-- Local Functions --
-- ======================================================= --

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their button_flow
-- Redraw this softmod's frame
-- Only happens for admins/owner depending on OWNER_ONLY flag
-- @param event on_player_joined_game
function admin_menu.on_player_joined(event)
    local player = game.players[event.player_index]
    if (OWNER_ONLY) then
        if (player.name == OWNER) then
            draw_menu_btn(player)
            draw_master_frame(player)
            GUI.toggle_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
        end
    elseif (player.admin == true) then
        draw_menu_btn(player)
        draw_master_frame(player)
    end
end

-- When a player leaves clean up their GUI in case this mod gets removed next time
-- @param event on_player_left_game
function admin_menu.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
end

-- Toggle playerlist is called if gui element is playerlist button
-- @param event on_gui_click
function admin_menu.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    -- Window toggle
    if el_name == MENU_BTN_NAME then
        GUI.toggle_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
    end

    if (el_name == BTN_FIND_IRON) then
        find_patch.findPatch("iron-ore", range, player)
    end
    if (el_name == BTN_FIND_COPPER) then
        find_patch.findPatch("copper-ore", range, player)
    end
    if (el_name == BTN_FIND_STONE) then
        find_patch.findPatch("stone", range, player)
    end
    if (el_name == BTN_FIND_COAL) then
        find_patch.findPatch("coal", range, player)
    end
    if (el_name == BTN_FIND_URANIUM) then
        find_patch.findPatch("uranium-ore", range, player)
    end
    if (el_name == BTN_FIND_OIL) then
        find_patch.findPatch("crude-oil", range, player)
    end
    if (el_name == BTN_MAKE_BELT_IN) then tools.make(player, "belt", "in") end
    if (el_name == BTN_MAKE_BELT_OUT) then tools.make(player, "belt", "out") end
    if (el_name == BTN_MAKE_LINK) then tools.make(player, "link") end

end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, admin_menu.on_player_joined)
Event.register(defines.events.on_player_left_game,
               admin_menu.on_player_left_game)
Event.register(defines.events.on_gui_click, admin_menu.on_gui_click)

-- Helper Functions --
-- ======================================================= --

--
-- @param player LuaPlayer
function admin_menu.draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add({
            type = "sprite-button",
            name = MENU_BTN_NAME,
            sprite = SPRITE_NAMES.menu,
            tooltip = "Admin Tools"
        })
    end
end

--
-- @param player LuaPlayer
function admin_menu.draw_master_frame(player)
    local master_frame = mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME]
    -- Draw the vertical frame on the left if its not drawn already
    if master_frame == nil then
        master_frame = mod_gui.get_frame_flow(player).add({
            type = 'frame',
            name = MASTER_FRAME_NAME,
            direction = 'vertical'
        })
    end
    -- Clear and repopulate player list
    GUI.clear_element(master_frame)

    -- Flow
    local flow_header = master_frame.add({
        type = 'flow',
        direction = 'horizontal'
    })
    flow_header.style.horizontal_spacing = 20

    -- Draw Header text
    flow_header.add({
        type = 'label',
        name = LABEL_FIND_ORE,
        caption = {'admin_panel.find_ore_header_caption'}
        -- tooltip = {'player_list.checkbox_tooltip'},
        -- state = Player_List.getConfig(player).show_offline_players or false
    })

    -- Add scrollable section to content frame
    local find_ore_button_flow = master_frame.add({
        type = 'flow',
        direction = 'vertical'
    })

    local find_ore_button_group_1 = find_ore_button_flow.add({
        type = 'flow',
        direction = 'horizontal'
    })

    local find_iron_ore_btn = find_ore_button_group_1.add({
        type = "sprite-button",
        name = BTN_FIND_IRON,
        sprite = SPRITE_NAMES.find_iron,
        tooltip = {'admin_panel.find_iron_tooltip'}
    })
    local find_copper_ore_btn = find_ore_button_group_1.add({
        type = "sprite-button",
        name = BTN_FIND_COPPER,
        sprite = SPRITE_NAMES.find_copper,
        tooltip = {'admin_panel.find_copper_tooltip'}
    })
    local find_stone_btn = find_ore_button_group_1.add({
        type = "sprite-button",
        name = BTN_FIND_STONE,
        sprite = SPRITE_NAMES.find_stone,
        tooltip = {'admin_panel.find_stone_tooltip'}
    })

    local find_ore_button_group_2 = find_ore_button_flow.add({
        type = 'flow',
        direction = 'horizontal'
    })

    local find_coal_btn = find_ore_button_group_2.add({
        type = "sprite-button",
        name = BTN_FIND_COAL,
        sprite = SPRITE_NAMES.find_coal,
        tooltip = {'admin_panel.find_coal_tooltip'}
    })
    local find_uranium_ore_btn = find_ore_button_group_2.add({
        type = "sprite-button",
        name = BTN_FIND_URANIUM,
        sprite = SPRITE_NAMES.find_uranium,
        tooltip = {'admin_panel.find_uranium_tooltip'}
    })
    local find_oil_btn = find_ore_button_group_2.add({
        type = "sprite-button",
        name = BTN_FIND_OIL,
        sprite = SPRITE_NAMES.find_oil,
        tooltip = {'admin_panel.find_oil_tooltip'}
    })

    local flow_header2 = master_frame.add({
        type = 'flow',
        direction = 'horizontal'
    })
    flow_header2.style.horizontal_spacing = 20

    -- Draw Header text
    flow_header2.add({
        type = 'label',
        name = LABEL_MAKE,
        caption = {'admin_panel.make_header_caption'}
        -- tooltip = {'player_list.checkbox_tooltip'},
        -- state = Player_List.getConfig(player).show_offline_players or false
    })
    -- Add scrollable section to content frame
    local make_button_flow = master_frame.add({
        type = 'flow',
        direction = 'vertical'
    })

    local make_button_group_1 = make_button_flow.add({
        type = 'flow',
        direction = 'horizontal'
    })

    local make_belt_in_btn = make_button_group_1.add({
        type = "sprite-button",
        name = BTN_MAKE_BELT_IN,
        sprite = SPRITE_NAMES.make_belt,
        tooltip = {'admin_panel.make_belt_in_tooltip'}
    })
    local make_belt_out_btn = make_button_group_1.add({
        type = "sprite-button",
        name = BTN_MAKE_BELT_OUT,
        sprite = SPRITE_NAMES.make_belt,
        tooltip = {'admin_panel.make_belt_out_tooltip'}
    })
    local make_link_btn = make_button_group_1.add({
        type = "sprite-button",
        name = BTN_MAKE_LINK,
        sprite = SPRITE_NAMES.make_link,
        tooltip = {'admin_panel.make_link_tooltip'}
    })
end

--
function function_name() end

--
function function_name() end

--
function function_name() end
