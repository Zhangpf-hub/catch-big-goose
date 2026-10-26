  (func $j74028 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127088
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953004 ;; CommonValueType_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3964920 ;; ValueManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5127088
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    i32.store offset=12
    block $B1
      block $B2
        block $B3
          block $B4
            local.get $p0
            i32.load offset=8
            br_table $B4 $B3 $B1
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          local.get $p1
          i32.const 22
          i32.store offset=12
          i32.const 3953004 ;; CommonValueType_TypeInfo
          i32.load
          local.set $l2
          local.get $p1
          i32.const -1
          i32.store offset=4
          local.get $p1
          local.get $l2
          i32.store
          local.get $p1
          local.get $p1
          i32.load offset=12
          i32.store offset=8
          local.get $p1
          i32.const 0
          i32.const 1891
          call_indirect $primary.table (type $t2)
          local.set $l2
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          local.get $l2
          i32.const 0
          i32.const 5885
          call_indirect $primary.table (type $t2)
          local.set $l2
          i32.const 3964920 ;; ValueManager_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 22
          i32.const 0
          i32.const 26414
          call_indirect $primary.table (type $t2)
          local.get $l2
          i32.ge_s
          br_if $B1
          br $B2
        end
        local.get $p0
        i32.load offset=16
        local.set $l2
        local.get $p0
        i32.const -1
        i32.store offset=8
        i32.const 3955472 ;; GameManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=4
        i32.eqz
        br_if $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=36
        br_if $B2
        local.get $l2
        i32.const 0
        i32.const 17910
        call_indirect $primary.table (type $t3)
      end
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      i32.load
      i32.const 137618
      call_indirect $primary.table (type $t1)
      local.set $l2
      local.get $l2
      f32.const 0x1p+0 (;=1;)
      f32.store offset=8
      local.get $p0
      local.get $l2
      i32.store offset=12
      i32.const 1
      local.set $l3
      local.get $p0
      i32.const 1
      i32.store offset=8
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $l3
    return)
