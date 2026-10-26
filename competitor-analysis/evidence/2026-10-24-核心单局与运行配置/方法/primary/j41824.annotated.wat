  (func $j41824 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139740
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4055864 ;; Method$NetDataManager.<>c__DisplayClass38_0.<UploadWinData>b__0()
      call $j922
      i32.const 3969844 ;; NetDataManager.<>c__DisplayClass38_0_TypeInfo
      call $j922
      i32.const 5139740
      i32.const 1
      i32.store8
    end
    i32.const 3969844 ;; NetDataManager.<>c__DisplayClass38_0_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.store offset=8
    i32.const 3939040 ;; System.Action<bool>_TypeInfo
    i32.load
    call $j924
    local.set $p0
    local.get $p0
    local.get $p1
    i32.const 4055864 ;; Method$NetDataManager.<>c__DisplayClass38_0.<UploadWinData>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p1
    call $j4349) ;; NetDataManager$$UploadPlayerServerData
