  (func $j101298 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139974
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139974
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    i32.const 0
    call $j7596 ;; ConfigManager$$GetEndlessLevelInfoData
    i32.eqz
    if $I1
      i32.const 1
      return
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    i32.const 0
    call $j7596 ;; ConfigManager$$GetEndlessLevelInfoData
    i32.load offset=12
    i32.const 0
    call $j23928 ;; ConfigManager$$GetEndlessLevelChapterData
    i32.load offset=16
    return)
