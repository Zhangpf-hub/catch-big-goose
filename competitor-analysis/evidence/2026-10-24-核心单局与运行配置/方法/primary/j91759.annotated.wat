  (func $j91759 (type $t4) (param $p0 i32)
    i32.const 5139753
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5139753
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
    local.set $p0
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j2169 ;; LevelManager$$CleanAll
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j22257 ;; LevelManager$$CleanLastMainLevelMemory
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    call $j21662 ;; NetDataManager$$ResetDaliyData
    local.get $p0
    call $j21660 ;; NetDataManager$$SetLevelData
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 0
    call $j22260) ;; LevelManager$$ChangeLevelScene
