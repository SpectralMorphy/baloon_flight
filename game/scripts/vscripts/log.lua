Log = Log or {}
Log.qMsgs = Log.Msgs or {}

function Log:Add( sMsg )
	table.insert( self.qMsgs, {
		sMsg = sMsg,
		nTime = GameRules:GetGameTime(),
	})
end

function Log:Print( nPlayer )
	local hPlayer = PlayerResource:GetPlayer( nPlayer )
	CustomGameEventManager:Send_ServerToPlayer( hPlayer, 'cl_pring_log', self.qMsgs )
end

Convars:RegisterCommand( 'print_log', function()
	local hPlayer = Convars:GetCommandClient()
	if exist( hPlayer ) then
		Log:Print( hPlayer:GetPlayerID() )
	end
end, 'print sv logs', 0 )