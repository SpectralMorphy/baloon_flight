-----------------------------------------------------------------
-- Apply special camera settings for player

function ApplyCameraSettings( nPlayer, tSettings )
	if tSettings then
		SetPlayerJsData( nPlayer, 'CameraSettings', table.overlay( CAMERA.DEFAULT, tSettings ) )
	else
		UnsetPlayerJsData( nPlayer, 'CameraSettings' )
	end
end

-----------------------------------------------------------------
-- Set forced camera position

function SetCameraTargetPosition( nPlayer, vTarget, nTime )
	local tSettings = GetPlayerJsData( nPlayer, 'CameraSettings' ) or table.deepcopy( CAMERA.DEFAULT )
	if vTarget then
		tSettings.vTarget = { vTarget.x, vTarget.y, vTarget.z }
	else
		tSettings.vTarget = nil
	end
	tSettings.nAnimTime = nTime
	SetPlayerJsData( nPlayer, 'CameraSettings', tSettings )
end

-----------------------------------------------------------------
-- Initialization

SetJsData( 'CameraSettings', CAMERA.DEFAULT )

-----------------------------------------------------------------
-- Register speed tracker

Timer( function()
	local tSpeeds = {}

	for nPlayer = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer( nPlayer ) then
			local hHero = PlayerResource:GetSelectedHeroEntity( nPlayer )
			if exist( hHero ) and exist( hHero.Balloon ) then
				tSpeeds[ hHero:entindex() ] = hHero.Balloon:GetSpeed()
			end
		end
	end

	SetJsData( 'CameraSpeed', tSpeeds )

	return 0.1
end, 'CameraSpeedTracker' )