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
            BalloonController( hUnit )
        end
    end )
end