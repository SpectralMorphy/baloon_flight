----------------------------------------------------------------
-- preinit

local bReload = false

if BalloonFlight then
	bReload = true
else
	BalloonFlight = {}
end

------------------------------------------------------------
-- Called within addon_game_mode Precache.

function BalloonFlight:Precache( c )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

------------------------------------------------------------
-- Called within addon_game_mode Activate.

function BalloonFlight:Activate()

	self:Load()
end

------------------------------------------------------------
-- Called then addon was reloaded (script_reload)

function BalloonFlight:Reload()

	self:Load()
end

------------------------------------------------------------
-- Setup gamemode (Called when Activate or Reload)

function BalloonFlight:Load()
	require 'lib/timer'
	require 'util'
	require 'settings/all'
	require 'events/init'
	require 'lib/jsdata'
	require 'physics/init'
	require 'camera'

	local GameModeEntity = GameRules:GetGameModeEntity()

	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameModeEntity:SetDaynightCycleDisabled( true )
	GameModeEntity:SetFogOfWarDisabled( true )
	GameModeEntity:SetCameraZRange( 0, MAP.RENDER_DISTANCE )

	CustomGameEventManager:Send_ServerToAllClients( 'cl_activate', {} )
end

------------------------------------------------------------
-- postinit

if bReload then
	BalloonFlight:Reload()
end