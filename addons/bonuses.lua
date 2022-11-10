bonuses = {}

function bonuses.on_built_entity(event)
	local created_entity = event.created_entity	
	local player = game.players[event.player_index]
	if event.item then
		local item = event.item
		if game.recipe_prototypes[item.name] then
			if game.recipe_prototypes[item.name].energy then
				player.character_crafting_speed_modifier = player.character_crafting_speed_modifier + (game.recipe_prototypes[item.name].energy*0.00017)
			    -- FlyingText("+" .. game.recipe_prototypes[item.name].energy*0.00017, player.position, {r=0, g=1, b=0}, player.surface)
			elseif game.recipe_prototypes[item.name].energy_required then
				player.character_crafting_speed_modifier = player.character_crafting_speed_modifier + (game.recipe_prototypes[item.name].energy_required*0.00017)
				-- FlyingText("+" .. game.recipe_prototypes[item.name].energy_required*0.00017, player.position, {r=0, g=1, b=0}, player.surface)
			end
		end
	end
end

function bonuses.on_entity_damaged(event)
	local entity = event.entity	
	local damage_type = event.damage_type
	local original_damage = event.original_damage_amount -- The damage amount before resistances.
	local final_damage = event.final_damage_amount -- The damage amount after resistances.
	local health = event.final_health -- The health of the entity after the damage was applied.
	local cause = event.cause
	local force = event.force

	if cause then
		if cause.type == "character" then
			local player = cause.player
			player.character_health_bonus = player.character_health_bonus + (original_damage*0.00001)
		end
	end
end

function bonuses.on_player_changed_position(event)
	local player = game.players[event.player_index]
	player.character_running_speed_modifier = player.character_running_speed_modifier + 0.00001
end

function bonuses.on_player_crafted_item(event)
	local item_stack = event.item_stack	
	local player = game.players[event.player_index]
	local recipe = event.recipe
	if recipe.energy then
		player.character_crafting_speed_modifier = player.character_crafting_speed_modifier + (recipe.energy*0.00017)
		FlyingText("+"..recipe.energy*0.0001, player.position, {r=0, g=1, b=0}, player.surface)
	elseif recipe.energy_required then
		player.character_crafting_speed_modifier = player.character_crafting_speed_modifier + (recipe.energy_required*0.00017)
		FlyingText("+"..recipe.energy_required*0.0001, player.position, {r=0, g=1, b=0}, player.surface)
	end
end

function bonuses.on_player_died(event)
	local player = game.players[event.player_index]
	local cause = event.cause
	player.character_health_bonus = player.character_health_bonus + 1
end

function bonuses.on_player_main_inventory_changed(event)
	local player = game.players[event.player_index]
	player.character_inventory_slots_bonus = player.character_inventory_slots_bonus + 0.00001
end

function bonuses.on_player_mined_entity(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	local buffer = event.buffer
-- The temporary inventory that holds the result of mining the entity.
-- The buffer inventory is special in that it's only valid during this event and has a dynamic size expanding as more items are transferred into it.
end

function bonuses.on_player_mined_item(event)
	local item_stack = event.item_stack
	local player = game.players[event.player_index]
end

function bonuses.on_player_trash_inventory_changed(event)
	local player = game.players[event.player_index]
end

function bonuses.on_player_used_capsule(event)
	local player = game.players[event.player_index]
	local item = event.item
	local position = event.position
end

return bonuses