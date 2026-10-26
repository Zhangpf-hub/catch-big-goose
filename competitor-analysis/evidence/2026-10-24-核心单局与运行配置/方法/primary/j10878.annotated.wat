  (func $j10878 (type $t122) (param $p0 i32) (param $p1 f32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 f32)
    block $B0
      local.get $p3
      i32.const 1
      i32.eq
      if $I1
        local.get $p0
        f32.load offset=264
        local.set $l5
        i32.const 1
        local.get $l5
        local.get $p1
        f32.gt
        local.get $p2
        select
        i32.eqz
        br_if $B0
        local.get $p2
        if $I2
          local.get $p0
          local.get $p1
          f32.store offset=264
          return
        end
        local.get $l5
        local.get $p0
        f32.load offset=440
        f32.sub
        local.set $l5
        local.get $p0
        local.get $l5
        local.get $p1
        local.get $p1
        local.get $l5
        f32.lt
        select
        f32.store offset=264
        return
      end
      local.get $p0
      f32.load offset=328
      local.set $l5
      i32.const 1
      local.get $l5
      local.get $p1
      f32.gt
      local.get $p2
      select
      i32.eqz
      br_if $B0
      local.get $p2
      if $I3
        local.get $p0
        local.get $p1
        f32.store offset=328
        return
      end
      local.get $l5
      local.get $p0
      f32.load offset=440
      f32.sub
      local.set $l5
      local.get $p0
      local.get $l5
      local.get $p1
      local.get $p1
      local.get $l5
      f32.lt
      select
      f32.store offset=328
    end)
