  (func $j10876 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i64)
    global.get $primary.global$0
    i32.const 304
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    local.get $p2
    local.get $p1
    i32.store offset=300
    i32.const 5140136
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3955916 ;; HWTaskReportHelper_TypeInfo
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      call $j922
      i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
      call $j922
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      call $j922
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      call $j922
      i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
      call $j922
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      call $j922
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
      call $j922
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      call $j922
      i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3950508 ;; ObjectUnit[]_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 3962284 ;; SoundManager_TypeInfo
      call $j922
      i32.const 3963668 ;; ToolType_TypeInfo
      call $j922
      i32.const 4124988 ;; 空位不足
      call $j922
      i32.const 4126652 ;; 道具加载中，稍后再试
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140136
      i32.const 1
      i32.store8
    end
    local.get $p2
    i32.const 0
    i32.store offset=296
    local.get $p2
    i64.const 0
    i64.store offset=288
    local.get $p2
    i32.const 0
    i32.store offset=280
    local.get $p2
    i64.const 0
    i64.store offset=272
    local.get $p2
    i32.const 0
    i32.store offset=264
    local.get $p2
    i64.const 0
    i64.store offset=256
    local.get $p2
    i32.const 0
    i32.store offset=248
    local.get $p2
    i64.const 0
    i64.store offset=240
    local.get $p2
    i32.const 0
    i32.store offset=232
    local.get $p2
    i64.const 0
    i64.store offset=224
    local.get $p2
    i32.const 0
    i32.store offset=216
    local.get $p2
    i64.const 0
    i64.store offset=208
    local.get $p2
    i32.const 0
    i32.store offset=200
    local.get $p2
    i64.const 0
    i64.store offset=192
    local.get $p2
    i32.const 0
    i32.store offset=184
    local.get $p2
    i64.const 0
    i64.store offset=176
    i32.const 3963668 ;; ToolType_TypeInfo
    i32.load
    local.set $l3
    local.get $p2
    i32.const 160
    i32.add
    local.set $p1
    local.get $p1
    i32.const -1
    i32.store offset=4
    local.get $p1
    local.get $l3
    i32.store
    local.get $p1
    local.get $p2
    i32.load offset=300
    i32.store offset=8
    local.get $p1
    i32.const 0
    call $j1009 ;; System.Enum$$ToString
    local.set $p1
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j23922 ;; ConfigManager$$GetItemIDByKey
    local.set $p1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 5142651
    i32.load8_u
    i32.eqz
    if $I1
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
    i32.load offset=36
    i32.load offset=8
    local.set $l3
    local.get $p0
    i32.load offset=196
    local.get $p0
    i32.load offset=200
    i32.sub
    local.set $l4
    i32.const 0
    call $j7299 ;; NetDataManager$$GetGameSumTime
    local.set $l5
    local.get $p0
    i32.load offset=384
    local.set $l6
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 4
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $l6
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    call $j1018
    local.set $l6
    local.get $p2
    i32.const 152
    i32.add
    i32.const 5
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $p0
    i32.load offset=384
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    call $j1359
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    local.set $l7
    local.get $p2
    i64.load offset=152
    local.set $l8
    local.get $p2
    local.get $l8
    i64.store offset=136
    local.get $p2
    local.get $l8
    i64.store offset=144
    local.get $p1
    local.get $l3
    local.get $l7
    local.get $l4
    f32.convert_i32_s
    local.get $l5
    local.get $l6
    local.get $p2
    i32.const 136
    i32.add
    i32.const 0
    call $j35701 ;; ThinkingManager$$ToolUse
    local.get $p2
    i32.load offset=300
    local.set $p1
    i32.const 3955916 ;; HWTaskReportHelper_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j44741 ;; HWTaskReportHelper$$OnToolUsed
    local.get $p2
    i32.load offset=300
    local.set $p1
    i32.const 3958084 ;; LevelToolMa_TypeInfo
    i32.load
    call $j923
    block $B2
      block $B3
        local.get $p1
        i32.const 3958084 ;; LevelToolMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.load offset=16
        i32.eq
        if $I4
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=40
          i32.load offset=24
          i32.const 16
          i32.add
          local.set $p1
          br $B3
        end
        i32.const 3958084 ;; LevelToolMa_TypeInfo
        i32.load
        call $j923
        block $B5
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B5
          local.get $p2
          i32.load offset=300
          local.set $p1
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.load offset=20
          i32.ne
          br_if $B5
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=40
          i32.load offset=24
          i32.const 20
          i32.add
          local.set $p1
          br $B3
        end
        i32.const 3958084 ;; LevelToolMa_TypeInfo
        i32.load
        call $j923
        block $B6
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.load offset=12
          i32.const 3
          i32.lt_s
          br_if $B6
          local.get $p2
          i32.load offset=300
          local.set $p1
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.load offset=24
          i32.ne
          br_if $B6
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=40
          i32.load offset=24
          i32.const 24
          i32.add
          local.set $p1
          br $B3
        end
        block $B7
          block $B8
            block $B9
              local.get $p2
              i32.load offset=300
              local.set $p1
              local.get $p1
              i32.const 3
              i32.sub
              br_table $B9 $B7 $B8
            end
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=40
            i32.const 28
            i32.add
            local.set $p1
            br $B3
          end
          local.get $p1
          i32.const 15
          i32.ne
          br_if $B2
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=40
        i32.const 32
        i32.add
        local.set $p1
      end
      local.get $p1
      local.get $p1
      i32.load
      i32.const 1
      i32.add
      i32.store
      local.get $p2
      i32.load offset=300
      local.set $p1
    end
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
                        block $B20
                          block $B21
                            block $B22
                              block $B23
                                block $B24
                                  local.get $p1
                                  br_table $B24 $B21 $B20 $B17 $B16 $B18 $B19 $B22 $B11 $B11 $B15 $B13 $B12 $B11 $B11 $B14 $B23
                                end
                                i32.const 3962284 ;; SoundManager_TypeInfo
                                i32.load
                                call $j923
                                i32.const 24
                                i32.const 0
                                i32.const 4063796 ;; 
                                i32.load
                                i32.const 0
                                call $j1654 ;; SoundManager$$PlayEffectSound
                                local.get $p0
                                local.get $p0
                                call $j4380 ;; LevelManager$$CheckObjMaxHeight
                                i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                                i32.load
                                drop
                                local.get $p0
                                i32.load offset=148
                                i32.load offset=12
                                local.set $p1
                                i32.const 3950508 ;; ObjectUnit[]_TypeInfo
                                i32.load
                                local.get $p1
                                i32.const 3
                                local.get $p1
                                i32.const 3
                                i32.lt_s
                                select
                                call $j939
                                local.set $p1
                                i32.const 0
                                local.set $l3
                                loop $L25
                                  local.get $p1
                                  i32.load offset=12
                                  local.set $l4
                                  local.get $l4
                                  local.get $l3
                                  i32.gt_s
                                  if $I26
                                    local.get $p0
                                    i32.load offset=148
                                    local.get $l3
                                    i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                    i32.load
                                    call $j947
                                    local.set $l4
                                    local.get $p1
                                    local.get $l4
                                    call $j930
                                    local.get $p1
                                    local.get $l3
                                    i32.const 2
                                    i32.shl
                                    i32.add
                                    local.get $l4
                                    i32.store offset=16
                                    local.get $l3
                                    i32.const 1
                                    i32.add
                                    local.set $l3
                                    br $L25
                                  end
                                end
                                i32.const 0
                                local.set $l3
                                loop $L27
                                  local.get $l3
                                  local.get $l4
                                  i32.lt_s
                                  if $I28
                                    local.get $p0
                                    i32.load offset=148
                                    local.get $p1
                                    local.get $l3
                                    i32.const 2
                                    i32.shl
                                    i32.add
                                    i32.load offset=16
                                    i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                                    i32.load
                                    call $j1387
                                    drop
                                    local.get $p0
                                    i32.load offset=152
                                    local.get $p1
                                    local.get $l3
                                    i32.const 2
                                    i32.shl
                                    i32.add
                                    i32.load offset=16
                                    i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                                    i32.load
                                    call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                                    block $B29
                                      local.get $p0
                                      i32.load8_u offset=644
                                      if $I30
                                        local.get $p0
                                        local.get $p1
                                        local.get $l3
                                        i32.const 2
                                        i32.shl
                                        i32.add
                                        i32.load offset=16
                                        local.get $p0
                                        call $j22236 ;; LevelManager$$SetObjIntoStore
                                        br $B29
                                      end
                                      local.get $p2
                                      i32.const 288
                                      i32.add
                                      local.get $p0
                                      i32.const 1
                                      local.get $p0
                                      call $j4699 ;; LevelManager$$ThrowPos
                                      local.get $p1
                                      local.get $l3
                                      i32.const 2
                                      i32.shl
                                      i32.add
                                      i32.load offset=16
                                      local.set $l4
                                      local.get $p0
                                      i32.load offset=88
                                      local.set $l5
                                      local.get $p2
                                      local.get $p2
                                      i32.load offset=296
                                      i32.store offset=16
                                      local.get $p2
                                      local.get $p2
                                      i64.load offset=288
                                      i64.store offset=8
                                      local.get $l4
                                      local.get $p2
                                      i32.const 8
                                      i32.add
                                      local.get $l5
                                      i32.const 0
                                      call $j6376 ;; ObjectUnit$$ThrowBack
                                    end
                                    local.get $l3
                                    i32.const 1
                                    i32.add
                                    local.set $l3
                                    local.get $p1
                                    i32.load offset=12
                                    local.set $l4
                                    br $L27
                                  end
                                end
                                block $B31
                                  local.get $p0
                                  i32.load8_u offset=644
                                  i32.eqz
                                  br_if $B31
                                  i32.const 0
                                  local.set $l3
                                  loop $L32
                                    local.get $l3
                                    local.get $l4
                                    i32.ge_s
                                    br_if $B31
                                    local.get $p1
                                    local.get $l3
                                    i32.const 2
                                    i32.shl
                                    i32.add
                                    i32.load offset=16
                                    local.set $l4
                                    local.get $p2
                                    i32.const 160
                                    i32.add
                                    local.get $p0
                                    i32.load offset=88
                                    i32.const 0
                                    call $j1418 ;; UnityEngine.Transform$$get_localScale
                                    local.get $l4
                                    local.get $p2
                                    f32.load offset=160
                                    i32.const 0
                                    call $j21506 ;; ObjectUnit$$StoreObj
                                    local.get $l3
                                    i32.const 1
                                    i32.add
                                    local.set $l3
                                    local.get $p1
                                    i32.load offset=12
                                    local.set $l4
                                    br $L32
                                  end
                                  unreachable
                                end
                                i32.const 3958052 ;; LevelManager_TypeInfo
                                i32.load
                                call $j923
                                local.get $p0
                                call $j6451 ;; LevelManager$$CanUseNewAnim
                                if $I33
                                  local.get $p0
                                  i32.load offset=612
                                  i32.const 1
                                  i32.const 0
                                  call $j10875 ;; LevelObjAnimManager$$SortContentObj
                                  br $B11
                                end
                                local.get $p0
                                i32.const 1
                                i32.const 0
                                local.get $p0
                                call $j5154 ;; LevelManager$$RefreshContentDisplay
                                br $B11
                              end
                              local.get $p1
                              i32.const 110
                              i32.ne
                              br_if $B11
                              i32.const 3962284 ;; SoundManager_TypeInfo
                              i32.load
                              call $j923
                              i32.const 24
                              i32.const 0
                              i32.const 4063796 ;; 
                              i32.load
                              i32.const 0
                              call $j1654 ;; SoundManager$$PlayEffectSound
                              local.get $p0
                              local.get $p0
                              call $j4380 ;; LevelManager$$CheckObjMaxHeight
                              i32.const 0
                              local.set $p1
                              loop $L34
                                i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                                i32.load
                                drop
                                local.get $p1
                                local.get $p0
                                i32.load offset=148
                                i32.load offset=12
                                i32.lt_s
                                if $I35
                                  local.get $p0
                                  i32.load offset=152
                                  local.get $p0
                                  i32.load offset=148
                                  local.get $p1
                                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                  i32.load
                                  call $j947
                                  i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                                  i32.load
                                  call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                                  local.get $p2
                                  i32.const 272
                                  i32.add
                                  local.get $p0
                                  i32.const 1
                                  local.get $p0
                                  call $j4699 ;; LevelManager$$ThrowPos
                                  local.get $p0
                                  i32.load offset=148
                                  local.get $p1
                                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                  i32.load
                                  call $j947
                                  local.set $l3
                                  local.get $p0
                                  i32.load offset=88
                                  local.set $l4
                                  local.get $p2
                                  local.get $p2
                                  i32.load offset=280
                                  i32.store offset=96
                                  local.get $p2
                                  local.get $p2
                                  i64.load offset=272
                                  i64.store offset=88
                                  local.get $l3
                                  local.get $p2
                                  i32.const 88
                                  i32.add
                                  local.get $l4
                                  i32.const 0
                                  call $j6376 ;; ObjectUnit$$ThrowBack
                                  local.get $p1
                                  i32.const 1
                                  i32.add
                                  local.set $p1
                                  br $L34
                                end
                              end
                              local.get $p0
                              i32.load offset=148
                              i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
                              i32.load
                              call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
                              local.get $p0
                              i32.const 1
                              i32.const 0
                              local.get $p0
                              call $j5154 ;; LevelManager$$RefreshContentDisplay
                              br $B11
                            end
                            i32.const 3962284 ;; SoundManager_TypeInfo
                            i32.load
                            call $j923
                            i32.const 24
                            i32.const 0
                            i32.const 4063796 ;; 
                            i32.load
                            i32.const 0
                            call $j1654 ;; SoundManager$$PlayEffectSound
                            local.get $p0
                            local.get $p0
                            call $j4380 ;; LevelManager$$CheckObjMaxHeight
                            i32.const 3959844 ;; PVPManager_TypeInfo
                            i32.load
                            call $j923
                            i32.const 3959844 ;; PVPManager_TypeInfo
                            i32.load
                            i32.load offset=92
                            i32.load offset=136
                            local.set $p1
                            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                            i32.load
                            drop
                            local.get $p0
                            i32.load offset=148
                            i32.load offset=12
                            local.set $l3
                            i32.const 3950508 ;; ObjectUnit[]_TypeInfo
                            i32.load
                            local.get $p1
                            local.get $l3
                            local.get $p1
                            local.get $l3
                            i32.lt_s
                            select
                            call $j939
                            local.set $p1
                            i32.const 0
                            local.set $l3
                            loop $L36
                              local.get $p1
                              i32.load offset=12
                              local.set $l4
                              local.get $l4
                              local.get $l3
                              i32.gt_s
                              if $I37
                                local.get $p0
                                i32.load offset=148
                                local.get $l3
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                local.set $l4
                                local.get $p1
                                local.get $l4
                                call $j930
                                local.get $p1
                                local.get $l3
                                i32.const 2
                                i32.shl
                                i32.add
                                local.get $l4
                                i32.store offset=16
                                local.get $l3
                                i32.const 1
                                i32.add
                                local.set $l3
                                br $L36
                              end
                            end
                            i32.const 0
                            local.set $l3
                            loop $L38
                              local.get $l3
                              local.get $l4
                              i32.lt_s
                              if $I39
                                local.get $p0
                                i32.load offset=148
                                local.get $p1
                                local.get $l3
                                i32.const 2
                                i32.shl
                                i32.add
                                i32.load offset=16
                                i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                                i32.load
                                call $j1387
                                drop
                                local.get $p0
                                i32.load offset=152
                                local.get $p1
                                local.get $l3
                                i32.const 2
                                i32.shl
                                i32.add
                                i32.load offset=16
                                i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                                i32.load
                                call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                                local.get $p2
                                i32.const 256
                                i32.add
                                local.get $p0
                                i32.const 1
                                local.get $p0
                                call $j4699 ;; LevelManager$$ThrowPos
                                local.get $p1
                                local.get $l3
                                i32.const 2
                                i32.shl
                                i32.add
                                i32.load offset=16
                                local.set $l4
                                local.get $p0
                                i32.load offset=88
                                local.set $l5
                                local.get $p2
                                local.get $p2
                                i32.load offset=264
                                i32.store offset=80
                                local.get $p2
                                local.get $p2
                                i64.load offset=256
                                i64.store offset=72
                                local.get $l4
                                local.get $p2
                                i32.const 72
                                i32.add
                                local.get $l5
                                i32.const 0
                                call $j6376 ;; ObjectUnit$$ThrowBack
                                local.get $l3
                                i32.const 1
                                i32.add
                                local.set $l3
                                local.get $p1
                                i32.load offset=12
                                local.set $l4
                                br $L38
                              end
                            end
                            local.get $p0
                            i32.const 1
                            i32.const 0
                            local.get $p0
                            call $j5154 ;; LevelManager$$RefreshContentDisplay
                            br $B11
                          end
                          i32.const 3962284 ;; SoundManager_TypeInfo
                          i32.load
                          call $j923
                          i32.const 25
                          i32.const 0
                          i32.const 4063796 ;; 
                          i32.load
                          i32.const 0
                          call $j1654 ;; SoundManager$$PlayEffectSound
                          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                          i32.load
                          drop
                          i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
                          i32.load
                          drop
                          local.get $p0
                          i32.load offset=148
                          i32.load offset=12
                          local.get $p0
                          i32.load offset=144
                          i32.load offset=12
                          i32.const 1
                          i32.sub
                          i32.eq
                          if $I40
                            local.get $p0
                            i32.load offset=148
                            i32.const 0
                            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                            i32.load
                            call $j947
                            i32.load offset=12
                            local.set $l3
                            i32.const 1
                            local.set $p1
                            loop $L41
                              i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                              i32.load
                              drop
                              local.get $p1
                              local.get $p0
                              i32.load offset=148
                              i32.load offset=12
                              i32.lt_s
                              if $I42
                                local.get $l3
                                local.get $p0
                                i32.load offset=148
                                local.get $p1
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                i32.load offset=12
                                i32.const 0
                                call $j949 ;; System.String$$op_Equality
                                if $I43
                                  i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                                  i32.load
                                  drop
                                  local.get $p0
                                  i32.load offset=152
                                  i32.load offset=12
                                  local.set $p1
                                  block $B44
                                    loop $L45
                                      local.get $p1
                                      i32.const 1
                                      i32.sub
                                      local.set $p1
                                      local.get $p1
                                      i32.const -1
                                      i32.le_s
                                      br_if $B44
                                      local.get $p0
                                      i32.load offset=152
                                      local.get $p1
                                      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                      i32.load
                                      call $j947
                                      i32.load offset=12
                                      local.get $l3
                                      i32.const 0
                                      call $j949 ;; System.String$$op_Equality
                                      i32.eqz
                                      br_if $L45
                                    end
                                    local.get $p0
                                    i32.load offset=152
                                    local.get $p1
                                    i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                    i32.load
                                    call $j947
                                    i32.const 0
                                    call $j979 ;; UnityEngine.Component$$get_transform
                                    local.set $l3
                                    local.get $p2
                                    i32.const 240
                                    i32.add
                                    local.get $p0
                                    local.get $p0
                                    i32.load offset=152
                                    local.get $p1
                                    i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                    i32.load
                                    call $j947
                                    i32.const 1
                                    i32.const 0
                                    local.get $p0
                                    call $j14621 ;; LevelManager$$GetUnit
                                    local.get $p2
                                    local.get $p2
                                    i32.load offset=248
                                    i32.store offset=32
                                    local.get $p2
                                    local.get $p2
                                    i64.load offset=240
                                    i64.store offset=24
                                    local.get $p0
                                    local.get $p2
                                    i32.const 24
                                    i32.add
                                    local.get $l3
                                    i32.const 0
                                    local.get $p0
                                    call $j22255 ;; LevelManager$$CreateAutoFindLighting
                                  end
                                  i32.const 3951356 ;; ActionManager_TypeInfo
                                  i32.load
                                  call $j923
                                  i32.const 1
                                  local.set $p1
                                  i32.const 3951356 ;; ActionManager_TypeInfo
                                  i32.load
                                  i32.load offset=92
                                  i32.load offset=16
                                  local.set $p0
                                  local.get $p0
                                  i32.eqz
                                  br_if $B10
                                  local.get $p0
                                  local.get $p2
                                  i32.load offset=300
                                  i32.const 0
                                  call $j1561
                                  br $B10
                                end
                                local.get $p0
                                i32.load offset=148
                                local.get $p1
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                i32.load offset=12
                                local.set $l3
                                local.get $p1
                                i32.const 1
                                i32.add
                                local.set $p1
                                br $L41
                              end
                            end
                            i32.const 0
                            local.set $p1
                            i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
                            i32.load
                            call $j923
                            i32.const 600
                            i32.const 4124988 ;; 空位不足
                            i32.load
                            i32.const 0
                            call $j1145 ;; Kunpo.KUIManager$$OpenATip
                            br $B10
                          end
                          i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
                          i32.load
                          call $j924
                          local.set $l3
                          local.get $l3
                          i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
                          i32.load
                          call $j965
                          i32.const 0
                          local.set $p1
                          loop $L46
                            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                            i32.load
                            drop
                            local.get $p1
                            local.get $p0
                            i32.load offset=148
                            i32.load offset=12
                            i32.lt_s
                            if $I47
                              local.get $l3
                              local.get $p0
                              i32.load offset=148
                              local.get $p1
                              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                              i32.load
                              call $j947
                              i32.load offset=12
                              i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
                              i32.load
                              call $j1262
                              i32.eqz
                              if $I48
                                local.get $l3
                                local.get $p0
                                i32.load offset=148
                                local.get $p1
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                i32.load offset=12
                                i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
                                i32.load
                                call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                              end
                              local.get $p1
                              i32.const 1
                              i32.add
                              local.set $p1
                              br $L46
                            end
                          end
                          i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
                          i32.load
                          drop
                          local.get $l3
                          i32.const 0
                          local.get $l3
                          i32.load offset=12
                          i32.const 0
                          call $j1479 ;; UnityEngine.Random$$Range
                          i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
                          i32.load
                          call $j947
                          local.set $l5
                          i32.const 0
                          local.set $p1
                          i32.const 0
                          local.set $l3
                          loop $L49
                            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                            i32.load
                            drop
                            local.get $p1
                            local.get $p0
                            i32.load offset=148
                            i32.load offset=12
                            i32.lt_s
                            if $I50
                              local.get $l3
                              i32.const 1
                              i32.add
                              local.get $l3
                              local.get $l5
                              local.get $p0
                              i32.load offset=148
                              local.get $p1
                              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                              i32.load
                              call $j947
                              i32.load offset=12
                              i32.const 0
                              call $j949 ;; System.String$$op_Equality
                              select
                              local.set $l3
                              local.get $p1
                              i32.const 1
                              i32.add
                              local.set $p1
                              br $L49
                            end
                          end
                          i32.const 0
                          local.set $l4
                          loop $L51
                            local.get $l4
                            i32.const 3
                            local.get $l3
                            i32.sub
                            i32.lt_s
                            if $I52
                              i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                              i32.load
                              drop
                              local.get $p0
                              i32.load offset=152
                              i32.load offset=12
                              local.set $p1
                              block $B53
                                loop $L54
                                  local.get $p1
                                  i32.const 1
                                  i32.sub
                                  local.set $p1
                                  local.get $p1
                                  i32.const -1
                                  i32.le_s
                                  br_if $B53
                                  local.get $p0
                                  i32.load offset=152
                                  local.get $p1
                                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                  i32.load
                                  call $j947
                                  i32.load offset=12
                                  local.get $l5
                                  i32.const 0
                                  call $j949 ;; System.String$$op_Equality
                                  i32.eqz
                                  br_if $L54
                                end
                                local.get $p0
                                i32.load offset=152
                                local.get $p1
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                i32.const 0
                                call $j979 ;; UnityEngine.Component$$get_transform
                                local.set $l6
                                local.get $p2
                                i32.const 224
                                i32.add
                                local.get $p0
                                local.get $p0
                                i32.load offset=152
                                local.get $p1
                                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                                i32.load
                                call $j947
                                i32.const 1
                                i32.const 0
                                local.get $p0
                                call $j14621 ;; LevelManager$$GetUnit
                                local.get $p2
                                local.get $p2
                                i32.load offset=232
                                i32.store offset=48
                                local.get $p2
                                local.get $p2
                                i64.load offset=224
                                i64.store offset=40
                                local.get $p0
                                local.get $p2
                                i32.const 40
                                i32.add
                                local.get $l6
                                local.get $l4
                                local.get $p0
                                call $j22255 ;; LevelManager$$CreateAutoFindLighting
                              end
                              local.get $l4
                              i32.const 1
                              i32.add
                              local.set $l4
                              br $L51
                            end
                          end
                          i32.const 3951356 ;; ActionManager_TypeInfo
                          i32.load
                          call $j923
                          i32.const 1
                          local.set $p1
                          i32.const 3951356 ;; ActionManager_TypeInfo
                          i32.load
                          i32.load offset=92
                          i32.load offset=16
                          local.set $p0
                          local.get $p0
                          i32.eqz
                          br_if $B10
                          local.get $p0
                          local.get $p2
                          i32.load offset=300
                          i32.const 0
                          call $j1561
                          br $B10
                        end
                        local.get $p0
                        i32.const 2
                        local.get $p0
                        call $j22238 ;; LevelManager$$PlayToolPartcle
                        local.get $p0
                        local.get $p0
                        local.get $p0
                        call $j22241 ;; LevelManager$$MessObjRotaAnim
                        i32.const 0
                        call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
                        drop
                        br $B11
                      end
                      i32.const 3962284 ;; SoundManager_TypeInfo
                      i32.load
                      call $j923
                      i32.const 35
                      i32.const 0
                      i32.const 4063796 ;; 
                      i32.load
                      i32.const 0
                      call $j1654 ;; SoundManager$$PlayEffectSound
                      local.get $p0
                      local.get $p0
                      call $j43510 ;; LevelManager$$ShakeObj
                      br $B11
                    end
                    local.get $p0
                    i32.load offset=704
                    local.set $l3
                    i32.const 0
                    local.set $p1
                    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
                    i32.load
                    call $j923
                    local.get $l3
                    i32.const 0
                    i32.const 0
                    call $j980 ;; UnityEngine.Object$$op_Equality
                    if $I55
                      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
                      i32.load
                      call $j923
                      i32.const 600
                      i32.const 4126652 ;; 道具加载中，稍后再试
                      i32.load
                      i32.const 0
                      call $j1145 ;; Kunpo.KUIManager$$OpenATip
                      br $B10
                    end
                    local.get $p0
                    local.get $p0
                    local.get $p0
                    call $j43553 ;; LevelManager$$ClawObj
                    i32.const 0
                    call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
                    drop
                    br $B11
                  end
                  i32.const 16
                  i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
                  i32.load
                  local.get $p0
                  i32.load offset=384
                  call $j951
                  local.set $p1
                  local.get $p0
                  local.get $p1
                  local.get $p0
                  i32.load offset=200
                  i32.add
                  i32.store offset=200
                  i32.const 3951356 ;; ActionManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3951356 ;; ActionManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=8
                  local.set $p1
                  local.get $p1
                  if $I56
                    local.get $p1
                    local.get $p0
                    i32.load offset=200
                    i32.const 0
                    call $j1561
                  end
                  i32.const 3958052 ;; LevelManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3958052 ;; LevelManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.const 0
                  i32.store8 offset=36
                  br $B11
                end
                i32.const 3962284 ;; SoundManager_TypeInfo
                i32.load
                call $j923
                i32.const 24
                i32.const 0
                i32.const 4063796 ;; 
                i32.load
                i32.const 0
                call $j1654 ;; SoundManager$$PlayEffectSound
                local.get $p0
                local.get $p0
                call $j4380 ;; LevelManager$$CheckObjMaxHeight
                i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
                i32.load
                drop
                i32.const 3950508 ;; ObjectUnit[]_TypeInfo
                i32.load
                local.get $p0
                i32.load offset=148
                i32.load offset=12
                call $j939
                local.set $p1
                i32.const 0
                local.set $l3
                loop $L57
                  local.get $p1
                  i32.load offset=12
                  local.set $l4
                  local.get $l4
                  local.get $l3
                  i32.gt_s
                  if $I58
                    local.get $p0
                    i32.load offset=148
                    local.get $l3
                    i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                    i32.load
                    call $j947
                    local.set $l4
                    local.get $p1
                    local.get $l4
                    call $j930
                    local.get $p1
                    local.get $l3
                    i32.const 2
                    i32.shl
                    i32.add
                    local.get $l4
                    i32.store offset=16
                    local.get $l3
                    i32.const 1
                    i32.add
                    local.set $l3
                    br $L57
                  end
                end
                i32.const 0
                local.set $l3
                loop $L59
                  local.get $l3
                  local.get $l4
                  i32.lt_s
                  if $I60
                    local.get $p0
                    i32.load offset=148
                    local.get $p1
                    local.get $l3
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                    i32.load
                    call $j1387
                    drop
                    local.get $p0
                    i32.load offset=152
                    local.get $p1
                    local.get $l3
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                    i32.load
                    call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                    block $B61
                      local.get $p0
                      i32.load8_u offset=644
                      if $I62
                        local.get $p0
                        local.get $p1
                        local.get $l3
                        i32.const 2
                        i32.shl
                        i32.add
                        i32.load offset=16
                        local.get $p0
                        call $j22236 ;; LevelManager$$SetObjIntoStore
                        br $B61
                      end
                      local.get $p2
                      i32.const 208
                      i32.add
                      local.get $p0
                      i32.const 1
                      local.get $p0
                      call $j4699 ;; LevelManager$$ThrowPos
                      local.get $p1
                      local.get $l3
                      i32.const 2
                      i32.shl
                      i32.add
                      i32.load offset=16
                      local.set $l4
                      local.get $p0
                      i32.load offset=88
                      local.set $l5
                      local.get $p2
                      i32.const -64
                      i32.sub
                      local.get $p2
                      i32.load offset=216
                      i32.store
                      local.get $p2
                      local.get $p2
                      i64.load offset=208
                      i64.store offset=56
                      local.get $l4
                      local.get $p2
                      i32.const 56
                      i32.add
                      local.get $l5
                      i32.const 0
                      call $j6376 ;; ObjectUnit$$ThrowBack
                    end
                    local.get $l3
                    i32.const 1
                    i32.add
                    local.set $l3
                    local.get $p1
                    i32.load offset=12
                    local.set $l4
                    br $L59
                  end
                end
                block $B63
                  local.get $p0
                  i32.load8_u offset=644
                  i32.eqz
                  br_if $B63
                  i32.const 0
                  local.set $l3
                  loop $L64
                    local.get $l3
                    local.get $l4
                    i32.ge_s
                    br_if $B63
                    local.get $p1
                    local.get $l3
                    i32.const 2
                    i32.shl
                    i32.add
                    i32.load offset=16
                    local.set $l4
                    local.get $p2
                    i32.const 160
                    i32.add
                    local.get $p0
                    i32.load offset=88
                    i32.const 0
                    call $j1418 ;; UnityEngine.Transform$$get_localScale
                    local.get $l4
                    local.get $p2
                    f32.load offset=160
                    i32.const 0
                    call $j21506 ;; ObjectUnit$$StoreObj
                    local.get $l3
                    i32.const 1
                    i32.add
                    local.set $l3
                    local.get $p1
                    i32.load offset=12
                    local.set $l4
                    br $L64
                  end
                  unreachable
                end
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                call $j923
                block $B65
                  local.get $p0
                  call $j6451 ;; LevelManager$$CanUseNewAnim
                  if $I66
                    local.get $p0
                    i32.load offset=612
                    i32.const 1
                    i32.const 0
                    call $j10875 ;; LevelObjAnimManager$$SortContentObj
                    br $B65
                  end
                  local.get $p0
                  i32.const 1
                  i32.const 0
                  local.get $p0
                  call $j5154 ;; LevelManager$$RefreshContentDisplay
                end
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                call $j923
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.const 0
                i32.store8 offset=36
                br $B11
              end
              i32.const 3962284 ;; SoundManager_TypeInfo
              i32.load
              call $j923
              i32.const 24
              i32.const 0
              i32.const 4063796 ;; 
              i32.load
              i32.const 0
              call $j1654 ;; SoundManager$$PlayEffectSound
              local.get $p0
              local.get $p0
              call $j4380 ;; LevelManager$$CheckObjMaxHeight
              i32.const 3963668 ;; ToolType_TypeInfo
              i32.load
              local.set $l3
              local.get $p2
              i32.const 160
              i32.add
              local.set $p1
              local.get $p1
              i32.const -1
              i32.store offset=4
              local.get $p1
              local.get $l3
              i32.store
              local.get $p1
              local.get $p2
              i32.load offset=300
              i32.store offset=8
              local.get $p1
              i32.const 0
              call $j1009 ;; System.Enum$$ToString
              local.set $p1
              i32.const 3953096 ;; ConfigManager_TypeInfo
              i32.load
              call $j923
              local.get $p1
              i32.const 0
              call $j4793 ;; ConfigManager$$GetGameToolData
              i32.load offset=28
              local.set $p1
              i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
              i32.load
              drop
              local.get $p0
              i32.load offset=148
              i32.load offset=12
              local.set $l3
              i32.const 3950508 ;; ObjectUnit[]_TypeInfo
              i32.load
              local.get $p1
              local.get $l3
              local.get $p1
              local.get $l3
              i32.lt_s
              select
              call $j939
              local.set $p1
              i32.const 0
              local.set $l3
              loop $L67
                local.get $p1
                i32.load offset=12
                local.set $l4
                local.get $l4
                local.get $l3
                i32.gt_s
                if $I68
                  local.get $p0
                  i32.load offset=148
                  local.get $l3
                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                  i32.load
                  call $j947
                  local.set $l4
                  local.get $p1
                  local.get $l4
                  call $j930
                  local.get $p1
                  local.get $l3
                  i32.const 2
                  i32.shl
                  i32.add
                  local.get $l4
                  i32.store offset=16
                  local.get $l3
                  i32.const 1
                  i32.add
                  local.set $l3
                  br $L67
                end
              end
              i32.const 0
              local.set $l3
              loop $L69
                local.get $l3
                local.get $l4
                i32.lt_s
                if $I70
                  local.get $p0
                  i32.load offset=148
                  local.get $p1
                  local.get $l3
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                  i32.load
                  call $j1387
                  drop
                  local.get $p0
                  i32.load offset=152
                  local.get $p1
                  local.get $l3
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                  i32.load
                  call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                  local.get $p2
                  i32.const 192
                  i32.add
                  local.get $p0
                  i32.const 1
                  local.get $p0
                  call $j4699 ;; LevelManager$$ThrowPos
                  local.get $p1
                  local.get $l3
                  i32.const 2
                  i32.shl
                  i32.add
                  i32.load offset=16
                  local.set $l4
                  local.get $p0
                  i32.load offset=88
                  local.set $l5
                  local.get $p2
                  local.get $p2
                  i32.load offset=200
                  i32.store offset=128
                  local.get $p2
                  local.get $p2
                  i64.load offset=192
                  i64.store offset=120
                  local.get $l4
                  local.get $p2
                  i32.const 120
                  i32.add
                  local.get $l5
                  i32.const 0
                  call $j6376 ;; ObjectUnit$$ThrowBack
                  local.get $l3
                  i32.const 1
                  i32.add
                  local.set $l3
                  local.get $p1
                  i32.load offset=12
                  local.set $l4
                  br $L69
                end
              end
              local.get $p0
              i32.const 1
              i32.const 0
              local.get $p0
              call $j5154 ;; LevelManager$$RefreshContentDisplay
              br $B11
            end
            i32.const 3962284 ;; SoundManager_TypeInfo
            i32.load
            call $j923
            i32.const 24
            i32.const 0
            i32.const 4063796 ;; 
            i32.load
            i32.const 0
            call $j1654 ;; SoundManager$$PlayEffectSound
            local.get $p0
            local.get $p0
            call $j4380 ;; LevelManager$$CheckObjMaxHeight
            i32.const 3963668 ;; ToolType_TypeInfo
            i32.load
            local.set $l3
            local.get $p2
            i32.const 160
            i32.add
            local.set $p1
            local.get $p1
            i32.const -1
            i32.store offset=4
            local.get $p1
            local.get $l3
            i32.store
            local.get $p1
            local.get $p2
            i32.load offset=300
            i32.store offset=8
            local.get $p1
            i32.const 0
            call $j1009 ;; System.Enum$$ToString
            local.set $p1
            i32.const 3953096 ;; ConfigManager_TypeInfo
            i32.load
            call $j923
            local.get $p1
            i32.const 0
            call $j4793 ;; ConfigManager$$GetGameToolData
            i32.load offset=28
            local.set $p1
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $p0
            i32.load offset=148
            i32.load offset=12
            local.set $l3
            i32.const 3950508 ;; ObjectUnit[]_TypeInfo
            i32.load
            local.get $p1
            local.get $l3
            local.get $p1
            local.get $l3
            i32.lt_s
            select
            call $j939
            local.set $p1
            i32.const 0
            local.set $l3
            loop $L71
              local.get $p1
              i32.load offset=12
              local.set $l4
              local.get $l4
              local.get $l3
              i32.gt_s
              if $I72
                local.get $p0
                i32.load offset=148
                local.get $l3
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                local.set $l4
                local.get $p1
                local.get $l4
                call $j930
                local.get $p1
                local.get $l3
                i32.const 2
                i32.shl
                i32.add
                local.get $l4
                i32.store offset=16
                local.get $l3
                i32.const 1
                i32.add
                local.set $l3
                br $L71
              end
            end
            i32.const 0
            local.set $l3
            loop $L73
              local.get $l3
              local.get $l4
              i32.lt_s
              if $I74
                local.get $p0
                i32.load offset=148
                local.get $p1
                local.get $l3
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                i32.load
                call $j1387
                drop
                local.get $p0
                i32.load offset=152
                local.get $p1
                local.get $l3
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                i32.load
                call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                local.get $p2
                i32.const 176
                i32.add
                local.get $p0
                i32.const 1
                local.get $p0
                call $j4699 ;; LevelManager$$ThrowPos
                local.get $p1
                local.get $l3
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                local.set $l4
                local.get $p0
                i32.load offset=88
                local.set $l5
                local.get $p2
                local.get $p2
                i32.load offset=184
                i32.store offset=112
                local.get $p2
                local.get $p2
                i64.load offset=176
                i64.store offset=104
                local.get $l4
                local.get $p2
                i32.const 104
                i32.add
                local.get $l5
                i32.const 0
                call $j6376 ;; ObjectUnit$$ThrowBack
                local.get $l3
                i32.const 1
                i32.add
                local.set $l3
                local.get $p1
                i32.load offset=12
                local.set $l4
                br $L73
              end
            end
            local.get $p0
            i32.const 1
            i32.const 0
            local.get $p0
            call $j5154 ;; LevelManager$$RefreshContentDisplay
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.const 0
            i32.store8 offset=36
            br $B11
          end
          local.get $p0
          i32.load offset=704
          local.set $l3
          i32.const 0
          local.set $p1
          i32.const 3959504 ;; UnityEngine.Object_TypeInfo
          i32.load
          call $j923
          local.get $l3
          i32.const 0
          i32.const 0
          call $j980 ;; UnityEngine.Object$$op_Equality
          if $I75
            i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
            i32.load
            call $j923
            i32.const 600
            i32.const 4126652 ;; 道具加载中，稍后再试
            i32.load
            i32.const 0
            call $j1145 ;; Kunpo.KUIManager$$OpenATip
            br $B10
          end
          local.get $p0
          local.get $p0
          local.get $p0
          call $j43552 ;; LevelManager$$ClawTargetObj
          i32.const 0
          call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
          drop
          br $B11
        end
        local.get $p0
        i32.const 2
        local.get $p0
        call $j22238 ;; LevelManager$$PlayToolPartcle
        local.get $p0
        local.get $p0
        local.get $p0
        call $j22241 ;; LevelManager$$MessObjRotaAnim
        i32.const 0
        call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
        drop
      end
      local.get $p2
      i32.load offset=300
      local.set $p1
      block $B76
        block $B77
          local.get $p1
          i32.const 15
          i32.le_u
          i32.const 0
          i32.const 1
          local.get $p1
          i32.shl
          i32.const 35840
          i32.and
          select
          br_if $B77
          block $B78
            local.get $p1
            br_table $B77 $B76 $B76 $B76 $B77 $B78
          end
          local.get $p1
          i32.const 110
          i32.ne
          br_if $B76
        end
        local.get $p0
        i32.const 4063796 ;; 
        i32.load
        local.get $p0
        call $j22237 ;; LevelManager$$RefreshTargetCount
      end
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 1
      local.set $p1
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B10
      local.get $p0
      local.get $p2
      i32.load offset=300
      i32.const 0
      call $j1561
    end
    local.get $p2
    i32.const 304
    i32.add
    global.set $primary.global$0
    local.get $p1
    return)
