----------------------------------------------------------------
-- List of events to register

local tEvents = {
    npc_spawned = true,
}

----------------------------------------------------------------
-- Allows to register unique event listeners

function BalloonFlight:ListenToGameEvent( sEvent, fCallback )
    if not self.tEventListeners then
        self.tEventListeners = {}
    end

    local nOldListener = self.tEventListeners[ sEvent ]
    if nOldListener then
        StopListeningToGameEvent( nOldListener )
    end

    if fCallback then
        local nListener = ListenToGameEvent( sEvent, fCallback, nil )
        self.tEventListeners[ sEvent ] = nListener
    end
end

function BalloonFlight:ListenToClientEvent( sEvent, fCallback )
    if not self.tClientEvents then
        self.tClientEvents = {}
    end

    local nOldListener = self.tClientEvents[ sEvent ]
    if nOldListener then
        CustomGameEventManager:UnregisterListener( nOldListener )
    end

    if fCallback then
        local nListener = CustomGameEventManager:RegisterListener( sEvent, function( _, t )
            fCallback( t )
        end )

        self.tClientEvents[ sEvent ] = nListener
    end
end

----------------------------------------------------------------
-- Registering events

for sEvent, bActive in pairs( tEvents ) do
    if bActive then
        BalloonFlight:ListenToGameEvent( sEvent, require( 'events/' .. sEvent ) )
    else
        BalloonFlight:ListenToGameEvent( sEvent, false )
    end
end

require 'events/controls'