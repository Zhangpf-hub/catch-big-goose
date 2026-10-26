  (func $j73745 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 i64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5130117
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      call $j922
      i32.const 5130117
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=16
    local.set $l3
    block $B1
      block $B2
        block $B3
          block $B4
            local.get $p0
            i32.load offset=8
            br_table $B4 $B3 $B1
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          local.get $l3
          i32.load offset=12
          local.set $l2
          local.get $l2
          i32.eqz
          br_if $B1
          local.get $l2
          i32.load offset=12
          local.set $l5
          local.get $l5
          i32.eqz
          br_if $B1
          loop $L5
            local.get $l4
            local.get $l5
            i32.lt_s
            if $I6
              local.get $l2
              local.get $l4
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              local.set $l5
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I7
                i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                call $j922
                i32.const 5142879
                i32.const 1
                i32.store8
              end
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.load
              i32.load offset=92
              local.set $l2
              local.get $l3
              f32.load offset=16
              local.set $l7
              local.get $l2
              f32.load offset=12
              local.get $l7
              f32.mul
              local.set $l8
              local.get $l2
              f32.load offset=16
              local.get $l7
              f32.mul
              local.set $l9
              local.get $p1
              local.get $l2
              f32.load offset=20
              local.get $l7
              f32.mul
              f32.store offset=56
              local.get $p1
              local.get $p1
              i32.load offset=56
              i32.store offset=8
              local.get $p1
              local.get $l9
              f32.store offset=52
              local.get $p1
              local.get $l8
              f32.store offset=48
              local.get $p1
              local.get $p1
              i64.load offset=48
              i64.store
              local.get $l5
              local.get $p1
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
              local.get $l4
              i32.const 1
              i32.add
              local.set $l4
              local.get $l3
              i32.load offset=12
              local.set $l2
              local.get $l2
              i32.load offset=12
              local.set $l5
              br $L5
            end
          end
          i32.const 0
          local.set $l4
          local.get $p0
          i32.const 0
          i32.store offset=20
          br $B2
        end
        local.get $p0
        i32.const -1
        i32.store offset=8
        local.get $p0
        i32.load offset=20
        i32.const 1
        i32.add
        local.set $l4
        local.get $p0
        local.get $l4
        i32.store offset=20
        local.get $l3
        i32.load offset=12
        local.set $l2
        local.get $l2
        i32.load offset=12
        local.set $l5
      end
      local.get $l4
      local.get $l5
      i32.ge_s
      br_if $B1
      local.get $l2
      local.get $l4
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      local.set $l4
      local.get $l3
      i32.load offset=40
      local.get $p0
      i32.load offset=20
      i32.const 12
      i32.mul
      i32.add
      local.set $l2
      local.get $p1
      local.get $l2
      i32.load offset=24
      i32.store offset=40
      local.get $l2
      i32.load offset=16
      i64.extend_i32_u
      local.get $l2
      i32.load offset=20
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      local.set $l10
      local.get $p1
      local.get $l10
      i32.wrap_i64
      i32.store offset=32
      local.get $p1
      local.get $l10
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      i32.store offset=36
      local.get $l3
      f32.load offset=20
      local.set $l7
      local.get $p1
      local.get $p1
      i32.load offset=40
      i32.store offset=24
      local.get $p1
      local.get $p1
      i64.load offset=32
      i64.store offset=16
      local.get $l4
      local.get $p1
      i32.const 16
      i32.add
      local.get $l7
      i32.const 0
      call $j1969 ;; DG.Tweening.ShortcutExtensions$$DOScale
      local.get $l3
      i32.load offset=24
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      i32.load
      call $j1137
      drop
      local.get $l3
      f32.load offset=28
      local.get $l3
      f32.load offset=32
      i32.const 0
      call $j1305 ;; UnityEngine.Random$$Range
      local.set $l7
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      i32.load
      call $j924
      local.set $l3
      local.get $l3
      local.get $l7
      f32.store offset=8
      local.get $p0
      local.get $l3
      i32.store offset=12
      i32.const 1
      local.set $l6
      local.get $p0
      i32.const 1
      i32.store offset=8
    end
    local.get $p1
    i32.const -64
    i32.sub
    global.set $primary.global$0
    local.get $l6
    return)
