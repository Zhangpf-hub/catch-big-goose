  (func $j21512 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127168
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4032312 ;; Method$ObjectUnit.<DelayToGrowScale>b__45_0()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
      call $j922
      i32.const 4039188 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 5127168
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $l3
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $l3
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load8_u offset=132
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load8_u offset=484
      br_if $B1
      local.get $p0
      i32.const 0
      i32.store8 offset=92
      local.get $p0
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      i32.const 0
      call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
      drop
      local.get $p0
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.set $l3
      i32.const 5158080
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5158080
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l2
      local.get $l2
      i32.load
      i64.extend_i32_u
      local.get $l2
      i32.load offset=4
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      local.set $l4
      local.get $p1
      local.get $l2
      i32.load offset=8
      i32.store offset=24
      local.get $p1
      local.get $p1
      i32.load offset=24
      i32.store offset=8
      local.get $p1
      local.get $l4
      i64.store offset=16
      local.get $p1
      local.get $p1
      i64.load offset=16
      i64.store
      local.get $l3
      local.get $p1
      i32.const 0
      call $j1159 ;; UnityEngine.Transform$$set_localScale
      local.get $p0
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      local.get $p0
      f32.load offset=128
      f32.const 0x1p+0 (;=1;)
      f32.mul
      f32.const 0x1.8p-1 (;=0.75;)
      i32.const 0
      call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
      local.set $l3
      i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      local.get $p0
      i32.const 4032312 ;; Method$ObjectUnit.<DelayToGrowScale>b__45_0()
      i32.load
      i32.const 0
      call $j1241 ;; DG.Tweening.TweenCallback$$.ctor
      local.get $l3
      local.get $l2
      i32.const 4039188 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<TweenerCore<Vector3, Vector3, VectorOptions>>()
      i32.load
      call $j1424
      drop
    end
    local.get $p1
    i32.const 32
    i32.add
    global.set $primary.global$0)
