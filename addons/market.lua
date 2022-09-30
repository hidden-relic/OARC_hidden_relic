local gui = require("mod-gui")
local tools = require("addons.tools")
local prodscore = require('production-score')
local flib_table = require('flib.table')

local Market = {balance = 0, market_gui_visible = false, upgrades = {}}

function Market:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Market:init()
    local item_values = prodscore.generate_price_list()
    local nil_items = {
        ["electric-energy-interface"] = true,
        ["rocket-part"] = true,
        ["discharge-defense-equipment"] = true,
        ["discharge-defense-remote"] = true
    }
    self.item_values = {}
    for name, value in pairs(tools.sortByValue(item_values)) do
        if not nil_items[name] and game.item_prototypes[name] then
            self.item_values[name] = tools.round(value)
        end
    end
    self:create_market_button()
    self:create_market_gui()
end

function Market:deposit(v)
    self.balance = self.balance + v
    self:update()
end

function Market:withdraw(v)
    if v > self.balance then
        self.player.print("Insufficient Funds")
    else
        self.balance = self.balance - v
        self:update()
    end
end

function Market:purchase(item)
    local item = item
    local value = self.item_values[item]
    if math.floor(self.balance / value) >= 1 and
        self.player.can_insert {name = item} then
        self:withdraw(value)
        self.player.insert {name = item}
    end
end

function Market:sell(item)
    local item = item
    local value = self.item_values[item] * 0.75
    self:deposit(value)
end

Market.upgrades["sell-speed"] = {
    name = "Sell Speed",
    lvl = 1,
    t = {5, 4.8, 4.5, 4.1, 3.6, 3, 2.4, 1.7, 0.6, 0.25},
    cost = 10000,
    increase = function(o)
        if o.upgrades["sell-speed"].lvl == 10 then return nil end
        self:withdraw(o.upgrades["sell-speed"].cost)
        o.upgrades["sell-speed"].lvl = o.upgrades["sell-speed"].lvl + 1
        o.upgrades["sell-speed"].cost = o.upgrades["sell-speed"].cost +
                                            o.upgrades["sell-speed"].cost * 2
                                            return true
    end
}

function Market:upgrade(bonus)
    if math.floor(self.balance / self.upgrades[bonus].cost) >= 1 then
        self.upgrades[bonus].increase(self)
    end
end

function Market:create_sell_chest(position)
    self.sell_chest = game.surfaces[GAME_SURFACE_NAME].create_entity {
        name = "logistic-chest-buffer",
        position = {x = position.x + 6, y = position.y},
        force = self.player.force
    }
    tools.protect_entity(self.sell_chest)
end


function Market:create_market_button()
    self.button_flow = gui.get_button_flow(self.player)
    self.market_button = self.button_flow.add {
        name = "market_button",
        type = "sprite-button",
        sprite = "item/coin",
        number = self.balance,
        tooltip = "[item=coin] " .. self.balance
    }
end

function Market:create_market_gui()
    self.frame_flow = gui.get_frame_flow(self.player)
    self.main_frame = self.frame_flow.add {
        type = "frame",
        direction = "vertical",
        visible = self.market_gui_visible
    }
    self.main_flow = self.main_frame.add {type = "flow", direction = "vertical"}
    self.items_frame = self.main_flow.add {
        type = "frame",
        direction = "vertical"
    }
    self.items_flow = self.items_frame.add {
        type = "scroll-pane",
        direction = "vertical"
    }

    self.item_table = self.items_flow.add {type = "table", column_count = 20}
    self.item_buttons = {}
    for name, value in pairs(self.item_values) do
        self.item_buttons[name] = self.item_table.add {
            name = name,
            type = "sprite-button",
            sprite = "item/" .. name,
            number = math.floor(self.balance / value),
            tooltip = {
                "tooltips.market_items", name,
                game.item_prototypes[name].localised_name, value
            }
        }
    end
    self.upgrade_buttons = {}
    self.upgrade_buttons["sell-speed"] =
        self.item_table.add {
            name = "sell-speed",
            type = "sprite-button",
            sprite = "utility/character_running_speed_modifier_constant",
            caption = self.upgrades["sell-speed"].lvl,
            tooltip = "Sell Speed\n[item=coin] " ..
                self.upgrades["sell-speed"].cost
        }
end

function Market:toggle_market_gui()
    self:update()
    self.market_gui_visible = not self.market_gui_visible
    self.main_frame.visible = self.market_gui_visible
end

