  (func $j11647 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    i32.const 5140274
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      call $j922
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      call $j922
      i32.const 3983488 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Count()
      call $j922
      i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
      call $j922
      i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 4119012 ;; {0}_{1}
      call $j922
      i32.const 4111716 ;; noABKey
      call $j922
      i32.const 5140274
      i32.const 1
      i32.store8
    end
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.eqz
      if $I2
        i32.const 4111716 ;; noABKey
        i32.load
        local.set $p0
        br $B1
      end
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3983488 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Count()
      i32.load
      drop
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p1
      local.get $p1
      i32.load offset=16
      local.get $p1
      i32.load offset=24
      i32.sub
      i32.const 0
      i32.le_s
      if $I3
        i32.const 4111716 ;; noABKey
        i32.load
        local.set $p0
        br $B1
      end
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.get $p0
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      i32.load
      call $j1040
      local.set $l2
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p1
      local.get $l2
      if $I4
        local.get $p1
        i32.load offset=4
        local.get $p0
        i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
        i32.load
        call $j1033
        local.set $p0
        br $B1
      end
      block $B5
        local.get $p1
        i32.load
        local.get $p0
        i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
        i32.load
        call $j1040
        i32.eqz
        br_if $B5
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        call $j923
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.get $p0
        i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
        i32.load
        call $j1033
        i32.load offset=12
        i32.const 1
        i32.ne
        if $I6
          i32.const 4111716 ;; noABKey
          i32.load
          local.set $p0
          br $B1
        end
        i32.const 5142650
        i32.load8_u
        i32.eqz
        if $I7
          i32.const 3952992 ;; CommonArchive_TypeInfo
          call $j922
          i32.const 5142650
          i32.const 1
          i32.store8
        end
        local.get $l4
        i32.const 3952992 ;; CommonArchive_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 0
        call $j48358 ;; CommonArchive$$GetRandomID
        i32.store offset=12
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $l4
        i32.const 12
        i32.add
        call $j935
        local.set $p1
        i32.const 4119012 ;; {0}_{1}
        i32.load
        local.get $p0
        local.get $p1
        i32.const 0
        call $j1060 ;; System.String$$Format
        local.set $p1
        local.get $p1
        local.set $l2
        local.get $p1
        i32.load
        local.set $p1
        local.get $l2
        local.get $p1
        i32.load offset=208
        local.get $p1
        i32.load offset=204
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t1)
        local.set $p1
        i32.const 5140479
        i32.load8_u
        i32.eqz
        if $I8
          i32.const 3958620 ;; System.Math_TypeInfo
          call $j922
          i32.const 5140479
          i32.const 1
          i32.store8
        end
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 31
        i32.shr_s
        local.set $l2
        local.get $p1
        local.get $l2
        i32.add
        local.get $l2
        i32.xor
        i32.const 100
        i32.rem_s
        i32.const 1
        i32.add
        local.set $l6
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        call $j923
        block $B9
          i32.const 3951300 ;; ABTestManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          local.get $p0
          i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
          i32.load
          call $j1033
          local.set $l2
          local.get $l2
          i32.load offset=16
          local.set $p1
          local.get $p1
          if $I10
            local.get $l2
            i32.load offset=20
            local.set $l5
            local.get $l5
            br_if $B9
          end
          i32.const 4111716 ;; noABKey
          i32.load
          local.set $p0
          br $B1
        end
        block $B11
          local.get $p1
          i32.load offset=12
          local.set $l3
          local.get $l3
          local.get $l5
          i32.load offset=12
          i32.eq
          if $I12
            i32.const 0
            local.set $p1
            i32.const 0
            local.set $l5
            br $B11
          end
          i32.const 4111716 ;; noABKey
          i32.load
          local.set $p0
          br $B1
        end
        loop $L13
          local.get $p1
          local.get $l3
          i32.ge_s
          br_if $B5
          block $B14
            local.get $l2
            i32.load offset=20
            local.get $p1
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $l3
            local.get $l3
            i32.const 1
            i32.lt_s
            br_if $B14
            local.get $l3
            local.get $l5
            i32.add
            local.set $l5
            local.get $l6
            local.get $l5
            i32.gt_s
            br_if $B14
            local.get $l2
            i32.load offset=16
            local.get $p1
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $l3
            i32.const 3951300 ;; ABTestManager_TypeInfo
            i32.load
            call $j923
            local.get $p0
            local.get $l3
            local.get $l4
            call $j24956 ;; ABTestManager$$SetFeature
            local.get $l2
            i32.load offset=16
            local.get $p1
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $p0
            br $B1
          end
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          local.get $l2
          i32.load offset=16
          i32.load offset=12
          local.set $l3
          br $L13
        end
        unreachable
      end
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 4111716 ;; noABKey
      i32.load
      local.get $l4
      call $j24956 ;; ABTestManager$$SetFeature
      i32.const 4111716 ;; noABKey
      i32.load
      local.set $p0
    end
    local.get $l4
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)
