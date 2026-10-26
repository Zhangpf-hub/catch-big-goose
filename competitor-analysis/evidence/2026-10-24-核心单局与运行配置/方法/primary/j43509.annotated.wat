  (func $j43509 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140160
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953004 ;; CommonValueType_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3964172 ;; UIGamePage_TypeInfo
      call $j922
      i32.const 3964920 ;; ValueManager_TypeInfo
      call $j922
      i32.const 4125220 ;; 结束摇晃提示
      call $j922
      i32.const 4084976 ;; LoopCheckTip
      call $j922
      i32.const 5140160
      i32.const 1
      i32.store8
    end
    block $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.const 1
      i32.eq
      br_if $B1
      local.get $p0
      i32.load offset=808
      local.set $l2
      local.get $l2
      i32.const 1
      i32.ge_s
      if $I2
        local.get $p0
        local.get $l2
        i32.const 1
        i32.sub
        i32.store offset=808
        br $B1
      end
      local.get $p0
      i32.load offset=804
      i32.const 1
      i32.add
      local.set $l2
      local.get $p0
      local.get $l2
      i32.store offset=804
      local.get $l2
      i32.const 6
      i32.lt_s
      br_if $B1
      local.get $p0
      i32.const 300
      i32.store offset=808
      i32.const 3964172 ;; UIGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l2
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      i32.const 0
      call $j980 ;; UnityEngine.Object$$op_Equality
      br_if $B1
      i32.const 3964172 ;; UIGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l2
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      i32.const 3964172 ;; UIGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 1
      i32.const 0
      call $j34226 ;; UIGamePage$$ShowShakeTip
      i32.const 3964920 ;; ValueManager_TypeInfo
      i32.load
      call $j923
      i32.const 22
      i32.const 0
      call $j8258 ;; ValueManager$$AddLimitCount
      local.get $p1
      i32.const 22
      i32.store offset=12
      i32.const 3953004 ;; CommonValueType_TypeInfo
      i32.load
      local.set $l2
      local.get $p1
      i32.const -1
      i32.store offset=4
      local.get $p1
      local.get $l2
      i32.store
      local.get $p1
      local.get $p1
      i32.load offset=12
      i32.store offset=8
      local.get $p1
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      call $j1731 ;; ConfigManager$$GetCommonInt
      local.set $l2
      i32.const 22
      i32.const 0
      call $j4559 ;; ValueManager$$GetLimitCount
      local.get $l2
      i32.lt_s
      br_if $B1
      local.get $p0
      i32.const 4084976 ;; LoopCheckTip
      i32.load
      i32.const 0
      call $j1451 ;; UnityEngine.MonoBehaviour$$StopCoroutine
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4125220 ;; 结束摇晃提示
      i32.load
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
