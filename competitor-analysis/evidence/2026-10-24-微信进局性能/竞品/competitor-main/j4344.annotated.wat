  (func $j4344 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 f32) (local $l5 f32) (local $l6 f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5127167
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5127167
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load offset=20
      i32.const 0
      call $j7217 ;; UnityEngine.Rigidbody$$get_isKinematic
      local.get $p1
      i32.eq
      br_if $B1
      local.get $p0
      i32.load8_u offset=19
      br_if $B1
      local.get $p0
      i32.load8_u offset=16
      i32.eqz
      br_if $B1
      local.get $p1
      i32.eqz
      if $I2
        local.get $p0
        i32.load8_u offset=18
        br_if $B1
      end
      block $B3
        local.get $p2
        br_if $B3
        local.get $p3
        local.get $p0
        i32.load offset=20
        i32.const 0
        call $j39442 ;; UnityEngine.Rigidbody$$get_velocity
        local.get $p3
        f32.load offset=8
        local.set $l4
        local.get $p3
        f32.load offset=4
        local.set $l5
        local.get $p3
        f32.load
        local.set $l6
        i32.const 5155400
        i32.load8_u
        i32.eqz
        if $I4
          i32.const 3958620 ;; System.Math_TypeInfo
          call $j922
          i32.const 5155400
          i32.const 1
          i32.store8
        end
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.load
        call $j923
        local.get $l6
        local.get $l6
        f32.mul
        local.get $l5
        local.get $l5
        f32.mul
        f32.add
        local.get $l4
        local.get $l4
        f32.mul
        f32.add
        f32.sqrt
        f32.const 0x1.99999ap-3 (;=0.2;)
        f32.gt
        i32.eqz
        br_if $B3
        local.get $p1
        br_if $B1
      end
      local.get $p0
      local.get $p1
      i32.const 1
      i32.xor
      local.get $p0
      call $j8794 ;; ObjectUnit$$SetRigid
      local.get $p1
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      br_if $B1
      local.get $p0
      i32.load8_u offset=92
      i32.eqz
      br_if $B1
      local.get $p0
      local.get $p0
      call $j21512 ;; ObjectUnit$$DelayToGrowScale
    end
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0)
