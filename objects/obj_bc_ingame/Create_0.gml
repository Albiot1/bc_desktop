instance_create_depth(0,SPAWN_Y,depth,obj_bc_enemycastle)
instance_create_depth(room_width,SPAWN_Y,depth,obj_bc_nyankocastle)
global.units_killed = 0
global.enemies_killed = 0

dragx = 0
newx = 0
dragging = false
held = 0
max_cam_x = obj_bc_nyankocastle.x - camera_get_view_width(view_camera[0]) + 96
camx = 0

prevmxgui = 0
camspd = 0

min_cam_x = obj_bc_enemycastle.x - 96

zoom = 1

base_w = 640
base_h = 360

update_size = function (){
    camera_set_view_size(
        view_camera[0],
        base_w*zoom,
        base_h*zoom
    )
    var _diff = cam_h
    cam_h = base_h*zoom
    _diff = cam_h - _diff
    max_cam_x = obj_bc_nyankocastle.x - camera_get_view_width(view_camera[0]) + 96
    camera_set_view_pos(
        view_camera[0],
        clamp(
        camera_get_view_x(view_camera[0])-_diff,
        min_cam_x,
        max_cam_x
            ),
        camera_get_view_y(view_camera[0])
    )
}


cam_h = 360