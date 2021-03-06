----------------------------------------------------------------
-- List of events to register

local tGameEvents = {
    -- npc_spawned = true,
	game_rules_state_change = true,
}

local tClientEvents = {
	sv_baloon_control = true,
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
        local nListener = CustomGameEventManager:RegisterListener( sEvent, function( nPlayerIndex, t )
            Log:Add('sv event '..sEvent..' '..tostring(nPlayerIndex)..' '..tostring(t.PlayerID))

			if t.PlayerID and PlayerResource:IsValidPlayer( t.PlayerID ) then
				fCallback( t )
			else
                if not nPlayerIndex then
                    Log:Add('event pizdets')
                end

				local nLimit = 1000
				local bSucc = false

                local function fCheckLimit()
                    if nLimit > 0 then
                        nLimit = nLimit - 1
                        return 1/30
                    end
                    Log:Add('sv event fail: initialization timeout')
                end

				Timer( function()
                    local hPlayer = EntIndexToHScript( nPlayerIndex )

					if not exist( hPlayer ) then
						return fCheckLimit()
					end

					local nPlayer = hPlayer:GetPlayerID()
					if not PlayerResource:IsValidPlayer( nPlayer ) then
						return fCheckLimit()
					end

					bSucc = true
					t.PlayerID = nPlayer
					fCallback( t )

				end ).OnDestroy = function( self )
					if not bSucc then
						print("Received event from ivalid client")
					end
				end

				return
			end
        end )

        self.tClientEvents[ sEvent ] = nListener
    end
end

----------------------------------------------------------------
-- Registering events

for sEvent, bActive in pairs( tGameEvents ) do
    if bActive then
        BalloonFlight:ListenToGameEvent( sEvent, require( 'events/' .. sEvent ) )
    else
        BalloonFlight:ListenToGameEvent( sEvent, false )
    end
end

for sEvent, bActive in pairs( tClientEvents ) do
    if bActive then
        BalloonFlight:ListenToClientEvent( sEvent, require( 'events/' .. sEvent ) )
    else
        BalloonFlight:ListenToClientEvent( sEvent, false )
    end
end