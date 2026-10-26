  (func $j50924 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140271
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3983476 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.Add()
      call $j922
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      call $j922
      i32.const 3985724 ;; Method$System.Collections.Generic.Dictionary<string, string>..ctor()
      call $j922
      i32.const 3983472 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>..ctor()
      call $j922
      i32.const 3941680 ;; System.Collections.Generic.Dictionary<string, ABTestDataData>_TypeInfo
      call $j922
      i32.const 3942632 ;; System.Collections.Generic.Dictionary<string, string>_TypeInfo
      call $j922
      i32.const 5140271
      i32.const 1
      i32.store8
    end
    i32.const 3941680 ;; System.Collections.Generic.Dictionary<string, ABTestDataData>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3983472 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>..ctor()
    i32.load
    call $j967
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3942632 ;; System.Collections.Generic.Dictionary<string, string>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3985724 ;; Method$System.Collections.Generic.Dictionary<string, string>..ctor()
    i32.load
    call $j967
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=4
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    block $B1
      local.get $p0
      i32.eqz
      br_if $B1
      i32.const 0
      local.set $p1
      loop $L2
        local.get $p1
        local.get $p0
        i32.load offset=12
        i32.ge_s
        br_if $B1
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        call $j923
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.get $p0
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=8
        i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
        i32.load
        call $j1040
        i32.eqz
        if $I3
          i32.const 3951300 ;; ABTestManager_TypeInfo
          i32.load
          call $j923
          i32.const 3951300 ;; ABTestManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          local.get $p0
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=8
          local.get $p0
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.const 3983476 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.Add()
          i32.load
          call $j953
        end
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L2
      end
      unreachable
    end)
