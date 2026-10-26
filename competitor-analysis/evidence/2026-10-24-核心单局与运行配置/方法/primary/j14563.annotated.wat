  (func $j14563 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32)
    i32.const 0
    local.set $p1
    i32.const 5127152
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 5127152
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j4083 ;; LevelManager$$CanPlayLevel
    local.set $p0
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 0
    call $j1480 ;; NetInitManager$$UseVideoMode
    local.set $l2
    i32.const 3951296 ;; ABPackManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j3370 ;; ABPackManager$$IsUseEnergyRes
    local.set $l3
    block $B1
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $l2
      br_if $B1
      local.get $l3
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j5670 ;; NetDataManager$$CanStartFree
      i32.const 1
      i32.xor
      local.set $p1
    end
    local.get $p1
    return)
