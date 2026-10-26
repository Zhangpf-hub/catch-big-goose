  (func $j14617 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    i32.const 5140070
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4005752 ;; Method$System.Collections.Generic.List<Transform>.Add()
      call $j922
      i32.const 4005760 ;; Method$System.Collections.Generic.List<Transform>.Clear()
      call $j922
      i32.const 5140070
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 4005760 ;; Method$System.Collections.Generic.List<Transform>.Clear()
    i32.load
    call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
    i32.const 0
    local.set $p0
    loop $L1
      local.get $p2
      i32.const 0
      call $j1462 ;; UnityEngine.Transform$$get_childCount
      local.get $p0
      i32.gt_s
      if $I2
        local.get $p1
        local.get $p2
        local.get $p0
        i32.const 0
        call $j1321 ;; UnityEngine.Transform$$GetChild
        i32.const 4005752 ;; Method$System.Collections.Generic.List<Transform>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        local.get $p0
        i32.const 1
        i32.add
        local.set $p0
        br $L1
      end
    end)
