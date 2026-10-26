  (func $j72927 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127070
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983680 ;; Method$System.Collections.Generic.Dictionary<string, bool>.Add()
      call $j922
      i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5127070
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=48
      local.get $p0
      i32.load offset=8
      i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
      i32.load
      call $j1040
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=48
      local.get $p0
      i32.load offset=8
      i32.const 1
      i32.const 3983680 ;; Method$System.Collections.Generic.Dictionary<string, bool>.Add()
      i32.load
      call $j23508
    end
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I2
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1184
    end)
