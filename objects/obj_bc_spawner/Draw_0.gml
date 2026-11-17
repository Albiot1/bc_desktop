if DEBUG_BOXES{
    var _px = obj_bc_nyankocastle.x-50
    var _py = obj_bc_nyankocastle.bbox_bottom
    
    draw_circle(_px,_py,12,1)
    //draw_line(_px,_py-32,_px,_py)
    
    _px = obj_bc_enemycastle.x+58
    _py = obj_bc_enemycastle.bbox_bottom
    
    draw_circle(_px,_py,12,1)
    //draw_line(_px,_py-32,_px,_py)
    
    _px = obj_bc_enemycastle.bbox_right+5
    _py = obj_bc_enemycastle.bbox_bottom
    
    draw_circle_colour(_px,_py,12,c_yellow,c_yellow,1)
    //draw_line(_px,_py-32,_px,_py)
}