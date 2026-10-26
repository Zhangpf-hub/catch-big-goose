  (func $j6377 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 f32) (local $l4 f32) (local $l5 f32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    local.get $p0
    i32.load8_u offset=92
    i32.eqz
    if $I0
      local.get $p1
      if $I1
        local.get $p0
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.set $l6
        i32.const 5142879
        i32.load8_u
        i32.eqz
        if $I2
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5142879
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p1
        local.get $p0
        f32.load offset=128
        local.set $l3
        local.get $p1
        f32.load offset=12
        local.get $l3
        f32.mul
        local.set $l4
        local.get $p1
        f32.load offset=16
        local.get $l3
        f32.mul
        local.set $l5
        local.get $p2
        local.get $p1
        f32.load offset=20
        local.get $l3
        f32.mul
        f32.store offset=24
        local.get $p2
        local.get $p2
        i32.load offset=24
        i32.store offset=8
        local.get $p2
        local.get $l5
        f32.store offset=20
        local.get $p2
        local.get $l4
        f32.store offset=16
        local.get $p2
        local.get $p2
        i64.load offset=16
        i64.store
        local.get $l6
        local.get $p2
        i32.const 0
        call $j1159 ;; UnityEngine.Transform$$set_localScale
      end
      local.get $p0
      i32.const 1
      i32.store8 offset=92
    end
    local.get $p2
    i32.const 32
    i32.add
    global.set $primary.global$0)
