  (func $j22244 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140077
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 5140077
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 212
    i32.const 276
    local.get $p1
    i32.const 1
    i32.eq
    select
    i32.add
    local.set $l3
    local.get $l3
    i32.load
    local.set $l4
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $l4
    i32.const 0
    i32.const 0
    call $j971 ;; UnityEngine.Object$$op_Inequality
    if $I1
      local.get $p2
      local.get $p0
      local.get $l4
      local.get $p1
      i32.const 1
      local.get $p0
      call $j14621 ;; LevelManager$$GetUnit
      local.get $l3
      i32.const 0
      i32.store
      local.get $p0
      i32.load offset=72
      local.get $p1
      i32.const 1
      i32.sub
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      i32.const 0
      i32.const 0
      call $j3070 ;; HighlightPlus.HighlightEffect$$SetHighlighted
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B2
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 7
      i32.ne
      br_if $B2
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      i32.const 0
      call $j971 ;; UnityEngine.Object$$op_Inequality
      i32.eqz
      br_if $B2
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      local.get $p0
      local.set $p1
      local.get $p0
      i32.load
      local.set $p0
      local.get $p1
      local.get $p0
      i32.const 40
      i32.add
      i32.load offset=192
      local.get $p0
      i32.load offset=228
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=32
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
