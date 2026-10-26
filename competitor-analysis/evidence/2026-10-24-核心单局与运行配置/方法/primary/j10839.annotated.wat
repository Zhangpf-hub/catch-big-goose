  (func $j10839 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127148
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4017564 ;; Method$ArrayHelper.GetValueOrDefault<MainLevelUpgradedDataData>()
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3955736 ;; GooseHelper_TypeInfo
      call $j922
      i32.const 3956456 ;; System.IDisposable_TypeInfo
      call $j922
      i32.const 3945348 ;; System.Collections.Generic.IEnumerable<KeyValuePair<int, List<MainLevelUpgradedDataData>>>_TypeInfo
      call $j922
      i32.const 3945536 ;; System.Collections.Generic.IEnumerator<KeyValuePair<int, List<MainLevelUpgradedDataData>>>_TypeInfo
      call $j922
      i32.const 3956544 ;; System.Collections.IEnumerator_TypeInfo
      call $j922
      i32.const 3996516 ;; Method$System.Collections.Generic.KeyValuePair<int, List<MainLevelUpgradedDataData>>.Deconstruct()
      call $j922
      i32.const 5127148
      i32.const 1
      i32.store8
    end
    local.get $p1
    i64.const 0
    i64.store offset=32
    local.get $p1
    i32.const 0
    i32.store offset=28
    local.get $p1
    i32.const 0
    i32.store offset=24
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 5128623
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 5128623
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    i32.const 3945348 ;; System.Collections.Generic.IEnumerable<KeyValuePair<int, List<MainLevelUpgradedDataData>>>_TypeInfo
    i32.load
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=624
    call $j951
    i32.store offset=44
    local.get $p1
    local.get $p1
    i32.const 44
    i32.add
    i32.store offset=8
    local.get $p1
    i32.const 0
    i32.store offset=16
    local.get $p1
    local.get $p1
    i32.load offset=8
    i32.store offset=20
    block $B2
      block $B3
        block $B4
          block $B5
            block $B6
              block $B7
                block $B8
                  block $B9
                    loop $L10
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 744
                      i32.const 0
                      i32.const 3956544 ;; System.Collections.IEnumerator_TypeInfo
                      i32.load
                      local.get $p1
                      i32.load offset=44
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
                      br_if $B4
                      local.get $l2
                      i32.eqz
                      br_if $B2
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5076
                      local.get $p1
                      i32.const 8
                      i32.add
                      i32.const 0
                      i32.const 3945536 ;; System.Collections.Generic.IEnumerator<KeyValuePair<int, List<MainLevelUpgradedDataData>>>_TypeInfo
                      i32.load
                      local.get $p1
                      i32.load offset=44
                      call $fimport$13
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
                      local.get $p1
                      local.get $p1
                      i64.load offset=8
                      i64.store offset=32
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5077
                      local.get $p1
                      i32.const 32
                      i32.add
                      local.get $p1
                      i32.const 28
                      i32.add
                      local.get $p1
                      i32.const 24
                      i32.add
                      i32.const 3996516 ;; Method$System.Collections.Generic.KeyValuePair<int, List<MainLevelUpgradedDataData>>.Deconstruct()
                      i32.load
                      call $fimport$13
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
                      i32.const 5078
                      local.get $p1
                      i32.load offset=24
                      i32.const 0
                      i32.const 0
                      i32.const 4017564 ;; Method$ArrayHelper.GetValueOrDefault<MainLevelUpgradedDataData>()
                      i32.load
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
                      br_if $B7
                      local.get $l2
                      i32.eqz
                      br_if $L10
                      local.get $l2
                      i32.load offset=24
                      local.set $l3
                      i32.const 0
                      local.set $l2
                      loop $L11
                        local.get $p1
                        local.get $l2
                        i32.store offset=28
                        local.get $l2
                        local.get $l3
                        i32.load offset=12
                        i32.ge_s
                        br_if $L10
                        local.get $l3
                        local.get $l2
                        i32.const 2
                        i32.shl
                        i32.add
                        i32.load offset=16
                        local.set $l2
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 735
                        i32.const 3955736 ;; GooseHelper_TypeInfo
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
                        i32.ne
                        if $I12
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 5079
                          local.get $l2
                          local.get $p0
                          i32.const 0
                          call $fimport$8
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
                          br_if $B9
                          block $B13
                            local.get $l2
                            i32.eqz
                            br_if $B13
                            local.get $l2
                            i32.load offset=8
                            local.set $l2
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            i32.const 5080
                            local.get $l2
                            i32.const 0
                            call $fimport$2
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
                            br_if $B8
                            local.get $l2
                            i32.eqz
                            br_if $B13
                            local.get $l5
                            i32.const 1
                            i32.add
                            local.set $l5
                          end
                          local.get $p1
                          i32.load offset=28
                          i32.const 1
                          i32.add
                          local.set $l2
                          br $L11
                        end
                      end
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $l2
                    br $B3
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $l2
                  br $B3
                end
                i32.const 2539788
                call $fimport$0
                local.set $l2
                br $B3
              end
              i32.const 2539788
              call $fimport$0
              local.set $l2
              br $B3
            end
            i32.const 2539788
            call $fimport$0
            local.set $l2
            br $B3
          end
          i32.const 2539788
          call $fimport$0
          local.set $l2
          br $B3
        end
        i32.const 2539788
        call $fimport$0
        local.set $l2
      end
      call $fimport$1
      i32.const 2539788
      call $fimport$9
      i32.eq
      if $I14
        local.get $p1
        local.get $l2
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
        i32.ne
        br_if $B2
        call $fimport$4
        local.set $l2
        call $fimport$1
        drop
      end
      i32.const 4610948
      i32.const 0
      i32.store
      i32.const 5081
      local.get $p1
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
      if $I15
        i32.const 0
        call $fimport$0
        drop
        call $fimport$1
        drop
        call $j944
        unreachable
      end
      local.get $l2
      call $fimport$10
      unreachable
    end
    local.get $p1
    i32.const 16
    i32.add
    call $j983
    drop
    local.get $p1
    i32.const 48
    i32.add
    global.set $primary.global$0
    local.get $l5
    return)
