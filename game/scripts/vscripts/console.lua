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

Convars:RegisterCommand( 'bf_bind_camera', function(_, sTarget, sPoint)
	local nPlayer = GetCommandPlayer()
	if not IsDev(nPlayer) then
		return
	end

	if not sTarget then
		SetCameraTargetPosition(nPlayer, nil)
		return
	end

	local nPoint = tonumber(sPoint) or 1
	local qEntities = Entities:FindAllByName(sTarget)
	local nCount = #qEntities

	print(nCount)
	if nCount < 1 then
		SetCameraTargetPosition(nPlayer, nil)
		return
	end

	local hTarget = qEntities[ (nPoint-1) % nCount + 1 ]
	SetCameraTargetPosition(nPlayer, hTarget:GetOrigin())
end, '', 0 )

Convars:RegisterCommand( 'bf_camera_distance', function(_, nDistance)
	local nPlayer = GetCommandPlayer()
	if not IsDev(nPlayer) then
		return
	end

	local tSettings = GetPlayerJsData( nPlayer, 'CameraSettings' ) or table.deepcopy( CAMERA.DEFAULT )
	tSettings.DISTANCE = tonumber(nDistance)
	SetPlayerJsData(nPlayer, 'CameraSettings', tSettings)
end, '', 0 )