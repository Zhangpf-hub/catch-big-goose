  (func $j37553 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139657
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3979504 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.ContainsKey()
      call $j922
      i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
      call $j922
      i32.const 3988452 ;; Method$System.Collections.Generic.HashSet.Enumerator<ValueTuple<string, int>>.Dispose()
      call $j922
      i32.const 3988456 ;; Method$System.Collections.Generic.HashSet.Enumerator<ValueTuple<string, int>>.MoveNext()
      call $j922
      i32.const 3988460 ;; Method$System.Collections.Generic.HashSet.Enumerator<ValueTuple<string, int>>.get_Current()
      call $j922
      i32.const 3994004 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.GetEnumerator()
      call $j922
      i32.const 3994012 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.get_Count()
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4120684 ;; 关物品
      call $j922
      i32.const 4124500 ;; 清理
      call $j922
      i32.const 5139657
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 0
    i32.store offset=56
    local.get $p0
    i64.const 0
    i64.store offset=48
    local.get $p0
    i64.const 0
    i64.store offset=40
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        block $B3
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=36
          i32.eqz
          br_if $B3
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3994012 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.get_Count()
          i32.load
          drop
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=36
          i32.load offset=16
          i32.eqz
          br_if $B3
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 16
          i32.add
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=36
          i32.const 3994004 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.GetEnumerator()
          i32.load
          call $j2056
          local.get $p0
          local.get $p0
          i32.load offset=32
          i32.store offset=56
          local.get $p0
          local.get $p0
          i64.load offset=24
          i64.store offset=48
          local.get $p0
          local.get $p0
          i64.load offset=16
          i64.store offset=40
          local.get $p0
          local.get $p0
          i32.const 40
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
                  block $B8
                    block $B9
                      block $B10
                        block $B11
                          loop $L12
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            i32.const 7403
                            local.get $p0
                            i32.const 40
                            i32.add
                            i32.const 3988456 ;; Method$System.Collections.Generic.HashSet.Enumerator<ValueTuple<string, int>>.MoveNext()
                            i32.load
                            call $fimport$2
                            local.set $l1
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
                            local.get $l1
                            i32.eqz
                            br_if $B4
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            i32.const 7404
                            local.get $p0
                            i32.const 8
                            i32.add
                            local.get $p0
                            i32.const 40
                            i32.add
                            i32.const 3988460 ;; Method$System.Collections.Generic.HashSet.Enumerator<ValueTuple<string, int>>.get_Current()
                            i32.load
                            call $fimport$5
                            i32.const 4610948
                            i32.load
                            local.set $l1
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            block $B13
                              block $B14
                                local.get $l1
                                i32.const 1
                                i32.ne
                                if $I15
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $p0
                                  i32.load offset=12
                                  local.set $l5
                                  local.get $p0
                                  i32.load offset=8
                                  local.set $l4
                                  i32.const 735
                                  i32.const 3953096 ;; ConfigManager_TypeInfo
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
                                  br_if $B14
                                  i32.const 0
                                  local.set $l1
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 7398
                                  local.get $l5
                                  local.get $l4
                                  i32.const 0
                                  call $fimport$8
                                  local.set $l5
                                  i32.const 4610948
                                  i32.load
                                  local.set $l2
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l2
                                  i32.const 1
                                  i32.ne
                                  br_if $B13
                                  i32.const 2539788
                                  call $fimport$0
                                  local.set $l1
                                  br $B5
                                end
                                i32.const 2539788
                                call $fimport$0
                                local.set $l1
                                br $B5
                              end
                              i32.const 2539788
                              call $fimport$0
                              local.set $l1
                              br $B5
                            end
                            loop $L16
                              local.get $l1
                              i32.const 5
                              i32.ge_s
                              br_if $L12
                              i32.const 4610948
                              i32.const 0
                              i32.store
                              i32.const 7399
                              local.get $l5
                              local.get $l1
                              i32.const 3979504 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.ContainsKey()
                              i32.load
                              call $fimport$8
                              local.set $l2
                              i32.const 4610948
                              i32.load
                              local.set $l3
                              i32.const 4610948
                              i32.const 0
                              i32.store
                              local.get $l3
                              i32.const 1
                              i32.eq
                              br_if $B6
                              block $B17
                                local.get $l2
                                if $I18
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 964
                                  i32.const 4124500 ;; 清理
                                  i32.load
                                  local.get $l4
                                  i32.const 4120684 ;; 关物品
                                  i32.load
                                  i32.const 0
                                  call $fimport$16
                                  local.set $l2
                                  i32.const 4610948
                                  i32.load
                                  local.set $l3
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l3
                                  i32.const 1
                                  i32.eq
                                  br_if $B17
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 7400
                                  local.get $l2
                                  i32.const 0
                                  call $fimport$12
                                  i32.const 4610948
                                  i32.load
                                  local.set $l2
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l2
                                  i32.const 1
                                  i32.eq
                                  br_if $B17
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 5413
                                  i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
                                  i32.load
                                  call $fimport$3
                                  local.set $l2
                                  i32.const 4610948
                                  i32.load
                                  local.set $l3
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l3
                                  i32.const 1
                                  i32.eq
                                  br_if $B11
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 7401
                                  local.get $l5
                                  local.get $l1
                                  i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                                  i32.load
                                  call $fimport$8
                                  local.set $l3
                                  i32.const 4610948
                                  i32.load
                                  local.set $l6
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l6
                                  i32.const 1
                                  i32.eq
                                  br_if $B10
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 5412
                                  local.get $l3
                                  i32.const 0
                                  i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                                  i32.load
                                  call $fimport$8
                                  local.set $l3
                                  i32.const 4610948
                                  i32.load
                                  local.set $l6
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  local.get $l6
                                  i32.const 1
                                  i32.eq
                                  br_if $B9
                                  local.get $l3
                                  i32.load offset=24
                                  local.set $l3
                                  i32.const 4610948
                                  i32.const 0
                                  i32.store
                                  i32.const 5414
                                  local.get $l2
                                  local.get $l3
                                  i32.const 0
                                  call $fimport$5
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
                                end
                                local.get $l1
                                i32.const 1
                                i32.add
                                local.set $l1
                                br $L16
                              end
                            end
                          end
                          i32.const 2539788
                          call $fimport$0
                          local.set $l1
                          br $B5
                        end
                        i32.const 2539788
                        call $fimport$0
                        local.set $l1
                        br $B5
                      end
                      i32.const 2539788
                      call $fimport$0
                      local.set $l1
                      br $B5
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $l1
                    br $B5
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $l1
                  br $B5
                end
                i32.const 2539788
                call $fimport$0
                local.set $l1
                br $B5
              end
              i32.const 2539788
              call $fimport$0
              local.set $l1
            end
            call $fimport$1
            i32.const 2539788
            call $fimport$9
            i32.ne
            br_if $B1
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
            i32.eq
            br_if $B2
          end
          local.get $p0
          i32.const 16
          i32.add
          call $j28433
          drop
        end
        local.get $p0
        i32.const -64
        i32.sub
        global.set $primary.global$0
        return
      end
      call $fimport$4
      local.set $l1
      call $fimport$1
      drop
    end
    i32.const 4610948
    i32.const 0
    i32.store
    i32.const 7405
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
    i32.eq
    if $I19
      i32.const 0
      call $fimport$0
      drop
      call $fimport$1
      drop
      call $j944
      unreachable
    end
    local.get $l1
    call $fimport$10
    unreachable)
