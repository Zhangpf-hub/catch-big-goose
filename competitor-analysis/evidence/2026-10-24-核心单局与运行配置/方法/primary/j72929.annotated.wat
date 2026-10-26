  (func $j72929 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140495
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4028400 ;; Method$JsonHelper.GetVal<int>()
      call $j922
      i32.const 4115060 ;; sort_num
      call $j922
      i32.const 5140495
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I1
      local.get $p0
      local.get $p1
      i32.const 4115060 ;; sort_num
      i32.load
      i32.const 0
      i32.const 4028400 ;; Method$JsonHelper.GetVal<int>()
      i32.load
      call $j1117
      i32.const 0
      call $j1561
    end)
