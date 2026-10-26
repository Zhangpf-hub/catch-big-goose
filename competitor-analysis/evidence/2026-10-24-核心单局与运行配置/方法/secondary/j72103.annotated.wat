  (func $j72103 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140486
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939680 ;; System.Action<bool, SearchTeamInfoData>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4031364 ;; Method$NetInitManager.BulidJsonData<SearchTeamInfoData>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4055912 ;; Method$NetDataManager.<>c__DisplayClass89_0.<SearchTeamInfoData>b__2()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140486
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=16
    local.set $p2
    local.get $p2
    i32.eqz
    if $I1
      i32.const 3939680 ;; System.Action<bool, SearchTeamInfoData>_TypeInfo
      i32.load
      i32.const 137618
      call_indirect $primary.table (type $t1)
      local.set $p2
      local.get $p2
      local.get $p0
      i32.const 4055912 ;; Method$NetDataManager.<>c__DisplayClass89_0.<SearchTeamInfoData>b__2()
      i32.load
      i32.const 0
      i32.const 7570
      call_indirect $primary.table (type $t6)
      local.get $p0
      local.get $p2
      i32.store offset=16
    end
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p1
    local.get $p2
    i32.const 3
    i32.const 4031364 ;; Method$NetInitManager.BulidJsonData<SearchTeamInfoData>()
    i32.load
    i32.const 104758
    call_indirect $primary.table (type $t6))
