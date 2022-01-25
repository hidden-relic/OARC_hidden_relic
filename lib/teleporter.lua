-- Teleporter addon for the store

local M = {}; -- M for Module


function M.CreateTeleporter(surface, teleporterPosition, dest)
    local car = surface.create_entity{name="car", position=teleporterPosition, force=MAIN_FORCE }
    car.destructible=false;
    car.minable=false;
    for _,item in pairs(scenario.config.teleporter.startItems) do
        car.insert(item);
    end
    table.insert(global.portal, { dest=dest, unit_number = car.unit_number });
end

function M.TeleportPlayer( player )
    local car = player.vehicle;
    if car ~= nil then
        local dest = nil
        for _,portal in pairs(global.portal) do
            if car.unit_number == portal.unit_number then
                if portal.dest == nil then
                    -- teleport from silo back to player spawn.
                    player.print("teleport back to player spawn");
                    dest = global.playerSpawns[player.name];
                    break
                -- we could allow only the player to use the teleporter.
                -- elseif SameCoord(portal.dest, global.playerSpawns[player.name]) then
                else    
                    -- teleport player to silo
                    player.print("you have been teleported");
                    dest = portal.dest;
                    break
                end
            end
        end

        -- TODO. transport anyone in the vicinity as well 
        if dest ~= nil then
            dest = FindNonCollidingPosition(dest)
            if dest == nil then
                player.print("Error.  No clear place to teleport to.");
                return
            end
            player.driving=false;
            player.teleport(dest);
        end
    end
end

-- Utilizes find_non_colliding_position for a small "character" sized object.  Use for teleporting players.
function FindNonCollidingPosition(position)
    return game.surfaces[GAME_SURFACE_NAME].find_non_colliding_position("character",  position, 50, 0.1);
end

return M;