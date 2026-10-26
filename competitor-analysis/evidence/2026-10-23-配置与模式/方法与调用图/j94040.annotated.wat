  (func $j94040 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i64) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5139995
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952324 ;; bool_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 4076204 ;; CurLevel is not exist
      call $j922
      i32.const 4119064 ;; {0}关清理生成池,isStart={1}
      call $j922
      i32.const 5139995
      i32.const 1
      i32.store8
    end
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    local.get $p3
    call $j1600 ;; NetInitManager$$CanShowSEventDetail
    if $I1
      local.get $p3
      local.get $p1
      i32.store offset=24
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      i32.load
      local.get $p3
      i32.const 24
      i32.add
      call $j935
      local.set $l5
      local.get $p3
      local.get $p2
      i32.store8 offset=16
      i32.const 3952324 ;; bool_TypeInfo
      i32.load
      local.get $p3
      i32.const 16
      i32.add
      call $j935
      local.set $l6
      i32.const 2
      i32.const 4119064 ;; {0}关清理生成池,isStart={1}
      i32.load
      local.get $l5
      local.get $l6
      i32.const 0
      call $j1060 ;; System.String$$Format
      i32.const 0
      call $j1429 ;; GameManager$$LogInColor
    end
    block $B2
      block $B3
        local.get $p2
        if $I4
          local.get $p0
          i32.load
          local.set $p2
          local.get $p3
          i32.const 16
          i32.add
          local.get $p0
          local.get $p1
          local.get $p2
          i32.const 272
          i32.add
          i32.load offset=192
          local.get $p2
          i32.load offset=460
          global.set $__wasm_split_waitTableId
          global.get $__wasm_split_waitTableId
          call_indirect $primary.table (type $t6)
          local.get $p3
          i64.load offset=16
          local.set $l4
          local.get $p3
          local.get $l4
          i64.store offset=24
          local.get $p3
          i32.const 24
          i32.add
          local.get $p3
          call $j4381 ;; LevelIndexAndType$$get_IsExist
          if $I5
            i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
            i32.load
            call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
            local.set $p0
            local.get $p3
            local.get $l4
            i64.store
            local.get $p3
            local.get $l4
            i64.store offset=8
            local.get $p0
            local.get $p3
            i32.const 0
            call $j43492 ;; LevelObjectPool$$ClearWithoutLevel
            br $B2
          end
          i32.const 4076204 ;; CurLevel is not exist
          i32.load
          i32.const 0
          i32.const 0
          call $j1229 ;; Kunpo.Debugger$$LogError
          local.get $p1
          i32.const 20
          i32.gt_u
          br_if $B2
          i32.const 1
          local.get $p1
          i32.shl
          local.set $p1
          local.get $p1
          i32.const 1049280
          i32.and
          br_if $B3
          local.get $p1
          i32.const 11
          i32.and
          i32.eqz
          br_if $B2
          local.get $p0
          i32.load offset=12
          i32.const 0
          call $j37313 ;; LevelManager.StateAPI$$CleanAllSpLevelMemory
          br $B2
        end
        i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
        i32.load
        call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
        i32.const 0
        call $j43491 ;; LevelObjectPool$$Clear
        br $B2
      end
      local.get $p0
      i32.load offset=12
      i32.const 0
      call $j37312 ;; LevelManager.StateAPI$$CleanMainLevelMemory
    end
    local.get $p3
    i32.const 32
    i32.add
    global.set $primary.global$0)
