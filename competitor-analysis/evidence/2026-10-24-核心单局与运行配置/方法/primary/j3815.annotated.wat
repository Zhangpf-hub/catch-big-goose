  (func $j3815 (type $t3) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i64) (local $l6 i64)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140307
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953832 ;; System.DateTime_TypeInfo
      call $j922
      i32.const 3983912 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.get_Values()
      call $j922
      i32.const 3992164 ;; Method$System.Collections.Generic.Dictionary.ValueCollection.Enumerator<string, CommonActiveDate>.Dispose()
      call $j922
      i32.const 3992168 ;; Method$System.Collections.Generic.Dictionary.ValueCollection.Enumerator<string, CommonActiveDate>.MoveNext()
      call $j922
      i32.const 3992172 ;; Method$System.Collections.Generic.Dictionary.ValueCollection.Enumerator<string, CommonActiveDate>.get_Current()
      call $j922
      i32.const 3999412 ;; Method$System.Collections.Generic.List<CommonActiveDate>.Add()
      call $j922
      i32.const 3999408 ;; Method$System.Collections.Generic.List<CommonActiveDate>..ctor()
      call $j922
      i32.const 3946584 ;; System.Collections.Generic.List<CommonActiveDate>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4015180 ;; Method$System.Collections.Generic.Dictionary.ValueCollection<string, CommonActiveDate>.GetEnumerator()
      call $j922
      i32.const 5140307
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=40
    local.get $p0
    i64.const 0
    i64.store offset=32
    i32.const 3946584 ;; System.Collections.Generic.List<CommonActiveDate>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    i32.const 3999408 ;; Method$System.Collections.Generic.List<CommonActiveDate>..ctor()
    i32.load
    call $j965
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i64.load offset=16
    local.set $l5
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 16
    i32.add
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=16
    i32.const 3983912 ;; Method$System.Collections.Generic.Dictionary<string, CommonActiveDate>.get_Values()
    i32.load
    call $j1526
    i32.const 4015180 ;; Method$System.Collections.Generic.Dictionary.ValueCollection<string, CommonActiveDate>.GetEnumerator()
    i32.load
    call $j1531
    local.get $p0
    local.get $p0
    i64.load offset=24
    i64.store offset=40
    local.get $p0
    local.get $p0
    i64.load offset=16
    i64.store offset=32
    local.get $p0
    local.get $p0
    i32.const 32
    i32.add
    i32.store offset=8
    local.get $p0
    i32.const 0
    i32.store offset=16
    local.get $p0
    local.get $p0
    i32.load offset=8
    i32.store offset=20
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    loop $L9
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 7467
                      local.get $p0
                      i32.const 32
                      i32.add
                      i32.const 3992168 ;; Method$System.Collections.Generic.Dictionary.ValueCollection.Enumerator<string, CommonActiveDate>.MoveNext()
                      i32.load
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
                      if $I10
                        i32.const 2539788
                        call $fimport$0
                        local.set $l1
                        br $B3
                      end
                      local.get $l1
                      i32.eqz
                      br_if $B2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 7468
                      local.get $p0
                      i32.const 32
                      i32.add
                      i32.const 3992172 ;; Method$System.Collections.Generic.Dictionary.ValueCollection.Enumerator<string, CommonActiveDate>.get_Current()
                      i32.load
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
                      br_if $B8
                      local.get $l1
                      i32.load offset=28
                      local.set $l2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 735
                      i32.const 3959332 ;; NetworkHelper_TypeInfo
                      i32.load
                      call $fimport$11
                      i32.const 4610948
                      i32.load
                      local.set $l4
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l4
                      i32.const 1
                      i32.eq
                      br_if $B7
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5240
                      local.get $l2
                      i32.const 0
                      call $j1430
                      local.set $l6
                      i32.const 4610948
                      i32.load
                      local.set $l2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l2
                      i32.const 1
                      i32.eq
                      br_if $B6
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 735
                      i32.const 3953832 ;; System.DateTime_TypeInfo
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
                      br_if $B5
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 1962
                      local.get $l5
                      local.get $l6
                      call $j2138
                      local.set $l2
                      i32.const 4610948
                      i32.load
                      local.set $l4
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l4
                      i32.const 1
                      i32.eq
                      br_if $B4
                      local.get $l2
                      i32.eqz
                      br_if $L9
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 7469
                      local.get $l3
                      local.get $l1
                      i32.const 3999412 ;; Method$System.Collections.Generic.List<CommonActiveDate>.Add()
                      i32.load
                      call $fimport$5
                      i32.const 4610948
                      i32.load
                      local.set $l1
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l1
                      i32.const 1
                      i32.ne
                      br_if $L9
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $l1
                    br $B3
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $l1
                  br $B3
                end
                i32.const 2539788
                call $fimport$0
                local.set $l1
                br $B3
              end
              i32.const 2539788
              call $fimport$0
              local.set $l1
              br $B3
            end
            i32.const 2539788
            call $fimport$0
            local.set $l1
            br $B3
          end
          i32.const 2539788
          call $fimport$0
          local.set $l1
        end
        call $fimport$1
        i32.const 2539788
        call $fimport$9
        i32.eq
        if $I11
          local.get $p0
          local.get $l1
          call $fimport$7
          i32.load
          i32.store offset=16
          i32.const 4610948
          i32.const 0
          i32.store
          i32.const 369
          call $fimport$6
          i32.const 4610948
          i32.load
          local.set $l1
          i32.const 4610948
          i32.const 0
          i32.store
          local.get $l1
          i32.const 1
          i32.ne
          br_if $B2
          call $fimport$4
          local.set $l1
          call $fimport$1
          drop
        end
        i32.const 4610948
        i32.const 0
        i32.store
        i32.const 7470
        local.get $p0
        i32.const 16
        i32.add
        call $fimport$3
        drop
        i32.const 4610948
        i32.load
        local.set $p0
        i32.const 4610948
        i32.const 0
        i32.store
        local.get $p0
        i32.const 1
        i32.ne
        br_if $B1
        i32.const 0
        call $fimport$0
        drop
        call $fimport$1
        drop
        call $j944
        unreachable
      end
      local.get $p0
      i32.const 16
      i32.add
      call $j28450
      drop
      local.get $p0
      i32.const 48
      i32.add
      global.set $primary.global$0
      local.get $l3
      return
    end
    local.get $l1
    call $fimport$10
    unreachable)
