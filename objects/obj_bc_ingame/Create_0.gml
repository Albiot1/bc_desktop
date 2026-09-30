instance_create_depth(0,720,depth,obj_bc_enemycastle)
instance_create_depth(room_width,720,depth,obj_bc_nyankocastle)
global.units_killed = 0
global.enemies_killed = 0

dragx = 0
newx = 0
dragging = false
held = 0
max_cam_x = obj_bc_nyankocastle.x + camera_get_view_width(view_camera[0])/2
camx = 0

prevmxgui = 0
camspd = 0

min_cam_x = obj_bc_enemycastle.x - camera_get_view_width(view_camera[0])/2