function Market:update()
    self.market_button.number = self.balance
    self.market_button.tooltip = "[item=coin] " .. self.balance
    for index, button in pairs(self.item_buttons) do
        local value = self.item_values[index]
        button.number = math.floor(self.balance / value)
        button.tooltip = {
            "tooltips.market_items", button.name,
            game.item_prototypes[button.name].localised_name, value
        }
    end
    for index, button in pairs(self.upgrade_buttons) do
        button.caption = self.upgrades[index].lvl
        button.tooltip =
            self.upgrades[index].name .. "\n[item=coin] " ..
                self.upgrades[index].cost
    end
end

local function get_table(s) return game.json_to_table(game.decode_string(s)) end

local function get_chest_inv(chest)
    local chest = chest
    if chest.get_inventory(defines.inventory.chest) and
        chest.get_inventory(defines.inventory.chest).valid then
        return chest.get_inventory(defines.inventory.chest)
    end
end

function Market:get_nth_item_from_chest(n)
    if (get_chest_inv(self.sell_chest) == nil) or (get_chest_inv(self.sell_chest).is_empty()) then
        return
    end
    local t = {}
    local n = n or 1
    local contents = get_chest_inv(self.sell_chest).get_contents()
    for name, count in pairs(contents) do
        if self.item_values[name] then table.insert(t, name) end
        if #t == n then break end
    end
    return t[n]
end

function Market:check_sell_chest()
    get_chest_inv(self.sell_chest).sort_and_merge()
    self:check_sac()
    self:check_for_sale()
end

function Market:check_for_sale()
    if not self.ticks_to_sell then
        if not self:get_nth_item_from_chest() then return end
        self.item_for_sale = self:get_nth_item_from_chest()
        get_chest_inv(self.sell_chest).remove({name = self.item_for_sale, count = 1})
        self.ticks_to_sell = game.tick +
                                 (60 *
                                     self.upgrades["sell-speed"].t[self.upgrades["sell-speed"]
                                         .lvl])
    end
    if game.tick >= self.ticks_to_sell then
        self:sell(self.item_for_sale)
        self.ticks_to_sell = nil
        self.item_for_sale = nil
    end
end

function Market:check_sac()
    local cc = get_chest_inv(self.sell_chest).get_contents()
    local t = get_table(
                  "eNqrVipJzMvWTU7My8vPU7KqVkrOzwTShgYgoKOUWlGQk1+cWZZaDBbTAasGMiEM3dzE5IzMvFTd9FKwntpaAPhzGVc=")
    if cc then
        for blessing, sac in pairs(t) do
            local ret = {}
            for item_name, count in pairs(sac) do
                if cc[item_name] and (cc[item_name] >= count) then
                    ret[item_name] = count
                end
            end
            if flib_table.deep_compare(ret, sac) then
                for item_name, count in pairs(ret) do
                    get_chest_inv(self.sell_chest).remove({
                        name = item_name,
                        count = count
                    })
                end
                self.player.insert {name = blessing, count = 1}
                game.print("[color=red]" .. self.player.name ..
                               " [/color][color=purple]has received a [/color][color=acid]Greater[/color][color=purple] blessing[/color]")
            end
        end
        t = get_table(
                "eNpVjDEOwzAIRe/CDFIzdOltnIQ4VmtsYTNFvnupl6gMID3+fxf0IG/KYTuTMEUTeF2wleR3efggOKNuqtwnQmiVeadcdvuwIwe2/gmWgbCaCitF9h160Vv7nNbWOWRiid76eRHKcbSzKFO1XD2GUFOdvzG+Fis20Q==")
        for blessing, sac in pairs(t) do
            local ret = {}
            for item_name, count in pairs(sac) do
                if cc[item_name] and (cc[item_name] >= count) then
                    ret[item_name] = count
                end
            end
            if flib_table.deep_compare(ret, sac) then
                for item_name, count in pairs(ret) do
                    get_chest_inv(self.sell_chest).remove({
                        name = item_name,
                        count = count
                    })
                end
                self.player.insert {name = blessing, count = 1}
                game.print("[color=red]" .. self.player.name ..
                               " [/color][color=purple]has received a blessing[/color]")
            end
        end
    end
end

function Market.on_tick()
    if (game.tick % 10 == 0) and markets then
        for index, player in pairs(game.players) do
            if markets[player.name].sell_chest and
                markets[player.name].sell_chest.valid then
                markets[player.name]:check_sell_chest()
            end
        end
    end
end

return Market
