  (func $j49959 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    local.get $p2
    i32.load offset=28
    i32.eqz
    if $I0
      i32.const 3963888 ;; System.Type_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      local.get $p2
      i32.const 137639
      call_indirect $primary.table (type $t0)
    end
    local.get $p2
    i32.load offset=28
    i32.load
    local.set $p2
    i32.const 3963888 ;; System.Type_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    local.get $p2
    i32.const 0
    i32.const 918
    call_indirect $primary.table (type $t2)
    local.get $p1
    i32.const 0
    call $j24624) ;; Kunpo.AssetManager$$Release
