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
	-- local hHero = PlayerResource:GetSelectedHeroEntity( 0 )
	-- hHero:

	self:Load()
end

------------------------------------------------------------
-- Setup gamemode (Called when Activate or Reload)

function BalloonFlight:Load()
	require 'log'
	require 'lib/timer'
	require 'util'
	require 'events/init'
	require 'lib/jsdata'
	require 'physics/init'
	require 'obstacles/init'
	require 'settings/all'
	require 'camera'

	local GameModeEntity = GameRules:GetGameModeEntity()

	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameModeEntity:SetDaynightCycleDisabled( true )
	GameModeEntity:SetFogOfWarDisabled( true )
	GameModeEntity:SetCameraZRange( 0, MAP.RENDER_DISTANCE )
	GameModeEntity:SetCustomGameForceHero('npc_dota_hero_wisp')

	Obstacles:RegisterTriggers()

	Log:Add('sv activate')
	CustomGameEventManager:Send_ServerToAllClients( 'cl_activate', {} )
end

------------------------------------------------------------
-- postinit

if bReload then
	BalloonFlight:Reload()
end