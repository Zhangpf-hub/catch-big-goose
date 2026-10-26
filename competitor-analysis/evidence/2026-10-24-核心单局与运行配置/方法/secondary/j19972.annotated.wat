  (func $j19972 (type $t0) (param $p0 i32)
    (local $l1 f32) (local $l2 f32) (local $l3 f32) (local $l4 f32) (local $l5 f32) (local $l6 i64) (local $l7 i32) (local $l8 i32)
    global.get $primary.global$0
    i32.const 144
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139666
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139666
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=136
    local.get $p0
    i64.const 0
    i64.store offset=128
    local.get $p0
    i64.const 0
    i64.store offset=120
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=8
    local.set $l8
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $l7
    block $B1
      local.get $l8
      if $I2
        local.get $p0
        i32.const 80
        i32.add
        i32.const 0
        i32.const 55112
        call_indirect $primary.table (type $t3)
        local.get $p0
        i32.load offset=88
        local.set $l8
        local.get $p0
        local.get $l8
        i32.store offset=112
        local.get $p0
        local.get $l8
        i32.store offset=40
        local.get $p0
        i64.load offset=80
        local.set $l6
        local.get $p0
        local.get $l6
        i64.store offset=104
        local.get $p0
        local.get $l6
        i64.store offset=32
        local.get $p0
        i32.const 80
        i32.add
        local.get $l7
        local.get $p0
        i32.const 32
        i32.add
        i32.const 0
        i32.const 50441
        call_indirect $primary.table (type $t6)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=20
        local.set $l1
        local.get $p0
        f32.load offset=80
        local.get $l1
        f32.mul
        local.set $l2
        local.get $p0
        f32.load offset=84
        local.get $l1
        f32.mul
        local.set $l3
        local.get $p0
        f32.load offset=88
        local.get $l1
        f32.mul
        local.set $l1
        br $B1
      end
      local.get $p0
      i32.const 80
      i32.add
      i32.const 0
      i32.const 55112
      call_indirect $primary.table (type $t3)
      local.get $p0
      i32.load offset=88
      local.set $l8
      local.get $p0
      local.get $l8
      i32.store offset=72
      local.get $p0
      local.get $l8
      i32.store offset=24
      local.get $p0
      i64.load offset=80
      local.set $l6
      local.get $p0
      local.get $l6
      i64.store offset=64
      local.get $p0
      local.get $l6
      i64.store offset=16
      local.get $p0
      i32.const 80
      i32.add
      local.get $l7
      local.get $p0
      i32.const 16
      i32.add
      i32.const 0
      i32.const 50449
      call_indirect $primary.table (type $t6)
      local.get $p0
      local.get $p0
      i64.load offset=96
      i64.store offset=136
      local.get $p0
      local.get $p0
      i64.load offset=88
      i64.store offset=128
      local.get $p0
      local.get $p0
      i64.load offset=80
      i64.store offset=120
      local.get $p0
      i32.load offset=132
      i64.extend_i32_u
      local.get $p0
      i32.load offset=136
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      local.set $l6
      local.get $p0
      local.get $l6
      i32.wrap_i64
      i32.store offset=80
      local.get $p0
      local.get $l6
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      i32.store offset=84
      local.get $p0
      local.get $p0
      i32.load offset=140
      i32.store offset=88
      local.get $p0
      f32.load offset=88
      local.set $l4
      local.get $p0
      f32.load offset=84
      local.set $l3
      local.get $p0
      f32.load offset=80
      local.set $l1
      local.get $p0
      i32.const 80
      i32.add
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      i32.const 5185
      call_indirect $primary.table (type $t2)
      i32.const 0
      i32.const 5186
      call_indirect $primary.table (type $t4)
      local.get $p0
      f32.load offset=84
      local.set $l2
      local.get $p0
      i32.load offset=132
      i64.extend_i32_u
      local.get $p0
      i32.load offset=136
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      local.set $l6
      local.get $p0
      local.get $l6
      i32.wrap_i64
      i32.store offset=80
      local.get $p0
      local.get $l6
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      i32.store offset=84
      local.get $p0
      local.get $p0
      i32.load offset=140
      i32.store offset=88
      local.get $l1
      local.set $l5
      local.get $l2
      local.get $p0
      f32.load offset=84
      f32.neg
      f32.div
      local.set $l1
      local.get $l5
      local.get $l1
      f32.mul
      local.set $l2
      local.get $l3
      local.get $l1
      f32.mul
      local.set $l3
      local.get $l4
      local.get $l1
      f32.mul
      local.set $l1
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l7
      local.get $p0
      i32.const 80
      i32.add
      i32.const 0
      i32.const 55112
      call_indirect $primary.table (type $t3)
      local.get $p0
      f32.load offset=80
      local.set $l4
      local.get $p0
      i32.const 80
      i32.add
      i32.const 0
      i32.const 55112
      call_indirect $primary.table (type $t3)
      local.get $p0
      f32.load offset=84
      local.set $l5
      i32.const 5155400
      i32.load8_u
      i32.eqz
      if $I3
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.const 810
        call_indirect $primary.table (type $t0)
        i32.const 5155400
        i32.const 1
        i32.store8
      end
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      local.get $p0
      local.get $l2
      local.get $l2
      f32.mul
      local.get $l3
      local.get $l3
      f32.mul
      f32.add
      local.get $l1
      local.get $l1
      f32.mul
      f32.add
      f32.sqrt
      f32.store offset=56
      local.get $p0
      local.get $p0
      i32.load offset=56
      i32.store offset=8
      local.get $p0
      local.get $l5
      f32.store offset=52
      local.get $p0
      local.get $l4
      f32.store offset=48
      local.get $p0
      local.get $p0
      i64.load offset=48
      i64.store
      local.get $p0
      i32.const 80
      i32.add
      local.get $l7
      local.get $p0
      i32.const 0
      i32.const 50440
      call_indirect $primary.table (type $t6)
      local.get $p0
      f32.load offset=88
      local.set $l1
      local.get $p0
      f32.load offset=84
      local.set $l3
      local.get $p0
      f32.load offset=80
      local.set $l2
      local.get $p0
      i32.const 80
      i32.add
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      i32.const 5185
      call_indirect $primary.table (type $t2)
      i32.const 0
      i32.const 5186
      call_indirect $primary.table (type $t4)
      local.get $l2
      local.get $p0
      f32.load offset=80
      f32.sub
      local.set $l2
      local.get $l3
      local.get $p0
      f32.load offset=84
      f32.sub
      local.set $l3
      local.get $l1
      local.get $p0
      f32.load offset=88
      f32.sub
      local.set $l1
    end
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.load offset=92
    local.set $l7
    local.get $l7
    local.get $l1
    f32.store offset=48
    local.get $l7
    local.get $l3
    f32.store offset=44
    local.get $l7
    local.get $l2
    f32.store offset=40
    local.get $p0
    i32.const 144
    i32.add
    global.set $primary.global$0)
