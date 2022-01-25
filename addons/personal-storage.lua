-- Personal Storage
-- Allow players to store infinite items
-- Uses locale personal-storage.cfg
-- @usage require('addons/personal-storage')
-- ======================================================= --
-- Dependencies --
-- ======================================================= --
local mod_gui = require('mod-gui') -- From `Factorio\data\core\lualib`
local GUI = require('stdlib/GUI')
local Sprites = require('util/Sprites')
local Math = require('util/Math')
require('stdlib/table')

-- Constants --
-- ======================================================= --
local personal_storage = {
    STORAGE = {},
    MENU_BTN_NAME = 'btn_menu_personal_storage',
    MASTER_FRAME_NAME = 'frame_personal_storage',
    ELEM_TABLE = 'element_table_personal_storage',
    ELEM = {
        'element_1_personal_storage',
        'element_2_personal_storage',
        'element_3_personal_storage',
        'element_4_personal_storage',
        'element_5_personal_storage',
        'element_6_personal_storage',
        'element_7_personal_storage',
        'element_8_personal_storage',
        'element_9_personal_storage',
        'element_10_personal_storage',
        'element_11_personal_storage',
        'element_12_personal_storage',
        'element_13_personal_storage',
        'element_14_personal_storage',
        'element_15_personal_storage',
        'element_16_personal_storage',
        AMOUNT = {
            'element_1_personal_storage_amount',
            'element_2_personal_storage_amount',
            'element_3_personal_storage_amount',
            'element_4_personal_storage_amount',
            'element_5_personal_storage_amount',
            'element_6_personal_storage_amount',
            'element_7_personal_storage_amount',
            'element_8_personal_storage_amount',
            'element_9_personal_storage_amount',
            'element_10_personal_storage_amount',
            'element_11_personal_storage_amount',
            'element_12_personal_storage_amount',
            'element_13_personal_storage_amount',
            'element_14_personal_storage_amount',
            'element_15_personal_storage_amount',
            'element_16_personal_storage_amount'
        }
    },
    SPRITE_NAMES = {
        menu = Sprites.logistic_chest_storage
        -- inventory_alt = Sprites.grey_rail_signal_placement_indicator,
    }
}

function personal_storage.store(player, item)
    local storage = personal_storage.STORAGE[player.name]
    if not storage[item] then storage[item] = 0 end
    local inv = player.get_main_inventory()
    local inv_item_count = inv.get_item_count(item)
    if inv_item_count == game.item_prototypes[item].stack_size then
        return storage[item]
    end
    if inv_item_count < game.item_prototypes[item].stack_size and storage[item] ==
        0 then return 0 end
    if inv_item_count < game.item_prototypes[item].stack_size and storage[item] >=
        0 then
        local amount_to_withdraw = game.item_prototypes[item].stack_size -
                                       inv_item_count
        if amount_to_withdraw >= storage[item] then
            amount_to_withdraw = storage[item]
        end
        local added = inv.insert {name = item, count = amount_to_withdraw}
        storage[item] = storage[item] - added
        return storage[item]
    end

    local amount_to_store = inv_item_count -
                                game.item_prototypes[item].stack_size
    local rem = inv.remove {name = item, count = amount_to_store}
    if rem then
        storage[item] = storage[item] + rem
        return storage[item]
    end
end

-- Event Functions --
-- ======================================================= --

-- When new player joins add the personal_storage btn to their GUI
-- Redraw the personal_storage frame to update with the new player
-- @param event on_player_joined_game
function personal_storage.on_player_joined_game(event)
    local player = game.players[event.player_index]
    if not personal_storage.STORAGE[player.name] then
        personal_storage.STORAGE[player.name] = {}
    end
    personal_storage.draw_menu_btn(player)
    personal_storage.draw_master_frame(player)
    GUI.toggle_element(
        mod_gui.get_frame_flow(player)[personal_storage.MASTER_FRAME_NAME])
end

