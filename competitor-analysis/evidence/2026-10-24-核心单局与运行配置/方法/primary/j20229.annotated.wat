  (func $j20229 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140320
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4057844 ;; Method$ServerFileCreate.<>c__DisplayClass74_0.<GetServerFlagData>b__0()
      call $j922
      i32.const 4057848 ;; Method$ServerFileCreate.<>c__DisplayClass74_0.<GetServerFlagData>b__1()
      call $j922
      i32.const 3971040 ;; ServerFileCreate.<>c__DisplayClass74_0_TypeInfo
      call $j922
      i32.const 4113232 ;; prod
      call $j922
      i32.const 4105668 ;; dev
      call $j922
      i32.const 4108300 ;; https://cdn-zhuadae.lanfeitech.com/Server/{0}/ServerFlag.config
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140320
      i32.const 1
      i32.store8
    end
    i32.const 3971040 ;; ServerFileCreate.<>c__DisplayClass74_0_TypeInfo
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
    block $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=40
      if $I2
        local.get $p2
        i32.load offset=8
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.load offset=32
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=36
        local.get $p0
        i32.load offset=20
        local.get $p0
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t2)
        return
      end
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=41
      br_if $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 1
      i32.store8 offset=41
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 4108300 ;; https://cdn-zhuadae.lanfeitech.com/Server/{0}/ServerFlag.config
      i32.load
      i32.const 4113232 ;; prod
      i32.const 4105668 ;; dev
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=112
      i32.const 2
      i32.eq
      select
      i32.load
      i32.const 0
      call $j1006 ;; System.String$$Format
      local.set $p0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $p2
      i32.const 4057844 ;; Method$ServerFileCreate.<>c__DisplayClass74_0.<GetServerFlagData>b__0()
      i32.load
      i32.const 0
      call $j969
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      i32.load
      call $j924
      local.set $l3
      local.get $l3
      local.get $p2
      i32.const 4057848 ;; Method$ServerFileCreate.<>c__DisplayClass74_0.<GetServerFlagData>b__1()
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
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      i32.const 0
      call $j3469 ;; NetworkHelper$$GetServerFile
    end)
