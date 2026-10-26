  (func $j14616 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i64) (local $l5 f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    block $B0
      local.get $p1
      if $I1
        i32.const 5156929
        i32.load8_u
        i32.eqz
        if $I2
          i32.const 3964964 ;; UnityEngine.Vector2_TypeInfo
          call $j922
          i32.const 5156929
          i32.const 1
          i32.store8
        end
        i32.const 3964964 ;; UnityEngine.Vector2_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p1
        local.get $p1
        f32.load offset=12
        local.set $l5
        local.get $p1
        f32.load offset=8
        f32.const -0x1.f4p+9 (;=-1000;)
        f32.mul
        i32.reinterpret_f32
        local.set $p1
        local.get $l5
        f32.const -0x1.f4p+9 (;=-1000;)
        f32.mul
        i32.reinterpret_f32
        local.set $l3
        br $B0
      end
      local.get $p2
      i32.const 0
      call $j1807 ;; UnityEngine.Input$$get_mousePosition
      local.get $p2
      i32.load
      local.set $p1
      local.get $p2
      i32.load offset=4
      local.set $l3
    end
    local.get $p1
    i64.extend_i32_u
    local.get $l3
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    local.set $l4
    local.get $p0
    local.get $l4
    i32.wrap_i64
    i32.store offset=172
    local.get $p0
    local.get $l4
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=176
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
