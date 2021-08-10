var _G = GameUI.CustomUIConfig();

// ==========================================
// Disable default UI 

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );	
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );	
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false );	
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false );	
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );

// ==========================================
// Improved AddCommand interface 

_G.tCommands = _G.tCommands || {};

_G.SetCommand = function( sCommand, fCallback ){
    if( !_G.tCommands[ sCommand ] ){
        Game.AddCommand( sCommand, function(){
            var f = _G.tCommands[ sCommand ];
            f();
        }, '', 0 );
    }

    _G.tCommands[ sCommand ] = fCallback;
}

GameEvents.Subscribe('cl_pring_log', function (qMsgs) {
	for( let k in qMsgs ){
		let t = qMsgs[k];
		$.Msg( '[' + t.nTime + ']:\t' + t.sMsg )
	}
})

$.Msg('main init');