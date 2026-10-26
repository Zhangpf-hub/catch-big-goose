  (func $j108293 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5121043
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4018060 ;; Method$Kunpo.AssetManager.Release<SceneInstance>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3961572 ;; UnityEngine.SceneManagement.SceneManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4051412 ;; Method$Kunpo.AssetManager.<>c__DisplayClass33_0.<ReleaseScene>g__OnSceneUnloaded|0()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3967076 ;; Kunpo.AssetManager.<>c__DisplayClass33_0_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3949392 ;; UnityEngine.Events.UnityAction<Scene>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5121043
      i32.const 1
      i32.store8
    end
    i32.const 3967076 ;; Kunpo.AssetManager.<>c__DisplayClass33_0_TypeInfo
    i32.load
    i32.const 137618
    call_indirect $primary.table (type $t1)
    local.set $p2
    local.get $p2
    local.get $p1
    i32.store offset=8
    i32.const 3949392 ;; UnityEngine.Events.UnityAction<Scene>_TypeInfo
    i32.load
    i32.const 137618
    call_indirect $primary.table (type $t1)
    local.set $p1
    local.get $p1
    local.get $p2
    i32.const 4051412 ;; Method$Kunpo.AssetManager.<>c__DisplayClass33_0.<ReleaseScene>g__OnSceneUnloaded|0()
    i32.load
    i32.const 137855
    call_indirect $primary.table (type $t4)
    i32.const 3961572 ;; UnityEngine.SceneManagement.SceneManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p1
    i32.const 0
    i32.const 53440
    call_indirect $primary.table (type $t3)
    local.get $p0
    i32.const 4018060 ;; Method$Kunpo.AssetManager.Release<SceneInstance>()
    i32.load
    call $j49958)
