  (func $j91761 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139725
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 4031356 ;; Method$NetDataManager.ResetDaliySaveAndLevel()
      call $j922
      i32.const 4045788 ;; Method$ValueManager.ResetDaliyLocalSave()
      call $j922
      i32.const 5139725
      i32.const 1
      i32.store8
    end
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=84
    local.set $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 0
    i32.const 4045788 ;; Method$ValueManager.ResetDaliyLocalSave()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    local.get $p0
    local.get $p1
    i32.const 0
    call $j1063 ;; System.Delegate$$Remove
    local.set $p0
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    local.set $p1
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=84
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    drop
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=84
    local.set $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 0
    i32.const 4031356 ;; Method$NetDataManager.ResetDaliySaveAndLevel()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    local.get $p0
    local.get $p1
    i32.const 0
    call $j1063 ;; System.Delegate$$Remove
    local.set $p0
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    local.set $p1
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=84
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    drop)
