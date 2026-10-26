  (func $j43542 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140161
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3964172 ;; UIGamePage_TypeInfo
      call $j922
      i32.const 5140161
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 1
    i32.store8 offset=444
    i32.const 3964172 ;; UIGamePage_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 1
    i32.const 1
    i32.const 0
    call $j10034 ;; UIGamePage$$ShowFirstTeach
    i32.const 3964172 ;; UIGamePage_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 1
    local.get $p0
    i32.load offset=152
    i32.const 0
    i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
    i32.load
    call $j947
    i32.const 0
    call $j979 ;; UnityEngine.Component$$get_transform
    i32.const 0
    call $j6988) ;; UIGamePage$$ShowHand
