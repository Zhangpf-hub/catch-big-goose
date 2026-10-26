  (func $j14627 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 f32) (local $l5 f32)
    i32.const 5140133
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952108 ;; BattleResult_TypeInfo
      call $j922
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140133
      i32.const 1
      i32.store8
    end
    i32.const 3955472 ;; GameManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=4
    if $I1
      i32.const 0
      call $j45181 ;; GameManager$$BattleEnd
      i32.const 3952108 ;; BattleResult_TypeInfo
      i32.load
      call $j924
      local.set $p3
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p3
      i32.store offset=32
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.get $p1
      i32.store offset=12
      block $B2
        block $B3
          block $B4
            block $B5
              local.get $p1
              br_table $B5 $B4 $B5 $B2
            end
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=32
            local.set $p1
            br $B3
          end
          local.get $p0
          f32.load offset=336
          local.set $l4
          local.get $p0
          f32.load offset=272
          local.set $l5
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          local.set $p1
          local.get $l4
          local.get $l5
          f32.eq
          if $I6
            i32.const 0
            local.set $p2
            br $B3
          end
          i32.const 1
          i32.const 2
          local.get $p0
          f32.load offset=272
          local.get $p0
          f32.load offset=336
          f32.gt
          select
          local.set $p2
        end
        local.get $p1
        local.get $p2
        i32.store offset=8
      end
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 224
      i32.const 0
      i32.const 0
      i32.const 0
      i32.const 0
      call $j1082 ;; Kunpo.KUIManager$$OpenUI
    end)
