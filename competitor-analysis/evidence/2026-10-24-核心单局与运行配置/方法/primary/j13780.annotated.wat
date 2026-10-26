  (func $j13780 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140303
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
      i32.const 4057824 ;; Method$ServerFileCreate.<>c__DisplayClass39_0.<LoadTimeDataFile>b__0()
      call $j922
      i32.const 4057828 ;; Method$ServerFileCreate.<>c__DisplayClass39_0.<LoadTimeDataFile>b__1()
      call $j922
      i32.const 3971024 ;; ServerFileCreate.<>c__DisplayClass39_0_TypeInfo
      call $j922
      i32.const 4125656 ;; 获取时间文件
      call $j922
      i32.const 4123528 ;; 时间文件
      call $j922
      i32.const 5140303
      i32.const 1
      i32.store8
    end
    i32.const 3971024 ;; ServerFileCreate.<>c__DisplayClass39_0_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p1
    i32.store offset=8
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    i32.const 4125656 ;; 获取时间文件
    i32.load
    i32.const 0
    call $j1051 ;; UnityEngine.Debug$$Log
    local.get $p0
    i32.load offset=80
    local.get $p0
    i32.const 88
    i32.const 84
    local.get $p0
    i32.load8_u offset=76
    select
    i32.add
    i32.load
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.get $p0
    i32.load offset=92
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.set $p0
    i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p2
    i32.const 4057824 ;; Method$ServerFileCreate.<>c__DisplayClass39_0.<LoadTimeDataFile>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3939460 ;; System.Action<string>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p2
    i32.const 4057828 ;; Method$ServerFileCreate.<>c__DisplayClass39_0.<LoadTimeDataFile>b__1()
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
    i32.const 4123528 ;; 时间文件
    i32.load
    i32.const 0
    i32.const 0
    call $j3469) ;; NetworkHelper$$GetServerFile
