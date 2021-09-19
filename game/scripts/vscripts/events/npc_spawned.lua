----------------------------------------------------------------
-- event: npc_spawned

-- Find spawn points
-- local qSpawnPoints = table.reduce(
--     Entities:FindAllByClassname('info_target'),
--     function( self, hPoint )
--         if hPoint:GetName() == 'spawnpoint' then
--             table.insert( self, hPoint:GetOrigin() )
--         end
--         return self
--     end,
--     {}
-- )

-- local qFreeSpawnPoints = {}

----------------------------------------------------------------
-- Event processing

return function( t )
    local hUnit = EntIndexToHScript( t.entindex )
    if not hUnit then
        return
    end

    ------------------------------------------------
    -- Apply motion controller to heroes

    -- Timer( 1/30, function()
    --     if IsPlayerMainHero( hUnit ) then
    --         local nIndex, vPos

    --         if #qFreeSpawnPoints < 1 then
    --             qFreeSpawnPoints = table.copy( qSpawnPoints )
    --         end

    --         if #qFreeSpawnPoints > 0 then
    --             nIndex, vPos = table.random( qFreeSpawnPoints )
    --             table.remove( qFreeSpawnPoints, nIndex )
    --         else
    --             vPos = hUnit:GetOrigin() + Vector( 0, 0, 128 )
    --         end

    --         hUnit:SetOrigin( vPos )
    --         BalloonController( hUnit )
    --     end
    -- end )
end