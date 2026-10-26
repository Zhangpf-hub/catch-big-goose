  (func $j14621 (type $t11) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32) (param $p5 i32)
    (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32) (local $l11 i32) (local $l12 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $l6
    local.get $l6
    global.set $primary.global$0
    i32.const 5140112
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
      call $j922
      i32.const 4003048 ;; Method$System.Collections.Generic.List<ObjectUnit>.Insert()
      call $j922
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      call $j922
      i32.const 5140112
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=36
      if $I2
        i32.const 5158080
        i32.load8_u
        i32.eqz
        if $I3
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5158080
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p5
        br $B1
      end
      local.get $p3
      i32.const 1
      i32.eq
      local.set $p5
      local.get $p1
      i32.const 152
      i32.const 168
      local.get $p5
      select
      i32.add
      i32.load
      local.set $l7
      local.get $p1
      i32.const 148
      i32.const 164
      local.get $p5
      select
      i32.add
      i32.load
      local.set $l8
      local.get $p2
      i32.load8_u offset=18
      local.set $l11
      local.get $p4
      if $I4
        local.get $l6
        i32.const 16
        i32.add
        local.get $p2
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        i32.const 0
        call $j1062 ;; UnityEngine.Transform$$get_position
        local.get $p1
        local.get $l6
        f32.load offset=20
        i32.const 0
        local.get $p3
        local.get $p5
        call $j10878 ;; LevelManager$$SetMinTouchHeight
      end
      i32.const 5158080
      i32.load8_u
      local.set $p5
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
      i32.load
      drop
      local.get $l8
      i32.load offset=12
      local.get $p1
      i32.load offset=144
      i32.load offset=12
      i32.ge_s
      if $I5
        local.get $p5
        i32.eqz
        if $I6
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5158080
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p5
        br $B1
      end
      local.get $p5
      i32.eqz
      if $I7
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5158080
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p5
      local.get $l6
      local.get $p5
      i32.load offset=8
      i32.store offset=24
      local.get $l6
      local.get $p5
      i32.load
      i64.extend_i32_u
      local.get $p5
      i32.load offset=4
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      i64.store offset=16
      local.get $p2
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.get $p1
      i32.load offset=84
      i32.const 0
      call $j1610 ;; UnityEngine.Transform$$SetParent
      local.get $p2
      i32.const 1
      local.get $p1
      f32.load offset=568
      i32.const 0
      call $j6378 ;; ObjectUnit$$BeClick
      local.get $p4
      if $I8
        local.get $p2
        i32.const 0
        call $j21507 ;; ObjectUnit$$PlaySound
      end
      local.get $l7
      local.get $p2
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      i32.load
      call $j1387
      drop
      i32.const 0
      local.set $p5
      i32.const 0
      local.set $l7
      loop $L9
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $p5
        local.get $l8
        i32.load offset=12
        i32.lt_s
        if $I10
          local.get $l8
          local.get $p5
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.load offset=12
          local.get $p2
          i32.load offset=12
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          local.set $l9
          local.get $p5
          local.get $l7
          local.get $l9
          select
          local.set $l7
          local.get $l10
          local.get $l9
          i32.or
          local.set $l10
          local.get $p5
          i32.const 1
          i32.add
          local.set $p5
          br $L9
        end
      end
      block $B11
        local.get $l10
        i32.const 1
        i32.and
        if $I12
          local.get $l8
          local.get $l7
          i32.const 1
          i32.add
          local.get $p2
          i32.const 4003048 ;; Method$System.Collections.Generic.List<ObjectUnit>.Insert()
          i32.load
          call $j2525
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p5
          call $j2087 ;; LevelManager$$HasTwoPlayer
          br_if $B11
          i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
          i32.load
          drop
          local.get $p1
          i32.load offset=144
          i32.load offset=12
          local.get $l7
          i32.const 1
          i32.add
          i32.le_s
          br_if $B11
          local.get $l6
          local.get $p1
          i32.load offset=144
          local.get $l7
          i32.const 1
          i32.add
          i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j1062 ;; UnityEngine.Transform$$get_position
          local.get $l6
          local.get $l6
          i32.load offset=8
          i32.store offset=24
          local.get $l6
          local.get $l6
          i64.load
          i64.store offset=16
          br $B11
        end
        local.get $l8
        local.get $p2
        i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p5
        call $j2087 ;; LevelManager$$HasTwoPlayer
        br_if $B11
        i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
        i32.load
        drop
        local.get $p1
        i32.load offset=144
        i32.load offset=12
        i32.const 1
        i32.lt_s
        br_if $B11
        local.get $p1
        i32.load offset=144
        local.set $p5
        i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
        i32.load
        drop
        local.get $l6
        local.get $p5
        local.get $p5
        i32.load offset=12
        i32.const 1
        i32.sub
        i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1062 ;; UnityEngine.Transform$$get_position
        local.get $l6
        local.get $l6
        i32.load offset=8
        i32.store offset=24
        local.get $l6
        local.get $l6
        i64.load
        i64.store offset=16
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B13
        local.get $p5
        call $j6451 ;; LevelManager$$CanUseNewAnim
        if $I14
          local.get $p1
          local.get $p1
          local.get $p3
          local.get $p1
          i32.load offset=612
          local.get $p2
          local.get $p3
          local.get $l11
          i32.const 0
          i32.ne
          i32.const 0
          call $j43500 ;; LevelObjAnimManager$$ClickObj
          local.get $p5
          call $j22253 ;; LevelManager$$DelayToCheckContent
          i32.const 0
          call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
          drop
          br $B13
        end
        local.get $p1
        local.get $p3
        i32.const 1
        local.get $p5
        call $j5154 ;; LevelManager$$RefreshContentDisplay
      end
      local.get $p1
      i32.const 0
      i32.store offset=804
      local.get $p2
      i32.load8_u offset=18
      if $I15
        local.get $p1
        local.get $p2
        local.get $p5
        call $j43513 ;; LevelManager$$SetObjOutStore
      end
      local.get $p2
      i32.const 0
      call $j961 ;; UnityEngine.Component$$get_gameObject
      i32.const 0
      call $j1139 ;; UnityEngine.Object$$get_name
      local.set $p5
      block $B16
        local.get $p4
        i32.eqz
        br_if $B16
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        call $j923
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=224
        local.set $p4
        local.get $p4
        i32.eqz
        br_if $B16
        local.get $p4
        i32.load offset=32
        local.get $p5
        local.get $p4
        i32.load offset=20
        local.get $p4
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t2)
      end
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=228
      local.set $p4
      local.get $p4
      if $I17
        local.get $p4
        i32.load offset=32
        local.get $p5
        local.get $p4
        i32.load offset=20
        local.get $p4
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t2)
      end
      local.get $l6
      i32.const 16
      i32.add
      local.set $p5
      local.get $p3
      i32.const 1
      i32.ne
      br_if $B1
      local.get $p1
      local.get $p2
      i32.load offset=12
      local.get $p5
      call $j22237 ;; LevelManager$$RefreshTargetCount
    end
    local.get $p5
    i32.load
    i64.extend_i32_u
    local.get $p5
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    local.set $l12
    local.get $p0
    local.get $l12
    i32.wrap_i64
    i32.store
    local.get $p0
    local.get $l12
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=4
    local.get $p0
    local.get $p5
    i32.load offset=8
    i32.store offset=8
    local.get $l6
    i32.const 32
    i32.add
    global.set $primary.global$0)
