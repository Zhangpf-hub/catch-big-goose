  (func $j5154 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i64) (local $l10 i64) (local $l11 f32) (local $l12 f32) (local $l13 f32)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140113
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      call $j922
      i32.const 4039280 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Quaternion, Quaternion, NoOptions>>()
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4039420 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Quaternion, Quaternion, NoOptions>>()
      call $j922
      i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 5140113
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 1
    i32.eq
    local.set $l4
    local.get $p0
    i32.const 144
    i32.const 160
    local.get $l4
    select
    i32.add
    i32.load
    local.set $l7
    local.get $p0
    i32.const 148
    i32.const 164
    local.get $l4
    select
    i32.add
    i32.load
    local.set $l5
    i32.const 0
    local.set $l4
    loop $L1
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $l4
      local.get $l5
      i32.load offset=12
      i32.lt_s
      if $I2
        local.get $p0
        i32.load offset=84
        local.set $l6
        local.get $p3
        i32.const 48
        i32.add
        local.get $l7
        local.get $l4
        i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1062 ;; UnityEngine.Transform$$get_position
        local.get $p3
        i32.load offset=56
        local.set $l8
        local.get $p3
        local.get $l8
        i32.store offset=72
        local.get $p3
        local.get $l8
        i32.store offset=24
        local.get $p3
        i64.load offset=48
        local.set $l9
        local.get $p3
        local.get $l9
        i64.store offset=64
        local.get $p3
        local.get $l9
        i64.store offset=16
        local.get $p3
        i32.const 48
        i32.add
        local.get $l6
        local.get $p3
        i32.const 16
        i32.add
        i32.const 0
        call $j2911 ;; UnityEngine.Transform$$InverseTransformPoint
        local.get $p3
        f32.load offset=56
        local.set $l11
        local.get $p3
        f32.load offset=52
        local.set $l12
        local.get $p3
        f32.load offset=48
        local.set $l13
        local.get $l5
        local.get $l4
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l13
        local.get $p0
        f32.load offset=568
        i32.const 0
        i32.const 0
        call $j6267 ;; DG.Tweening.ShortcutExtensions$$DOLocalMoveX
        i32.const 1
        i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1315
        local.get $p0
        i32.load offset=572
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l5
        local.get $l4
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l12
        local.get $p0
        f32.load offset=568
        i32.const 0
        i32.const 0
        call $j20153 ;; DG.Tweening.ShortcutExtensions$$DOLocalMoveY
        i32.const 1
        i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1315
        local.get $p0
        i32.load offset=576
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l5
        local.get $l4
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l11
        local.get $p0
        f32.load offset=568
        i32.const 0
        i32.const 0
        call $j20152 ;; DG.Tweening.ShortcutExtensions$$DOLocalMoveZ
        i32.const 1
        i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1315
        local.get $p0
        i32.load offset=572
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l5
        local.get $l4
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.set $l6
        local.get $p3
        i32.const 48
        i32.add
        local.get $l7
        local.get $l4
        i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1748 ;; UnityEngine.Transform$$get_rotation
        local.get $p3
        i64.load offset=56
        local.set $l9
        local.get $p3
        local.get $l9
        i64.store offset=40
        local.get $p3
        i64.load offset=48
        local.set $l10
        local.get $p3
        local.get $l10
        i64.store offset=32
        local.get $p0
        f32.load offset=568
        local.set $l11
        local.get $p3
        local.get $l9
        i64.store offset=8
        local.get $p3
        local.get $l10
        i64.store
        local.get $l6
        local.get $p3
        local.get $l11
        i32.const 0
        call $j8540 ;; DG.Tweening.ShortcutExtensions$$DORotateQuaternion
        i32.const 1
        i32.const 4039420 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Quaternion, Quaternion, NoOptions>>()
        i32.load
        call $j1315
        local.get $p0
        i32.load offset=580
        i32.const 4039280 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Quaternion, Quaternion, NoOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l4
        i32.const 1
        i32.add
        local.set $l4
        br $L1
      end
    end
    local.get $p2
    if $I3
      local.get $p0
      local.get $p0
      local.get $p1
      local.get $p0
      f32.load offset=568
      local.get $p3
      call $j22253 ;; LevelManager$$DelayToCheckContent
      i32.const 0
      call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      drop
    end
    local.get $p3
    i32.const 80
    i32.add
    global.set $primary.global$0)
