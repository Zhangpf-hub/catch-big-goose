  (func $j14380 (type $t4) (param $p0 i32)
    i32.const 5139745
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3961176 ;; ReturnPlayerMa_TypeInfo
      call $j922
      i32.const 3964920 ;; ValueManager_TypeInfo
      call $j922
      i32.const 5139745
      i32.const 1
      i32.store8
    end
    i32.const 3961176 ;; ReturnPlayerMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j39590 ;; ReturnPlayerMa$$ChangeIsReturnPlayer
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j21663 ;; NetDataManager$$IsNextDay
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j21662 ;; NetDataManager$$ResetDaliyData
      i32.const 3964920 ;; ValueManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j32687 ;; ValueManager$$ResetDaliyLocalSave
    end)
