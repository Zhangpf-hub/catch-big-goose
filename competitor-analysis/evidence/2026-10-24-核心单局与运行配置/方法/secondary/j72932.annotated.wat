  (func $j72932 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I0
      local.get $p0
      i32.const 0
      i32.const 0
      i32.const 10831
      call_indirect $primary.table (type $t4)
    end)
