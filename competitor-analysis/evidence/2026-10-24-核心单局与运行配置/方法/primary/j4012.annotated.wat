  (func $j4012 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139644
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5139644
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 20
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.load offset=384
    call $j951
    return)
