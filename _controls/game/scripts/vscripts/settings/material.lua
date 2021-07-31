local DEFAULT_SPACE = {
	TYPE = Obstacle.TYPE.SPACE,
	DISABLE_TIME = 0,
}

MATERIAL = {
	DEFAULT = {
		TYPE = Obstacle.TYPE.SOLID,
		SIDE_BOUNCE = 0,
		BOT_BOUNCE = 0,
		-- BOT_STUN = 1,
	},
	simple = {
		SIDE_BOUNCE = 1,
		BOT_BOUNCE = 1,
	},
	space = table.overlay( DEFAULT_SPACE, {
		DISABLE_TIME = 0.5,
	}),
}