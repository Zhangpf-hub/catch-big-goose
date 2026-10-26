  (func $j6394 (type $t4) (param $p0 i32)
    i32.const 5139736
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3958880 ;; MiniArchiveManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4113036 ;; playerPublicArchive
      call $j922
      i32.const 5139736
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    local.set $p0
    i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j1163 ;; LitJson.JsonMapper$$ToJson
    local.set $p0
    i32.const 3958880 ;; MiniArchiveManager_TypeInfo
    i32.load
    call $j923
    i32.const 4113036 ;; playerPublicArchive
    i32.load
    local.get $p0
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    call $j21838) ;; MiniArchiveManager$$RecordOldArchive
