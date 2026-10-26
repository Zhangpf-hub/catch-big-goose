  (func $j50927 (type $t4) (param $p0 i32)
    i32.const 5140281
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3985744 ;; Method$System.Collections.Generic.Dictionary<string, string>.Clear()
      call $j922
      i32.const 5140281
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
    i32.const 3985744 ;; Method$System.Collections.Generic.Dictionary<string, string>.Clear()
    i32.load
    call $j1200
    i32.const 0
    call $j24955) ;; ABTestManager$$ShowABType
