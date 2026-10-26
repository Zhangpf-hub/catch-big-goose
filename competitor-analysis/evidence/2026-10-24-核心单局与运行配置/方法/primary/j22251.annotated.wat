  (func $j22251 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32) (local $l6 i32) (local $l7 i64)
    global.get $primary.global$0
    i32.const 112
    i32.sub
    local.set $p4
    local.get $p4
    global.set $primary.global$0
    i32.const 5140116
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 5140116
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      i32.load8_u offset=94
      br_if $B1
      local.get $p0
      i32.load offset=76
      local.set $l5
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $l5
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      local.get $p4
      i32.const 96
      i32.add
      local.get $p1
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      call $j1062 ;; UnityEngine.Transform$$get_position
      local.get $p4
      i32.load offset=104
      local.set $l5
      local.get $p4
      local.get $l5
      i32.store offset=88
      local.get $p4
      local.get $l5
      i32.store offset=40
      local.get $p4
      i64.load offset=96
      local.set $l7
      local.get $p4
      local.get $l7
      i64.store offset=80
      local.get $p4
      local.get $l7
      i64.store offset=32
      local.get $p0
      local.get $p4
      i32.const 32
      i32.add
      local.get $p4
      call $j22240 ;; LevelManager$$PlayCombineParticle
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j4012 ;; SpLevelManager$$CurLevelIsSpLevel
    if $I2
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3
      i32.const 0
      call $j37556 ;; SpLevelManager$$AddSpLevelProgress
    end
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=44
    local.set $l5
    local.get $l5
    if $I3
      local.get $p4
      i32.const 96
      i32.add
      local.get $p1
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      call $j1062 ;; UnityEngine.Transform$$get_position
      local.get $p4
      i32.load offset=104
      local.set $l6
      local.get $p4
      local.get $l6
      i32.store offset=72
      local.get $p4
      local.get $l6
      i32.store offset=24
      local.get $p4
      i64.load offset=96
      local.set $l7
      local.get $p4
      local.get $l7
      i64.store offset=64
      local.get $p4
      local.get $l7
      i64.store offset=16
      local.get $l5
      i32.load offset=32
      local.get $p4
      i32.const 16
      i32.add
      local.get $l5
      i32.load offset=20
      local.get $l5
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t2)
    end
    local.get $p1
    i32.const 0
    call $j41504 ;; ObjectUnit$$OnCombine
    local.get $p0
    local.get $p2
    local.get $p3
    local.get $p4
    call $j14624 ;; LevelManager$$CheckLevelState
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=236
    local.set $p0
    local.get $p0
    if $I4
      local.get $p1
      i32.load offset=12
      local.set $p2
      local.get $p4
      i32.const 96
      i32.add
      local.get $p1
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      call $j1062 ;; UnityEngine.Transform$$get_position
      local.get $p4
      i32.load offset=104
      local.set $p1
      local.get $p4
      local.get $p1
      i32.store offset=56
      local.get $p4
      local.get $p1
      i32.store offset=8
      local.get $p4
      i64.load offset=96
      local.set $l7
      local.get $p4
      local.get $l7
      i64.store offset=48
      local.get $p4
      local.get $l7
      i64.store
      local.get $p0
      i32.load offset=32
      local.get $p2
      local.get $p4
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t6)
    end
    local.get $p4
    i32.const 112
    i32.add
    global.set $primary.global$0)
