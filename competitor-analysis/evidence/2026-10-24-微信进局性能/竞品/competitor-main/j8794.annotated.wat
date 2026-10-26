  (func $j8794 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127166
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5127166
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      if $I2
        local.get $p0
        i32.load8_u offset=18
        br_if $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 2
      i32.eq
      i32.const 0
      local.get $p1
      select
      br_if $B1
      local.get $p1
      local.get $p1
      call $j21509 ;; ObjectUnit$$IsLockGuidePhysic
      i32.const 0
      local.get $p1
      select
      br_if $B1
      local.get $p0
      i32.load offset=20
      local.get $p1
      i32.const 1
      i32.xor
      i32.const 0
      call $j5617 ;; UnityEngine.Rigidbody$$set_isKinematic
    end)
