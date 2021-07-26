MAPS = {
	DEFAULT = {
		FIXED_Y = 0,
		RENDER_DISTANCE = 5000,
	},
}

MAP = table.overlay( MAPS.DEFAULT, MAPS[ GetMapName() ] )