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
	require 'physics/init'
	require 'settings/const'

	local GameModeEntity = GameRules:GetGameModeEntity()

	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameModeEntity:SetFogOfWarDisabled( true )

	require 'events/init'
end

------------------------------------------------------------
-- postinit

if bReload then
	BalloonFlight:Reload()
end