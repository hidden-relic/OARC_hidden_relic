local solo_spawn = {
    spawn_radius = 32,
    spawn_green_zone_radius = 48,
    spawn_yellow_zone_radius = 72,
    spawn_red_zone_radius = 108,
    distance_from_center = 320
}

function solo_spawn.on_player_created(event)
    local player = game.players[event.player_index]
    if not solo_spawn.spawns[player.name] then solo_spawn.spawns[player.name] = d
end
end

function solo_spawn.create_new_spawn(player, position)
 
    local small_bugs = {"small-worm-turret", "small-biter", "small-spitter"}
    local medium_bugs = {"medium-worm-turret", "medium-biter", "medium-spitter"}
    local big_bugs = {"big-worm-turret", "big-biter", "big-spitter"}
    local behemoth_bugs = {"behemoth-worm-turret", "behemoth-biter", "behemoth-spitter"}
    local spawner_table = {}

    local results = {}
    local r = solo_spawn.spawn_radius
    local r_sq = r ^ 2
    local wall_space = r*math.pi
    local center = position

    -- green zone
    local bugs = player.surface.find_entities_filtered{position=position, radius=solo_spawn.spawn_green_zone_radius, force="enemy"}
    for each, bug in pairs(bugs) do
        bug.destroy()
    end

    -- yellow zone
    bugs = player.surface.find_entities_filtered{position=position, radius=solo_spawn.spawn_yellow_zone_radius, force="enemy"}
    for each, bug in pairs(bugs) do
        if small_bugs[bug.name] then bug.destroy() end
        if medium_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("medium", "small"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if big_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("big", "small"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if behemoth_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("behemoth", "medium"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if bug.name == "biter_spawner" or bug.name == "spitter_spawner" then
            table.insert(spawner_table, bug)
        end
        for each, spawner in pairs(spawner_table) do
            if math.random(4) ~= 4 then
                spawner.destroy()
            end
        end
    end

    -- red zone
    bugs = player.surface.find_entities_filtered{position=position, radius=solo_spawn.spawn_red_zone_radius, force="enemy"}
    for each, bug in pairs(bugs) do
        if small_bugs[bug.name] then bug.destroy() end
        if medium_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("medium", "small"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if big_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("big", "medium"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if behemoth_bugs[bug.name] then
            player.surface.create_entity{name=bug.name.gsub("behemoth", "medium"), position=bug.position, force="enemy"}
            bug.destroy()
        end
        if bug.name == "biter_spawner" or bug.name == "spitter_spawner" then
            table.insert(spawner_table, bug)
        end
        for each, spawner in pairs(spawner_table) do
            if math.random(2) == 2 then
                spawner.destroy()
            end
        end
    end
    local area = {top_left={x=center.x-r, y=center.y-r}, bottom_right={x=center.x+r, y=center.y+r}}
  
    for i = area.top_left.x, area.bottom_right.x, 1 do
      for j = area.top_left.y, area.bottom_right.y, 1 do
    
          local dist = math.floor((center.x - i) ^ 2 + (center.y - j) ^ 2)
    
          if (dist < r_sq) then
              table.insert(results, {name = "concrete", position ={i,j}})
  
              if ((dist < r_sq) and
              (dist > r_sq-wall_space)) then
                  player.surface.create_entity({name="stone-wall", force=player.force, position={i, j}})
              end
          end
      end
  end
    
  player.surface.set_tiles(results)
  player.force.chart(player.surface, area)
end