  (func $j72895 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140500
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4028380 ;; Method$JsonHelper.GetArray<string>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4103920 ;; cards_tb
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140500
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I1
      local.get $p1
      i32.const 4103920 ;; cards_tb
      i32.load
      i32.const 4028380 ;; Method$JsonHelper.GetArray<string>()
      i32.load
      i32.const 142123
      call_indirect $primary.table (type $t5)
      local.set $p1
      local.get $p0
      i32.load offset=32
      local.get $p1
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      call_indirect $primary.table (type $t4)
    end)
