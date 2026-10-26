  (func $j38168 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    i32.const 5140305
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952988 ;; CommonActiveDate_TypeInfo
      call $j922
      i32.const 3953216 ;; System.Convert_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3983896 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.Add()
      call $j922
      i32.const 3983900 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.Clear()
      call $j922
      i32.const 3983904 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.ContainsKey()
      call $j922
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4122196 ;; 已转译时间文件
      call $j922
      i32.const 5140305
      i32.const 1
      i32.store8
    end
    local.get $l5
    i32.const 8
    i32.add
    local.set $l4
    local.get $l4
    i32.const 0
    i32.store offset=4
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.eqz
      br_if $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.load offset=12
      i32.eqz
      br_if $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      i32.const 3983900 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.Clear()
      i32.load
      call $j1200
      i32.const 0
      local.set $p0
      loop $L2
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        block $B3
          block $B4
            block $B5
              i32.const 3961880 ;; ServerFileCreate_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              i32.load offset=12
              local.get $p0
              i32.gt_s
              if $I6
                i32.const 3952988 ;; CommonActiveDate_TypeInfo
                i32.load
                call $j924
                local.set $l3
                local.get $l3
                local.get $p0
                call $j48366 ;; CommonActiveDate$$.ctor
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 735
                i32.const 3961880 ;; ServerFileCreate_TypeInfo
                i32.load
                call $fimport$11
                i32.const 4610948
                i32.load
                local.set $l1
                i32.const 4610948
                i32.const 0
                i32.store
                block $B7
                  local.get $l1
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l3
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=8
                  i32.store offset=8
                  local.get $l3
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=12
                  i32.store offset=12
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=16
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  block $B8
                    local.get $l1
                    if $I9
                      i32.const 0
                      local.set $l2
                      local.get $l1
                      i32.load offset=8
                      br_if $B8
                    end
                    i32.const 1
                    local.set $l2
                  end
                  local.get $l2
                  local.set $l1
                  i32.const 4610948
                  i32.load
                  local.set $l2
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l2
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l1
                  i32.eqz
                  if $I10
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=12
                    local.get $p0
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.load offset=16
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3953216 ;; System.Convert_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 6038
                    local.get $l1
                    i32.const 0
                    call $j1430
                    local.set $l6
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3959332 ;; NetworkHelper_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5686
                    local.get $l6
                    i32.const 0
                    call $j5991
                    local.set $l1
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    local.get $l3
                    local.get $l1
                    i32.store offset=16
                  end
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 735
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $fimport$11
                  i32.const 4610948
                  i32.load
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l1
                  i32.const 1
                  i32.eq
                  br_if $B7
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=20
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  block $B11
                    local.get $l1
                    if $I12
                      i32.const 0
                      local.set $l2
                      local.get $l1
                      i32.load offset=8
                      br_if $B11
                    end
                    i32.const 1
                    local.set $l2
                  end
                  local.get $l2
                  local.set $l1
                  i32.const 4610948
                  i32.load
                  local.set $l2
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l2
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l1
                  i32.eqz
                  if $I13
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=12
                    local.get $p0
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.load offset=20
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3953216 ;; System.Convert_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 6038
                    local.get $l1
                    i32.const 0
                    call $j1430
                    local.set $l6
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3959332 ;; NetworkHelper_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5686
                    local.get $l6
                    i32.const 0
                    call $j5991
                    local.set $l1
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    local.get $l3
                    local.get $l1
                    i32.store offset=20
                  end
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 735
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $fimport$11
                  i32.const 4610948
                  i32.load
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l1
                  i32.const 1
                  i32.eq
                  br_if $B7
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=24
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  block $B14
                    local.get $l1
                    if $I15
                      i32.const 0
                      local.set $l2
                      local.get $l1
                      i32.load offset=8
                      br_if $B14
                    end
                    i32.const 1
                    local.set $l2
                  end
                  local.get $l2
                  local.set $l1
                  i32.const 4610948
                  i32.load
                  local.set $l2
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l2
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l1
                  i32.eqz
                  if $I16
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=12
                    local.get $p0
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.load offset=24
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3953216 ;; System.Convert_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 6038
                    local.get $l1
                    i32.const 0
                    call $j1430
                    local.set $l6
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3959332 ;; NetworkHelper_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5686
                    local.get $l6
                    i32.const 0
                    call $j5991
                    local.set $l1
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    local.get $l3
                    local.get $l1
                    i32.store offset=24
                  end
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 735
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $fimport$11
                  i32.const 4610948
                  i32.load
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l1
                  i32.const 1
                  i32.eq
                  br_if $B7
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=28
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  block $B17
                    local.get $l1
                    if $I18
                      i32.const 0
                      local.set $l2
                      local.get $l1
                      i32.load offset=8
                      br_if $B17
                    end
                    i32.const 1
                    local.set $l2
                  end
                  local.get $l2
                  local.set $l1
                  i32.const 4610948
                  i32.load
                  local.set $l2
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l2
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l1
                  i32.eqz
                  if $I19
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 3961880 ;; ServerFileCreate_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=12
                    local.get $p0
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.load offset=28
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3953216 ;; System.Convert_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 6038
                    local.get $l1
                    i32.const 0
                    call $j1430
                    local.set $l6
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 735
                    i32.const 3959332 ;; NetworkHelper_TypeInfo
                    i32.load
                    call $fimport$11
                    i32.const 4610948
                    i32.load
                    local.set $l1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5686
                    local.get $l6
                    i32.const 0
                    call $j5991
                    local.set $l1
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B7
                    local.get $l3
                    local.get $l1
                    i32.store offset=28
                  end
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 735
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $fimport$11
                  i32.const 4610948
                  i32.load
                  local.set $l1
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l1
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $l3
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=32
                  i32.store offset=32
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=16
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=8
                  i32.const 3983904 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.ContainsKey()
                  i32.load
                  call $j1040
                  br_if $B3
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=16
                  i32.const 3961880 ;; ServerFileCreate_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=12
                  local.get $p0
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.load offset=8
                  local.get $l3
                  i32.const 3983896 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.Add()
                  i32.load
                  call $j953
                  br $B3
                end
                i32.const 2539788
                call $fimport$0
                local.set $l3
                call $fimport$1
                i32.const 2539788
                call $fimport$9
                i32.eq
                if $I20
                  local.get $l3
                  call $fimport$7
                  local.set $l3
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 704
                  i32.const 3959500 ;; object_TypeInfo
                  call $fimport$3
                  local.set $l1
                  i32.const 4610948
                  i32.load
                  local.set $l2
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  block $B21
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B21
                    local.get $l3
                    i32.load
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 705
                    local.get $l1
                    local.get $l2
                    call $fimport$2
                    local.set $l1
                    i32.const 4610948
                    i32.load
                    local.set $l2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l2
                    i32.const 1
                    i32.eq
                    br_if $B21
                    local.get $l1
                    if $I22
                      local.get $l4
                      i32.load offset=4
                      local.set $l1
                      local.get $l4
                      local.get $l1
                      i32.const 2
                      i32.shl
                      i32.add
                      local.get $l3
                      i32.load
                      i32.store
                      local.get $l4
                      local.get $l1
                      i32.const 1
                      i32.add
                      i32.store offset=4
                      call $fimport$15
                      local.get $l4
                      local.get $l4
                      i32.load offset=4
                      i32.const 1
                      i32.sub
                      i32.store offset=4
                      br $B3
                    end
                    i32.const 4
                    call $fimport$14
                    local.set $p0
                    local.get $p0
                    local.get $l3
                    i32.load
                    i32.store
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 706
                    local.get $p0
                    i32.const 2539788
                    i32.const 0
                    call $fimport$5
                    i32.const 4610948
                    i32.load
                    local.set $p0
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $p0
                    i32.const 1
                    i32.ne
                    br_if $B4
                  end
                  call $fimport$4
                  local.set $l3
                  call $fimport$1
                  drop
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 369
                  call $fimport$6
                  i32.const 4610948
                  i32.load
                  local.set $p0
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $p0
                  i32.const 1
                  i32.eq
                  br_if $B5
                end
                local.get $l3
                call $fimport$10
                unreachable
              end
              i32.const 4
              i32.const 4122196 ;; 已转译时间文件
              i32.load
              local.get $p0
              call $j1429 ;; GameManager$$LogInColor
              i32.const 3959304 ;; NetInitManager_TypeInfo
              i32.load
              call $j923
              i32.const 0
              call $j1600 ;; NetInitManager$$CanShowSEventDetail
              i32.eqz
              br_if $B1
              i32.const 3961880 ;; ServerFileCreate_TypeInfo
              i32.load
              call $j923
              i32.const 3961880 ;; ServerFileCreate_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=16
              local.set $p0
              i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
              i32.load
              call $j923
              local.get $p0
              i32.const 0
              call $j1163 ;; LitJson.JsonMapper$$ToJson
              local.set $p0
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              i32.load
              call $j923
              local.get $p0
              i32.const 0
              call $j1051 ;; UnityEngine.Debug$$Log
              br $B1
            end
            i32.const 0
            call $fimport$0
            drop
            call $fimport$1
            drop
            call $j944
          end
          unreachable
        end
        local.get $p0
        i32.const 1
        i32.add
        local.set $p0
        br $L2
      end
      unreachable
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)
