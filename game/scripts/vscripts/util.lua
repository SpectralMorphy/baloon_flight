----------------------------------------------------------------
-- Check if passed unit is player's main controlled hero.

function IsPlayerMainHero( hUnit )
    local nPlayer = hUnit:GetPlayerOwnerID()
    return nPlayer and nPlayer >= 0 and PlayerResource:GetSelectedHeroEntity( nPlayer ) == hUnit
end

----------------------------------------------------------------
-- Players iteration

function IsActivePlayer(nPlayer)
	return PlayerResource:IsValidPlayer(nPlayer) and not PlayerResource:IsBroadcaster(nPlayer)
end

function Players()
	return function(_, nPlayer)
		local nMaxPlayers = DOTA_MAX_PLAYERS
		if not nPlayer then
			nPlayer = -1
		end

		while nPlayer < nMaxPlayers do
			nPlayer = nPlayer + 1
			if IsActivePlayer(nPlayer) then
				return nPlayer
			end
		end
	end
end

----------------------------------------------------------------
-- Get all heroes playing on the map

function FindAllHeroes()
    local qHeroes = {}
    for nPlayer = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer( nPlayer ) then
            local hHero = PlayerResource:GetSelectedHeroEntity( nPlayer )
            if exist( hHero ) then
                table.insert( qHeroes, hHero )
            end
        end
    end
    return qHeroes
end

----------------------------------------------------------------
-- Apply interpolation

function Interp( f, v, min, max )
	if v > max then
		return -1
	end
	local delta = max - min
	if delta > 0 then
		return f( math.max( 0, math.min( 1, ( v - min ) / delta ) ) )
	end
	return 1
end

----------------------------------------------------------------
-- Get command client ID

function GetCommandPlayer()
	return Convars:GetCommandClient():GetPlayerID()
end

----------------------------------------------------------------
-- Check if player is developer

local tDevs = {}
for _, nSteamID in ipairs(require('settings/dev')) do
	tDevs[nSteamID] = true
end

function IsDev(nPlayer)
	return tDevs[PlayerResource:GetSteamAccountID(nPlayer)] or false
end