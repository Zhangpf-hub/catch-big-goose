  (func $j34805 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i64) (local $l10 i64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $l2
    local.get $l2
    global.set $primary.global$0
    local.get $l2
    local.get $p0
    i32.store offset=60
    i32.const 5140338
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      call $j922
      i32.const 4018184 ;; Method$System.Runtime.CompilerServices.AsyncTaskMethodBuilder.AwaitOnCompleted<IEnumeratorAwaitExtensions.SimpleCoroutineAwaiter, ServerFileCreate.<LoadHotFixScriptable>d__54>()
      call $j922
      i32.const 3952016 ;; Awaiters_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3983240 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Clear()
      call $j922
      i32.const 3989156 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.Dispose()
      call $j922
      i32.const 3989160 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.MoveNext()
      call $j922
      i32.const 3989164 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.get_Current()
      call $j922
      i32.const 4000932 ;; Method$System.Collections.Generic.List<HotFixScriptable>.GetEnumerator()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 3968888 ;; IEnumeratorAwaitExtensions.SimpleCoroutineAwaiter_TypeInfo
      call $j922
      i32.const 3950800 ;; string[]_TypeInfo
      call $j922
      i32.const 3971032 ;; ServerFileCreate.<>c__DisplayClass54_0_TypeInfo
      call $j922
      i32.const 4057836 ;; Method$ServerFileCreate.<>c__DisplayClass54_1.<LoadHotFixScriptable>b__0()
      call $j922
      i32.const 4057840 ;; Method$ServerFileCreate.<>c__DisplayClass54_1.<LoadHotFixScriptable>b__1()
      call $j922
      i32.const 3971036 ;; ServerFileCreate.<>c__DisplayClass54_1_TypeInfo
      call $j922
      i32.const 4126248 ;; 读取热更数据配置
      call $j922
      i32.const 4068412 ;; .txt
      call $j922
      i32.const 4068428 ;; /
      call $j922
      i32.const 4125704 ;; 获取热更数据配置 
      call $j922
      i32.const 5140338
      i32.const 1
      i32.store8
    end
    local.get $l2
    i32.const 0
    i32.store offset=56
    local.get $l2
    i32.const 0
    i32.store offset=52
    local.get $l2
    i32.const 40
    i32.add
    local.set $p1
    local.get $p1
    i32.const 0
    i32.store offset=4
    local.get $l2
    i32.load offset=60
    local.set $p0
    local.get $p0
    i32.load
    local.set $l3
    local.get $l2
    local.get $l3
    i32.store offset=56
    local.get $p0
    i32.load offset=16
    local.set $l5
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
                            block $B13
                              block $B14
                                block $B15
                                  block $B16
                                    block $B17
                                      block $B18
                                        block $B19
                                          local.get $l3
                                          if $I20
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            i32.const 731
                                            i32.const 3971032 ;; ServerFileCreate.<>c__DisplayClass54_0_TypeInfo
                                            i32.load
                                            call $fimport$3
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
                                            br_if $B19
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            i32.const 4610948
                                            i32.load
                                            local.set $l3
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            local.get $l3
                                            i32.const 1
                                            i32.eq
                                            br_if $B19
                                            local.get $l2
                                            i32.load offset=60
                                            local.get $p0
                                            i32.store offset=20
                                            local.get $l2
                                            i32.load offset=60
                                            local.set $p0
                                            local.get $p0
                                            i32.load offset=20
                                            local.get $p0
                                            i32.load offset=16
                                            i32.store offset=8
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            i32.const 735
                                            i32.const 3961880 ;; ServerFileCreate_TypeInfo
                                            i32.load
                                            call $fimport$11
                                            i32.const 4610948
                                            i32.load
                                            local.set $p0
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            local.get $p0
                                            i32.const 1
                                            i32.eq
                                            br_if $B18
                                            i32.const 3961880 ;; ServerFileCreate_TypeInfo
                                            i32.load
                                            i32.load offset=92
                                            i32.load offset=32
                                            local.set $p0
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            i32.const 7478
                                            local.get $p0
                                            i32.const 3983240 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Clear()
                                            i32.load
                                            call $fimport$12
                                            i32.const 4610948
                                            i32.load
                                            local.set $p0
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            local.get $p0
                                            i32.const 1
                                            i32.eq
                                            br_if $B17
                                            local.get $l2
                                            i32.load offset=60
                                            i32.load offset=20
                                            i32.const 0
                                            i32.store8 offset=12
                                            local.get $l5
                                            i32.load offset=96
                                            local.set $p0
                                            i32.const 4610948
                                            i32.const 0
                                            i32.store
                                            i32.const 7479
                                            local.get $l2
                                            i32.const 8
                                            i32.add
                                            local.get $p0
                                            i32.const 4000932 ;; Method$System.Collections.Generic.List<HotFixScriptable>.GetEnumerator()
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
                                            br_if $B16
                                            local.get $l2
                                            i64.load offset=16
                                            local.set $l9
                                            local.get $l2
                                            local.get $l9
                                            i64.store offset=32
                                            local.get $l2
                                            i64.load offset=8
                                            local.set $l10
                                            local.get $l2
                                            local.get $l10
                                            i64.store offset=24
                                            local.get $l2
                                            i32.load offset=60
                                            local.set $p0
                                            local.get $p0
                                            local.get $l9
                                            i32.wrap_i64
                                            i32.store offset=40
                                            local.get $p0
                                            local.get $l9
                                            i64.const 32
                                            i64.shr_u
                                            i32.wrap_i64
                                            i32.store offset=44
                                            local.get $p0
                                            local.get $l10
                                            i32.wrap_i64
                                            i32.store offset=32
                                            local.get $p0
                                            local.get $l10
                                            i64.const 32
                                            i64.shr_u
                                            i32.wrap_i64
                                            i32.store offset=36
                                          end
                                          local.get $l2
                                          local.get $l2
                                          i32.const 60
                                          i32.add
                                          i32.store offset=12
                                          local.get $l2
                                          local.get $l2
                                          i32.const 56
                                          i32.add
                                          i32.store offset=8
                                          local.get $l2
                                          i32.const 0
                                          i32.store offset=24
                                          local.get $l2
                                          i32.load offset=8
                                          i64.extend_i32_u
                                          local.get $l2
                                          i32.load offset=12
                                          i64.extend_i32_u
                                          i64.const 32
                                          i64.shl
                                          i64.or
                                          local.set $l9
                                          local.get $l2
                                          local.get $l9
                                          i32.wrap_i64
                                          i32.store offset=28
                                          local.get $l2
                                          local.get $l9
                                          i64.const 32
                                          i64.shr_u
                                          i32.wrap_i64
                                          i32.store offset=32
                                          local.get $l2
                                          i32.load offset=56
                                          br_if $B15
                                          local.get $l2
                                          i32.load offset=60
                                          i32.load offset=48
                                          local.set $p0
                                          i32.const 4610948
                                          i32.const 0
                                          i32.store
                                          i32.const 753
                                          local.get $p0
                                          i32.const 3968888 ;; IEnumeratorAwaitExtensions.SimpleCoroutineAwaiter_TypeInfo
                                          i32.load
                                          call $fimport$2
                                          local.set $p0
                                          i32.const 4610948
                                          i32.load
                                          local.set $l4
                                          i32.const 4610948
                                          i32.const 0
                                          i32.store
                                          local.get $l4
                                          i32.const 1
                                          i32.eq
                                          br_if $B13
                                          local.get $l2
                                          local.get $p0
                                          i32.store offset=52
                                          local.get $l2
                                          i32.load offset=60
                                          i32.const 0
                                          i32.store offset=48
                                          local.get $l2
                                          i32.const -1
                                          i32.store offset=56
                                          local.get $l2
                                          i32.load offset=60
                                          i32.const -1
                                          i32.store
                                          local.get $l2
                                          i32.load offset=52
                                          local.set $l4
                                          i32.const 0
                                          local.set $p0
                                          br $B14
                                        end
                                        i32.const 2539788
                                        call $fimport$0
                                        local.set $p0
                                        br $B7
                                      end
                                      i32.const 2539788
                                      call $fimport$0
                                      local.set $p0
                                      br $B7
                                    end
                                    i32.const 2539788
                                    call $fimport$0
                                    local.set $p0
                                    br $B7
                                  end
                                  i32.const 2539788
                                  call $fimport$0
                                  local.set $p0
                                  br $B7
                                end
                                i32.const 1
                                local.set $p0
                              end
                              loop $L21
                                block $B22
                                  block $B23
                                    block $B24
                                      local.get $p0
                                      i32.eqz
                                      if $I25
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        i32.const 5651
                                        local.get $l4
                                        i32.const 0
                                        call $fimport$12
                                        br $B24
                                      end
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 7471
                                      local.get $l2
                                      i32.load offset=60
                                      i32.const 32
                                      i32.add
                                      i32.const 3989160 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.MoveNext()
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
                                      br_if $B13
                                      local.get $p0
                                      i32.eqz
                                      br_if $B23
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 731
                                      i32.const 3971036 ;; ServerFileCreate.<>c__DisplayClass54_1_TypeInfo
                                      i32.load
                                      call $fimport$3
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
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 4610948
                                      i32.load
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l3
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $l2
                                      i32.load offset=60
                                      local.get $p0
                                      i32.store offset=24
                                      local.get $l2
                                      i32.load offset=60
                                      local.set $p0
                                      local.get $p0
                                      i32.load offset=24
                                      local.get $p0
                                      i32.load offset=20
                                      i32.store offset=16
                                      local.get $l2
                                      i32.load offset=60
                                      local.set $p0
                                      local.get $p0
                                      i32.load offset=24
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 7472
                                      local.get $p0
                                      i32.const 32
                                      i32.add
                                      i32.const 3989164 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.get_Current()
                                      i32.load
                                      call $fimport$2
                                      local.set $p0
                                      i32.const 4610948
                                      i32.load
                                      local.set $l6
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l6
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $l3
                                      local.get $p0
                                      i32.store offset=8
                                      local.get $l2
                                      i32.load offset=60
                                      i32.load offset=24
                                      local.set $p0
                                      local.get $p0
                                      i32.load offset=8
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 5063
                                      local.get $l3
                                      i32.const 0
                                      call $fimport$2
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
                                      br_if $B13
                                      local.get $p0
                                      local.get $l3
                                      i32.store offset=12
                                      local.get $l2
                                      i32.load offset=60
                                      i32.load offset=24
                                      local.set $p0
                                      local.get $p0
                                      i32.load offset=16
                                      i32.const 0
                                      i32.store8 offset=12
                                      local.get $p0
                                      i32.load offset=12
                                      local.set $p0
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 812
                                      i32.const 4125704 ;; 获取热更数据配置 
                                      i32.load
                                      local.get $p0
                                      i32.const 0
                                      call $fimport$8
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
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 735
                                      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                                      i32.load
                                      call $fimport$11
                                      i32.const 4610948
                                      i32.load
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l3
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 4983
                                      local.get $p0
                                      i32.const 0
                                      call $fimport$12
                                      i32.const 4610948
                                      i32.load
                                      local.set $p0
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $p0
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1085
                                      i32.const 3950800 ;; string[]_TypeInfo
                                      i32.load
                                      i32.const 6
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
                                      br_if $B13
                                      local.get $l5
                                      i32.load offset=44
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      local.get $l3
                                      call $fimport$12
                                      i32.const 4610948
                                      i32.load
                                      local.set $l6
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l6
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $p0
                                      local.get $l3
                                      i32.store offset=16
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      i32.const 4068428 ;; /
                                      i32.load
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
                                      br_if $B13
                                      local.get $p0
                                      i32.const 4068428 ;; /
                                      i32.load
                                      i32.store offset=20
                                      local.get $l5
                                      i32.load offset=52
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      local.get $l3
                                      call $fimport$12
                                      i32.const 4610948
                                      i32.load
                                      local.set $l6
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l6
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $p0
                                      local.get $l3
                                      i32.store offset=24
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      i32.const 4068428 ;; /
                                      i32.load
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
                                      br_if $B13
                                      local.get $p0
                                      i32.const 4068428 ;; /
                                      i32.load
                                      i32.store offset=28
                                      local.get $l2
                                      i32.load offset=60
                                      i32.load offset=24
                                      i32.load offset=12
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      local.get $l3
                                      call $fimport$12
                                      i32.const 4610948
                                      i32.load
                                      local.set $l6
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l6
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $p0
                                      local.get $l3
                                      i32.store offset=32
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1070
                                      local.get $p0
                                      i32.const 4068412 ;; .txt
                                      i32.load
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
                                      br_if $B13
                                      local.get $p0
                                      i32.const 4068412 ;; .txt
                                      i32.load
                                      i32.store offset=36
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 1229
                                      local.get $p0
                                      i32.const 0
                                      call $fimport$2
                                      local.set $l6
                                      i32.const 4610948
                                      i32.load
                                      local.set $p0
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $p0
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $l2
                                      i32.load offset=60
                                      i32.load offset=24
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 731
                                      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
                                      i32.load
                                      call $fimport$3
                                      local.set $p0
                                      i32.const 4610948
                                      i32.load
                                      local.set $l7
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l7
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 7481
                                      local.get $p0
                                      local.get $l3
                                      i32.const 4057836 ;; Method$ServerFileCreate.<>c__DisplayClass54_1.<LoadHotFixScriptable>b__0()
                                      i32.load
                                      i32.const 0
                                      call $fimport$13
                                      i32.const 4610948
                                      i32.load
                                      local.set $l3
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l3
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      local.get $l2
                                      i32.load offset=60
                                      i32.load offset=24
                                      local.set $l7
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 731
                                      i32.const 3939460 ;; System.Action<string>_TypeInfo
                                      i32.load
                                      call $fimport$3
                                      local.set $l3
                                      i32.const 4610948
                                      i32.load
                                      local.set $l8
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l8
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 5229
                                      local.get $l3
                                      local.get $l7
                                      i32.const 4057840 ;; Method$ServerFileCreate.<>c__DisplayClass54_1.<LoadHotFixScriptable>b__1()
                                      i32.load
                                      i32.const 0
                                      call $fimport$13
                                      i32.const 4610948
                                      i32.load
                                      local.set $l7
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l7
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 735
                                      i32.const 3959332 ;; NetworkHelper_TypeInfo
                                      i32.load
                                      call $fimport$11
                                      i32.const 4610948
                                      i32.load
                                      local.set $l7
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      local.get $l7
                                      i32.const 1
                                      i32.eq
                                      br_if $B13
                                      i32.const 4610948
                                      i32.const 0
                                      i32.store
                                      i32.const 7482
                                      local.get $l6
                                      local.get $p0
                                      local.get $l3
                                      i32.const 3
                                      i32.const 4126248 ;; 读取热更数据配置
                                      i32.load
                                      i32.const 0
                                      i32.const 0
                                      call $fimport$28
                                    end
                                    i32.const 4610948
                                    i32.load
                                    local.set $p0
                                    i32.const 4610948
                                    i32.const 0
                                    i32.store
                                    local.get $p0
                                    i32.const 1
                                    i32.eq
                                    br_if $B13
                                    local.get $l2
                                    i32.load offset=60
                                    local.set $p0
                                    local.get $p0
                                    i32.load offset=24
                                    i32.load offset=16
                                    i32.load8_u offset=12
                                    if $I26
                                      local.get $p0
                                      i32.const 0
                                      i32.store offset=24
                                      i32.const 1
                                      local.set $p0
                                      br $L21
                                    end
                                    i32.const 4610948
                                    i32.const 0
                                    i32.store
                                    i32.const 735
                                    i32.const 3952016 ;; Awaiters_TypeInfo
                                    i32.load
                                    call $fimport$11
                                    i32.const 4610948
                                    i32.load
                                    local.set $p0
                                    i32.const 4610948
                                    i32.const 0
                                    i32.store
                                    block $B27
                                      local.get $p0
                                      i32.const 1
                                      i32.ne
                                      if $I28
                                        i32.const 5142100
                                        i32.load8_u
                                        i32.eqz
                                        if $I29
                                          i32.const 4610948
                                          i32.const 0
                                          i32.store
                                          i32.const 810
                                          i32.const 3952016 ;; Awaiters_TypeInfo
                                          call $fimport$11
                                          i32.const 4610948
                                          i32.load
                                          local.set $p0
                                          i32.const 4610948
                                          i32.const 0
                                          i32.store
                                          local.get $p0
                                          i32.const 1
                                          i32.eq
                                          br_if $B13
                                          i32.const 5142100
                                          i32.const 1
                                          i32.store8
                                        end
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        i32.const 735
                                        i32.const 3952016 ;; Awaiters_TypeInfo
                                        i32.load
                                        call $fimport$11
                                        i32.const 4610948
                                        i32.load
                                        local.set $p0
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        local.get $p0
                                        i32.const 1
                                        i32.eq
                                        br_if $B13
                                        i32.const 3952016 ;; Awaiters_TypeInfo
                                        i32.load
                                        i32.load offset=92
                                        i32.load
                                        local.set $p0
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        i32.const 7483
                                        local.get $p0
                                        i32.const 0
                                        call $fimport$2
                                        local.set $l4
                                        i32.const 4610948
                                        i32.load
                                        local.set $p0
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        local.get $p0
                                        i32.const 1
                                        i32.eq
                                        br_if $B27
                                        local.get $l2
                                        local.get $l4
                                        i32.store offset=52
                                        local.get $l4
                                        i32.load8_u offset=8
                                        br_if $B22
                                        local.get $l2
                                        i32.const 0
                                        i32.store offset=56
                                        local.get $l2
                                        i32.load offset=60
                                        local.set $p0
                                        local.get $p0
                                        local.get $l4
                                        i32.store offset=48
                                        local.get $p0
                                        i32.const 0
                                        i32.store
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        local.get $l2
                                        i32.load offset=60
                                        local.set $p0
                                        i32.const 7484
                                        local.get $p0
                                        i32.const 4
                                        i32.add
                                        local.get $l2
                                        i32.const 52
                                        i32.add
                                        local.get $p0
                                        i32.const 4018184 ;; Method$System.Runtime.CompilerServices.AsyncTaskMethodBuilder.AwaitOnCompleted<IEnumeratorAwaitExtensions.SimpleCoroutineAwaiter, ServerFileCreate.<LoadHotFixScriptable>d__54>()
                                        i32.load
                                        call $fimport$13
                                        i32.const 4610948
                                        i32.load
                                        local.set $p0
                                        i32.const 4610948
                                        i32.const 0
                                        i32.store
                                        i32.const 9
                                        local.set $l4
                                        local.get $p0
                                        i32.const 1
                                        i32.ne
                                        br_if $B12
                                        br $B13
                                      end
                                      br $B13
                                    end
                                    br $B13
                                  end
                                  i32.const 10
                                  local.set $l4
                                  br $B12
                                end
                                i32.const 0
                                local.set $p0
                                br $L21
                              end
                              unreachable
                            end
                            i32.const 2539788
                            call $fimport$0
                            local.set $p0
                            call $fimport$1
                            local.set $l4
                            local.get $l4
                            i32.const 2539788
                            call $fimport$9
                            i32.ne
                            br_if $B10
                            local.get $l2
                            local.get $p0
                            call $fimport$7
                            i32.load
                            i32.store offset=24
                            i32.const 0
                            local.set $l4
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
                            br_if $B11
                          end
                          i32.const 4610948
                          i32.const 0
                          i32.store
                          i32.const 7485
                          local.get $l2
                          i32.const 24
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
                          if $I30
                            local.get $l4
                            i32.const 10
                            i32.ne
                            i32.const 0
                            local.get $l4
                            select
                            br_if $B1
                            local.get $l2
                            i32.load offset=60
                            i32.const 32
                            i32.add
                            i32.const 16
                            call $j948
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            i32.const 735
                            i32.const 3961880 ;; ServerFileCreate_TypeInfo
                            i32.load
                            call $fimport$11
                            i32.const 4610948
                            i32.load
                            local.set $p0
                            i32.const 4610948
                            i32.const 0
                            i32.store
                            local.get $p0
                            i32.const 1
                            i32.eq
                            br_if $B9
                            i32.const 3961880 ;; ServerFileCreate_TypeInfo
                            i32.load
                            i32.load offset=92
                            i32.const 1
                            i32.store8 offset=28
                            local.get $l2
                            i32.load offset=60
                            local.set $p0
                            local.get $p0
                            i32.load offset=28
                            local.set $l4
                            local.get $l4
                            br_if $B8
                            br $B2
                          end
                          i32.const 2539788
                          call $fimport$0
                          local.set $p0
                          br $B7
                        end
                        i32.const 2539788
                        call $fimport$0
                        local.set $p0
                        call $fimport$1
                        local.set $l4
                      end
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 7485
                      local.get $l2
                      i32.const 24
                      i32.add
                      call $fimport$3
                      drop
                      i32.const 4610948
                      i32.load
                      local.set $l5
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l5
                      i32.const 1
                      i32.ne
                      br_if $B6
                      br $B5
                    end
                    i32.const 2539788
                    call $fimport$0
                    local.set $p0
                    br $B7
                  end
                  local.get $l4
                  i32.load offset=20
                  local.set $p0
                  local.get $l4
                  i32.load offset=32
                  local.set $l5
                  local.get $l4
                  i32.load offset=12
                  local.set $l4
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l4
                  local.get $l5
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
                  if $I31
                    local.get $l2
                    i32.load offset=60
                    local.set $p0
                    br $B2
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p0
                end
                call $fimport$1
                local.set $l4
              end
              i32.const 2539788
              call $fimport$9
              local.get $l4
              i32.ne
              br_if $B3
              local.get $p0
              call $fimport$7
              local.set $p0
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 704
              i32.const 3954812 ;; System.Exception_TypeInfo
              call $fimport$3
              local.set $l4
              i32.const 4610948
              i32.load
              local.set $l5
              i32.const 4610948
              i32.const 0
              i32.store
              block $B32
                local.get $l5
                i32.const 1
                i32.eq
                br_if $B32
                local.get $p0
                i32.load
                i32.load
                local.set $l5
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 705
                local.get $l4
                local.get $l5
                call $fimport$2
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
                br_if $B32
                local.get $l4
                if $I33
                  local.get $p1
                  i32.load offset=4
                  local.set $l4
                  local.get $p1
                  local.get $l4
                  i32.const 2
                  i32.shl
                  i32.add
                  local.get $p0
                  i32.load
                  i32.store
                  local.get $p1
                  local.get $l4
                  i32.const 1
                  i32.add
                  i32.store offset=4
                  call $fimport$15
                  local.get $p1
                  i32.load offset=4
                  i32.const 2
                  i32.shl
                  local.get $p1
                  i32.add
                  i32.const 4
                  i32.sub
                  i32.load
                  local.set $p0
                  local.get $l2
                  i32.load offset=60
                  local.set $l4
                  local.get $l4
                  i32.const 0
                  i32.store offset=20
                  local.get $l4
                  i32.const -2
                  i32.store
                  local.get $l2
                  i32.load offset=60
                  i32.const 4
                  i32.add
                  local.get $p0
                  i32.const 0
                  call $j2303 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder$$SetException
                  local.get $p1
                  local.get $p1
                  i32.load offset=4
                  i32.const 1
                  i32.sub
                  i32.store offset=4
                  br $B1
                end
                i32.const 4
                call $fimport$14
                local.set $p1
                local.get $p1
                local.get $p0
                i32.load
                i32.store
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 706
                local.get $p1
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
              local.set $p1
              i32.const 4610948
              i32.const 0
              i32.store
              local.get $p1
              i32.const 1
              i32.ne
              br_if $B3
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
        call $fimport$10
        unreachable
      end
      local.get $p0
      i32.const 0
      i32.store offset=20
      local.get $p0
      i32.const -2
      i32.store
      local.get $l2
      i32.load offset=60
      i32.const 4
      i32.add
      i32.const 0
      call $j2302 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder$$SetResult
    end
    local.get $l2
    i32.const -64
    i32.sub
    global.set $primary.global$0)
