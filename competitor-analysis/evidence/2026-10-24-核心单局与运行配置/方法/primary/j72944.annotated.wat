  (func $j72944 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140491
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3960792 ;; RedPointManager_TypeInfo
      call $j922
      i32.const 4104820 ;; count
      call $j922
      i32.const 4123192 ;; 无count
      call $j922
      i32.const 5140491
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=92
    block $B1
      local.get $p1
      i32.const 4104820 ;; count
      i32.load
      i32.const 0
      call $j1273 ;; LitJson.JsonData$$ContainsKey
      if $I2
        local.get $p1
        i32.const 4104820 ;; count
        i32.load
        i32.const 0
        call $j1155 ;; LitJson.JsonData$$get_Item
        i32.const 0
        call $j1625 ;; LitJson.JsonData$$ToJson
        i32.const 0
        call $j1292 ;; System.Int32$$Parse
        local.set $p1
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p1
        i32.store offset=92
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        call $j923
        i32.const 8
        i32.const 0
        i32.const 0
        call $j1940 ;; ActionManager$$TriggerEvent
        br $B1
      end
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4123192 ;; 无count
      i32.load
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store8 offset=96
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=124
    local.set $p1
    local.get $p1
    if $I3
      local.get $p1
      i32.load offset=32
      local.get $p1
      i32.load offset=20
      local.get $p1
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
    end
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I4
      local.get $p0
      i32.load offset=32
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=92
    i32.const 0
    call $j35793 ;; ThinkingManager$$RecordInviteNewPlayerCount
    i32.const 3960792 ;; RedPointManager_TypeInfo
    i32.load
    call $j923
    i32.const 28
    i32.const 0
    call $j1690) ;; RedPointManager$$RefreshRedPoint
