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

    MAX_VEL_X = 1400,
    ACC_X = 500,
    ACC_X_INTERP = ACC_INTERP.SIMPLE,

    MAX_VEL_FALL = 1800,
    MAX_VEL_RISE = 1400,
    ACC_FALL = 700,
    ACC_RISE = 500,

    ANIM_IDLE = ACT_DOTA_FLAIL,
    ANIM_MOVE = ACT_DOTA_RUN,
}