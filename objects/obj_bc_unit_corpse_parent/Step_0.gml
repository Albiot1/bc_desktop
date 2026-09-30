if reviving == false{
    if creator.state != UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK{
        
        revive_time-=0.5
        if revive_time<=0{
            reviving = true
            frame = 0
            sprite_index = spr_zombie_revive
        }
    
    }
}

if creator!=noone{
    if !reviving{
        switch (creator.state) {
        	case UNIT_STATE.ZOMBIE_DEAD:
                if sprite_index != spr_zombie_revive and sprite_index != spr_zombie_fake_death{
                    sprite_index = spr_zombie_fake_death
                    frame = 0
                }
            break;
            case UNIT_STATE.ZOMBIE_DEAD_KNOCKBACK:
                if sprite_index != spr_zombie_revive and sprite_index != spr_zombie_knockback{
                    sprite_index = spr_zombie_knockback
                    frame = 0
                }
            break;
        }
    }
}

switch(sprite_index){
    case spr_zombie_fake_death:
        if frame<15{
            frame += 0.5
        }
        if image_xscale == 0{
            image_xscale = 0.5
            image_yscale = 0.5
        }
    break;
    case spr_zombie_knockback:
        frame = 0
        if image_xscale == 0.5{
            image_xscale = 0
            image_yscale = 0
        }
    break;
    case spr_zombie_revive:
        if image_xscale == 0{
            image_xscale = 0.5
            image_yscale = 0.5
        }
        
        frame += 0.5

        if frame==33{
            if creator.effects & U_EFFECTS.STRENGTHEN > 0 and !(creator.effects_active & U_EFFECTS.STRENGTHEN > 0){
                with creator{
                    if life < baselife*effects_data.strengthen.threshold{
                        effects_active |= U_EFFECTS.STRENGTHEN
                    }
                }
            }
            
            with creator{
                state = UNIT_STATE.IDLE
                corpse_ref = noone
                current_anim = anim_idle
                frame = 0
                image_xscale = (320/5)/2
                image_yscale = 1
            }
            instance_destroy()
        }
    break;
}

