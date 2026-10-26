  (func $j72111 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5139826
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139826
      i32.const 1
      i32.store8
    end
    local.get $p1
    if $I1
      local.get $p0
      i32.load8_u offset=8
      local.set $p1
      local.get $p0
      i32.load8_u offset=9
      local.set $p2
      local.get $p0
      i32.load8_u offset=16
      local.set $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $p2
      local.get $p1
      i32.const 0
      local.get $p0
      call $j7301 ;; NetDataManager$$AddGlobalLevelData
    end)
