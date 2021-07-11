var _G = GameUI.CustomUIConfig();

// ==========================================
// Mouse disable

GameUI.SetMouseCallback( function( e, n ){
	return true;
});

// ==========================================
// Register controls

_G.SetCommand( '+baloon_left', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'x',
		dir: -1,
		active: 1,
	})
});

_G.SetCommand( '-baloon_left', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'x',
		dir: -1,
		active: 0,
	})
});

_G.SetCommand( '+baloon_right', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'x',
		dir: 1,
		active: 1,
	})
});

_G.SetCommand( '-baloon_right', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'x',
		dir: 1,
		active: 0,
	})
});

_G.SetCommand( '+baloon_up', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'z',
		active: 1,
	})
});

_G.SetCommand( '-baloon_up', function(){
	GameEvents.SendCustomGameEventToServer( 'sv_baloon_control', {
		axis: 'z',
		active: 0,
	})
});

Game.CreateCustomKeyBind( 'A', '+baloon_left' );
Game.CreateCustomKeyBind( 'D', '+baloon_right' );
Game.CreateCustomKeyBind( 'W', '+baloon_up' );