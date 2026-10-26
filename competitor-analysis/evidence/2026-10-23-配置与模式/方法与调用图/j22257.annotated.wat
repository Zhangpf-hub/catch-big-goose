  (func $j22257 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140086
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 4122940 ;; 换关清理主线生成池
      call $j922
      i32.const 5140086
      i32.const 1
      i32.store8
    end
    local.get $l3
    i32.const 24
    i32.add
    local.set $l2
    local.get $l2
    i32.const 0
    i32.store offset=4
    i32.const 4610948
    i32.const 0
    i32.store
    i32.const 735
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $fimport$11
    i32.const 4610948
    i32.load
    local.set $p0
    i32.const 4610948
    i32.const 0
    i32.store
    block $B1
      block $B2
        block $B3
          block $B4
            local.get $p0
            i32.const 1
            i32.ne
            if $I5
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 7446
              local.get $l3
              call $fimport$3
              local.set $p0
              i32.const 4610948
              i32.load
              local.set $l1
              i32.const 4610948
              i32.const 0
              i32.store
              local.get $l1
              i32.const 1
              i32.eq
              br_if $B4
              local.get $p0
              i32.eqz
              br_if $B3
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 5839
              i32.const 2
              i32.const 4122940 ;; 换关清理主线生成池
              i32.load
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
              br_if $B3
            end
            i32.const 2539788
            call $fimport$0
            local.set $p0
            br $B2
          end
          i32.const 2539788
          call $fimport$0
          local.set $p0
          br $B2
        end
        i32.const 1
        local.set $p0
        block $B6
          block $B7
            block $B8
              block $B9
                block $B10
                  block $B11
                    block $B12
                      loop $L13
                        local.get $p0
                        i32.const 3
                        i32.ge_s
                        br_if $B1
                        i32.const 4610948
                        i32.const 0
                        i32.store
                        i32.const 735
                        i32.const 3959288 ;; NetDataManager_TypeInfo
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
                        i32.ne
                        if $I14
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7447
                          local.get $p0
                          i32.const 0
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
                          br_if $B12
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7448
                          local.get $l3
                          i32.const 16
                          i32.add
                          local.get $l1
                          local.get $l3
                          call $fimport$5
                          i32.const 4610948
                          i32.load
                          local.set $l1
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l1
                          i32.const 1
                          i32.eq
                          br_if $B11
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l3
                          i64.load offset=16
                          local.set $l6
                          i32.const 735
                          i32.const 3958024 ;; LevelDataHelper_TypeInfo
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
                          br_if $B10
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l3
                          local.get $l6
                          i64.store offset=8
                          local.get $l3
                          local.get $l6
                          i64.store
                          i32.const 7449
                          local.get $l3
                          i32.const 2
                          local.get $l3
                          call $fimport$8
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
                          br_if $B9
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 5413
                          i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
                          i32.load
                          call $fimport$3
                          local.set $l4
                          i32.const 4610948
                          i32.load
                          local.set $l5
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l5
                          i32.const 1
                          i32.eq
                          br_if $B8
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 5412
                          local.get $l1
                          i32.const 0
                          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                          i32.load
                          call $fimport$8
                          local.set $l1
                          i32.const 4610948
                          i32.load
                          local.set $l5
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l5
                          i32.const 1
                          i32.eq
                          br_if $B7
                          local.get $l1
                          i32.load offset=24
                          local.set $l1
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 5414
                          local.get $l4
                          local.get $l1
                          i32.const 0
                          call $fimport$5
                          i32.const 4610948
                          i32.load
                          local.set $l1
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l1
                          i32.const 1
                          i32.eq
                          br_if $B6
                          local.get $p0
                          i32.const 1
                          i32.add
                          local.set $p0
                          br $L13
                        end
                      end
                      i32.const 2539788
                      call $fimport$0
                      local.set $p0
                      br $B2
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $p0
                    br $B2
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p0
                  br $B2
                end
                i32.const 2539788
                call $fimport$0
                local.set $p0
                br $B2
              end
              i32.const 2539788
              call $fimport$0
              local.set $p0
              br $B2
            end
            i32.const 2539788
            call $fimport$0
            local.set $p0
            br $B2
          end
          i32.const 2539788
          call $fimport$0
          local.set $p0
          br $B2
        end
        i32.const 2539788
        call $fimport$0
        local.set $p0
      end
      block $B15
        call $fimport$1
        i32.const 2539788
        call $fimport$9
        i32.ne
        br_if $B15
        local.get $p0
        call $fimport$7
        local.set $p0
        i32.const 4610948
        i32.const 0
        i32.store
        i32.const 704
        i32.const 3954812 ;; System.Exception_TypeInfo
        call $fimport$3
        local.set $l1
        i32.const 4610948
        i32.load
        local.set $l4
        i32.const 4610948
        i32.const 0
        i32.store
        block $B16
          block $B17
            local.get $l4
            i32.const 1
            i32.eq
            br_if $B17
            local.get $p0
            i32.load
            i32.load
            local.set $l4
            i32.const 4610948
            i32.const 0
            i32.store
            i32.const 705
            local.get $l1
            local.get $l4
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
            br_if $B17
            local.get $l1
            if $I18
              local.get $l2
              i32.load offset=4
              local.set $l1
              local.get $l2
              local.get $l1
              i32.const 2
              i32.shl
              i32.add
              local.get $p0
              i32.load
              i32.store
              local.get $l2
              local.get $l1
              i32.const 1
              i32.add
              i32.store offset=4
              call $fimport$15
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              call $j925
              call $j923
              i32.const 4124532 ;; 清理内存2出错
              call $j925
              i32.const 0
              call $j1050 ;; UnityEngine.Debug$$LogError
              local.get $l2
              i32.load offset=4
              i32.const 2
              i32.shl
              local.get $l2
              i32.add
              i32.const 4
              i32.sub
              i32.load
              i32.const 0
              call $j1050 ;; UnityEngine.Debug$$LogError
              local.get $l2
              local.get $l2
              i32.load offset=4
              i32.const 1
              i32.sub
              i32.store offset=4
              br $B1
            end
            i32.const 4
            call $fimport$14
            local.set $l2
            local.get $l2
            local.get $p0
            i32.load
            i32.store
            i32.const 4610948
            i32.const 0
            i32.store
            i32.const 706
            local.get $l2
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
            br_if $B16
          end
          call $fimport$4
          local.set $p0
          call $fimport$1
          drop
          i32.const 4610948
          i32.const 0
          i32.store
          i32.const 369
          call $fimport$6
          i32.const 4610948
          i32.load
          local.set $l2
          i32.const 4610948
          i32.const 0
          i32.store
          local.get $l2
          i32.const 1
          i32.ne
          br_if $B15
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
      call $fimport$10
      unreachable
    end
    local.get $l3
    i32.const 32
    i32.add
    global.set $primary.global$0)
