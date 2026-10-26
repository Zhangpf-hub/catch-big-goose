  (func $j43558 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32)
    global.get $primary.global$0
    i32.const 96
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140039
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3982124 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.GetEnumerator()
      call $j922
      i32.const 3991888 ;; Method$System.Collections.Generic.Dictionary.Enumerator<LevelIndexAndType, LevelLoader>.Dispose()
      call $j922
      i32.const 3991892 ;; Method$System.Collections.Generic.Dictionary.Enumerator<LevelIndexAndType, LevelLoader>.MoveNext()
      call $j922
      i32.const 3991896 ;; Method$System.Collections.Generic.Dictionary.Enumerator<LevelIndexAndType, LevelLoader>.get_Current()
      call $j922
      i32.const 3996676 ;; Method$System.Collections.Generic.KeyValuePair<LevelIndexAndType, LevelLoader>.get_Value()
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 5140039
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 0
    i32.store offset=88
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
    i32.const 0
    i32.store offset=56
    local.get $p0
    i64.const 0
    i64.store offset=48
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 16
    i32.add
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 3982124 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.GetEnumerator()
    i32.load
    call $j1250
    local.get $p0
    local.get $p0
    i32.load offset=40
    i32.store offset=88
    local.get $p0
    local.get $p0
    i64.load offset=32
    i64.store offset=80
    local.get $p0
    local.get $p0
    i64.load offset=24
    i64.store offset=72
    local.get $p0
    local.get $p0
    i64.load offset=16
    i64.store offset=64
    local.get $p0
    local.get $p0
    i32.const -64
    i32.sub
    i32.store offset=16
    local.get $p0
    i32.const 0
    i32.store offset=8
    local.get $p0
    local.get $p0
    i32.load offset=16
    i32.store offset=12
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              loop $L6
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 7439
                local.get $p0
                i32.const -64
                i32.sub
                i32.const 3991892 ;; Method$System.Collections.Generic.Dictionary.Enumerator<LevelIndexAndType, LevelLoader>.MoveNext()
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
                if $I7
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
                i32.const 7440
                local.get $p0
                i32.const 16
                i32.add
                local.get $p0
                i32.const -64
                i32.sub
                i32.const 3991896 ;; Method$System.Collections.Generic.Dictionary.Enumerator<LevelIndexAndType, LevelLoader>.get_Current()
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
                br_if $B5
                local.get $p0
                local.get $p0
                i32.load offset=24
                i32.store offset=56
                local.get $p0
                local.get $p0
                i64.load offset=16
                i64.store offset=48
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 7441
                local.get $p0
                i32.const 48
                i32.add
                i32.const 3996676 ;; Method$System.Collections.Generic.KeyValuePair<LevelIndexAndType, LevelLoader>.get_Value()
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
                br_if $B4
                local.get $l1
                i32.load8_u offset=24
                i32.eqz
                br_if $L6
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 7442
                local.get $l1
                local.get $p0
                call $fimport$12
                i32.const 4610948
                i32.load
                local.set $l1
                i32.const 4610948
                i32.const 0
                i32.store
                local.get $l1
                i32.const 1
                i32.ne
                br_if $L6
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
        if $I8
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
        i32.const 7443
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
      i32.const 8
      i32.add
      i32.const 7443
      global.set $__wasm_split_waitTableId
      i32.const 7443
      call_indirect $primary.table (type $t3)
      drop
      local.get $p0
      i32.const 96
      i32.add
      global.set $primary.global$0
      return
    end
    local.get $l1
    call $fimport$10
    unreachable)
