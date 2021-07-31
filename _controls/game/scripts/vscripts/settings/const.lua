ACC_INTERP = {
    SIMPLE = function( v )
        return 1
    end,
    FALL_LINEAR = function( v )
        return 1 - v
    end,
}

CONST = {
    FIXED_Y = 0,

    MAX_VEL_X = 2000,
    ACC_X = 800,
    ACC_X_INTERP = ACC_INTERP.SIMPLE,

    MAX_VEL_FALL = 2500,
    MAX_VEL_RISE = 2000,
    ACC_FALL = 1200,
    ACC_RISE = 800,

    ANIM_IDLE = ACT_DOTA_FLAIL,
    ANIM_MOVE = ACT_DOTA_RUN,
}