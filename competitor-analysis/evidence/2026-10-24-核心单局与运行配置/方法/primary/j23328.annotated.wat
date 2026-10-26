  (func $j23328 (type $t4) (param $p0 i32)
    (local $l1 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139966
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 4124520 ;; 清理{0}关物品
      call $j922
      i32.const 5139966
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.eqz
      br_if $B1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.store offset=12
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $p0
      i32.const 12
      i32.add
      call $j935
      local.set $l1
      i32.const 4124520 ;; 清理{0}关物品
      i32.load
      local.get $l1
      i32.const 0
      call $j1006 ;; System.String$$Format
      local.set $l1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $l1
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.const 0
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=24
      i32.load offset=12
      i32.eqz
      br_if $B1
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      i32.load
      call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
      local.set $l1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      call $j923
      local.get $l1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.const 0
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=24
      i32.const 0
      call $j4379 ;; LevelObjectPool$$ClearByList
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
