__JsData_NIL = __JsData_NIL or {}
__JsData_tGeneral = __JsData_tGeneral or {}
__JsData_tPlayers = __JsData_tPlayers or {}

local function JsDataEncodeValue( xValue )
	return xValue == nil and __JsData_NIL or xValue
end

local function JsDataDecodeValue( xValue )
	if xValue == __JsData_NIL then
		return nil
	end
	return xValue
end

local function SendPlayerJsData( nPlayer, sKey )
	local hPlayer = PlayerResource:GetPlayer( nPlayer )
	if sKey == 'CameraSettings' then
		Log:Add('jsdata sv send camera '..nPlayer)
		if not exist(hPlayer) then
			Log:Add('player unknown')
		end
	end
	if exist( hPlayer ) then
		CustomGameEventManager:Send_ServerToPlayer( hPlayer, 'cl_jsdata_set', {
			sKey = sKey,
			xData = GetPlayerJsData( nPlayer, sKey )
		})
	end
end

local function SendAllPlayerJsData( nPlayer )
	for sKey in pairs( table.overlay( __JsData_tGeneral, __JsData_tPlayers[ nPlayer] ) ) do
		SendPlayerJsData( nPlayer, sKey )
	end
end

local function SendJsData( sKey )
	for nPlayer = 0, DOTA_MAX_PLAYERS do
		SendPlayerJsData( nPlayer, sKey )
	end
end

function SetPlayerJsData( nPlayer, sKey, xValue )
	local tPlayer = goc( __JsData_tPlayers, nPlayer )
	tPlayer[ sKey ] = xValue

	SendPlayerJsData( nPlayer, sKey )
end

function UnsetPlayerJsData( nPlayer, sKey )
	local tPlayer = __JsData_tPlayers[ nPlayer ]
	if tPlayer then
		tPlayer[ sKey ] = nil

		if table.empty( tPlayer ) then
			__JsData_tPlayers[ nPlayer ] = nil
		end

		SendPlayerJsData( nPlayer, sKey )
	end
end

function SetJsData( sKey, xValue )
	__JsData_tGeneral[ sKey ] = JsDataEncodeValue( xValue )

	SendJsData( sKey )
end

function UnsetJsData( sKey )
	__JsData_tGeneral[ sKey ] = nil

	SendJsData( sKey )
end

function GetPlayerJsData( nPlayer, sKey )
	local xGeneral = __JsData_tGeneral[ sKey ]
	local xPlayer = ( __JsData_tPlayers[ nPlayer ] or {} )[ sKey ]

	if xPlayer == __JsData_NIL then
		return nil
	elseif xPlayer == nil then
		return JsDataDecodeValue( xGeneral )
	else
		return JsDataEncodeValue( xPlayer )
	end
end

function AddPlayerJsData(nPlayer, sKey, tData)
	SetPlayerJsData(nPlayer, sKey, table.overlay(GetPlayerJsData(nPlayer, sKey), tData))
end

Log:Add('jsdata sv register for request')
BalloonFlight:ListenToClientEvent( 'sv_jsdata_request', function( t )
	Log:Add('jsdata sv get request')
	SendAllPlayerJsData( t.PlayerID )
end )