  (func $j10880 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140076
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 5140076
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 7
      i32.ne
      br_if $B1
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      i32.const 0
      call $j971 ;; UnityEngine.Object$$op_Inequality
      i32.eqz
      br_if $B1
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=32
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end)
