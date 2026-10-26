  (func $j41850 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    i32.const 5139731
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3954292 ;; DouYinExpertManager_TypeInfo
      call $j922
      i32.const 3955752 ;; GooseStoreHelper_TypeInfo
      call $j922
      i32.const 3955916 ;; HWTaskReportHelper_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3964920 ;; ValueManager_TypeInfo
      call $j922
      i32.const 5139731
      i32.const 1
      i32.store8
    end
    local.get $l4
    i32.const 8
    i32.add
    local.set $p0
    local.get $p0
    i32.const 0
    i32.store offset=4
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    call $j2837 ;; NetDataManager$$GetLocalData
    drop
    i32.const 0
    local.get $p0
    call $j21668 ;; NetDataManager$$CheckDefaultPlayerPublicData
    i32.const 0
    local.get $p0
    call $j21667 ;; NetDataManager$$CheckDefaultPlayerSelfData
    local.get $p0
    call $j41861 ;; NetDataManager$$CheckDefaultGlobalData
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store8 offset=68
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=76
    local.set $l1
    local.get $l1
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $l1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i64.load offset=16
      i32.const 140014
      global.set $__wasm_split_waitTableId
      i32.const 140014
      call_indirect $primary.table (type $t50)
    end
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=80
    local.set $l1
    local.get $l1
    if $I2
      local.get $l1
      i32.load offset=32
      local.get $l1
      i32.load offset=20
      local.get $l1
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
    end
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j41767 ;; NetworkHelper$$CheckWXWinCount
    i32.const 4610948
    i32.const 0
    i32.store
    i32.const 735
    i32.const 3964920 ;; ValueManager_TypeInfo
    i32.load
    call $fimport$11
    i32.const 4610948
    i32.load
    local.set $l1
    i32.const 4610948
    i32.const 0
    i32.store
    block $B3
      block $B4
        block $B5
          block $B6
            block $B7
              local.get $l1
              i32.const 1
              i32.ne
              if $I8
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 7406
                i32.const 0
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
                br_if $B7
              end
              i32.const 2539788
              call $fimport$0
              local.set $l1
              call $fimport$1
              i32.const 2539788
              call $fimport$9
              i32.ne
              br_if $B3
              local.get $l1
              call $fimport$7
              local.set $l1
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 704
              i32.const 3954812 ;; System.Exception_TypeInfo
              call $fimport$3
              local.set $l3
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
              local.get $l1
              i32.load
              i32.load
              local.set $l2
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 705
              local.get $l3
              local.get $l2
              call $fimport$2
              local.set $l3
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
              local.get $l3
              i32.eqz
              br_if $B6
              local.get $p0
              i32.load offset=4
              local.set $l3
              local.get $p0
              local.get $l3
              i32.const 2
              i32.shl
              i32.add
              local.get $l1
              i32.load
              i32.store
              local.get $p0
              local.get $l3
              i32.const 1
              i32.add
              i32.store offset=4
              call $fimport$15
              local.get $p0
              i32.load offset=4
              i32.const 2
              i32.shl
              local.get $p0
              i32.add
              i32.const 4
              i32.sub
              i32.load
              local.set $l1
              i32.const 4124008 ;; 校验存档错误
              call $j925
              i32.const 0
              call $j2817 ;; ThinkingManager$$TestError
              i32.const 4124008 ;; 校验存档错误
              call $j925
              local.set $l3
              i32.const 0
              local.set $l2
              local.get $l1
              if $I9
                i32.const 4124008 ;; 校验存档错误
                call $j925
                local.set $l3
                local.get $l1
                local.set $l2
                local.get $l1
                i32.load
                local.set $l1
                local.get $l2
                local.get $l1
                i32.load offset=216
                local.get $l1
                i32.load offset=212
                global.set $__wasm_split_waitTableId
                global.get $__wasm_split_waitTableId
                call_indirect $primary.table (type $t1)
                local.set $l2
              end
              local.get $l3
              local.get $l2
              i32.const 0
              call $j962 ;; System.String$$Concat
              local.set $l1
              i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
              call $j925
              call $j923
              local.get $l1
              i32.const 0
              call $j1050 ;; UnityEngine.Debug$$LogError
              local.get $p0
              local.get $p0
              i32.load offset=4
              i32.const 1
              i32.sub
              i32.store offset=4
            end
            i32.const 3955752 ;; GooseStoreHelper_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j44932 ;; GooseStoreHelper$$CheckStoreNetGoose
            i32.const 0
            call $j4547 ;; WeChatWASM.WX$$GetLaunchOptionsSync
            i32.load offset=8
            local.set $p0
            i32.const 3954292 ;; DouYinExpertManager_TypeInfo
            i32.load
            call $j923
            local.get $p0
            i32.const 1
            i32.const 0
            call $j46911 ;; DouYinExpertManager$$GetOnlineQuery
            i32.const 3955916 ;; HWTaskReportHelper_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j44742 ;; HWTaskReportHelper$$OnInit
            local.get $l4
            i32.const 16
            i32.add
            global.set $primary.global$0
            return
          end
          i32.const 4
          call $fimport$14
          local.set $p0
          local.get $p0
          local.get $l1
          i32.load
          i32.store
          i32.const 4610948
          i32.const 0
          i32.store
          i32.const 706
          local.get $p0
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
        local.set $l1
        call $fimport$1
        drop
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
        br_if $B3
        i32.const 0
        call $fimport$0
        drop
        call $fimport$1
        drop
        call $j944
      end
      unreachable
    end
    local.get $l1
    call $fimport$10
    unreachable)
