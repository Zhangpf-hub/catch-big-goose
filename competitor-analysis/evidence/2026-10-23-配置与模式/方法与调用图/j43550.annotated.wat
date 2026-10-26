  (func $j43550 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140084
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 4124524 ;; 清理主线关物品
      call $j922
      i32.const 5140084
      i32.const 1
      i32.store8
    end
    i32.const 4124524 ;; 清理主线关物品
    i32.load
    i32.const 0
    call $j1441 ;; UnityEngine.MonoBehaviour$$print
    i32.const 1
    local.set $p1
    loop $L1
      local.get $p1
      i32.const 3
      i32.lt_s
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 8
        i32.add
        local.get $p1
        i32.const 0
        call $j7298 ;; NetDataManager$$GetMainLevelIndex
        local.get $p0
        call $j3322 ;; LevelIndexAndType$$MainLevel
        i32.const 3958024 ;; LevelDataHelper_TypeInfo
        i32.load
        call $j923
        local.get $p0
        local.get $p0
        i64.load offset=8
        i64.store
        local.get $p0
        i32.const 2
        local.get $p0
        call $j4382 ;; LevelDataHelper$$GetLevelData
        local.set $l2
        i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
        i32.load
        call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
        local.get $l2
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=24
        i32.const 0
        call $j4379 ;; LevelObjectPool$$ClearByList
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
