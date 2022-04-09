--[[
Copyright 2017-2018 "Kovus" <kovus@soulless.wtf>

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    death_marker.lua - Create a death marker at player death location.
    @usage require('modules/common/deathmarker')

--]] local deathmarkers = {}

function deathmarkers.init(event)
    local player = game.players[event.player_index]
    if not global.death_markers then
        global.death_markers = {counters = {}, markers = {}, lines = {}}
    end
    global.death_markers.lines[player.name] = {}
end

local function removeCorpseTag(entity)
    local player = game.players[entity.character_corpse_player_index]
    if not player then return end

    local tick = entity.character_corpse_tick_of_death
    local position = entity.position

    local markers = global.death_markers.markers
    for idx = 1, #markers do
        local entry = markers[idx]
        if entry and entry.player_index == player.index and entry.death_tick ==
            tick then
            if entry.tag and entry.tag.valid then
                for i, line in pairs(global.death_markers.lines[player.name]) do
                    if line.corpse and line.corpse == entity then
                        rendering.destroy(line.line)
                        table.remove(global.death_markers.lines[player.name], i)
                    end
                end
                if player.connected then
                    player.print({'death_marker.removed', entry.tag.text})
                end
                entry.tag.destroy()
            end
            table.remove(markers, idx)
            return
        end
    end
end

function deathmarkers.playerRespawned(event)
    local plidx = event.player_index
    local player = game.players[plidx]
    local position = player.position
    local surface = player.surface
    local lines = global.death_markers.lines[player.name]
    for i, line in pairs(lines) do
        local corpse = surface.find_entity("character-corpse",
                                           line.corpse_position)
        if corpse and corpse.type == "character-corpse" then
            local newline = rendering.draw_line {
                surface = player.surface,
                from = player.character,
                to = corpse,
                players = {player.index},
                color = {r = 1, g = 0, b = 0},
                width = 3.2,
                gap_length = 5,
                dash_length = 8,
                time_to_live = 60 * 60 * 5
            }
            line = newline
        else
            table.remove(lines, i)
        end

    end
end

function deathmarkers.playerDied(event)
    local plidx = event.player_index
    local player = game.players[plidx]
    local position = player.position
    local surface = player.surface
    local force = player.force

    local counters = global.death_markers.counters
    if counters[plidx] then
        counters[plidx] = counters[plidx] + 1
    else
        counters[plidx] = 1
    end

    -- cannot localize the marker text, as it's a map entity common to all
    -- players, and not a gui element or player-based output message.
    local text = table.concat({'RIP ', player.name, ' (', counters[plidx], ')'})

    local tag = force.add_chart_tag(surface, {
        position = position,
        text = text,
        icon = {type = 'item', name = 'power-armor-mk2'}
    })
    table.insert(global.death_markers.markers,
                 {tag = tag, player_index = plidx, death_tick = event.tick})
    table.insert(global.death_markers.lines[player.name],
                 {corpse_position = position, line = {}})

    for index, cplayer in pairs(player.force.connected_players) do
        if cplayer.surface == surface then
            cplayer.print({
                'death_marker.message', player.name, text, position.x,
                position.y
            })
        end
    end
end

function deathmarkers.corpseExpired(event) removeCorpseTag(event.corpse) end

function deathmarkers.onMined(event)
    if event.entity.valid and event.entity.name == 'character-corpse' then
        removeCorpseTag(event.entity)
    end
end

return deathmarkers
