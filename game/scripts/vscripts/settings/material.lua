local DEFAULT_SPACE = {
	TYPE = Obstacle.TYPE.SPACE,
	DISABLE_TIME = 0,
}

MATERIAL = {
	DEFAULT = {
		TYPE = Obstacle.TYPE.SOLID,
		TOP_BOUNCE = 0,
		SIDE_BOUNCE = 0,
		BOT_BOUNCE = 0,
		TOP_EVENTS = {},
		SIDE_EVENTS = {},
		BOT_EVENTS = {},
	},
	simple = {
		TOP_BOUNCE = 0.5,
		SIDE_BOUNCE = 1,
		BOT_BOUNCE = 1,
		TOP_EVENTS = {'IMPACT','WALK'},
		SIDE_EVENTS = {'IMPACT'},
		BOT_EVENTS = {'IMPACT'},
	},
	space = table.overlay( DEFAULT_SPACE, {
		DISABLE_TIME = 0.5,
	}),
}