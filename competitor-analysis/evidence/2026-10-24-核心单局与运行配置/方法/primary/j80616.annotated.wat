  (func $j80616 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140309
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4057832 ;; Method$ServerFileCreate.<>c__DisplayClass47_0.<GetCommonTimeAsyn>b__0()
      call $j922
      i32.const 3971028 ;; ServerFileCreate.<>c__DisplayClass47_0_TypeInfo
      call $j922
      i32.const 5140309
      i32.const 1
      i32.store8
    end
    i32.const 3971028 ;; ServerFileCreate.<>c__DisplayClass47_0_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p0
    i32.store offset=8
    local.get $p2
    local.get $p1
    i32.store offset=12
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p0
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      i32.const 0
      call $j980 ;; UnityEngine.Object$$op_Equality
      i32.eqz
      br_if $B1
      local.get $p2
      i32.load offset=12
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.const 0
      i32.const 0
      call $j2630
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    block $B2
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=20
      if $I3
        local.get $p2
        i32.load offset=8
        local.set $p0
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        local.get $l3
        i32.const 8
        i32.add
        local.get $p0
        local.get $p0
        call $j13782 ;; ServerFileCreate$$GetCommonTimeData
        local.get $p2
        i32.load offset=12
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B2
        local.get $p0
        local.get $l3
        i32.load offset=8
        i32.const 1
        i32.and
        local.get $l3
        i32.load offset=12
        call $j2630
        br $B2
      end
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $p2
      i32.const 4057832 ;; Method$ServerFileCreate.<>c__DisplayClass47_0.<GetCommonTimeAsyn>b__0()
      i32.load
      i32.const 0
      call $j969
      local.get $p0
      local.get $p1
      local.get $p2
      call $j13780 ;; ServerFileCreate$$LoadTimeDataFile
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0)
