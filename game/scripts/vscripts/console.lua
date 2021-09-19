Convars:RegisterCommand( 'bf_set_map', function(_, nMap)
	local nPlayer = GetCommandPlayer()
	if not IsDev(nPlayer) then
		return
	end

	nMap = tonumber(nMap)
	if not nMap then
		return
	end

	BalloonFlight:SetMap(nMap)
	BalloonFlight:RespawnAll()
end, '', 0 )

Convars:RegisterCommand( 'bf_next_round', function()
	local nPlayer = GetCommandPlayer()
	if not IsDev(nPlayer) then
		return
	end

	BalloonFlight:NextRound()
end, '', 0 )