  (func $j71642 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 f32)
    i32.const 0
    local.set $p1
    block $B0
      block $B1
        block $B2
          block $B3
            local.get $p0
            i32.load offset=8
            br_table $B3 $B2 $B0
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          local.get $p0
          i32.const 0
          i32.store offset=24
          local.get $p0
          local.get $p0
          f32.load offset=16
          f32.store offset=20
          f32.const 0x0p+0 (;=0;)
          local.set $l2
          br $B1
        end
        local.get $p0
        i32.const -1
        i32.store offset=8
        local.get $p0
        f32.load offset=24
        local.set $l2
      end
      local.get $l2
      i32.const 0
      i32.const 7505
      call_indirect $primary.table (type $t20)
      f32.add
      local.set $l2
      local.get $p0
      local.get $l2
      f32.store offset=24
      local.get $l2
      local.get $p0
      f32.load offset=20
      f32.gt
      br_if $B0
      i32.const 0
      i32.const 0
      i32.const 55104
      call_indirect $primary.table (type $t2)
      br_if $B0
      local.get $p0
      i32.const 0
      i32.store offset=12
      i32.const 1
      local.set $p1
      local.get $p0
      i32.const 1
      i32.store offset=8
    end
    local.get $p1
    return)
