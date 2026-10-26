  (func $j72485 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127156
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4063796 ;; 
      call $j922
      i32.const 5127156
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.eqz
    if $I1
      local.get $p0
      i32.load offset=16
      local.set $p0
      local.get $p0
      local.set $p1
      local.get $p0
      i32.load offset=60
      local.set $p2
      i32.const 4063796 ;; 
      i32.load
      local.set $p0
      local.get $p1
      i32.const 0
      local.get $p2
      i32.const 0
      local.get $p0
      local.get $p0
      i32.const 0
      call $j1571 ;; UIADAndShareBtn$$SetAD
    end)
