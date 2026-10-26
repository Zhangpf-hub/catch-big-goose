  (func $j94018 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    local.get $p3
    local.get $p1
    i32.store offset=12
    i32.const 5139981
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951304 ;; ADShareManager_TypeInfo
      call $j922
      i32.const 3952576 ;; CameraControl_TypeInfo
      call $j922
      i32.const 3955500 ;; GameSceneMa_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 5139981
      i32.const 1
      i32.store8
    end
    i32.const 3952576 ;; CameraControl_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.get $p2
    i32.const 0
    call $j15611 ;; CameraControl$$ChangeCameraPos
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    local.get $p1
                    br_table $B8 $B7 $B1 $B6 $B1 $B1 $B4 $B5 $B1 $B2 $B3
                  end
                  i32.const 3955500 ;; GameSceneMa_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load
                  i32.const 2
                  i32.const 0
                  i32.const 0
                  call $j5209 ;; GameSceneMa$$ChangeToScene
                  i32.const 1
                  i32.const 0
                  call $j1601 ;; GameManager$$SetGameState
                  i32.const 3958052 ;; LevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3958052 ;; LevelManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=28
                  i32.const 1
                  i32.ne
                  if $I9
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    i32.load
                    call $j923
                    i32.const 5140203
                    i32.load8_u
                    i32.eqz
                    if $I10
                      i32.const 3958464 ;; MainLevelManager_TypeInfo
                      call $j922
                      i32.const 5140203
                      i32.const 1
                      i32.store8
                    end
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    i32.load
                    call $j923
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=4
                    i32.const 2
                    i32.lt_s
                    br_if $B1
                  end
                  local.get $p0
                  i32.load
                  local.set $p1
                  local.get $p0
                  i32.const 0
                  i32.const 1
                  local.get $p1
                  i32.const 344
                  i32.add
                  i32.load offset=192
                  local.get $p1
                  i32.load offset=532
                  global.set $__wasm_split_waitTableId
                  global.get $__wasm_split_waitTableId
                  call_indirect $primary.table (type $t6)
                  local.get $p0
                  i32.load offset=12
                  i32.const 0
                  call $j37310 ;; LevelManager.StateAPI$$ResetEndAnim
                  i32.const 3958464 ;; MainLevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 5140204
                  i32.load8_u
                  i32.eqz
                  if $I11
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    call $j922
                    i32.const 5140204
                    i32.const 1
                    i32.store8
                  end
                  i32.const 3958464 ;; MainLevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3958464 ;; MainLevelManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=8
                  local.set $p1
                  i32.const 5140203
                  i32.load8_u
                  i32.eqz
                  if $I12
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    call $j922
                    i32.const 5140203
                    i32.const 1
                    i32.store8
                  end
                  i32.const 3958464 ;; MainLevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3958464 ;; MainLevelManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=4
                  local.set $p2
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 5142651
                  i32.load8_u
                  i32.eqz
                  if $I13
                    i32.const 3959288 ;; NetDataManager_TypeInfo
                    call $j922
                    i32.const 5142651
                    i32.const 1
                    i32.store8
                  end
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=32
                  i32.load offset=96
                  local.get $p1
                  local.get $p2
                  i32.const 0
                  call $j35801 ;; ThinkingManager$$MainLevelStart
                  i32.const 3951304 ;; ADShareManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 0
                  call $j50920 ;; ADShareManager$$EndLevel
                  local.get $p0
                  i32.load offset=12
                  i32.const 0
                  call $j7111 ;; LevelManager.StateAPI$$InitShake
                  br $B1
                end
                local.get $p0
                i32.load
                local.set $p1
                local.get $p0
                i32.const 1
                i32.const 1
                local.get $p1
                i32.const 344
                i32.add
                i32.load offset=192
                local.get $p1
                i32.load offset=532
                global.set $__wasm_split_waitTableId
                global.get $__wasm_split_waitTableId
                call_indirect $primary.table (type $t6)
                local.get $p0
                i32.load offset=16
                i32.const 0
                i32.store8 offset=8
                i32.const 3955500 ;; GameSceneMa_TypeInfo
                i32.load
                i32.load offset=92
                i32.load
                i32.const 4
                i32.const 0
                i32.const 0
                call $j5209 ;; GameSceneMa$$ChangeToScene
                i32.const 6
                i32.const 0
                call $j1601 ;; GameManager$$SetGameState
                br $B1
              end
              local.get $p0
              i32.load
              local.set $p1
              local.get $p0
              i32.const 3
              i32.const 1
              local.get $p1
              i32.const 344
              i32.add
              i32.load offset=192
              local.get $p1
              i32.load offset=532
              global.set $__wasm_split_waitTableId
              global.get $__wasm_split_waitTableId
              call_indirect $primary.table (type $t6)
              i32.const 3955500 ;; GameSceneMa_TypeInfo
              i32.load
              i32.load offset=92
              i32.load
              i32.const 2
              i32.const 0
              i32.const 0
              call $j5209 ;; GameSceneMa$$ChangeToScene
              i32.const 8
              i32.const 0
              call $j1601 ;; GameManager$$SetGameState
              local.get $p0
              i32.load offset=12
              i32.const 0
              call $j37311 ;; LevelManager.StateAPI$$InitOnlineLevelData
              local.get $p0
              i32.load offset=12
              i32.const 0
              call $j7111 ;; LevelManager.StateAPI$$InitShake
              br $B1
            end
            local.get $p0
            i32.load
            local.set $p1
            local.get $p0
            i32.const 7
            i32.const 1
            local.get $p1
            i32.const 344
            i32.add
            i32.load offset=192
            local.get $p1
            i32.load offset=532
            global.set $__wasm_split_waitTableId
            global.get $__wasm_split_waitTableId
            call_indirect $primary.table (type $t6)
            i32.const 3955500 ;; GameSceneMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.const 2
            i32.const 0
            i32.const 0
            call $j5209 ;; GameSceneMa$$ChangeToScene
            i32.const 12
            i32.const 0
            call $j1601 ;; GameManager$$SetGameState
            local.get $p0
            i32.load offset=12
            i32.const 0
            call $j7111 ;; LevelManager.StateAPI$$InitShake
            i32.const 3952576 ;; CameraControl_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.const 1
            i32.const 0
            call $j15611 ;; CameraControl$$ChangeCameraPos
            br $B1
          end
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 0
          call $j2269 ;; SpLevelManager$$GetSpLevelTodaySave
          local.set $p1
          local.get $p1
          if $I14
            local.get $p1
            local.get $p1
            i32.load offset=16
            i32.const 1
            i32.add
            i32.store offset=16
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
            i32.const 3955516 ;; GameTypeEnum_TypeInfo
            i32.load
            local.set $p2
            local.get $p3
            i32.const -1
            i32.store offset=4
            local.get $p3
            local.get $p2
            i32.store
            local.get $p3
            local.get $p3
            i32.load offset=12
            i32.store offset=8
            local.get $p3
            i32.const 0
            call $j1009 ;; System.Enum$$ToString
            local.get $p1
            i32.load offset=16
            i32.const 0
            call $j35704 ;; ThinkingManager$$SpLevelStart
            local.get $p3
            i32.load offset=12
            local.set $p2
          else
            i32.const 6
            local.set $p2
          end
          local.get $p0
          i32.load
          local.set $p1
          local.get $p0
          local.get $p2
          i32.const 1
          local.get $p1
          i32.const 344
          i32.add
          i32.load offset=192
          local.get $p1
          i32.load offset=532
          global.set $__wasm_split_waitTableId
          global.get $__wasm_split_waitTableId
          call_indirect $primary.table (type $t6)
          i32.const 3955500 ;; GameSceneMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.const 2
          i32.const 0
          i32.const 0
          call $j5209 ;; GameSceneMa$$ChangeToScene
          i32.const 11
          i32.const 0
          call $j1601 ;; GameManager$$SetGameState
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j37551 ;; SpLevelManager$$InitSpLevelData
          local.get $p0
          i32.load offset=12
          i32.const 0
          call $j7111 ;; LevelManager.StateAPI$$InitShake
          br $B1
        end
        local.get $p1
        i32.const 20
        i32.ne
        br_if $B1
        local.get $p0
        i32.load
        local.set $p1
        local.get $p0
        i32.const 20
        i32.const 1
        local.get $p1
        i32.const 344
        i32.add
        i32.load offset=192
        local.get $p1
        i32.load offset=532
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t6)
        i32.const 3955500 ;; GameSceneMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 2
        i32.const 0
        i32.const 0
        call $j5209 ;; GameSceneMa$$ChangeToScene
        i32.const 11
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        local.get $p0
        i32.load offset=12
        i32.const 0
        call $j7111 ;; LevelManager.StateAPI$$InitShake
        br $B1
      end
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 0
      call $j2269 ;; SpLevelManager$$GetSpLevelTodaySave
      local.set $p1
      local.get $p1
      if $I15
        local.get $p1
        local.get $p1
        i32.load offset=16
        i32.const 1
        i32.add
        i32.store offset=16
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
      end
      local.get $p0
      i32.load
      local.set $p1
      local.get $p0
      i32.const 9
      i32.const 1
      local.get $p1
      i32.const 344
      i32.add
      i32.load offset=192
      local.get $p1
      i32.load offset=532
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t6)
      i32.const 3955500 ;; GameSceneMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 2
      i32.const 0
      i32.const 0
      call $j5209 ;; GameSceneMa$$ChangeToScene
      i32.const 11
      i32.const 0
      call $j1601 ;; GameManager$$SetGameState
      local.get $p0
      i32.load offset=12
      i32.const 0
      call $j7111 ;; LevelManager.StateAPI$$InitShake
      local.get $p0
      i32.load
      local.set $p1
      local.get $p0
      local.get $p1
      i32.const 328
      i32.add
      i32.load offset=192
      local.get $p1
      i32.load offset=516
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t1)
      i32.eqz
      br_if $B1
      i32.const 3952576 ;; CameraControl_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 2
      i32.const 0
      call $j15611 ;; CameraControl$$ChangeCameraPos
    end
    local.get $p0
    local.get $p0
    call $j43086 ;; MainLevelModeCtrl$$OnStartLevelInitEnd
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0)
