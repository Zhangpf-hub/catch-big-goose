  (func $j46543 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5139965
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957596 ;; int_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4121080 ;; 加载的id={0}
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4121084 ;; 加载的id不符{0}
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139965
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      local.get $p1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.eq
      if $I2
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p0
        i32.store8 offset=4
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=24
        local.set $l3
        local.get $l3
        if $I3
          local.get $l3
          local.get $p0
          i32.const 0
          i32.const 5294
          call_indirect $primary.table (type $t4)
        end
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store8 offset=28
        local.get $p2
        local.get $p1
        i32.store offset=12
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $p2
        i32.const 12
        i32.add
        i32.const 1282
        call_indirect $primary.table (type $t2)
        local.set $p0
        i32.const 2
        i32.const 4121080 ;; 加载的id={0}
        i32.load
        local.get $p0
        i32.const 0
        i32.const 2370
        call_indirect $primary.table (type $t5)
        i32.const 0
        i32.const 5839
        call_indirect $primary.table (type $t4)
        br $B1
      end
      local.get $p2
      local.get $p1
      i32.store offset=8
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $p2
      i32.const 8
      i32.add
      i32.const 1282
      call_indirect $primary.table (type $t2)
      local.set $p0
      i32.const 4121084 ;; 加载的id不符{0}
      i32.load
      local.get $p0
      i32.const 0
      i32.const 2370
      call_indirect $primary.table (type $t5)
      local.set $p0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      local.get $p0
      i32.const 0
      i32.const 5662
      call_indirect $primary.table (type $t3)
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
