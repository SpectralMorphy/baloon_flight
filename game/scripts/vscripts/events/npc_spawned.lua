----------------------------------------------------------------
-- event: npc_spawned

return function( t )
    local hUnit = EntIndexToHScript( t.entindex )
    if not hUnit then
        return
    end

    ------------------------------------------------
    -- Apply motion controller to heroes

    Timer( 1/30, function()
        if IsPlayerMainHero( hUnit ) then
            hUnit:SetAbsOrigin( hUnit:GetOrigin() + Vector( 0, 0, 100 ) )
            BalloonController( hUnit )
        end
    end )
end