  (func $j43540 (type $t16) (param $p0 i32) (param $p1 i32) (result f32)
    (local $l2 i32) (local $l3 f32) (local $l4 f32)
    i32.const 5140171
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 5140171
      i32.const 1
      i32.store8
    end
    f32.const 0x1p+0 (;=1;)
    local.set $l4
    block $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B1
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j1480 ;; NetInitManager$$UseVideoMode
      br_if $B1
      local.get $p0
      i32.load offset=196
      local.set $p1
      local.get $p1
      local.get $p0
      i32.load offset=200
      i32.sub
      local.get $p1
      i32.div_s
      local.set $p1
      local.get $p1
      i32.const -1
      i32.gt_s
      local.set $l2
      local.get $p1
      f32.convert_i32_s
      f32.const 0x1p+0 (;=1;)
      f32.min
      local.set $l3
      local.get $p0
      i32.load offset=840
      local.set $p1
      block $B2
        local.get $p1
        i32.eqz
        br_if $B2
        local.get $p1
        i32.load offset=12
        i32.eqz
        br_if $B2
        local.get $p1
        i32.load offset=16
        f32.load offset=16
        local.set $l4
      end
      local.get $l3
      f32.const 0x0p+0 (;=0;)
      local.get $l2
      select
      local.set $l3
      i32.const 0
      local.set $p1
      loop $L3
        local.get $p0
        i32.load offset=840
        local.set $l2
        local.get $p1
        local.get $l2
        i32.load offset=12
        i32.ge_s
        br_if $B1
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        f32.load offset=8
        local.get $l3
        f32.gt
        if $I4
          local.get $p0
          i32.load offset=840
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          f32.load offset=16
          return
        else
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L3
        end
        unreachable
      end
      unreachable
    end
    local.get $l4
    return)
