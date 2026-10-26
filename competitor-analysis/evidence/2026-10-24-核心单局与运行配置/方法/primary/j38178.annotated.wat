  (func $j38178 (type $t78) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 i32) (result f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140315
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 5140315
      i32.const 1
      i32.store8
    end
    local.get $p3
    i32.const 0
    i32.store offset=12
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    local.get $p3
    local.get $p0
    local.get $p1
    local.get $p3
    call $j3816 ;; ServerFileCreate$$GetHotFixData
    local.get $p3
    local.get $p2
    f32.store offset=12
    local.get $p3
    i32.load offset=4
    local.set $p0
    block $B1
      local.get $p0
      if $I2
        i32.const 0
        local.set $p1
        local.get $p0
        i32.load offset=8
        br_if $B1
      end
      i32.const 1
      local.set $p1
    end
    local.get $p1
    i32.eqz
    if $I3
      local.get $p0
      local.get $p3
      i32.const 12
      i32.add
      i32.const 0
      call $j6264 ;; System.Single$$TryParse
      drop
      local.get $p3
      f32.load offset=12
      local.set $p2
    end
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p2
    return)
