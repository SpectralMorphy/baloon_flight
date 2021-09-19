MAPS = {
	DEFAULT = {
		SUBMAP_COUNT = 1,
		RENDER_DISTANCE = 50000,
		HEIGHT_OFFSET = 0,
	},
	demo = {
		SUBMAP_COUNT = 3,
		HEIGHT_OFFSET = -10000,
	}
}

MAP = table.overlay( MAPS.DEFAULT, MAPS[ GetMapName() ] )
