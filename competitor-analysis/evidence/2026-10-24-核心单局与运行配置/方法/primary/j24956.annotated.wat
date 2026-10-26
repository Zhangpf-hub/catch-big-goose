  (func $j24956 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140276
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3985740 ;; Method$System.Collections.Generic.Dictionary<string, string>.Add()
      call $j922
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      call $j922
      i32.const 4071656 ;; AB测试分组 
      call $j922
      i32.const 4070568 ;; :
      call $j922
      i32.const 5140276
      i32.const 1
      i32.store8
    end
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    local.get $p0
    i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
    i32.load
    call $j1040
    i32.eqz
    if $I1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.get $p0
      local.get $p1
      i32.const 3985740 ;; Method$System.Collections.Generic.Dictionary<string, string>.Add()
      i32.load
      call $j953
    end
    i32.const 5
    i32.const 4071656 ;; AB测试分组 
    i32.load
    local.get $p0
    i32.const 4070568 ;; :
    i32.load
    local.get $p1
    i32.const 0
    call $j1151 ;; System.String$$Concat
    local.get $p0
    call $j1429 ;; GameManager$$LogInColor
    local.get $p0
    local.get $p1
    i32.const 0
    call $j35766) ;; ThinkingManager$$SetABTestFeature
