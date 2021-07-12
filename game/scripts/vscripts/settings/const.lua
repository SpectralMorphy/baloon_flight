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

    MAX_VEL_X = 700,
    ACC_X = 300,
    ACC_X_INTERP = ACC_INTERP.SIMPLE,

    MAX_VEL_FALL = 900,
    MAX_VEL_RISE = 700,
    ACC_FALL = 500,
    ACC_RISE = 400,

    ANIM_IDLE = ACT_DOTA_FLAIL,
    ANIM_MOVE = ACT_DOTA_RUN,
}