  (func $j95007 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5140183
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4099208 ;; VideoModeShakeForce
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140183
      i32.const 1
      i32.store8
    end
    local.get $p0
    local.get $p0
    i32.const 17778
    call_indirect $primary.table (type $t2)
    if $I1
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 4099208 ;; VideoModeShakeForce
      i32.load
      i32.const 0
      i32.const 16901
      call_indirect $primary.table (type $t16)
      drop
      local.get $p0
      f32.const 0x0p+0 (;=0;)
      local.get $p0
      i32.const 17886
      call_indirect $primary.table (type $t14)
    end)
