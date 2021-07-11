GameUI.SetCameraPitchMin( 5 );
GameUI.SetCameraPitchMax( 5 );
GameUI.SetCameraDistance( 1500 );
GameUI.SetCameraLookAtPositionHeightOffset( 700 );


function SetFixedCamera(){
	$.Schedule( 0.01, SetFixedCamera );
	GameUI.SetCameraTargetPosition( [0,0,0], 0.06 );
}
SetFixedCamera();