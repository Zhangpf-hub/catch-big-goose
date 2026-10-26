  (func $j37545 (type $t0) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 f32) (local $l4 f32) (local $l5 f32) (local $l6 f32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 i64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139665
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139665
      i32.const 1
      i32.store8
    end
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=24
      br_if $B1
      i32.const 0
      i32.const 0
      i32.const 55103
      call_indirect $primary.table (type $t2)
      if $I2
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        local.get $p0
        call $j19972 ;; SpModeLongTableMa$$GetMousePos
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store offset=76
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $p0
        local.get $l1
        i32.load offset=48
        i32.store offset=56
        local.get $p0
        local.get $l1
        i32.load offset=40
        i64.extend_i32_u
        local.get $l1
        i32.load offset=44
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=48
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        local.get $p0
        i32.load offset=56
        i32.store offset=36
        local.get $p0
        i64.load offset=48
        local.set $l10
        local.get $l1
        local.get $l10
        i32.wrap_i64
        i32.store offset=28
        local.get $l1
        local.get $l10
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        i32.store offset=32
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store offset=64
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 1
        i32.store8 offset=73
      end
      i32.const 0
      i32.const 0
      i32.const 55104
      call_indirect $primary.table (type $t2)
      if $I3
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store offset=76
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store8 offset=73
      end
      block $B4
        i32.const 0
        i32.const 0
        i32.const 55102
        call_indirect $primary.table (type $t2)
        i32.eqz
        br_if $B4
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=73
        i32.eqz
        br_if $B4
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        local.get $p0
        call $j19972 ;; SpModeLongTableMa$$GetMousePos
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=8
        local.set $l1
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 44
        i32.const 48
        local.get $l1
        select
        i32.add
        f32.load
        local.set $l3
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 32
        i32.const 36
        local.get $l1
        select
        i32.add
        f32.load
        local.set $l5
        i32.const 0
        i32.const 52954
        call_indirect $primary.table (type $t20)
        local.set $l4
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l3
        local.get $l5
        f32.sub
        local.get $l4
        f32.div
        f32.store offset=68
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        block $B5
          block $B6
            block $B7
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.load offset=92
              f32.load offset=68
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.load offset=92
              f32.load offset=64
              f32.gt
              if $I8
                i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
                i32.load
                i32.load offset=92
                f32.load offset=68
                f32.const 0x0p+0 (;=0;)
                f32.gt
                br_if $B7
              end
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.load offset=92
              f32.load offset=68
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.load offset=92
              f32.load offset=64
              f32.lt
              i32.eqz
              br_if $B6
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
              i32.load
              i32.load offset=92
              f32.load offset=68
              f32.const 0x0p+0 (;=0;)
              f32.lt
              i32.eqz
              br_if $B6
            end
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=68
            local.set $l3
            br $B5
          end
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=64
          local.set $l3
          local.get $l3
          local.set $l4
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=68
          local.get $l3
          f32.sub
          local.set $l5
          i32.const 0
          i32.const 52954
          call_indirect $primary.table (type $t20)
          f32.const 0x1.4p+4 (;=20;)
          f32.mul
          local.set $l3
          local.get $l4
          local.get $l5
          f32.const 0x0p+0 (;=0;)
          local.get $l3
          f32.const 0x1p+0 (;=1;)
          f32.min
          local.get $l3
          f32.const 0x0p+0 (;=0;)
          f32.lt
          select
          f32.mul
          f32.add
          local.set $l3
        end
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l3
        f32.store offset=64
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=64
        f32.const 0x0p+0 (;=0;)
        f32.ge
        i32.store8 offset=72
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=8
        local.set $l2
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $l1
        block $B9
          local.get $l2
          if $I10
            local.get $p0
            i32.const 48
            i32.add
            local.get $l1
            i32.const 0
            i32.const 5186
            call_indirect $primary.table (type $t4)
            local.get $p0
            f32.load offset=56
            local.set $l6
            local.get $p0
            f32.load offset=52
            local.set $l5
            local.get $p0
            f32.load offset=48
            local.set $l3
            i32.const 5156933
            i32.load8_u
            i32.eqz
            if $I11
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.const 810
              call_indirect $primary.table (type $t0)
              i32.const 5156933
              i32.const 1
              i32.store8
            end
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            i32.load
            i32.load offset=92
            local.set $l1
            local.get $l1
            f32.load offset=80
            local.set $l7
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=44
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=32
            f32.sub
            f32.neg
            local.set $l4
            local.get $l3
            local.get $l1
            f32.load offset=72
            local.get $l4
            f32.mul
            f32.add
            local.set $l3
            local.get $l5
            local.get $l1
            f32.load offset=76
            local.get $l4
            f32.mul
            f32.add
            local.set $l5
            local.get $l6
            local.get $l7
            local.get $l4
            f32.mul
            f32.add
            local.set $l4
            br $B9
          end
          local.get $p0
          i32.const 48
          i32.add
          local.get $l1
          i32.const 0
          i32.const 5186
          call_indirect $primary.table (type $t4)
          local.get $p0
          f32.load offset=56
          local.set $l6
          local.get $p0
          f32.load offset=52
          local.set $l5
          local.get $p0
          f32.load offset=48
          local.set $l3
          i32.const 5156933
          i32.load8_u
          i32.eqz
          if $I12
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            i32.const 810
            call_indirect $primary.table (type $t0)
            i32.const 5156933
            i32.const 1
            i32.store8
          end
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          i32.load
          i32.load offset=92
          local.set $l1
          local.get $l1
          f32.load offset=80
          local.set $l7
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=48
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=36
          f32.sub
          f32.neg
          local.set $l4
          local.get $l3
          local.get $l1
          f32.load offset=72
          local.get $l4
          f32.mul
          f32.add
          local.set $l3
          local.get $l5
          local.get $l1
          f32.load offset=76
          local.get $l4
          f32.mul
          f32.add
          local.set $l5
          local.get $l6
          local.get $l7
          local.get $l4
          f32.mul
          f32.add
          local.set $l4
        end
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        local.get $l4
        f32.store offset=60
        local.get $l1
        local.get $l5
        f32.store offset=56
        local.get $l1
        local.get $l3
        f32.store offset=52
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=52
        local.set $l6
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=60
        local.set $l3
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=12
        local.set $l5
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=16
        local.set $l4
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=56
        f32.store offset=56
        local.get $l1
        local.get $l6
        f32.store offset=52
        local.get $l1
        local.get $l5
        local.get $l4
        local.get $l3
        local.get $l3
        local.get $l4
        f32.gt
        select
        local.get $l3
        local.get $l5
        f32.lt
        select
        f32.store offset=60
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $l1
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l2
        local.get $p0
        local.get $l2
        i32.load offset=60
        i32.store offset=24
        local.get $p0
        local.get $l2
        i32.load offset=52
        i64.extend_i32_u
        local.get $l2
        i32.load offset=56
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=16
        local.get $l1
        local.get $p0
        i32.const 16
        i32.add
        i32.const 0
        i32.const 53035
        call_indirect $primary.table (type $t4)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=76
        local.set $l6
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        f32.load offset=36
        local.set $l4
        local.get $l1
        f32.load offset=32
        local.set $l5
        local.get $l1
        f32.load offset=28
        local.set $l3
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        f32.load offset=48
        local.set $l7
        local.get $l1
        f32.load offset=44
        local.set $l8
        local.get $l1
        f32.load offset=40
        local.set $l9
        i32.const 5140222
        i32.load8_u
        i32.eqz
        if $I13
          i32.const 3958620 ;; System.Math_TypeInfo
          i32.const 810
          call_indirect $primary.table (type $t0)
          i32.const 5140222
          i32.const 1
          i32.store8
        end
        local.get $l3
        local.get $l9
        f32.sub
        local.set $l3
        local.get $l5
        local.get $l8
        f32.sub
        local.set $l5
        local.get $l4
        local.get $l7
        f32.sub
        local.set $l4
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l6
        local.get $l3
        local.get $l3
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
        f32.add
        f32.store offset=76
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $p0
        local.get $l1
        i32.load offset=48
        i32.store offset=56
        local.get $p0
        local.get $l1
        i32.load offset=40
        i64.extend_i32_u
        local.get $l1
        i32.load offset=44
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=48
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        local.get $p0
        i32.load offset=56
        i32.store offset=36
        local.get $p0
        i64.load offset=48
        local.set $l10
        local.get $l1
        local.get $l10
        i32.wrap_i64
        i32.store offset=28
        local.get $l1
        local.get $l10
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        i32.store offset=32
        br $B1
      end
      i32.const 0
      i32.const 0
      i32.const 55102
      call_indirect $primary.table (type $t2)
      br_if $B1
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      f32.load offset=84
      f32.neg
      local.set $l5
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      f32.load offset=84
      local.set $l4
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      f32.load offset=64
      local.set $l3
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      local.get $l5
      local.get $l4
      local.get $l3
      local.get $l3
      local.get $l4
      f32.gt
      select
      local.get $l3
      local.get $l5
      f32.lt
      select
      f32.store offset=64
      local.get $p0
      i32.const 32
      i32.add
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 0
      i32.const 5186
      call_indirect $primary.table (type $t4)
      local.get $p0
      local.get $p0
      i32.load offset=40
      i32.store offset=56
      local.get $p0
      local.get $p0
      i64.load offset=32
      i64.store offset=48
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l1
      local.get $l1
      local.get $p0
      i32.load offset=56
      i32.store offset=60
      local.get $p0
      i64.load offset=48
      local.set $l10
      local.get $l1
      local.get $l10
      i32.wrap_i64
      i32.store offset=52
      local.get $l1
      local.get $l10
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      i32.store offset=56
      block $B14
        block $B15
          block $B16
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=64
            f32.const 0x0p+0 (;=0;)
            f32.gt
            i32.eqz
            br_if $B16
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load8_u offset=72
            i32.eqz
            br_if $B16
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=64
            i32.const 0
            i32.const 52954
            call_indirect $primary.table (type $t20)
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=80
            f32.mul
            f32.sub
            local.set $l3
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            local.get $l3
            f32.store offset=64
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=64
            local.set $l3
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            local.get $l3
            f32.const 0x0p+0 (;=0;)
            local.get $l3
            f32.const 0x0p+0 (;=0;)
            f32.gt
            select
            f32.store offset=64
            local.get $p0
            i32.const 48
            i32.add
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=4
            i32.const 0
            i32.const 5186
            call_indirect $primary.table (type $t4)
            local.get $p0
            f32.load offset=56
            local.set $l6
            local.get $p0
            f32.load offset=52
            local.set $l5
            local.get $p0
            f32.load offset=48
            local.set $l4
            i32.const 5156933
            i32.load8_u
            i32.eqz
            if $I17
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.const 810
              call_indirect $primary.table (type $t0)
              i32.const 5156933
              i32.const 1
              i32.store8
            end
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            i32.load
            i32.load offset=92
            local.set $l1
            local.get $l1
            f32.load offset=80
            local.set $l7
            i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
            i32.load
            i32.load offset=92
            f32.load offset=64
            f32.neg
            local.set $l3
            local.get $l1
            f32.load offset=72
            local.get $l3
            f32.mul
            local.set $l8
            local.get $l1
            f32.load offset=76
            local.get $l3
            f32.mul
            local.set $l9
            local.get $l7
            local.get $l3
            f32.mul
            local.set $l7
            local.get $l4
            local.set $l3
            i32.const 0
            i32.const 52954
            call_indirect $primary.table (type $t20)
            local.set $l4
            local.get $l3
            local.get $l8
            local.get $l4
            f32.mul
            f32.add
            local.set $l3
            local.get $l5
            local.get $l9
            local.get $l4
            f32.mul
            f32.add
            local.set $l5
            local.get $l6
            local.get $l7
            local.get $l4
            f32.mul
            f32.add
            local.set $l4
            br $B15
          end
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=64
          f32.const 0x0p+0 (;=0;)
          f32.lt
          i32.eqz
          br_if $B14
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=72
          br_if $B14
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=64
          i32.const 0
          i32.const 52954
          call_indirect $primary.table (type $t20)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=80
          f32.mul
          f32.add
          local.set $l3
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          local.get $l3
          f32.store offset=64
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=64
          local.set $l3
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          local.get $l3
          f32.const 0x0p+0 (;=0;)
          local.get $l3
          f32.const 0x0p+0 (;=0;)
          f32.lt
          select
          f32.store offset=64
          local.get $p0
          i32.const 48
          i32.add
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 0
          i32.const 5186
          call_indirect $primary.table (type $t4)
          local.get $p0
          f32.load offset=56
          local.set $l6
          local.get $p0
          f32.load offset=52
          local.set $l5
          local.get $p0
          f32.load offset=48
          local.set $l4
          i32.const 5156933
          i32.load8_u
          i32.eqz
          if $I18
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            i32.const 810
            call_indirect $primary.table (type $t0)
            i32.const 5156933
            i32.const 1
            i32.store8
          end
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          i32.load
          i32.load offset=92
          local.set $l1
          local.get $l1
          f32.load offset=80
          local.set $l7
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=64
          f32.neg
          local.set $l3
          local.get $l1
          f32.load offset=72
          local.get $l3
          f32.mul
          local.set $l8
          local.get $l1
          f32.load offset=76
          local.get $l3
          f32.mul
          local.set $l9
          local.get $l7
          local.get $l3
          f32.mul
          local.set $l7
          local.get $l4
          local.set $l3
          i32.const 0
          i32.const 52954
          call_indirect $primary.table (type $t20)
          local.set $l4
          local.get $l3
          local.get $l8
          local.get $l4
          f32.mul
          f32.add
          local.set $l3
          local.get $l5
          local.get $l9
          local.get $l4
          f32.mul
          f32.add
          local.set $l5
          local.get $l6
          local.get $l7
          local.get $l4
          f32.mul
          f32.add
          local.set $l4
        end
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        local.get $l4
        f32.store offset=60
        local.get $l1
        local.get $l5
        f32.store offset=56
        local.get $l1
        local.get $l3
        f32.store offset=52
      end
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      block $B19
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=60
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=16
        f32.gt
        i32.eqz
        if $I20
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=60
          i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
          i32.load
          i32.load offset=92
          f32.load offset=12
          f32.lt
          i32.eqz
          br_if $B19
        end
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=52
        local.set $l6
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=60
        local.set $l3
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=12
        local.set $l5
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=16
        local.set $l4
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        local.get $l1
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=56
        f32.store offset=56
        local.get $l1
        local.get $l6
        f32.store offset=52
        local.get $l1
        local.get $l5
        local.get $l4
        local.get $l3
        local.get $l3
        local.get $l4
        f32.gt
        select
        local.get $l3
        local.get $l5
        f32.lt
        select
        f32.store offset=60
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store offset=64
      end
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 0
      i32.const 5185
      call_indirect $primary.table (type $t2)
      local.set $l1
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l2
      local.get $p0
      local.get $l2
      i32.load offset=60
      i32.store offset=8
      local.get $p0
      local.get $l2
      i32.load offset=52
      i64.extend_i32_u
      local.get $l2
      i32.load offset=56
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      i64.store
      local.get $l1
      local.get $p0
      i32.const 0
      i32.const 53035
      call_indirect $primary.table (type $t4)
    end
    local.get $p0
    i32.const -64
    i32.sub
    global.set $primary.global$0)
