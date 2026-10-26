  (func $j43505 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140162
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3964172 ;; UIGamePage_TypeInfo
      call $j922
      i32.const 5140162
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load8_u offset=444
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load8_u offset=812
      i32.eqz
      br_if $B1
      local.get $p1
      i32.eqz
      if $I2
        local.get $p0
        local.get $p0
        call $j22247 ;; LevelManager$$GetNextSameObj
        local.set $p0
        i32.const 3964172 ;; UIGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 1
        local.get $p0
        i32.const 0
        call $j6988 ;; UIGamePage$$ShowHand
        return
      end
      local.get $p0
      i32.const 0
      i32.store8 offset=812
      i32.const 3964172 ;; UIGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 1
      i32.const 2
      i32.const 0
      call $j10034 ;; UIGamePage$$ShowFirstTeach
    end)
