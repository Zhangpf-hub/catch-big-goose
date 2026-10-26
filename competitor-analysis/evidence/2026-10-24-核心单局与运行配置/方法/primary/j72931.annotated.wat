  (func $j72931 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    block $B0
      local.get $p1
      if $I1
        local.get $p0
        i32.load offset=8
        i32.const 1
        i32.sub
        local.set $p1
        local.get $p0
        local.get $p1
        i32.store offset=8
        local.get $p1
        i32.const 0
        i32.gt_s
        br_if $B0
        local.get $p0
        i32.load offset=12
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B0
        local.get $p0
        i32.const 1
        i32.const 0
        call $j1184
        return
      end
      local.get $p0
      i32.load offset=12
      local.set $p1
      local.get $p1
      if $I2
        local.get $p1
        i32.const 0
        i32.const 0
        call $j1184
      end
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      i32.store
    end)
