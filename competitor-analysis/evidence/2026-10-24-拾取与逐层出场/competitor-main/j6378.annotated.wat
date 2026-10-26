  (func $j6378 (type $t25) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    i32.const 5127171
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
      call $j922
      i32.const 4039188 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 4056384 ;; Method$ObjectUnit.<>c__DisplayClass48_0.<BeClick>b__0()
      call $j922
      i32.const 4056388 ;; Method$ObjectUnit.<>c__DisplayClass48_0.<BeClick>b__1()
      call $j922
      i32.const 3970156 ;; ObjectUnit.<>c__DisplayClass48_0_TypeInfo
      call $j922
      i32.const 5127171
      i32.const 1
      i32.store8
    end
    i32.const 3970156 ;; ObjectUnit.<>c__DisplayClass48_0_TypeInfo
    i32.load
    call $j924
    local.set $p3
    local.get $p3
    local.get $p0
    i32.store offset=8
    local.get $p3
    local.get $p2
    f32.store offset=12
    block $B1
      local.get $p0
      i32.load8_u offset=16
      i32.eqz
      br_if $B1
      local.get $l5
      local.get $p0
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      call $j1418 ;; UnityEngine.Transform$$get_localScale
      local.get $p3
      local.get $l5
      f32.load
      f32.store offset=16
      local.get $p0
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      i32.const 0
      call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
      drop
      local.get $p0
      i32.const 1
      local.get $p0
      call $j7288 ;; ObjectUnit$$SetVisible
      local.get $p0
      i32.const 0
      i32.store8 offset=19
      local.get $p0
      i32.const 0
      i32.store8 offset=16
      local.get $p0
      i32.const 0
      local.get $p0
      call $j8794 ;; ObjectUnit$$SetRigid
      local.get $p0
      local.get $p0
      local.get $p0
      call $j41507 ;; ObjectUnit$$DelayToHideCol
      i32.const 0
      call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      drop
      block $B2
        block $B3
          local.get $p1
          i32.eqz
          br_if $B3
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j6451 ;; LevelManager$$CanUseNewAnim
          br_if $B3
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          local.set $p1
          i32.const 3959504 ;; UnityEngine.Object_TypeInfo
          i32.load
          call $j923
          block $B4
            local.get $p1
            i32.const 0
            call $j1022 ;; UnityEngine.Object$$op_Implicit
            i32.eqz
            br_if $B4
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.load8_u offset=584
            i32.eqz
            br_if $B4
            local.get $p0
            i32.const 0
            call $j979 ;; UnityEngine.Component$$get_transform
            local.set $p1
            local.get $p3
            f32.load offset=16
            local.set $p2
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            local.get $p1
            local.get $p2
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            f32.load offset=600
            f32.mul
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            f32.load offset=596
            i32.const 0
            call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
            i32.const 1
            i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
            i32.load
            call $j1315
            local.set $p1
            i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
            i32.load
            call $j924
            local.set $l4
            local.get $l4
            local.get $p3
            i32.const 4056384 ;; Method$ObjectUnit.<>c__DisplayClass48_0.<BeClick>b__0()
            i32.load
            i32.const 0
            call $j1241 ;; DG.Tweening.TweenCallback$$.ctor
            local.get $p1
            local.get $l4
            i32.const 4039188 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<TweenerCore<Vector3, Vector3, VectorOptions>>()
            i32.load
            call $j1424
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.load offset=588
            i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
            i32.load
            call $j1137
            drop
            br $B2
          end
          local.get $p0
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          local.get $p0
          f32.load offset=64
          local.get $p3
          f32.load offset=12
          i32.const 0
          call $j1473 ;; DG.Tweening.ShortcutExtensions$$DOScale
          i32.const 1
          i32.const 4039444 ;; Method$DG.Tweening.TweenSettingsExtensions.SetUpdate<TweenerCore<Vector3, Vector3, VectorOptions>>()
          i32.load
          call $j1315
          local.set $p1
          i32.const 3963844 ;; DG.Tweening.TweenCallback_TypeInfo
          i32.load
          call $j924
          local.set $l4
          local.get $l4
          local.get $p3
          i32.const 4056388 ;; Method$ObjectUnit.<>c__DisplayClass48_0.<BeClick>b__1()
          i32.load
          i32.const 0
          call $j1241 ;; DG.Tweening.TweenCallback$$.ctor
          local.get $p1
          local.get $l4
          i32.const 4039188 ;; Method$DG.Tweening.TweenSettingsExtensions.OnComplete<TweenerCore<Vector3, Vector3, VectorOptions>>()
          i32.load
          call $j1424
          drop
          br $B2
        end
        local.get $p0
        i32.const 1
        i32.store8 offset=93
      end
      local.get $p0
      i32.const 1
      local.get $p0
      call $j8795 ;; ObjectUnit$$PlayAnim
      local.get $p0
      i32.load offset=124
      local.set $p1
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      if $I5
        local.get $p0
        i32.load offset=124
        local.set $p1
        local.get $p1
        local.set $p3
        local.get $p1
        i32.load
        local.set $p1
        local.get $p3
        local.get $p1
        i32.load offset=248
        local.get $p1
        i32.load offset=244
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t0)
      end
      local.get $p0
      i32.load offset=136
      i32.eqz
      br_if $B1
      local.get $p0
      i32.const 0
      call $j961 ;; UnityEngine.Component$$get_gameObject
      i32.const 0
      call $j1428 ;; UnityEngine.GameObject$$get_activeInHierarchy
      i32.eqz
      br_if $B1
      local.get $p0
      local.get $p0
      i32.load offset=136
      i32.const 0
      call $j1739 ;; UnityEngine.MonoBehaviour$$StopCoroutine
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)
