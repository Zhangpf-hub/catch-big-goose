  (func $j38174 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140322
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3950800 ;; string[]_TypeInfo
      call $j922
      i32.const 4057852 ;; Method$ServerFileCreate.<>c__DisplayClass79_0.<LoadABTestDataFile>b__0()
      call $j922
      i32.const 4057856 ;; Method$ServerFileCreate.<>c__DisplayClass79_0.<LoadABTestDataFile>b__1()
      call $j922
      i32.const 3971044 ;; ServerFileCreate.<>c__DisplayClass79_0_TypeInfo
      call $j922
      i32.const 4068428 ;; /
      call $j922
      i32.const 4125388 ;; 获取AB参数
      call $j922
      i32.const 4071644 ;; AB文件
      call $j922
      i32.const 5140322
      i32.const 1
      i32.store8
    end
    i32.const 3971044 ;; ServerFileCreate.<>c__DisplayClass79_0_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p1
    i32.store offset=8
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    i32.const 4125388 ;; 获取AB参数
    i32.load
    i32.const 0
    call $j1051 ;; UnityEngine.Debug$$Log
    i32.const 3950800 ;; string[]_TypeInfo
    i32.load
    i32.const 5
    call $j939
    local.set $p1
    local.get $p0
    i32.load offset=44
    local.set $l3
    local.get $p1
    local.get $l3
    call $j930
    local.get $p1
    local.get $l3
    i32.store offset=16
    local.get $p1
    i32.const 4068428 ;; /
    i32.load
    call $j930
    local.get $p1
    i32.const 4068428 ;; /
    i32.load
    i32.store offset=20
    local.get $p0
    i32.load offset=52
    local.set $l3
    local.get $p1
    local.get $l3
    call $j930
    local.get $p1
    local.get $l3
    i32.store offset=24
    local.get $p1
    i32.const 4068428 ;; /
    i32.load
    call $j930
    local.get $p1
    i32.const 4068428 ;; /
    i32.load
    i32.store offset=28
    local.get $p0
    i32.load offset=120
    local.set $p0
    local.get $p1
    local.get $p0
    call $j930
    local.get $p1
    local.get $p0
    i32.store offset=32
    local.get $p1
    i32.const 0
    call $j1167 ;; System.String$$Concat
    local.set $p0
    i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p2
    i32.const 4057852 ;; Method$ServerFileCreate.<>c__DisplayClass79_0.<LoadABTestDataFile>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3939460 ;; System.Action<string>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p2
    i32.const 4057856 ;; Method$ServerFileCreate.<>c__DisplayClass79_0.<LoadABTestDataFile>b__1()
    i32.load
    i32.const 0
    call $j969
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p1
    local.get $l3
    i32.const 3
    i32.const 4071644 ;; AB文件
    i32.load
    i32.const 0
    i32.const 0
    call $j3469) ;; NetworkHelper$$GetServerFile
