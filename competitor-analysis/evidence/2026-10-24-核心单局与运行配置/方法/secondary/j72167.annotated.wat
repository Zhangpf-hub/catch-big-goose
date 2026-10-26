  (func $j72167 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140340
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4125448 ;; 获取SeverFlag表失败: 
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140340
      i32.const 1
      i32.store8
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store8 offset=41
    i32.const 4125448 ;; 获取SeverFlag表失败: 
    i32.load
    local.get $p1
    i32.const 0
    i32.const 812
    call_indirect $primary.table (type $t5)
    local.set $p1
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p1
    i32.const 0
    i32.const 5660
    call_indirect $primary.table (type $t3)
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I1
      local.get $p0
      i32.load offset=32
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      call_indirect $primary.table (type $t3)
    end)
