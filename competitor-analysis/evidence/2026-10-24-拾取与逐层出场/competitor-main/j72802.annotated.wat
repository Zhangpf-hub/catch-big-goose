  (func $j72802 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5127102
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 5127102
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p1
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j1022 ;; UnityEngine.Object$$op_Implicit
    if $I1
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.get $p0
      f32.load offset=12
      local.get $p0
      f32.load offset=16
      f32.const 0x1p+0 (;=1;)
      local.get $p0
      i32.load offset=20
      i32.load offset=56
      f32.load offset=200
      f32.sub
      f32.mul
      i32.const 0
      call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
      i32.const 1
      i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
      i32.load
      call $j1315
      local.set $p0
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=592
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      i32.load
      call $j1137
      drop
    end)
