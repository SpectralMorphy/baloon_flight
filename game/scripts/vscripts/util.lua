----------------------------------------------------------------
-- Check if passed unit is player's main controlled hero.

function IsPlayerMainHero( hUnit )
    local nPlayer = hUnit:GetPlayerOwnerID()
    return nPlayer and nPlayer >= 0 and PlayerResource:GetSelectedHeroEntity( nPlayer ) == hUnit
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