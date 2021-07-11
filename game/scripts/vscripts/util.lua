----------------------------------------------------------------
-- Check if passed unit is player's main controlled hero.

function IsPlayerMainHero( hUnit )
    local nPlayer = hUnit:GetPlayerOwnerID()
    return nPlayer and nPlayer >= 0 and PlayerResource:GetSelectedHeroEntity( nPlayer ) == hUnit
end