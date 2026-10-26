  (func $j101299 (type $t3) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5139975
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957596 ;; int_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4126060 ;; 该关卡 {0} 普通物品权重
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4126064 ;; 该关卡 {0} 的WinNameList:{1}有中文逗号
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4126056 ;; 该关卡 {0} OtherNameList:{1}有中文逗号
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4126068 ;; 该关卡 {0} 胜利物品数错误
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139975
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=20
    local.set $l2
    i32.const 0
    local.set $p1
    loop $L1
      local.get $l2
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I2
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=16
        local.set $l5
        i32.const 0
        local.set $p0
        loop $L3
          local.get $l5
          i32.load offset=12
          local.get $p0
          i32.gt_s
          if $I4
            local.get $l5
            local.get $p0
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $l4
            local.get $l4
            i32.const 65292
            i32.const 0
            call $j13624 ;; System.String$$Contains
            if $I5
              local.get $l3
              local.get $l2
              local.get $p1
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              i32.load offset=8
              i32.store offset=12
              i32.const 3957596 ;; int_TypeInfo
              i32.load
              local.get $l3
              i32.const 12
              i32.add
              i32.const 1282
              call_indirect $primary.table (type $t2)
              local.set $l6
              i32.const 4126064 ;; 该关卡 {0} 的WinNameList:{1}有中文逗号
              i32.load
              local.get $l6
              local.get $l4
              i32.const 0
              i32.const 3235
              call_indirect $primary.table (type $t8)
              local.set $l4
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              local.get $l4
              i32.const 0
              i32.const 5662
              call_indirect $primary.table (type $t3)
            end
            local.get $p0
            i32.const 1
            i32.add
            local.set $p0
            br $L3
          end
        end
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=28
        local.set $l5
        i32.const 0
        local.set $p0
        loop $L6
          local.get $l5
          i32.load offset=12
          local.get $p0
          i32.gt_s
          if $I7
            local.get $l5
            local.get $p0
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $l4
            local.get $l4
            i32.const 65292
            i32.const 0
            call $j13624 ;; System.String$$Contains
            if $I8
              local.get $l3
              local.get $l2
              local.get $p1
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              i32.load offset=8
              i32.store offset=12
              i32.const 3957596 ;; int_TypeInfo
              i32.load
              local.get $l3
              i32.const 12
              i32.add
              i32.const 1282
              call_indirect $primary.table (type $t2)
              local.set $l6
              i32.const 4126056 ;; 该关卡 {0} OtherNameList:{1}有中文逗号
              i32.load
              local.get $l6
              local.get $l4
              i32.const 0
              i32.const 3235
              call_indirect $primary.table (type $t8)
              local.set $l4
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              local.get $l4
              i32.const 0
              i32.const 5662
              call_indirect $primary.table (type $t3)
            end
            local.get $p0
            i32.const 1
            i32.add
            local.set $p0
            br $L6
          end
        end
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=16
        i32.load offset=12
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=20
        i32.load offset=12
        i32.ne
        if $I9
          local.get $l3
          local.get $l2
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=8
          i32.store offset=12
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $l3
          i32.const 12
          i32.add
          i32.const 1282
          call_indirect $primary.table (type $t2)
          local.set $p0
          i32.const 4126068 ;; 该关卡 {0} 胜利物品数错误
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
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=28
        i32.load offset=12
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=32
        i32.load offset=12
        i32.ne
        if $I10
          local.get $l3
          local.get $l2
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=8
          i32.store offset=12
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $l3
          i32.const 12
          i32.add
          i32.const 1282
          call_indirect $primary.table (type $t2)
          local.set $p0
          i32.const 4126060 ;; 该关卡 {0} 普通物品权重
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
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0)
