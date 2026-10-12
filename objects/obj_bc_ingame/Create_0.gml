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