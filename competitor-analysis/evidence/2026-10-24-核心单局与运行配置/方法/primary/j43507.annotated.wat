  (func $j43507 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140062
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3984740 ;; Method$System.Collections.Generic.Dictionary<string, int>.GetEnumerator()
      call $j922
      i32.const 3984752 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Count()
      call $j922
      i32.const 3992296 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, int>.Dispose()
      call $j922
      i32.const 3992300 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, int>.MoveNext()
      call $j922
      i32.const 3992304 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, int>.get_Current()
      call $j922
      i32.const 3996812 ;; Method$System.Collections.Generic.KeyValuePair<string, int>.get_Key()
      call $j922
      i32.const 3996816 ;; Method$System.Collections.Generic.KeyValuePair<string, int>.get_Value()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4054900 ;; Method$LevelManager.<>c__DisplayClass114_0.<StartLoadAllSpLevel>b__0()
      call $j922
      i32.const 3969168 ;; LevelManager.<>c__DisplayClass114_0_TypeInfo
      call $j922
      i32.const 4122400 ;; 开始加载特殊关物品
      call $j922
      i32.const 5140062
      i32.const 1
      i32.store8
    end
    local.get $p2
    i64.const 0
    i64.store offset=56
    local.get $p2
    i64.const 0
    i64.store offset=48
    local.get $p2
    i64.const 0
    i64.store offset=40
    local.get $p2
    i64.const 0
    i64.store offset=32
    i32.const 3969168 ;; LevelManager.<>c__DisplayClass114_0_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p1
    i32.store offset=12
    i32.const 4122400 ;; 开始加载特殊关物品
    i32.load
    i32.const 0
    call $j1441 ;; UnityEngine.MonoBehaviour$$print
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3984752 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Count()
    i32.load
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=60
    local.set $p1
    local.get $l3
    local.get $p1
    i32.load offset=16
    local.get $p1
    i32.load offset=24
    i32.sub
    i32.store offset=8
    local.get $p2
    i32.const 8
    i32.add
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=60
    i32.const 3984740 ;; Method$System.Collections.Generic.Dictionary<string, int>.GetEnumerator()
    i32.load
    call $j1250
    local.get $p2
    local.get $p2
    i64.load offset=24
    i64.store offset=56
    local.get $p2
    local.get $p2
    i64.load offset=16
    i64.store offset=48
    local.get $p2
    local.get $p2
    i64.load offset=8
    i64.store offset=40
    local.get $p2
    local.get $p2
    i32.const 40
    i32.add
    i32.store
    local.get $p2
    i32.const 0
    i32.store offset=8
    local.get $p2
    local.get $p2
    i32.load
    i32.store offset=12
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  loop $L8
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5135
                    local.get $p2
                    i32.const 40
                    i32.add
                    i32.const 3992300 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, int>.MoveNext()
                    i32.load
                    call $fimport$2
                    local.set $p1
                    i32.const 4610948
                    i32.load
                    local.set $l4
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $l4
                    i32.const 1
                    i32.eq
                    if $I9
                      i32.const 2539788
                      call $fimport$0
                      local.set $p1
                      br $B3
                    end
                    local.get $p1
                    i32.eqz
                    br_if $B2
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5136
                    local.get $p2
                    local.get $p2
                    i32.const 40
                    i32.add
                    i32.const 3992304 ;; Method$System.Collections.Generic.Dictionary.Enumerator<string, int>.get_Current()
                    i32.load
                    call $fimport$5
                    i32.const 4610948
                    i32.load
                    local.set $p1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $p1
                    i32.const 1
                    i32.eq
                    br_if $B7
                    local.get $p2
                    local.get $p2
                    i64.load
                    i64.store offset=32
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5137
                    local.get $p2
                    i32.const 32
                    i32.add
                    i32.const 3996812 ;; Method$System.Collections.Generic.KeyValuePair<string, int>.get_Key()
                    i32.load
                    call $fimport$2
                    local.set $l4
                    i32.const 4610948
                    i32.load
                    local.set $p1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $p1
                    i32.const 1
                    i32.eq
                    br_if $B6
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 5139
                    local.get $p2
                    i32.const 32
                    i32.add
                    i32.const 3996816 ;; Method$System.Collections.Generic.KeyValuePair<string, int>.get_Value()
                    i32.load
                    call $fimport$2
                    local.set $l6
                    i32.const 4610948
                    i32.load
                    local.set $p1
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    local.get $p1
                    i32.const 1
                    i32.eq
                    br_if $B5
                    local.get $l3
                    i32.load offset=16
                    local.set $p1
                    local.get $p1
                    i32.eqz
                    if $I10
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 731
                      i32.const 3939040 ;; System.Action<bool>_TypeInfo
                      i32.load
                      call $fimport$3
                      local.set $p1
                      i32.const 4610948
                      i32.load
                      local.set $l5
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l5
                      i32.const 1
                      i32.eq
                      br_if $B4
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      i32.const 5228
                      local.get $p1
                      local.get $l3
                      i32.const 4054900 ;; Method$LevelManager.<>c__DisplayClass114_0.<StartLoadAllSpLevel>b__0()
                      i32.load
                      i32.const 0
                      call $fimport$13
                      i32.const 4610948
                      i32.load
                      local.set $l5
                      i32.const 4610948
                      i32.const 0
                      i32.store
                      local.get $l5
                      i32.const 1
                      i32.eq
                      br_if $B4
                      local.get $l3
                      local.get $p1
                      i32.store offset=16
                    end
                    i32.const 4610948
                    i32.const 0
                    i32.store
                    i32.const 7444
                    local.get $p0
                    local.get $l4
                    local.get $l6
                    local.get $p1
                    local.get $p2
                    call $fimport$17
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
                  end
                  i32.const 2539788
                  call $fimport$0
                  local.set $p1
                  br $B3
                end
                i32.const 2539788
                call $fimport$0
                local.set $p1
                br $B3
              end
              i32.const 2539788
              call $fimport$0
              local.set $p1
              br $B3
            end
            i32.const 2539788
            call $fimport$0
            local.set $p1
            br $B3
          end
          i32.const 2539788
          call $fimport$0
          local.set $p1
        end
        call $fimport$1
        i32.const 2539788
        call $fimport$9
        i32.eq
        if $I11
          local.get $p2
          local.get $p1
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
          local.set $p1
          call $fimport$1
          drop
        end
        i32.const 4610948
        i32.const 0
        i32.store
        i32.const 7445
        local.get $p2
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
      local.get $p2
      i32.const 8
      i32.add
      call $j4894
      drop
      local.get $p2
      i32.const -64
      i32.sub
      global.set $primary.global$0
      return
    end
    local.get $p1
    call $fimport$10
    unreachable)
