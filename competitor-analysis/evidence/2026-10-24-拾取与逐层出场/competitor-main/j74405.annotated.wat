  (func $j74405 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 f32) (local $l5 f32) (local $l6 f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 0
    local.set $p1
    i32.const 5127107
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3958620 ;; System.Math_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
      call $j922
      i32.const 4124668 ;; 物体缺失
      call $j922
      i32.const 5127107
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=20
    local.set $l2
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                local.get $p0
                i32.load offset=8
                br_table $B6 $B5 $B4 $B3 $B2 $B1
              end
              local.get $p0
              i32.const -1
              i32.store offset=8
              local.get $p0
              f32.load offset=16
              local.set $l4
              local.get $l2
              i32.load offset=56
              f32.load offset=228
              local.set $l5
              i32.const 3958620 ;; System.Math_TypeInfo
              i32.load
              call $j923
              f32.const 0x0p+0 (;=0;)
              local.get $l4
              local.get $l5
              f32.add
              i32.const 0
              call $j1951 ;; System.Math$$Max
              local.set $l4
              i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
              i32.load
              call $j924
              local.set $p1
              local.get $p1
              local.set $l2
              local.get $l2
              i32.const -1082130432
              i32.store offset=12
              local.get $l2
              local.get $l4
              f32.store offset=8
              local.get $p0
              local.get $l2
              i32.store offset=12
              i32.const 1
              local.set $p1
              local.get $p0
              i32.const 1
              i32.store offset=8
              br $B1
            end
            local.get $p0
            i32.const -1
            i32.store offset=8
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $p0
            i32.load offset=24
            i32.load offset=12
            i32.const 2
            i32.le_s
            if $I7
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              i32.load
              call $j923
              i32.const 4124668 ;; 物体缺失
              i32.load
              i32.const 0
              call $j1050 ;; UnityEngine.Debug$$LogError
              br $B1
            end
            local.get $l3
            local.get $p0
            i32.load offset=24
            i32.const 1
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            i32.const 0
            call $j979 ;; UnityEngine.Component$$get_transform
            i32.const 0
            call $j1062 ;; UnityEngine.Transform$$get_position
            local.get $l2
            i32.load offset=56
            local.set $p1
            local.get $p1
            f32.load offset=252
            local.set $l4
            local.get $l3
            f32.load
            local.get $p1
            f32.load offset=244
            f32.add
            local.set $l5
            local.get $l3
            f32.load offset=4
            local.get $p1
            f32.load offset=248
            f32.add
            local.set $l6
            local.get $l3
            f32.load offset=8
            local.get $l4
            f32.add
            local.set $l4
            i32.const 0
            local.set $p1
            loop $L8
              i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
              i32.load
              drop
              local.get $p1
              local.get $p0
              i32.load offset=24
              i32.load offset=12
              i32.lt_s
              if $I9
                local.get $p0
                i32.load offset=24
                local.get $p1
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
                i32.load offset=24
                local.get $p1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.get $l6
                local.get $l2
                i32.load offset=56
                f32.load offset=236
                i32.const 0
                i32.const 0
                call $j8541 ;; DG.Tweening.ShortcutExtensions$$DOMoveY
                i32.const 1
                i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1315
                local.get $l2
                i32.load offset=56
                i32.load offset=256
                i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1137
                drop
                local.get $p0
                i32.load offset=24
                local.get $p1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.get $l4
                local.get $l2
                i32.load offset=56
                f32.load offset=236
                i32.const 0
                i32.const 0
                call $j20151 ;; DG.Tweening.ShortcutExtensions$$DOMoveZ
                i32.const 1
                i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1315
                local.get $l2
                i32.load offset=56
                i32.load offset=256
                i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1137
                drop
                local.get $p0
                i32.load offset=24
                local.get $p1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.get $l5
                local.get $l2
                i32.load offset=56
                f32.load offset=236
                i32.const 0
                i32.const 0
                call $j5575 ;; DG.Tweening.ShortcutExtensions$$DOMoveX
                i32.const 1
                i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1315
                local.get $l2
                i32.load offset=56
                i32.load offset=260
                i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1137
                drop
                local.get $p0
                i32.load offset=24
                local.get $p1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.const 0
                call $j979 ;; UnityEngine.Component$$get_transform
                local.get $l2
                i32.load offset=56
                f32.load offset=264
                local.get $p0
                i32.load offset=24
                local.get $p1
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                f32.load offset=64
                f32.mul
                local.get $l2
                i32.load offset=56
                f32.load offset=236
                i32.const 0
                call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
                i32.const 1
                i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1315
                local.get $l2
                i32.load offset=56
                i32.load offset=272
                i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
                i32.load
                call $j1137
                drop
                local.get $p1
                i32.const 1
                i32.add
                local.set $p1
                br $L8
              end
            end
            local.get $l2
            i32.load offset=56
            f32.load offset=236
            local.set $l4
            i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
            i32.load
            call $j924
            local.set $p1
            local.get $p1
            local.set $l2
            local.get $l2
            i32.const -1082130432
            i32.store offset=12
            local.get $l2
            local.get $l4
            f32.store offset=8
            local.get $p0
            local.get $l2
            i32.store offset=12
            local.get $p0
            i32.const 2
            i32.store offset=8
            i32.const 1
            local.set $p1
            br $B1
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          loop $L10
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $p1
            local.get $p0
            i32.load offset=24
            i32.load offset=12
            i32.lt_s
            if $I11
              local.get $p0
              i32.load offset=24
              local.get $p1
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              i32.const 0
              i32.const 0
              call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
              drop
              local.get $p1
              i32.const 1
              i32.add
              local.set $p1
              br $L10
            end
          end
          i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
          i32.load
          call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
          local.get $p0
          i32.load offset=24
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
          i32.load offset=24
          i32.const 2
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          local.get $p0
          call $j4698 ;; LevelObjectPool$$Recycle
          i32.const 1
          local.set $p1
          local.get $p0
          i32.load offset=24
          i32.const 1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          local.get $l2
          i32.load offset=56
          f32.load offset=268
          local.get $p0
          i32.load offset=24
          i32.const 1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          f32.load offset=64
          f32.mul
          local.get $l2
          i32.load offset=56
          f32.load offset=240
          i32.const 0
          call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
          i32.const 1
          i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
          i32.load
          call $j1315
          local.get $l2
          i32.load offset=56
          i32.load offset=276
          i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
          i32.load
          call $j1137
          drop
          local.get $l2
          i32.load offset=56
          f32.load offset=240
          local.set $l4
          i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
          i32.load
          call $j924
          local.set $l2
          local.get $l2
          i32.const -1082130432
          i32.store offset=12
          local.get $l2
          local.get $l4
          f32.store offset=8
          local.get $p0
          local.get $l2
          i32.store offset=12
          local.get $p0
          i32.const 3
          i32.store offset=8
          br $B1
        end
        local.get $p0
        i32.const -1
        i32.store offset=8
        i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
        i32.load
        call $j924
        local.set $p1
        local.get $p1
        local.set $l2
        local.get $l2
        i32.const -1082130432
        i32.store offset=12
        local.get $l2
        f32.const 0x1.99999ap-5 (;=0.05;)
        f32.store offset=8
        local.get $p0
        local.get $l2
        i32.store offset=12
        local.get $p0
        i32.const 4
        i32.store offset=8
        i32.const 1
        local.set $p1
        br $B1
      end
      local.get $p0
      i32.const -1
      i32.store offset=8
      local.get $p0
      i32.load offset=24
      i32.const 1
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      i32.load
      call $j947
      local.set $l2
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=24
      i32.const 1
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
      i32.load offset=24
      i32.const 1
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      i32.load
      call $j947
      local.get $p0
      call $j4698 ;; LevelObjectPool$$Recycle
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p1
    return)
