  (func $j89318 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 0
    local.set $p1
    i32.const 5126974
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      call $j922
      i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
      call $j922
      i32.const 3958172 ;; LoadManager_TypeInfo
      call $j922
      i32.const 3960348 ;; PrepareLoadMa_TypeInfo
      call $j922
      i32.const 5126974
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load offset=12
      local.set $l2
      local.get $l2
      i32.eqz
      br_if $B1
      loop $L2
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        local.get $p1
        local.get $l2
        i32.load offset=12
        i32.ge_s
        br_if $B1
        local.get $p0
        i32.load offset=12
        local.get $p1
        i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
        i32.load
        call $j947
        local.set $l2
        i32.const 3960348 ;; PrepareLoadMa_TypeInfo
        i32.load
        call $j923
        local.get $l2
        i32.const 0
        call $j14179 ;; PrepareLoadMa$$PreLoadTempObj
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        local.get $p0
        i32.load offset=12
        local.set $l2
        br $L2
      end
      unreachable
    end
    block $B3
      local.get $p0
      i32.load offset=16
      local.set $l2
      local.get $l2
      i32.eqz
      br_if $B3
      i32.const 0
      local.set $p1
      loop $L4
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        local.get $p1
        local.get $l2
        i32.load offset=12
        i32.ge_s
        br_if $B3
        local.get $p0
        i32.load offset=16
        local.get $p1
        i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
        i32.load
        call $j947
        local.set $l2
        i32.const 3958172 ;; LoadManager_TypeInfo
        i32.load
        call $j923
        local.get $l2
        i32.const 0
        call $j7364 ;; LoadManager$$LoadParticle
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        local.get $p0
        i32.load offset=16
        local.set $l2
        br $L4
      end
      unreachable
    end)