-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- Redraw the personal_storage frame to update
-- @param event on_player_left_game
function personal_storage.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(
        mod_gui.get_button_flow(player)[personal_storage.MENU_BTN_NAME])
    GUI.destroy_element(
        mod_gui.get_frame_flow(player)[personal_storage.MASTER_FRAME_NAME])
    personal_storage.draw_master_frame(player)
end

-- Toggle personal_storage is called if gui element is personal_storage button
-- @param event on_gui_click
function personal_storage.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    -- Window toggle
    if el_name == personal_storage.MENU_BTN_NAME then
        GUI.toggle_element(
            mod_gui.get_frame_flow(player)[personal_storage.MASTER_FRAME_NAME])
    end
end

function personal_storage.on_gui_elem_changed(event)
    local player = game.players[event.player_index]
    if not personal_storage.STORAGE[player.name] then
        personal_storage.STORAGE[player.name] = {}
    end
    local storage = personal_storage.STORAGE[player.name]
    local el_name = event.element.name
    local el_val = event.element.elem_value
    if el_val then
        if storage[el_val] or #storage >= 16 then
            event.element.elem_value = nil
            return
        end
        personal_storage.store(player, el_val)
    end
end

function personal_storage.on_tick(event)
    if game.tick % 30 == 0 then
        for each, player in pairs(game.connected_players) do
            if not personal_storage.STORAGE[player.name] then
                personal_storage.STORAGE[player.name] = {}
            end
            local storage = personal_storage.STORAGE[player.name]
            for index, __ in pairs(personal_storage.elem_table_element) do
                if not personal_storage.elem_table_element[index].elem_value then
                    return
                end
                local name = personal_storage.elem_table_element[index]
                                 .elem_value
                local amount = personal_storage.store(player, name)
                if amount > 0 then
                    personal_storage.elem_table_element_amount[index].caption =
                        amount
                end
                if amount == 0 then
                    personal_storage.elem_table_element_amount[index].caption = ""
                end
            end
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game,
               personal_storage.on_player_joined_game)
Event.register(defines.events.on_player_left_game,
               personal_storage.on_player_left_game)
Event.register(defines.events.on_gui_click, personal_storage.on_gui_click)
Event.register(defines.events.on_gui_elem_changed,
               personal_storage.on_gui_elem_changed)
Event.register(defines.events.on_tick, personal_storage.on_tick)

-- Helper Functions --
-- ======================================================= --

--
-- @param player LuaPlayer
function personal_storage.draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[personal_storage.MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add({
            type = "sprite-button",
            name = personal_storage.MENU_BTN_NAME,
            sprite = personal_storage.SPRITE_NAMES.menu,
            tooltip = "Personal Storage"
        })
    end
end

--
-- @param player LuaPlayer
function personal_storage.draw_master_frame(player)
    local master_frame =
        mod_gui.get_frame_flow(player)[personal_storage.MASTER_FRAME_NAME]
    -- Draw the vertical frame on the left if its not drawn already
    if master_frame == nil then
        master_frame = mod_gui.get_frame_flow(player).add({
            type = 'frame',
            name = personal_storage.MASTER_FRAME_NAME,
            direction = 'vertical'
        })
    end
    -- Clear and repopulate player list
    GUI.clear_element(master_frame)

    personal_storage.elem_table = master_frame.add({
        type = 'table',
        name = personal_storage.ELEM_TABLE,
        column_count = 4,
        draw_horizontal_lines = true
    })

    personal_storage.elem_table_element = {}
    personal_storage.elem_table_element_amount = {}
    for i = 1, 16, 4 do
        for n = 0, 3 do
            personal_storage.elem_table_element[i + n] =
                personal_storage.elem_table.add({
                    name = personal_storage.ELEM[i + n],
                    type = 'choose-elem-button',
                    elem_type = 'item'
                })
        end
        for n = 0, 3 do
            personal_storage.elem_table_element_amount[i + n] =
                personal_storage.elem_table.add({
                    name = personal_storage.ELEM.AMOUNT[i + n],
                    type = 'label',
                    caption = nil
                })
            personal_storage.elem_table_element_amount[i + n].style.left_padding =
                2
        end
    end
end

return personal_storage
