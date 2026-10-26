  (func $j14376 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139749
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 5139749
      i32.const 1
      i32.store8
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j6273 ;; ServerFileCreate$$GetFreeLevelCount
    local.set $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 1
    i32.add
    local.get $p0
    local.get $p0
    call $j21658 ;; NetDataManager$$get_TodayHasUpgradeMainLevel
    select
    return)
