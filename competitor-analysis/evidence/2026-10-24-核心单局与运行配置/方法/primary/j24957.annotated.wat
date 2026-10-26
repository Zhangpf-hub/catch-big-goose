  (func $j24957 (type $t3) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $l1
    local.get $l1
    global.set $primary.global$0
    i32.const 5140280
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3985752 ;; Method$System.Collections.Generic.Dictionary<string, string>.GetEnumerator()
      call $j922
      i32.const 3992428 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.Dispose()
      call $j922
      i32.const 3992432 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.MoveNext()
      call $j922
      i32.const 3992436 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.get_Current()
      call $j922
      i32.const 3996872 ;; Method$System.Collections.Generic.KeyValuePair<string, string>.get_Key()
      call $j922
      i32.const 3996876 ;; Method$System.Collections.Generic.KeyValuePair<string, string>.get_Value()
      call $j922
      i32.const 3950800 ;; string[]_TypeInfo
      call $j922
      i32.const 4063964 ;; 

      call $j922
      i32.const 4064484 ;;  : 
      call $j922
      i32.const 4071112 ;; <color=grey>AB组</color> 
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140280
      i32.const 1
      i32.store8
    end
    local.get $l1
    i64.const 0
    i64.store offset=56
    local.get $l1
    i64.const 0
    i64.store offset=48
    local.get $l1
    i64.const 0
    i64.store offset=40
    local.get $l1
    i64.const 0
    i64.store offset=32
    i32.const 4063796 ;; 
    i32.load
    local.set $p0
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    local.get $l1
    i32.const 8
    i32.add
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    i32.const 3985752 ;; Method$System.Collections.Generic.Dictionary<string, string>.GetEnumerator()
    i32.load
    call $j1250
    local.get $l1
    local.get $l1
    i64.load offset=24
    i64.store offset=56
    local.get $l1
    local.get $l1
    i64.load offset=16
    i64.store offset=48
    local.get $l1
    local.get $l1
    i64.load offset=8
    i64.store offset=40
    local.get $l1
    local.get $l1
    i32.const 40
    i32.add
    i32.store
    local.get $l1
    i32.const 0
    i32.store offset=8
    local.get $l1
    local.get $l1
    i32.load
    i32.store offset=12
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    block $B9
                      block $B10
                        block $B11
                          block $B12
                            loop $L13
                              block $B14
                                local.get $p0
                                local.set $l4
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 3153
                                local.get $l1
                                i32.const 40
                                i32.add
                                i32.const 3992432 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.MoveNext()
                                i32.load
                                call $fimport$2
                                local.set $p0
                                i32.const 4610948
                                i32.load
                                local.set $l2
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                local.get $l2
                                i32.const 1
                                i32.eq
                                br_if $B14
                                local.get $p0
                                i32.eqz
                                br_if $B2
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 3154
                                local.get $l1
                                local.get $l1
                                i32.const 40
                                i32.add
                                i32.const 3992436 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.get_Current()
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
                                br_if $B12
                                local.get $l1
                                local.get $l1
                                i64.load
                                i64.store offset=32
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1085
                                i32.const 3950800 ;; string[]_TypeInfo
                                i32.load
                                i32.const 5
                                call $fimport$2
                                local.set $p0
                                i32.const 4610948
                                i32.load
                                local.set $l2
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                local.get $l2
                                i32.const 1
                                i32.eq
                                br_if $B11
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1070
                                local.get $p0
                                i32.const 4071112 ;; <color=grey>AB组</color> 
                                i32.load
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
                                br_if $B10
                                local.get $p0
                                i32.const 4071112 ;; <color=grey>AB组</color> 
                                i32.load
                                i32.store offset=16
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 3003
                                local.get $l1
                                i32.const 32
                                i32.add
                                i32.const 3996872 ;; Method$System.Collections.Generic.KeyValuePair<string, string>.get_Key()
                                i32.load
                                call $fimport$2
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
                                br_if $B9
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1070
                                local.get $p0
                                local.get $l2
                                call $fimport$12
                                i32.const 4610948
                                i32.load
                                local.set $l3
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                local.get $l3
                                i32.const 1
                                i32.eq
                                br_if $B9
                                local.get $p0
                                local.get $l2
                                i32.store offset=20
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1070
                                local.get $p0
                                i32.const 4064484 ;;  : 
                                i32.load
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
                                br_if $B8
                                local.get $p0
                                i32.const 4064484 ;;  : 
                                i32.load
                                i32.store offset=24
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 3004
                                local.get $l1
                                i32.const 32
                                i32.add
                                i32.const 3996876 ;; Method$System.Collections.Generic.KeyValuePair<string, string>.get_Value()
                                i32.load
                                call $fimport$2
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
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1070
                                local.get $p0
                                local.get $l2
                                call $fimport$12
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
                                local.get $p0
                                local.get $l2
                                i32.store offset=28
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1070
                                local.get $p0
                                i32.const 4063964 ;; 

                                i32.load
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
                                br_if $B6
                                local.get $p0
                                i32.const 4063964 ;; 

                                i32.load
                                i32.store offset=32
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                i32.const 1229
                                local.get $p0
                                i32.const 0
                                call $fimport$2
                                local.set $p0
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
                                local.get $p0
                                local.set $l2
                                i32.const 4063796 ;; 
                                i32.load
                                local.set $p0
                                i32.const 5176
                                local.get $l4
                                local.get $l2
                                local.get $p0
                                local.get $p0
                                local.get $p0
                                local.get $p0
                                local.get $l1
                                call $fimport$24
                                local.set $p0
                                i32.const 4610948
                                i32.load
                                local.set $l2
                                i32.const 4610948
                                i32.const 0
                                i32.store
                                local.get $l2
                                i32.const 1
                                i32.ne
                                br_if $L13
                                br $B4
                              end
                            end
                            i32.const 2539788
                            call $fimport$0
                            local.set $p0
                            br $B3
                          end
                          i32.const 2539788
                          call $fimport$0
                          local.set $p0
                          br $B3
                        end
                        i32.const 2539788
                        call $fimport$0
                        local.set $p0
                        br $B3
                      end
                      i32.const 2539788
                      call $fimport$0
                      local.set $p0
                      br $B3
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $p0
                    br $B3
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p0
                  br $B3
                end
                i32.const 2539788
                call $fimport$0
                local.set $p0
                br $B3
              end
              i32.const 2539788
              call $fimport$0
              local.set $p0
              br $B3
            end
            i32.const 2539788
            call $fimport$0
            local.set $p0
            br $B3
          end
          i32.const 2539788
          call $fimport$0
          local.set $p0
        end
        call $fimport$1
        i32.const 2539788
        call $fimport$9
        i32.eq
        if $I15
          local.get $l1
          local.get $p0
          call $fimport$7
          i32.load
          i32.store offset=8
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
          local.set $p0
          call $fimport$1
          drop
        end
        i32.const 4610948
        i32.const 0
        i32.store
        i32.const 7460
        local.get $l1
        i32.const 8
        i32.add
        call $fimport$3
        drop
        i32.const 4610948
        i32.load
        local.set $l4
        i32.const 4610948
        i32.const 0
        i32.store
        local.get $l4
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
      local.get $l1
      i32.const 8
      i32.add
      call $j3012
      drop
      local.get $l1
      i32.const -64
      i32.sub
      global.set $primary.global$0
      local.get $l4
      return
    end
    local.get $p0
    call $fimport$10
    unreachable)
