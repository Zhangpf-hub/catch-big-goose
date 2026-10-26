  (func $j72107 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5139828
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4055900 ;; Method$NetDataManager.<>c__DisplayClass88_0.<RefreshTeamInfoData>b__2()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139828
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=20
    local.set $p2
    local.get $p2
    i32.eqz
    if $I1
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      i32.const 137618
      call_indirect $primary.table (type $t1)
      local.set $p2
      local.get $p2
      local.get $p0
      i32.const 4055900 ;; Method$NetDataManager.<>c__DisplayClass88_0.<RefreshTeamInfoData>b__2()
      i32.load
      i32.const 0
      i32.const 9548
      call_indirect $primary.table (type $t6)
      local.get $p0
      local.get $p2
      i32.store offset=20
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p1
    local.get $p2
    local.get $p0
    i32.const 18552
    call_indirect $primary.table (type $t4))
