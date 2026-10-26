  (func $j10055 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I0
      local.get $p0
      i32.const 0
      i32.const 0
      call $j1184
    end)
