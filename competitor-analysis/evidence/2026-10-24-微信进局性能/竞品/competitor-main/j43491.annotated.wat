  (func $j43491 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127112
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983108 ;; Method$System.Collections.Generic.Dictionary<string, JObjectPool<ObjectUnit>>.GetEnumerator()
      call $j922
      i32.const 3992056 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, JObjectPool<ObjectUnit>>.Dispose()
      call $j922
      i32.const 3992060 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, JObjectPool<ObjectUnit>>.MoveNext()
      call $j922
      i32.const 3992064 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, JObjectPool<ObjectUnit>>.get_Current()
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3995992 ;; Method$JObjectPoolGroup<ObjectUnit>.get_ObjectPool()
      call $j922
      i32.const 3996012 ;; Method$JObjectPool<ObjectUnit>.get_Count()
      call $j922
      i32.const 3996744 ;; Method$System.Collections.Generic.KeyValuePair<string, JObjectPool<ObjectUnit>>.Deconstruct()
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3962528 ;; string_TypeInfo
      call $j922
      i32.const 4124528 ;; 清理了包括{0}的{1}件物品
      call $j922
      i32.const 5127112
      i32.const 1
      i32.store8
    end
    local.get $p1
    i64.const 0
    i64.store offset=72
    local.get $p1
    i32.const -64
    i32.sub
    local.set $l2
    local.get $l2
    i64.const 0
    i64.store
    local.get $p1
    i64.const 0
    i64.store offset=56
    local.get $p1
    i64.const 0
    i64.store offset=48
    local.get $p1
    i32.const 0
    i32.store offset=44
    local.get $p1
    i32.const 0
    i32.store offset=40
    i32.const 3962528 ;; string_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $l4
    i32.const 3995992 ;; Method$JObjectPoolGroup<ObjectUnit>.get_ObjectPool()
    i32.load
    drop
    local.get $p1
    i32.const 16
    i32.add
    local.get $p0
    i32.load offset=12
    i32.load offset=12
    i32.const 3983108 ;; Method$System.Collections.Generic.Dictionary<string, JObjectPool<ObjectUnit>>.GetEnumerator()
    i32.load
    call $j1250
    local.get $p1
    local.get $p1
    i64.load offset=32
    i64.store offset=72
    local.get $l2
    local.get $p1
    i64.load offset=24
    i64.store
    local.get $p1
    local.get $p1
    i64.load offset=16
    i64.store offset=56
    local.get $p1
    local.get $p1
    i32.const 56
    i32.add
    i32.store offset=8
    local.get $p1
    i32.const 0
    i32.store offset=16
    local.get $p1
    local.get $p1
    i32.load offset=8
    i32.store offset=20
    i32.const 0
    local.set $l2
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    loop $L9
                      block $B10
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 5069
                        local.get $p1
                        i32.const 56
                        i32.add
                        i32.const 3992060 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, JObjectPool<ObjectUnit>>.MoveNext()
                        i32.load
                        call $fimport$2
                        local.set $p0
                        i32.const 4610948
                        i32.load
                        local.set $l3
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $l3
                        i32.const 1
                        i32.eq
                        br_if $B10
                        local.get $p0
                        i32.eqz
                        br_if $B3
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 5070
                        local.get $p1
                        i32.const 8
                        i32.add
                        local.get $p1
                        i32.const 56
                        i32.add
                        i32.const 3992064 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, JObjectPool<ObjectUnit>>.get_Current()
                        i32.load
                        call $fimport$5
                        i32.const 4610948
                        i32.load
                        local.set $p0
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $p0
                        i32.const 1
                        i32.eq
                        br_if $B8
                        local.get $p1
                        local.get $p1
                        i64.load offset=8
                        i64.store offset=48
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 5071
                        local.get $p1
                        i32.const 48
                        i32.add
                        local.get $p1
                        i32.const 44
                        i32.add
                        local.get $p1
                        i32.const 40
                        i32.add
                        i32.const 3996744 ;; Method$System.Collections.Generic.KeyValuePair<string, JObjectPool<ObjectUnit>>.Deconstruct()
                        i32.load
                        call $fimport$13
                        i32.const 4610948
                        i32.load
                        local.set $p0
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $p0
                        i32.const 1
                        i32.eq
                        br_if $B7
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $p1
                        i32.load offset=44
                        local.set $l4
                        local.get $p1
                        i32.load offset=40
                        local.set $p0
                        i32.const 5072
                        local.get $p0
                        i32.const 3996012 ;; Method$JObjectPool<ObjectUnit>.get_Count()
                        i32.load
                        call $fimport$2
                        local.set $l3
                        i32.const 4610948
                        i32.load
                        local.set $l5
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $l5
                        i32.const 1
                        i32.eq
                        br_if $B6
                        local.get $l2
                        local.get $l3
                        i32.add
                        local.set $l2
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 945
                        i32.const 6
                        local.get $p0
                        call $fimport$12
                        i32.const 4610948
                        i32.load
                        local.set $p0
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        local.get $p0
                        i32.const 1
                        i32.ne
                        br_if $L9
                        br $B5
                      end
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $p0
                    br $B4
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p0
                  br $B4
                end
                i32.const 2539788
                call $fimport$0
                local.set $p0
                br $B4
              end
              i32.const 2539788
              call $fimport$0
              local.set $p0
              br $B4
            end
            i32.const 2539788
            call $fimport$0
            local.set $p0
          end
          call $fimport$1
          i32.const 2539788
          call $fimport$9
          i32.ne
          br_if $B1
          local.get $p1
          local.get $p0
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
          local.set $p0
          i32.const 4610948
          i32.const 0
          i32.store
          local.get $p0
          i32.const 1
          i32.eq
          br_if $B2
        end
        local.get $p1
        i32.const 16
        i32.add
        call $j8047
        drop
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j1600 ;; NetInitManager$$CanShowSEventDetail
        if $I11
          local.get $p1
          local.get $l2
          i32.store offset=16
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $p1
          i32.const 16
          i32.add
          call $j935
          local.set $p0
          i32.const 4124528 ;; 清理了包括{0}的{1}件物品
          i32.load
          local.get $l4
          local.get $p0
          i32.const 0
          call $j1060 ;; System.String$$Format
          i32.const 0
          call $j1441 ;; UnityEngine.MonoBehaviour$$print
        end
        local.get $p1
        i32.const 80
        i32.add
        global.set $primary.global$0
        return
      end
      call $fimport$4
      local.set $p0
      call $fimport$1
      drop
    end
    i32.const 4610948
    i32.const 0
    i32.store
    i32.const 5073
    local.get $p1
    i32.const 16
    i32.add
    call $fimport$3
    drop
    i32.const 4610948
    i32.load
    local.set $p1
    i32.const 4610948
    i32.const 0
    i32.store
    local.get $p1
    i32.const 1
    i32.ne
    if $I12
      local.get $p0
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
