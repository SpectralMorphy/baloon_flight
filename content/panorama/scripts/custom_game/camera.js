var _G = GameUI.CustomUIConfig();
var Camera = {};

// ==========================================
// Initialization

Camera.Init = function(){
	$.Msg('['+Game.GetGameTime()+']: camera register');
	_G.ListenJsData( 'CameraSettings', t => {
		Camera.ChangeSettings( t );
	})
	
	Camera.ScheduleUpdate();
}

// ==========================================
// Apply camera settings

Camera.ChangeSettings = function( t ){
	$.Msg('Camera settings');
	t.PITCH = t.PITCH || 0;
	t.DISTANCE = t.DISTANCE || 1000;
	t.HEIGHT_OFFSET = t.HEIGHT_OFFSET || 0;
	t.SPEED_FOR_MIN_DISTANCE = t.SPEED_FOR_MIN_DISTANCE || 0;
	t.DISTANCE_CHANGE_TIME = t.DISTANCE_CHANGE_TIME || 0;

	this.SETTINGS = t;

	if( !this.IsDistanceDynamic() ){
		this.nDistance = t.DISTANCE;
		GameUI.SetCameraDistance( t.DISTANCE );
	}

	GameUI.SetCameraPitchMin( t.PITCH );
	GameUI.SetCameraPitchMax( t.PITCH );
}

// ==========================================
// Util

Camera.IsDistanceDynamic = function(){
	return this.SETTINGS.MAX_DISTANCE && this.SETTINGS.SPEED_FOR_MAX_DISTANCE && true || false;
}

// ==========================================
// Update camera

Camera.Update = function(){
	if( !this.SETTINGS ) return;
    let nHero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	if(nHero < 1) return;
    let vPos = Entities.GetAbsOrigin( nHero );
	if( !vPos ) return;

	let nTimeDelta = 0;
	let nTime = Game.Time();
	if( this.nLastUpdate ){
		nTimeDelta = nTime - this.nLastUpdate;
	}

	if( this.IsDistanceDynamic() ){
		let nSpeed = ( _G.GetJsData('CameraSpeed') || {} )[ nHero ];
		let nPart = nSpeed ? Math.max( 0, Math.min( 1, ( nSpeed - this.SETTINGS.SPEED_FOR_MIN_DISTANCE ) / ( this.SETTINGS.SPEED_FOR_MAX_DISTANCE - this.SETTINGS.SPEED_FOR_MIN_DISTANCE ) ) ) : 0;
		let nTargetDistance = this.SETTINGS.DISTANCE + ( this.SETTINGS.MAX_DISTANCE - this.SETTINGS.DISTANCE ) * nPart;
		
		if( nTimeDelta && nTimeDelta < this.SETTINGS.DISTANCE_CHANGE_TIME ){
			let nDeltaDistance = nTargetDistance - this.nDistance;
			this.nDistance = this.nDistance + nDeltaDistance * nTimeDelta / this.SETTINGS.DISTANCE_CHANGE_TIME;
		} else {
			this.nDistance = nTargetDistance;
		}

		GameUI.SetCameraDistance( this.nDistance );
	}

	vPos[2] += this.SETTINGS.HEIGHT_OFFSET;

    GameUI.SetCameraTargetPosition( vPos, 0.06 );
    GameUI.SetCameraLookAtPositionHeightOffset( vPos[2] );
	
	this.nLastUpdate = nTime;
}

// ==========================================
// Update timer

Camera.ScheduleUpdate = function(){
	$.Schedule( 0.01, () => this.ScheduleUpdate() );
	this.Update();
}

// ==========================================
// Call Initialization

Camera.Init();