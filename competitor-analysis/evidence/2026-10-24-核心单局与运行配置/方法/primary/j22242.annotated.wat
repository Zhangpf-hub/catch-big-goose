  (func $j22242 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 f32) (local $l3 f32) (local $l4 f32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 1
    local.set $l5
    block $B0
      local.get $p0
      i32.load8_u offset=68
      i32.eqz
      br_if $B0
      local.get $p1
      i32.const 0
      call $j1807 ;; UnityEngine.Input$$get_mousePosition
      local.get $p1
      f32.load
      local.set $l2
      local.get $p0
      f32.load offset=172
      local.set $l3
      i32.const 5150501
      i32.load8_u
      i32.eqz
      if $I1
        i32.const 3958628 ;; UnityEngine.Mathf_TypeInfo
        call $j922
        i32.const 5150501
        i32.const 1
        i32.store8
      end
      local.get $l3
      local.get $l2
      f32.sub
      f32.abs
      local.set $l4
      local.get $l2
      f32.abs
      local.set $l2
      local.get $l3
      f32.abs
      local.set $l3
      local.get $l2
      local.get $l3
      local.get $l2
      local.get $l3
      f32.gt
      select
      f32.const 0x1.0c6f7ap-20 (;=1e-06;)
      f32.mul
      local.set $l2
      i32.const 3958628 ;; UnityEngine.Mathf_TypeInfo
      i32.load
      i32.load offset=92
      f32.load
      f32.const 0x1p+3 (;=8;)
      f32.mul
      local.set $l3
      local.get $l4
      local.get $l2
      local.get $l3
      local.get $l2
      local.get $l3
      f32.gt
      select
      f32.lt
      if $I2
        i32.const 0
        local.set $l5
        local.get $p1
        i32.const 0
        call $j1807 ;; UnityEngine.Input$$get_mousePosition
        local.get $p1
        f32.load offset=4
        local.set $l2
        local.get $p0
        f32.load offset=176
        local.set $l3
        i32.const 5150501
        i32.load8_u
        i32.eqz
        if $I3
          i32.const 3958628 ;; UnityEngine.Mathf_TypeInfo
          call $j922
          i32.const 5150501
          i32.const 1
          i32.store8
        end
        local.get $l3
        local.get $l2
        f32.sub
        f32.abs
        local.set $l4
        local.get $l2
        f32.abs
        local.set $l2
        local.get $l3
        f32.abs
        local.set $l3
        local.get $l2
        local.get $l3
        local.get $l2
        local.get $l3
        f32.gt
        select
        f32.const 0x1.0c6f7ap-20 (;=1e-06;)
        f32.mul
        local.set $l2
        i32.const 3958628 ;; UnityEngine.Mathf_TypeInfo
        i32.load
        i32.load offset=92
        f32.load
        f32.const 0x1p+3 (;=8;)
        f32.mul
        local.set $l3
        local.get $l4
        local.get $l2
        local.get $l3
        local.get $l2
        local.get $l3
        f32.gt
        select
        f32.lt
        br_if $B0
      end
      i32.const 1
      local.set $l5
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $l5
    return)
