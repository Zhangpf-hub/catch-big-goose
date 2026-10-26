  (func $j21666 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139758
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983424 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>..ctor()
      call $j922
      i32.const 3941672 ;; System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139758
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=40
    i32.eqz
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      i32.const 3941672 ;; System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      i32.const 3983424 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>..ctor()
      i32.load
      call $j967
      local.get $p0
      local.get $p1
      i32.store offset=40
    end)
