local function on_pre_player_died (e)
	if e.cause and e.cause.type == "character" then --PvP death
		print("JLOGGER: DIED: PLAYER: " .. game.get_player(e.player_index).name .. " " .. (game.get_player(e.cause.player.index).name or "no-cause"))
	elseif (e.cause) then
		print ("JLOGGER: DIED: " .. game.get_player(e.player_index).name .. " " .. (e.cause.name or "no-cause"))
	else
		print ("JLOGGER: DIED: " .. game.get_player(e.player_index).name .. " " .. "no-cause") --e.g. poison damage
	end
end

-- Determines and logs a leave reason for a player leaving, logs it to script-output/ext/awflogging.out
local function on_player_left_game(e)
	local player = game.get_player(e.player_index)
	local reason
	if e.reason == defines.disconnect_reason.quit then
		reason = "quit"
	elseif e.reason == defines.disconnect_reason.dropped then
		reason = "dropped"
	elseif e.reason == defines.disconnect_reason.reconnect then
		reason = "reconnect"
	elseif e.reason == defines.disconnect_reason.wrong_input then
		reason = "wrong_input"
	elseif e.reason == defines.disconnect_reason.desync_limit_reached then
		reason = "desync_limit_reached"
	elseif e.reason == defines.disconnect_reason.cannot_keep_up then
		reason = "cannot_keep_up"
	elseif e.reason == defines.disconnect_reason.afk then
		reason = "afk"
	elseif e.reason == defines.disconnect_reason.kicked then
		reason = "kicked"
	elseif e.reason == defines.disconnect_reason.kicked_and_deleted then
		reason = "kicked_and_deleted"
	elseif e.reason == defines.disconnect_reason.banned then
		reason = "banned"
	elseif e.reason == defines.disconnect_reason.switching_servers then
		reason = "switching_servers"
	else
		reason = "other"
	end
	game.write_file("ext/awflogging.out", game.table_to_json(
		{
			type='leave',
			playerName=player.name,
			reason=reason
		}
	) .. "\n", true, 0)
end
local function on_player_joined_game(e)
	local player = game.get_player(e.player_index)
	game.write_file("ext/awflogging.out", game.table_to_json(
		{
			type='join',
			playerName=player.name
		}
	) .. "\n", true, 0)
end

local function get_infinite_research_name(name)
	-- gets the name of infinite research (without numbers)
  	return string.match(name, "^(.-)%-%d+$") or name
end

local function on_research_finished(event)
	local research_name = get_infinite_research_name(event.research.name)
	print ("JLOGGER: RESEARCH FINISHED: " .. research_name .. " " .. (event.research.level or "no-level"))
end

local function on_built_entity(event)
	-- get the corresponding data
	local player = game.get_player(event.player_index)
	local data = global.playerstats[player.name]
	if data == nil then
		-- format of array: {entities placed, ticks played}
		global.playerstats[player.name] = {1, 0}
	else
		data[1] = data[1] + 1 --indexes start with 1 in lua
		global.playerstats[player.name] = data
	end
end

local function on_init ()
	global.playerstats = {}
end

local function logStats()
	-- log built entities and playtime of players
	for _, p in pairs(game.players)
	do
		local pdat = global.playerstats[p.name]
		if (pdat == nil) then
				-- format of array: {entities placed, ticks played}
				pdat = {0, p.online_time}
				print ("JLOGGER: STATS: " .. p.name .. " " .. 0 .. " " .. p.online_time)
				global.playerstats[p.name] = pdat
		else
			if (pdat[1] ~= 0 or (p.online_time - pdat[2]) ~= 0) then
				print ("JLOGGER: STATS: " .. p.name .. " " .. pdat[1] .. " " .. (p.online_time - pdat[2]))
			end
			-- update the data
			global.playerstats[p.name] = {0, p.online_time}
		end
	end
end

local function on_rocket_launched(e)
	print ("JLOGGER: ROCKET: " .. "ROCKET LAUNCHED")
end
local function checkEvolution(e)
	print("JLOGGER: EVOLUTION: " .. string.format("%.4f", game.forces["enemy"].evolution_factor))
end
local function on_trigger_fired_artillery(e)
	print ("JLOGGER: ARTILLERY: " .. e.entity.name .. (e.source.name or "no source"))
end

local logging = {}
logging.events = {
	[defines.events.on_rocket_launched] = on_rocket_launched,
	[defines.events.on_research_finished] = on_research_finished,
	[defines.events.on_player_joined_game] = on_player_joined_game,
	[defines.events.on_player_left_game] = on_player_left_game,
	[defines.events.on_pre_player_died] = on_pre_player_died,
	[defines.events.on_built_entity] = on_built_entity,
	[defines.events.on_trigger_fired_artillery] = on_trigger_fired_artillery,
}

logging.on_nth_tick = {
	[60*60*15] = function() -- every 15 minutes
		logStats()
	end,
	[60*60] = checkEvolution,
}

logging.on_init = on_init

return logging