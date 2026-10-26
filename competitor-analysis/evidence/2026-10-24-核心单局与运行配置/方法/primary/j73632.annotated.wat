  (func $j73632 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5127063
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 4024736 ;; Method$System.Linq.Enumerable.ToList<SubscribeStateData>()
      call $j922
      i32.const 3990380 ;; Method$System.Collections.Generic.List.Enumerator<SubscribeStateData>.Dispose()
      call $j922
      i32.const 3990384 ;; Method$System.Collections.Generic.List.Enumerator<SubscribeStateData>.MoveNext()
      call $j922
      i32.const 3990388 ;; Method$System.Collections.Generic.List.Enumerator<SubscribeStateData>.get_Current()
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 4005220 ;; Method$System.Collections.Generic.List<SubscribeStateData>.GetEnumerator()
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4123988 ;; 查询订阅成功
      call $j922
      i32.const 5127063
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=40
    local.get $p0
    i64.const 0
    i64.store offset=32
    local.get $p1
    i32.const 4024736 ;; Method$System.Linq.Enumerable.ToList<SubscribeStateData>()
    i32.load
    call $j1396
    local.set $p1
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=12
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    i32.const 4123988 ;; 查询订阅成功
    i32.load
    i32.const 0
    call $j1051 ;; UnityEngine.Debug$$Log
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        i32.const 0
        call $j1600 ;; NetInitManager$$CanShowSEventDetail
        if $I3
          i32.const 3959332 ;; NetworkHelper_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 16
          i32.add
          i32.const 3959332 ;; NetworkHelper_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 4005220 ;; Method$System.Collections.Generic.List<SubscribeStateData>.GetEnumerator()
          i32.load
          call $j1043
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
          block $B4
            block $B5
              block $B6
                block $B7
                  loop $L8
                    block $B9
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5066
                      local.get $p0
                      i32.const 32
                      i32.add
                      i32.const 3990384 ;; Method$System.Collections.Generic.List.Enumerator<SubscribeStateData>.MoveNext()
                      i32.load
                      call $fimport$2
                      local.set $p1
                      i32.const 4610948
                      i32.load
                      local.set $p2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p2
                      i32.const 1
                      i32.eq
                      br_if $B9
                      local.get $p1
                      i32.eqz
                      br_if $B4
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5067
                      local.get $p0
                      i32.const 32
                      i32.add
                      i32.const 3990388 ;; Method$System.Collections.Generic.List.Enumerator<SubscribeStateData>.get_Current()
                      i32.load
                      call $fimport$2
                      local.set $p1
                      i32.const 4610948
                      i32.load
                      local.set $p2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p2
                      i32.const 1
                      i32.eq
                      br_if $B7
                      local.get $p1
                      i32.load offset=12
                      local.set $p1
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p0
                      local.get $p1
                      i32.store offset=8
                      i32.const 1282
                      i32.const 3957596 ;; int_TypeInfo
                      i32.load
                      local.get $p0
                      i32.const 8
                      i32.add
                      call $fimport$2
                      local.set $p1
                      i32.const 4610948
                      i32.load
                      local.set $p2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p2
                      i32.const 1
                      i32.eq
                      br_if $B6
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 735
                      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                      i32.load
                      call $fimport$11
                      i32.const 4610948
                      i32.load
                      local.set $p2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p2
                      i32.const 1
                      i32.eq
                      br_if $B6
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 4983
                      local.get $p1
                      i32.const 0
                      call $fimport$12
                      i32.const 4610948
                      i32.load
                      local.set $p1
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $p1
                      i32.const 1
                      i32.ne
                      br_if $L8
                      br $B6
                    end
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p1
                  br $B5
                end
                i32.const 2539788
                call $fimport$0
                local.set $p1
                br $B5
              end
              i32.const 2539788
              call $fimport$0
              local.set $p1
            end
            call $fimport$1
            i32.const 2539788
            call $fimport$9
            i32.ne
            br_if $B1
            local.get $p0
            local.get $p1
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
            local.set $p1
            i32.const 4610948
            i32.const 0
            i32.store
            local.get $p1
            i32.const 1
            i32.eq
            br_if $B2
          end
          local.get $p0
          i32.const 16
          i32.add
          i32.const 5222
          global.set $__wasm_split_waitTableId
          i32.const 5222
          call_indirect $primary.table (type $t3)
          drop
        end
        local.get $p0
        i32.const 48
        i32.add
        global.set $primary.global$0
        return
      end
      call $fimport$4
      local.set $p1
      call $fimport$1
      drop
    end
    i32.const 4610948
    i32.const 0
    i32.store
    i32.const 5068
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
    if $I10
      local.get $p1
      call $fimport$10
      unreachable
    end
    i32.const 0
    call $fimport$0
    drop
    call $fimport$1
    drop
    call $j944
    unreachable)
