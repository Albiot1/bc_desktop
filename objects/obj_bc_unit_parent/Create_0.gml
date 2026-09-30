tm=0
frame = 0

scale = 1

freezed = 0
freezedmax = 0
slow = { time: 0, percent: 0 }
weaken = { time: 0, percent: 0 }
curse = 0
warp = { time: 0, distance: 0, state:0, animframe:0 }
dodging = 0
dodging_behemoth = 0
survived = 0

hitanenemy = false

//
effects_active = 0



freezed_frame = 0
survived_frame = 0
dodging_frame = 0
curse_frame = 0
strengthen_frame = 0
weaken_frame = 0
slowed_frame = 0
immunity_frame = 0
immunity_specatk_frame = 0
wave_shield_frame = 0
//

is_crit = false
is_savage_blow = false
is_toxic = false
is_metal_kill = false

//
is_knockback = false
is_freeze = false
is_slow = false
is_weaken = false
is_warp = false
is_curse = false
//

hitanenemy = false

state = UNIT_STATE.MOVE
attacked = 0

lastpos = 0
lastposy = y

knockback = {
    type: 0,
    distance:0,
    time:0,
    maxtime:12,
    anim: animcurve_get_channel( animcurve_get(an_bounce_1),"curve1" ),
    anims: animcurve_get_channel( animcurve_get(an_bounce_1),"curve2" ),
    anmsmall: animcurve_get_channel( animcurve_get(an_bounce_small),"curve1" ),
    ansmalls: animcurve_get_channel( animcurve_get(an_bounce_small),"curve2" )
}

enemylist = ds_list_create()