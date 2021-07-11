-----------------------------------------------------------
-- Prcess balloon controls

BalloonFlight:ListenToClientEvent( 'sv_baloon_control', function( t )

    -----------------------------------------------------------
    -- Find appropriate balloon interface

    local hUnit = PlayerResource:GetSelectedHeroEntity( t.PlayerID )
    if not exist( hUnit ) or not exist( hUnit.Balloon ) then
        return
    end

    -----------------------------------------------------------
    -- X Processing

    if t.axis == 'x' then
        if t.dir == -1 then
            hUnit.Balloon:MoveLeft( toboolean( t.active ) )
        elseif t.dir == 1 then
            hUnit.Balloon:MoveRight( toboolean( t.active ) )
        end
    end

    -----------------------------------------------------------
    -- Z Processing

    if t.axis == 'z' then
        hUnit.Balloon:MoveUp( toboolean( t.active ) )
    end
end )