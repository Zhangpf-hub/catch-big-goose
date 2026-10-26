  (func $j72800 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i64) (local $l10 f32) (local $l11 f32) (local $l12 f32) (local $l13 f32)
    global.get $primary.global$0
    i32.const 160
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127105
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003040 ;; Method$System.Collections.Generic.List<ObjectUnit>.Contains()
      call $j922
      i32.const 4003044 ;; Method$System.Collections.Generic.List<ObjectUnit>.IndexOf()
      call $j922
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      call $j922
      i32.const 4003444 ;; Method$System.Collections.Generic.List<PlateContentItem>.get_Item()
      call $j922
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
      call $j922
      i32.const 4039196 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<Tween>()
      call $j922
      i32.const 4039320 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<Tweener>()
      call $j922
      i32.const 4039324 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<Tweener>()
      call $j922
      i32.const 4039456 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<Tweener>()
      call $j922
      i32.const 4055004 ;; Method$LevelObjAnimManager.<>c.<ClickObj>b__15_18()
      call $j922
      i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
      call $j922
      i32.const 5127105
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=104
    local.set $l2
    local.get $l2
    if $I1
      local.get $l2
      i32.const 0
      i32.const 0
      call $j3141 ;; DG.Tweening.TweenExtensions$$Kill
    end
    local.get $p0
    i32.load offset=108
    local.set $l2
    local.get $l2
    if $I2
      local.get $l2
      i32.const 0
      i32.const 0
      call $j3141 ;; DG.Tweening.TweenExtensions$$Kill
    end
    local.get $p0
    i32.load offset=112
    local.set $l2
    local.get $l2
    if $I3
      local.get $l2
      i32.const 0
      i32.const 0
      call $j3141 ;; DG.Tweening.TweenExtensions$$Kill
    end
    local.get $p0
    i32.load offset=8
    local.set $l2
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $l2
    i32.const 0
    call $j1022 ;; UnityEngine.Object$$op_Implicit
    if $I4
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      i32.const 0
      call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
      drop
      block $B5
        local.get $p0
        i32.load offset=28
        local.get $p0
        i32.load offset=8
        i32.const 4003040 ;; Method$System.Collections.Generic.List<ObjectUnit>.Contains()
        i32.load
        call $j1262
        if $I6
          local.get $p0
          i32.load offset=28
          local.get $p0
          i32.load offset=8
          i32.const 4003044 ;; Method$System.Collections.Generic.List<ObjectUnit>.IndexOf()
          i32.load
          call $j1405
          local.set $l4
          br $B5
        end
        local.get $p0
        i32.load offset=32
        local.set $l4
      end
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.set $l2
      local.get $p1
      i32.const 128
      i32.add
      local.get $p0
      i32.load offset=48
      local.get $l4
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      i32.load
      call $j947
      i32.const 0
      call $j1062 ;; UnityEngine.Transform$$get_position
      local.get $p1
      i32.load offset=136
      local.set $l3
      local.get $p1
      local.get $l3
      i32.store offset=152
      local.get $p1
      local.get $l3
      i32.store offset=88
      local.get $p1
      i64.load offset=128
      local.set $l9
      local.get $p1
      local.get $l9
      i64.store offset=144
      local.get $p1
      local.get $l9
      i64.store offset=80
      local.get $l2
      local.get $p1
      i32.const 80
      i32.add
      i32.const 0
      call $j1289 ;; UnityEngine.Transform$$set_position
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.set $l2
      local.get $p1
      i32.const 128
      i32.add
      local.get $p0
      i32.load offset=48
      local.get $l4
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      i32.load
      call $j947
      i32.const 0
      call $j1748 ;; UnityEngine.Transform$$get_rotation
      local.get $p1
      i64.load offset=136
      local.set $l9
      local.get $p1
      local.get $l9
      i64.store offset=120
      local.get $p1
      local.get $l9
      i64.store offset=72
      local.get $p1
      i64.load offset=128
      local.set $l9
      local.get $p1
      local.get $l9
      i64.store offset=112
      local.get $p1
      local.get $l9
      i64.store offset=64
      local.get $l2
      local.get $p1
      i32.const -64
      i32.sub
      i32.const 0
      call $j2263 ;; UnityEngine.Transform$$set_rotation
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.set $l3
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
      local.get $l2
      f32.load offset=20
      local.set $l11
      local.get $p0
      f32.load offset=12
      local.set $l10
      local.get $l2
      f32.load offset=12
      local.get $l10
      f32.mul
      local.set $l12
      local.get $l2
      f32.load offset=16
      local.get $l10
      f32.mul
      local.set $l13
      local.get $p1
      local.get $l11
      local.get $l10
      f32.mul
      f32.store offset=104
      local.get $p1
      local.get $p1
      i32.load offset=104
      i32.store offset=56
      local.get $p1
      local.get $l13
      f32.store offset=100
      local.get $p1
      local.get $l12
      f32.store offset=96
      local.get $p1
      local.get $p1
      i64.load offset=96
      i64.store offset=48
      local.get $l3
      local.get $p1
      i32.const 48
      i32.add
      i32.const 0
      call $j1159 ;; UnityEngine.Transform$$set_localScale
      local.get $p0
      i32.load offset=20
      i32.load offset=56
      i32.load8_u offset=180
      local.set $l6
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.set $l3
      local.get $p0
      i32.load offset=20
      i32.load offset=56
      local.set $l5
      local.get $l5
      local.set $l2
      local.get $l2
      f32.load offset=164
      local.set $l10
      block $B8
        local.get $l6
        if $I9
          local.get $p1
          local.get $l2
          i32.load offset=160
          i32.store offset=40
          local.get $p1
          local.get $l2
          i32.load offset=152
          i64.extend_i32_u
          local.get $l2
          i32.load offset=156
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          i64.store offset=32
          local.get $l3
          local.get $p1
          i32.const 32
          i32.add
          local.get $l10
          i32.const 1
          f32.const 0x1p+0 (;=1;)
          i32.const 0
          i32.const 0
          call $j13758 ;; DG.Tweening.ShortcutExtensions$$DOPunchPosition
          i32.const 1
          i32.const 4039456 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<Tweener>()
          i32.load
          call $j1315
          local.get $p0
          i32.load offset=20
          i32.load offset=56
          i32.load offset=188
          i32.const 4039320 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<Tweener>()
          i32.load
          call $j6175
          local.set $l3
          br $B8
        end
        local.get $l5
        i32.load offset=176
        local.set $l5
        local.get $p1
        local.get $l2
        i32.load offset=160
        i32.store offset=24
        local.get $p1
        local.get $l2
        i32.load offset=152
        i64.extend_i32_u
        local.get $l2
        i32.load offset=156
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=16
        local.get $l3
        local.get $p1
        i32.const 16
        i32.add
        local.get $l10
        local.get $l5
        f32.const 0x1p+0 (;=1;)
        i32.const 0
        i32.const 0
        call $j13758 ;; DG.Tweening.ShortcutExtensions$$DOPunchPosition
        i32.const 1
        i32.const 4039456 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<Tweener>()
        i32.load
        call $j1315
        local.get $p0
        i32.load offset=20
        i32.load offset=56
        i32.load offset=184
        i32.const 4039324 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<Tweener>()
        i32.load
        call $j1137
        local.set $l3
      end
      local.get $p0
      i32.load offset=20
      i32.load offset=32
      local.get $l4
      i32.const 4003444 ;; Method$System.Collections.Generic.List<PlateContentItem>.get_Item()
      i32.load
      call $j947
      local.set $l4
      local.get $p0
      i32.load offset=20
      i32.load offset=56
      local.set $l2
      local.get $l2
      f32.load offset=172
      local.set $l10
      local.get $l2
      f32.load offset=168
      local.set $l11
      local.get $l2
      i32.load offset=176
      local.set $l5
      local.get $l2
      i32.load offset=188
      local.set $l6
      local.get $l2
      i32.load offset=184
      local.set $l7
      local.get $l2
      i32.load8_u offset=180
      local.set $l8
      local.get $l2
      f32.load offset=164
      local.set $l12
      local.get $p1
      local.get $l2
      i32.load offset=160
      i32.store offset=8
      local.get $p1
      local.get $l2
      i32.load offset=152
      i64.extend_i32_u
      local.get $l2
      i32.load offset=156
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      i64.store
      local.get $l4
      local.get $p1
      local.get $l12
      i32.const 1
      local.get $l8
      local.get $l7
      local.get $l6
      local.get $l5
      local.get $l11
      local.get $l10
      i32.const 0
      call $j40854 ;; PlateContentItem$$SetPunchAnim
      local.get $p0
      i32.load offset=20
      i32.load offset=52
      local.get $p0
      i32.load offset=8
      i32.const 4003040 ;; Method$System.Collections.Generic.List<ObjectUnit>.Contains()
      i32.load
      call $j1262
      if $I10
        local.get $p0
        i32.load offset=20
        i32.load offset=52
        local.get $p0
        i32.load offset=8
        i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
        i32.load
        call $j1387
        drop
      end
      i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.set $p0
      local.get $p0
      i32.eqz
      if $I11
        i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
        i32.load
        call $j923
        i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $l2
        i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p0
        local.get $l2
        i32.const 4055004 ;; Method$LevelObjAnimManager.<>c.<ClickObj>b__15_18()
        i32.load
        i32.const 0
        call $j1241 ;; DG.Tweening.TweenCallback$$.ctor
        i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p0
        i32.store offset=4
        i32.const 3969272 ;; LevelObjAnimManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        drop
      end
      local.get $l3
      local.get $p0
      i32.const 4039196 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<Tween>()
      i32.load
      call $j1424
      drop
    end
    local.get $p1
    i32.const 160
    i32.add
    global.set $primary.global$0)
