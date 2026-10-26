  (func $j74252 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 f32) (local $l6 f32) (local $l7 i64)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127080
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 3963584 ;; TimerManager_TypeInfo
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      call $j922
      i32.const 5127080
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=16
    local.set $l2
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    local.get $p0
                    i32.load offset=8
                    br_table $B8 $B7 $B6 $B5 $B4 $B2 $B1
                  end
                  local.get $p0
                  i32.const -1
                  i32.store offset=8
                  i32.const 3958052 ;; LevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 0
                  call $j6451 ;; LevelManager$$CanUseNewAnim
                  br_if $B3
                  local.get $l2
                  f32.load offset=568
                  local.set $l5
                  i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
                  i32.load
                  call $j924
                  local.set $l2
                  local.get $l2
                  local.get $l5
                  f32.store offset=8
                  local.get $p0
                  local.get $l2
                  i32.store offset=12
                  i32.const 1
                  local.set $l3
                  local.get $p0
                  i32.const 1
                  i32.store offset=8
                  br $B1
                end
                local.get $p0
                i32.const -1
                i32.store offset=8
                local.get $p0
                i32.load offset=20
                i32.const 0
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.set $l2
                i32.const 1
                local.set $l3
                local.get $p1
                i32.const -64
                i32.sub
                local.get $p0
                i32.load offset=20
                i32.const 1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                i32.const 0
                call $j1062 ;; UnityEngine.Transform$$get_position
                local.get $p1
                i32.load offset=72
                local.set $l4
                local.get $p1
                local.get $l4
                i32.store offset=56
                local.get $p1
                local.get $l4
                i32.store offset=24
                local.get $p1
                i64.load offset=64
                local.set $l7
                local.get $p1
                local.get $l7
                i64.store offset=48
                local.get $p1
                local.get $l7
                i64.store offset=16
                local.get $l2
                local.get $p1
                i32.const 16
                i32.add
                f32.const 0x1.99999ap-3 (;=0.2;)
                i32.const 0
                i32.const 0
                call $j2237 ;; DG.Tweening.ShortcutExtensions$$DOMove
                drop
                local.get $p0
                i32.load offset=20
                i32.const 2
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.set $l2
                local.get $p1
                i32.const -64
                i32.sub
                local.get $p0
                i32.load offset=20
                i32.const 1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                i32.const 0
                call $j1062 ;; UnityEngine.Transform$$get_position
                local.get $p1
                i32.load offset=72
                local.set $l4
                local.get $p1
                local.get $l4
                i32.store offset=40
                local.get $p1
                local.get $l4
                i32.store offset=8
                local.get $p1
                i64.load offset=64
                local.set $l7
                local.get $p1
                local.get $l7
                i64.store offset=32
                local.get $p1
                local.get $l7
                i64.store
                local.get $l2
                local.get $p1
                f32.const 0x1.99999ap-3 (;=0.2;)
                i32.const 0
                i32.const 0
                call $j2237 ;; DG.Tweening.ShortcutExtensions$$DOMove
                drop
                i32.const 3963584 ;; TimerManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.const 3963584 ;; TimerManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=16
                i32.store offset=12
                local.get $p0
                i32.const 2
                i32.store offset=8
                br $B1
              end
              local.get $p0
              i32.const -1
              i32.store offset=8
              local.get $p0
              i32.load offset=20
              i32.const 0
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              i32.const 0
              i32.const 0
              call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
              drop
              local.get $p0
              i32.load offset=20
              i32.const 2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              i32.const 0
              i32.const 0
              call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
              drop
              i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
              i32.load
              call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
              local.get $p0
              i32.load offset=20
              i32.const 0
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              local.get $p0
              call $j4698 ;; LevelObjectPool$$Recycle
              i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
              i32.load
              call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
              local.get $p0
              i32.load offset=20
              i32.const 2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              local.get $p0
              call $j4698 ;; LevelObjectPool$$Recycle
              i32.const 1
              local.set $l3
              local.get $p0
              i32.load offset=20
              i32.const 1
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              f32.const 0x0p+0 (;=0;)
              f32.const 0x1.99999ap-3 (;=0.2;)
              i32.const 0
              call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
              i32.const 26
              i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
              i32.load
              call $j1137
              drop
              i32.const 3963584 ;; TimerManager_TypeInfo
              i32.load
              call $j923
              local.get $p0
              i32.const 3963584 ;; TimerManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=16
              i32.store offset=12
              local.get $p0
              i32.const 3
              i32.store offset=8
              br $B1
            end
            local.get $p0
            i32.const -1
            i32.store offset=8
            i32.const 1
            local.set $l3
            local.get $l2
            local.get $p0
            i32.load offset=20
            i32.const 1
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            local.get $p0
            i32.load offset=24
            local.get $p0
            i32.load offset=28
            i32.const 0
            call $j22251 ;; LevelManager$$EndCombineObjAnim
            i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
            i32.load
            call $j924
            local.set $l2
            local.get $l2
            f32.const 0x1.99999ap-5 (;=0.05;)
            f32.store offset=8
            local.get $p0
            local.get $l2
            i32.store offset=12
            local.get $p0
            i32.const 4
            i32.store offset=8
            br $B1
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
          i32.load
          call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
          local.get $p0
          i32.load offset=20
          i32.const 1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          local.get $p0
          call $j4698 ;; LevelObjectPool$$Recycle
          local.get $l2
          local.get $p0
          i32.load offset=28
          i32.const 0
          i32.const 0
          call $j5154 ;; LevelManager$$RefreshContentDisplay
          br $B1
        end
        local.get $l2
        i32.load offset=612
        i32.load offset=56
        local.set $l2
        local.get $l2
        f32.load offset=240
        local.set $l5
        local.get $l2
        f32.load offset=228
        local.get $l2
        f32.load offset=236
        f32.add
        local.get $l5
        f32.add
        local.set $l5
        local.get $p0
        f32.load offset=32
        local.set $l6
        i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
        i32.load
        call $j924
        local.set $l2
        local.get $l2
        local.get $l5
        local.get $l6
        f32.add
        f32.store offset=8
        local.get $p0
        local.get $l2
        i32.store offset=12
        local.get $p0
        i32.const 5
        i32.store offset=8
        i32.const 1
        local.set $l3
        br $B1
      end
      local.get $p0
      i32.const -1
      i32.store offset=8
      local.get $l2
      local.get $p0
      i32.load offset=20
      i32.const 1
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      i32.load
      call $j947
      local.get $p0
      i32.load offset=24
      local.get $p0
      i32.load offset=28
      i32.const 0
      call $j22251 ;; LevelManager$$EndCombineObjAnim
    end
    local.get $p1
    i32.const 80
    i32.add
    global.set $primary.global$0
    local.get $l3
    return)
