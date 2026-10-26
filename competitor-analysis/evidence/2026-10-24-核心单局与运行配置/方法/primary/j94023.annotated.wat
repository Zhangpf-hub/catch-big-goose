  (func $j94023 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140000
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 5140000
      i32.const 1
      i32.store8
    end
    i32.const 3955840 ;; GroupBattleManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j5748 ;; GroupBattleManager$$IsThisState
    if $I1
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      call $j923
      i32.const 3
      i32.const 0
      call $j44800 ;; GroupBattleManager$$AddObjCount
    end)
