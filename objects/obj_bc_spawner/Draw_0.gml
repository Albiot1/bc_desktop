if DEBUG_BOXES{
    var _px = obj_bc_nyankocastle.x-50
    var _py = 720
    
    draw_circle(_px,_py,12,1)
    draw_line(_px,_py-32,_px,_py)
    
    _px = obj_bc_enemycastle.x+58
    _py = 720
    
    draw_circle(_px,_py,12,1)
    draw_line(_px,_py-32,_px,_py)
    
    _px = obj_bc_enemycastle.bbox_right+5
    _py = 720
    
    draw_circle(_px,_py,12,1)
    draw_line(_px,_py-32,_px,_py)
}