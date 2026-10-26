  (func $j23324 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5139962
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139962
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p1
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      local.get $p1
      i32.const 0
      i32.const 5062
      call_indirect $primary.table (type $t2)
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p0
      i32.const 20
      i32.const 1
      i32.const 0
      local.get $p1
      i32.const 17819
      call_indirect $primary.table (type $t11)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      i32.eqz
      br_if $B1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      i32.load offset=8
      i32.const 0
      call $j35838 ;; ThinkingManager$$EndlessLevelRestart
    end)
