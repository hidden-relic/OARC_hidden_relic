local spy = {}

function spy.is_watching(player)
    assert(player and player.valid, 'Invalid player')
    return player.controller_type == defines.controllers.spectator
end

function spy.start_watching(player)
    assert(player and player.valid, 'Invalid player')
    if global.ocore.spy.watching[player.index] or not player.character then return false end
    local character = player.character
    local opened = player.opened
    player.set_controller{ type = defines.controllers.spectator }
    player.associate_character(character)
    global.ocore.spy.watching[player.index] = character
    if opened then player.opened = opened end -- Maintain opened after controller change
    return true
end

function spy.stop_watching(player)
    assert(player and player.valid, 'Invalid player')
    local character = global.ocore.spy.watching[player.index]
    global.ocore.spy.watching[player.index] = nil
    if character and character.valid then
        local opened = player.opened
        player.teleport(character.position, character.surface)
        player.set_controller{ type = defines.controllers.character, character = character }
        if opened then player.opened = opened end -- Maintain opened after controller change
    else
        player.ticks_to_respawn = 300
    end
end


function spy.is_stalking(player)
    assert(player and player.valid, 'Invalid player')
    return global.ocore.spy.stalking[player.index] ~= nil
end


function spy.start_stalking(player, entity)
    assert(player and player.valid, 'Invalid player')
    assert(entity and entity.valid, 'Invalid entity')
    local watching = spy.start_watching(player)
    player.close_map()
    player.teleport(entity.position, entity.surface)
    global.ocore.spy.stalking[player.index] = { player, entity, entity.position, watching }
end


function spy.stop_stalking(player)
    assert(player and player.valid, 'Invalid player')
    if global.ocore.spy.stalking[player.index] and global.ocore.spy.stalking[player.index][4] then spy.stop_watching(player) end
    global.ocore.spy.stalking[player.index] = nil
end


function spy.stop_all()
    for key, data in pairs(global.ocore.spy.stalking) do
        spy.stop_stalking(data[1])
    end
end

function spy.update_player_location(player, entity, old_position)
    if player.character or not entity.valid then
        spy.stop_follow(player)
    elseif player.position.x ~= old_position.x or player.position.y ~= old_position.y then
        spy.stop_follow(player)
    else
        player.teleport(entity.position, entity.surface)
    end
end

function spy.update_all()
    for _, data in pairs(global.ocore.spy.stalking) do
        spy.update_player_location(data[1], data[2], data[3])
        data[3] = data[1].position
    end
end

----- Module Return -----
return spy