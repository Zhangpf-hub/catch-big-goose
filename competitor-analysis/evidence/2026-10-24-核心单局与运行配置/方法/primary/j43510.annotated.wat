  (func $j43510 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 f32) (local $l3 f32) (local $l4 f32) (local $l5 i32) (local $l6 i32) (local $l7 f64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    i32.const 5140137
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 5140137
      i32.const 1
      i32.store8
    end
    local.get $p0
    f32.load offset=264
    local.set $l2
    local.get $p0
    f32.load offset=732
    local.set $l3
    block $B1
      local.get $l2
      local.get $l3
      f32.lt
      i32.eqz
      if $I2
        local.get $p0
        i32.load offset=728
        local.set $p1
        br $B1
      end
      local.get $l3
      local.get $l2
      f32.sub
      local.get $p0
      f32.load offset=720
      f32.div
      f64.promote_f32
      local.set $l7
      block $B3
        local.get $l7
        f64.abs
        f64.const 0x1p+31 (;=2.14748e+09;)
        f64.lt
        if $I4
          local.get $l7
          i32.trunc_f64_s
          local.set $p1
          br $B3
        end
        i32.const -2147483648
        local.set $p1
      end
      local.get $p0
      local.get $p1
      i32.store offset=728
      local.get $p0
      i32.load offset=724
      local.set $l6
      i32.const 3
      local.get $p1
      i32.sub
      local.set $p1
      i32.const 0
      local.get $l6
      local.get $p1
      local.get $p1
      local.get $l6
      i32.gt_s
      select
      local.get $p1
      i32.const 0
      i32.lt_s
      select
      local.set $p1
      local.get $p0
      local.get $p1
      i32.store offset=728
    end
    local.get $p0
    i32.load offset=724
    local.get $p1
    i32.gt_s
    if $I5
      local.get $p0
      local.get $p1
      i32.const 1
      i32.add
      i32.store offset=728
      local.get $p0
      local.get $p0
      f32.load offset=264
      local.get $p0
      f32.load offset=720
      f32.sub
      i32.const 0
      i32.const 1
      local.get $p0
      call $j10878 ;; LevelManager$$SetMinTouchHeight
      local.get $p0
      local.get $p0
      f32.load offset=264
      f32.store offset=732
      local.get $p0
      local.get $p0
      call $j22259 ;; LevelManager$$CheckAllRigidAndVisible
    end
    local.get $p0
    local.get $p0
    call $j43503 ;; LevelManager$$getRealMax
    local.set $l3
    i32.const 0
    local.set $p1
    loop $L6
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p1
      local.get $p0
      i32.load offset=152
      i32.load offset=12
      i32.lt_s
      if $I7
        local.get $l5
        local.get $p0
        i32.load offset=152
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        i32.const 0
        call $j1062 ;; UnityEngine.Transform$$get_position
        local.get $p0
        f32.load offset=260
        local.set $l2
        local.get $p0
        f32.load offset=716
        local.set $l4
        f32.const 0x1p+0 (;=1;)
        local.get $l5
        f32.load offset=4
        local.get $l2
        local.get $l4
        f32.sub
        f32.sub
        local.get $l3
        local.get $l2
        local.get $l4
        f32.sub
        f32.sub
        f32.div
        f32.sub
        local.set $l2
        local.get $p0
        i32.load offset=152
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        local.get $p0
        f32.load offset=708
        f32.const 0x0p+0 (;=0;)
        local.get $l2
        f32.const 0x1p+0 (;=1;)
        f32.min
        local.get $l2
        f32.const 0x0p+0 (;=0;)
        f32.lt
        select
        local.get $p0
        f32.load offset=712
        f32.mul
        f32.add
        i32.const 0
        call $j21508 ;; ObjectUnit$$MessForce
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L6
      end
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    i32.const 7
    i32.eq
    if $I8
      local.get $p0
      f32.load offset=708
      local.set $l2
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      i32.const 19328
      global.set $__wasm_split_waitTableId
      i32.const 19328
      call_indirect $primary.table (type $t114)
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)
