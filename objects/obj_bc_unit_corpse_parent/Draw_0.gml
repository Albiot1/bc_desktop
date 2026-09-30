draw_sprite_ext(sprite_index,frame,x,y,0.5*side,0.5,0,c_white,1)
draw_rectangle(bbox_left,bbox_top,bbox_right,bbox_bottom,1)
draw_text(x,y-128,creator)

if frame >= 19 and reviving{
    with creator{
        if surface_exists(atlas)
            bc_draw_baked_frame_atlas_new_fixed(anim_idle,0,atlas,x,y,0.5*scale,image_alpha)
    }
}