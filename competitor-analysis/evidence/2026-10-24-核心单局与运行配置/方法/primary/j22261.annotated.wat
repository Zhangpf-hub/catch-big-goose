  (func $j22261 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140050
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140050
      i32.const 1
      i32.store8
    end
    block $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=12
      br_if $B1
      local.get $p0
      i32.load8_u offset=56
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=36
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=5
      br_if $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=20
      i32.eqz
      return
    end
    i32.const 0
    return)
