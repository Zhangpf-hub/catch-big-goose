  (func $j43536 (type $t24) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result f32)
    (local $l3 f32)
    i32.const 5140098
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955276 ;; GMLevelManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4079720 ;; GMLevel
      call $j922
      i32.const 5140098
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    i32.const 9
    i32.eq
    if $I1
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j38359 ;; SeasonLevelMa$$GetSizeData
      return
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    f32.const 0x1p+0 (;=1;)
    local.set $l3
    block $B2
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 6
      i32.ne
      br_if $B2
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 4079720 ;; GMLevel
      i32.load
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      i32.eqz
      br_if $B2
      i32.const 3955276 ;; GMLevelManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.const 24846
      global.set $__wasm_split_waitTableId
      i32.const 24846
      call_indirect $primary.table (type $t16)
      local.set $l3
    end
    local.get $l3
    return)
