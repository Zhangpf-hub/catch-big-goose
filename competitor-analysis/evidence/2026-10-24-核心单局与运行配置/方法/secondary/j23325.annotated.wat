  (func $j23325 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139959
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957596 ;; int_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4123376 ;; 无该关{0}
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4123384 ;; 无该关卡 {0}
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139959
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    i32.const 0
    call $j7596 ;; ConfigManager$$GetEndlessLevelInfoData
    local.set $l2
    block $B1
      local.get $l2
      i32.eqz
      if $I2
        local.get $p1
        local.get $p0
        i32.store offset=12
        i32.const 0
        local.set $p0
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $p1
        i32.const 12
        i32.add
        i32.const 1282
        call_indirect $primary.table (type $t2)
        local.set $l2
        i32.const 4123376 ;; 无该关{0}
        i32.load
        local.get $l2
        i32.const 0
        i32.const 2370
        call_indirect $primary.table (type $t5)
        local.set $l2
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        local.get $l2
        i32.const 0
        i32.const 5662
        call_indirect $primary.table (type $t3)
        br $B1
      end
      local.get $l2
      i32.load offset=16
      local.set $l3
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 1
      local.set $p0
      local.get $l3
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.eq
      br_if $B1
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      local.get $p1
      i32.const 17668
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store8 offset=4
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      local.get $l2
      i32.load offset=16
      i32.store
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l3
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      local.get $l3
      i32.const 0
      i32.const 16984
      call_indirect $primary.table (type $t2)
      local.set $l3
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l4
      local.get $l3
      if $I3
        local.get $l4
        local.get $l3
        i32.store offset=20
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        drop
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l2
        i32.store offset=16
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        drop
        local.get $l2
        i32.load offset=24
        local.set $l2
        local.get $l2
        i32.const 2
        i32.le_u
        if $I4
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          local.get $l2
          i32.store offset=12
        end
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        local.get $p1
        i32.const 17659
        call_indirect $primary.table (type $t2)
        local.set $l2
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l2
        i32.store offset=8
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        drop
        br $B1
      end
      local.get $p1
      local.get $l4
      i32.load
      i32.store offset=8
      i32.const 0
      local.set $p0
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $p1
      i32.const 8
      i32.add
      i32.const 1282
      call_indirect $primary.table (type $t2)
      local.set $l2
      i32.const 4123384 ;; 无该关卡 {0}
      i32.load
      local.get $l2
      i32.const 0
      i32.const 2370
      call_indirect $primary.table (type $t5)
      local.set $l2
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      local.get $l2
      i32.const 0
      i32.const 5662
      call_indirect $primary.table (type $t3)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=20
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      drop
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=16
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)
