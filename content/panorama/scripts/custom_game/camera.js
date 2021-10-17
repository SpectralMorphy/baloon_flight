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
	this.nDistance = t.DISTANCE;

	GameUI.SetCameraDistance( t.DISTANCE );
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
	let nTime = Game.Time();
	let nTimeDelta = Game.GetGameFrameTime();

	if(this.SETTINGS.vTarget){
		if(!this.vTarget || this.vTarget[0] != this.SETTINGS.vTarget[1]
		|| this.vTarget[1] != this.SETTINGS.vTarget[2] || this.vTarget[2] != this.SETTINGS.vTarget[3] ){
			
			let nAnimTime = this.SETTINGS.nAnimTime || 0.001;
			this.vTarget = [ this.SETTINGS.vTarget[1], this.SETTINGS.vTarget[2], this.SETTINGS.vTarget[3] ];

			this.nAnimEnd = nTime + nAnimTime;
			this.nHeightSpeed = ( this.vTarget[2] - (this.nHeight || GameUI.GetCameraLookAtPosition()[2]) ) / nAnimTime

			GameUI.SetCameraTargetPosition(this.vTarget, nAnimTime);
		}
	}else{
		this.vTarget = null;
	}

	let vPos;
	let nHeight;

	if(this.vTarget){
		let nAnimTimeRemaining = (this.nAnimEnd || 0) - nTime;
		if(nAnimTimeRemaining > 0){
			nHeight = this.vTarget[2] - this.nHeightSpeed * nAnimTimeRemaining;
		}else{
			vPos = this.vTarget;
		}
	} else {
		let nHero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
		if(nHero < 1) return;
		vPos = Entities.GetAbsOrigin( nHero );

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
	}

	if(!nHeight && nHeight != 0){
		this.nHeight = vPos[2];
	}else{
		this.nHeight = nHeight;
	}

	nHeight = this.nHeight + this.SETTINGS.HEIGHT_OFFSET;
    GameUI.SetCameraLookAtPositionHeightOffset( nHeight );
	
	if(vPos){
    	GameUI.SetCameraTargetPosition( vPos, 0.06 );
	}
}

// ==========================================
// Update timer

Camera.ScheduleUpdate = function(){
	$.Schedule( 0, () => this.ScheduleUpdate() );
	this.Update();
}

// ==========================================
// Call Initialization

Camera.Init();