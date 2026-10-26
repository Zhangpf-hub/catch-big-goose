  (func $j72057 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140489
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 4031472 ;; Method$NetworkHelper.UploadEvent<JsonData>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4055916 ;; Method$NetDataManager.<>c__DisplayClass93_0.<UpSpGooseToTable>b__1()
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140489
      i32.const 1
      i32.store8
    end
    local.get $p1
    if $I1
      local.get $p0
      i32.load offset=8
      local.set $p2
      local.get $p0
      call $j19575 ;; NetUrls.Team$$get_AddUserSeasonScore
      local.set $l3
      local.get $p0
      i32.load offset=12
      local.set $p1
      local.get $p1
      i32.load offset=12
      local.set $p0
      local.get $p0
      i32.eqz
      if $I2
        i32.const 3951352 ;; System.Action_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p0
        local.get $p1
        i32.const 4055916 ;; Method$NetDataManager.<>c__DisplayClass93_0.<UpSpGooseToTable>b__1()
        i32.load
        i32.const 0
        call $j994 ;; System.Action$$.ctor
        local.get $p1
        local.get $p0
        i32.store offset=12
      end
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      local.get $p2
      local.get $l3
      local.get $p0
      i32.const 0
      i32.const 2
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      i32.const 4031472 ;; Method$NetworkHelper.UploadEvent<JsonData>()
      i32.load
      call $j2016
    end)
