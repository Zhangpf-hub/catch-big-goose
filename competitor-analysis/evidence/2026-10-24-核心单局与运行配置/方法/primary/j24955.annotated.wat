  (func $j24955 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32)
    global.get $primary.global$0
    i32.const 96
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140272
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      call $j922
      i32.const 3985752 ;; Method$System.Collections.Generic.Dictionary<string, string>.GetEnumerator()
      call $j922
      i32.const 3983484 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.GetEnumerator()
      call $j922
      i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
      call $j922
      i32.const 3992428 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.Dispose()
      call $j922
      i32.const 3992092 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, ABTestDataData>.Dispose()
      call $j922
      i32.const 3992096 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, ABTestDataData>.MoveNext()
      call $j922
      i32.const 3992432 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.MoveNext()
      call $j922
      i32.const 3992436 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, string>.get_Current()
      call $j922
      i32.const 3992100 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, ABTestDataData>.get_Current()
      call $j922
      i32.const 3996752 ;; Method$System.Collections.Generic.KeyValuePair<string, ABTestDataData>.get_Key()
      call $j922
      i32.const 3996872 ;; Method$System.Collections.Generic.KeyValuePair<string, string>.get_Key()
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 4071652 ;; AB测试Debug 
      call $j922
      i32.const 4127388 ;; ：
      call $j922
      i32.const 4123864 ;; 未获取到ab文件
      call $j922
      i32.const 5140272
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=88
    local.get $p0
    i64.const 0
    i64.store offset=80
    local.get $p0
    i64.const 0
    i64.store offset=72
    local.get $p0
    i64.const 0
    i64.store offset=64
    local.get $p0
    i64.const 0
    i64.store offset=56
    local.get $p0
    i64.const 0
    i64.store offset=48
    local.get $p0
    i64.const 0
    i64.store offset=40
    local.get $p0
    i64.const 0
    i64.store offset=32
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        block $B3
          block $B4
            i32.const 3951300 ;; ABTestManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.eqz
            if $I5
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              i32.load
              call $j923
              i32.const 4123864 ;; 未获取到ab文件
              i32.load
              i32.const 0
              call $j1075 ;; UnityEngine.Debug$$LogWarning
              br $B4
            end
            i32.const 3959304 ;; NetInitManager_TypeInfo
            i32.load
            call $j923
            i32.const 3959304 ;; NetInitManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            local.set $l1
            i32.const 3959504 ;; UnityEngine.Object_TypeInfo
            i32.load
            call $j923
            block $B6
              block $B7
                block $B8
                  local.get $l1
                  i32.const 0
                  call $j1022 ;; UnityEngine.Object$$op_Implicit
                  i32.eqz
                  br_if $B8
                  i32.const 3959304 ;; NetInitManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 0
                  call $j4064 ;; NetInitManager$$GetExData
                  drop
                  br $B8
                end
                i32.const 3951300 ;; ABTestManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.const 8
                i32.add
                i32.const 3951300 ;; ABTestManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load
                i32.const 3983484 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.GetEnumerator()
                i32.load
                call $j1250
                local.get $p0
                local.get $p0
                i64.load offset=24
                i64.store offset=56
                local.get $p0
                local.get $p0
                i64.load offset=16
                i64.store offset=48
                local.get $p0
                local.get $p0
                i64.load offset=8
                i64.store offset=40
                local.get $p0
                local.get $p0
                i32.const 40
                i32.add
                i32.store
                local.get $p0
                i32.const 0
                i32.store offset=8
                local.get $p0
                local.get $p0
                i32.load
                i32.store offset=12
                br $B6
              end
              unreachable
            end
            block $B9
              block $B10
                block $B11
                  block $B12
                    block $B13
                      loop $L14
                        block $B15
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7455
                          local.get $p0
                          i32.const 40
                          i32.add
                          i32.const 3992096 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, ABTestDataData>.MoveNext()
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
                          br_if $B15
                          local.get $l1
                          i32.eqz
                          br_if $B9
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7456
                          local.get $p0
                          local.get $p0
                          i32.const 40
                          i32.add
                          i32.const 3992100 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, ABTestDataData>.get_Current()
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
                          i32.eq
                          br_if $B13
                          local.get $p0
                          local.get $p0
                          i64.load
                          i64.store offset=32
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7457
                          local.get $p0
                          i32.const 32
                          i32.add
                          i32.const 3996752 ;; Method$System.Collections.Generic.KeyValuePair<string, ABTestDataData>.get_Key()
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
                          br_if $B12
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 735
                          i32.const 3951300 ;; ABTestManager_TypeInfo
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
                          br_if $B12
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7458
                          local.get $l1
                          local.get $p0
                          call $fimport$2
                          drop
                          i32.const 4610948
                          i32.load
                          local.set $l1
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          local.get $l1
                          i32.const 1
                          i32.ne
                          br_if $L14
                          br $B11
                        end
                      end
                      i32.const 2539788
                      call $fimport$0
                      local.set $l1
                      br $B10
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $l1
                    br $B10
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $l1
                  br $B10
                end
                i32.const 2539788
                call $fimport$0
                local.set $l1
              end
              call $fimport$1
              i32.const 2539788
              call $fimport$9
              i32.ne
              br_if $B2
              local.get $p0
              local.get $l1
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
              local.set $l1
              i32.const 4610948
              i32.const 0
              i32.store
              local.get $l1
              i32.const 1
              i32.eq
              br_if $B3
            end
            local.get $p0
            i32.const 8
            i32.add
            call $j28625
            drop
          end
          local.get $p0
          i32.const 96
          i32.add
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
      i32.const 7459
      local.get $p0
      i32.const 8
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
      br_if $B1
      local.get $l1
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
