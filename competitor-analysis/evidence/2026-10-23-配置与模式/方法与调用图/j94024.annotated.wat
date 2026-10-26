  (func $j94024 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139993
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 5139993
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 20
      i32.eq
      if $I2
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.eqz
        br_if $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 9
      i32.eq
      if $I3
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.eqz
        br_if $B1
      end
      i32.const 0
      return
    end
    i32.const 1
    return)
