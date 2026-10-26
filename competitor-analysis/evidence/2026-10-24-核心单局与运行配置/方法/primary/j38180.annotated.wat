  (func $j38180 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    i32.const 5140324
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939684 ;; System.Action<bool, string>_TypeInfo
      call $j922
      i32.const 3983360 ;; Method$System.Collections.Generic.Dictionary<string, List<string>>.TryGetValue()
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4057860 ;; Method$ServerFileCreate.<>c__DisplayClass83_0.<GetCDNLongText>b__0()
      call $j922
      i32.const 3971048 ;; ServerFileCreate.<>c__DisplayClass83_0_TypeInfo
      call $j922
      i32.const 4108276 ;; https://cdn-zhuadae.lanfeitech.com/LongTextFile/{0}/{1}.txt
      call $j922
      i32.const 4113232 ;; prod
      call $j922
      i32.const 4105668 ;; dev
      call $j922
      i32.const 4073644 ;; CDN文本 
      call $j922
      i32.const 5140324
      i32.const 1
      i32.store8
    end
    local.get $l5
    i32.const 0
    i32.store offset=12
    i32.const 3971048 ;; ServerFileCreate.<>c__DisplayClass83_0_TypeInfo
    i32.load
    call $j924
    local.set $p4
    local.get $p4
    local.get $p0
    i32.store offset=8
    local.get $p4
    local.get $p1
    i32.store offset=12
    local.get $p4
    local.get $p2
    i32.store offset=16
    local.get $p4
    local.get $p3
    i32.store offset=20
    block $B1
      local.get $p0
      i32.load offset=128
      local.get $p4
      i32.load offset=12
      local.get $l5
      i32.const 12
      i32.add
      i32.const 3983360 ;; Method$System.Collections.Generic.Dictionary<string, List<string>>.TryGetValue()
      i32.load
      call $j1052
      if $I2
        local.get $p4
        i32.load offset=16
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=32
        local.get $l5
        i32.load offset=12
        local.get $p0
        i32.load offset=20
        local.get $p0
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t2)
        br $B1
      end
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 4108276 ;; https://cdn-zhuadae.lanfeitech.com/LongTextFile/{0}/{1}.txt
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
      local.get $p4
      i32.load offset=12
      i32.const 0
      call $j1060 ;; System.String$$Format
      local.set $p0
      i32.const 3939684 ;; System.Action<bool, string>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $p4
      i32.const 4057860 ;; Method$ServerFileCreate.<>c__DisplayClass83_0.<GetCDNLongText>b__0()
      i32.load
      i32.const 0
      call $j1132
      i32.const 4073644 ;; CDN文本 
      i32.load
      local.get $p4
      i32.load offset=12
      i32.const 0
      call $j962 ;; System.String$$Concat
      local.set $p2
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $p1
      local.get $p2
      i32.const 0
      call $j41760 ;; NetworkHelper$$GetServerText
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)
