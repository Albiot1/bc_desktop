function scr_get_files_number(_path,_folders){
    var _number = 0
    var _search = fa_none
    if _folders{
        _search = fa_directory
    }
    
    var _first_file = file_find_first(_path+"\\*",_search)
    
    if _first_file!=""{
        var _file = 0
        var _max = 0
        _number++
        while _file!=_first_file and _max<5{
            _file = file_find_next()
            if _file!=""{
                _number++
            }
            else{
                _max++
            }
        }
    }

    return _number
}