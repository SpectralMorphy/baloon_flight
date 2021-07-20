GameUI.SetCameraPitchMin( 5 );
GameUI.SetCameraPitchMax( 5 );
GameUI.SetCameraDistance( 600 );


function SetFixedCamera(){
    var nHero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    var vPos = Entities.GetAbsOrigin( nHero );
    
    $.Schedule( 0.01, SetFixedCamera );
    GameUI.SetCameraTargetPosition( vPos, 0.06 );
    GameUI.SetCameraLookAtPositionHeightOffset( vPos[2] + 0 );
}

SetFixedCamera();