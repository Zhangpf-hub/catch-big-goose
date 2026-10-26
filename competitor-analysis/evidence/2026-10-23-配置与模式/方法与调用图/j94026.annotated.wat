  (func $j94026 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 f32) (local $l11 i64)
    global.get $primary.global$0
    i32.const 352
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    local.get $p3
    local.get $p2
    i32.store offset=348
    i32.const 5139987
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
      call $j922
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
      call $j922
      i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3955276 ;; GMLevelManager_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3958444 ;; MahjongModeHelper_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959072 ;; MonopolyManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      call $j922
      i32.const 4120672 ;; 关卡类型:{0},关卡id:{1}
      call $j922
      i32.const 4076524 ;; DailyChallenge
      call $j922
      i32.const 4079716 ;; GMDiyLevel
      call $j922
      i32.const 4092740 ;; SpHardLevel
      call $j922
      i32.const 4120260 ;; 今日无特殊关
      call $j922
      i32.const 4086068 ;; Monopoly
      call $j922
      i32.const 4125532 ;; 获取关卡
      call $j922
      i32.const 4079720 ;; GMLevel
      call $j922
      i32.const 4085312 ;; MajiangModeLevel
      call $j922
      i32.const 4094136 ;; TaoYuanSpLevel
      call $j922
      i32.const 4084592 ;; LevelSlot
      call $j922
      i32.const 4075248 ;; CollegeExamSpLevel
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5139987
      i32.const 1
      i32.store8
    end
    local.get $p3
    i32.const 0
    i32.store offset=344
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    block $B9
                      local.get $p2
                      br_table $B9 $B8 $B1 $B7 $B5 $B5 $B5 $B6 $B1 $B3 $B2 $B1 $B1 $B1 $B1 $B1 $B1 $B1 $B1 $B1 $B4 $B1
                    end
                    local.get $p0
                    i32.load offset=16
                    local.set $p2
                    i32.const 3958464 ;; MainLevelManager_TypeInfo
                    i32.load
                    call $j923
                    i32.const 5140204
                    i32.load8_u
                    i32.eqz
                    if $I10
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
                    local.set $l4
                    local.get $l4
                    i32.load offset=8
                    i64.extend_i32_u
                    local.get $l4
                    i32.load offset=12
                    i64.extend_i32_u
                    i64.const 32
                    i64.shl
                    i64.or
                    local.set $l11
                    i32.const 3958024 ;; LevelDataHelper_TypeInfo
                    i32.load
                    call $j923
                    local.get $p3
                    local.get $l11
                    i64.store offset=24
                    local.get $p3
                    local.get $l11
                    i64.store offset=336
                    local.get $p2
                    local.get $p3
                    i32.const 24
                    i32.add
                    local.get $p1
                    local.get $p3
                    call $j4382 ;; LevelDataHelper$$GetLevelData
                    i32.store offset=24
                    i32.const 3959304 ;; NetInitManager_TypeInfo
                    i32.load
                    call $j923
                    local.get $p3
                    call $j3058 ;; NetInitManager$$IsHideAllLog
                    i32.eqz
                    if $I11
                      i32.const 3955516 ;; GameTypeEnum_TypeInfo
                      i32.load
                      local.set $p2
                      local.get $p3
                      i32.const 320
                      i32.add
                      local.set $p1
                      local.get $p1
                      i32.const -1
                      i32.store offset=4
                      local.get $p1
                      local.get $p2
                      i32.store
                      local.get $p1
                      local.get $p3
                      i32.load offset=348
                      i32.store offset=8
                      local.get $p1
                      i32.const 0
                      call $j1009 ;; System.Enum$$ToString
                      local.set $p1
                      local.get $p3
                      local.get $p0
                      i32.load offset=16
                      i32.load offset=24
                      i32.const 0
                      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                      i32.load
                      call $j947
                      i32.load offset=12
                      i32.store offset=344
                      local.get $p1
                      local.set $p2
                      local.get $p3
                      i32.const 344
                      i32.add
                      i32.const 0
                      call $j1012 ;; System.Int32$$ToString
                      local.set $l4
                      i32.const 4063796 ;; 
                      i32.load
                      local.set $p1
                      local.get $p2
                      local.get $l4
                      local.get $p1
                      local.get $p1
                      local.get $p1
                      local.get $p1
                      i32.const 0
                      call $j1120 ;; GameManager$$StringAppend
                      local.set $p1
                      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                      i32.load
                      call $j923
                      local.get $p1
                      i32.const 0
                      call $j1051 ;; UnityEngine.Debug$$Log
                    end
                    local.get $p0
                    i32.load offset=8
                    i32.load offset=88
                    local.set $p2
                    i32.const 5142879
                    i32.load8_u
                    i32.eqz
                    if $I12
                      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                      call $j922
                      i32.const 5142879
                      i32.const 1
                      i32.store8
                    end
                    i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                    i32.load
                    i32.load offset=92
                    local.set $p1
                    local.get $p1
                    f32.load offset=20
                    local.set $l9
                    local.get $p1
                    f32.load offset=16
                    local.set $l10
                    local.get $p1
                    f32.load offset=12
                    local.set $l7
                    local.get $p0
                    i32.load offset=16
                    i32.load offset=24
                    i32.const 0
                    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                    i32.load
                    call $j947
                    f32.load offset=68
                    local.set $l8
                    local.get $l7
                    local.get $l8
                    f32.mul
                    local.set $l7
                    local.get $p3
                    local.get $l9
                    local.get $l8
                    f32.mul
                    f32.store offset=312
                    local.get $p3
                    local.get $p3
                    i32.load offset=312
                    i32.store offset=16
                    local.get $p3
                    local.get $l10
                    local.get $l8
                    f32.mul
                    f32.store offset=308
                    local.get $p3
                    local.get $l7
                    f32.store offset=304
                    local.get $p3
                    local.get $p3
                    i64.load offset=304
                    i64.store offset=8
                    local.get $p2
                    local.get $p3
                    i32.const 8
                    i32.add
                    i32.const 0
                    call $j1159 ;; UnityEngine.Transform$$set_localScale
                    i32.const 3951356 ;; ActionManager_TypeInfo
                    i32.load
                    call $j923
                    i32.const 25
                    i32.const 0
                    i32.const 0
                    call $j1940 ;; ActionManager$$TriggerEvent
                    br $B1
                  end
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  i32.load
                  call $j923
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load offset=60
                  local.set $l4
                  i32.const 3955516 ;; GameTypeEnum_TypeInfo
                  i32.load
                  local.set $l5
                  local.get $p3
                  i32.const 320
                  i32.add
                  local.set $p2
                  local.get $p2
                  i32.const -1
                  i32.store offset=4
                  local.get $p2
                  local.get $l5
                  i32.store
                  local.get $p2
                  local.get $p3
                  i32.load offset=348
                  i32.store offset=8
                  local.get $l4
                  local.get $p2
                  i32.const 0
                  call $j1009 ;; System.Enum$$ToString
                  i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
                  i32.load
                  call $j1040
                  if $I13
                    local.get $p0
                    i32.load offset=16
                    local.set $l5
                    i32.const 3959288 ;; NetDataManager_TypeInfo
                    i32.load
                    call $j923
                    i32.const 3959288 ;; NetDataManager_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=60
                    local.set $l6
                    i32.const 3955516 ;; GameTypeEnum_TypeInfo
                    i32.load
                    local.set $l4
                    local.get $p3
                    i32.const 320
                    i32.add
                    local.set $p2
                    local.get $p2
                    i32.const -1
                    i32.store offset=4
                    local.get $p2
                    local.get $l4
                    i32.store
                    local.get $p2
                    local.get $p3
                    i32.load offset=348
                    i32.store offset=8
                    local.get $l6
                    local.get $p2
                    i32.const 0
                    call $j1009 ;; System.Enum$$ToString
                    i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
                    i32.load
                    call $j1033
                    local.set $l4
                    i32.const 3955516 ;; GameTypeEnum_TypeInfo
                    i32.load
                    local.set $l6
                    local.get $p3
                    i32.const 288
                    i32.add
                    local.set $p2
                    local.get $p2
                    i32.const -1
                    i32.store offset=4
                    local.get $p2
                    local.get $l6
                    i32.store
                    local.get $p2
                    local.get $p3
                    i32.load offset=348
                    i32.store offset=8
                    local.get $p2
                    i32.const 0
                    call $j1009 ;; System.Enum$$ToString
                    local.set $p2
                    i32.const 3953096 ;; ConfigManager_TypeInfo
                    i32.load
                    call $j923
                    local.get $l5
                    local.get $l4
                    local.get $p2
                    i32.const 0
                    call $j2094 ;; ConfigManager$$GetLevelData
                    local.get $p1
                    i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                    i32.load
                    call $j1068
                    i32.store offset=24
                    local.get $p0
                    i32.load offset=8
                    i32.load offset=88
                    local.set $p2
                    i32.const 5142879
                    i32.load8_u
                    i32.eqz
                    if $I14
                      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                      call $j922
                      i32.const 5142879
                      i32.const 1
                      i32.store8
                    end
                    i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                    i32.load
                    i32.load offset=92
                    local.set $p1
                    local.get $p1
                    f32.load offset=20
                    local.set $l9
                    local.get $p1
                    f32.load offset=16
                    local.set $l10
                    local.get $p1
                    f32.load offset=12
                    local.set $l7
                    local.get $p0
                    i32.load offset=16
                    i32.load offset=24
                    i32.const 0
                    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                    i32.load
                    call $j947
                    f32.load offset=68
                    local.set $l8
                    local.get $l7
                    local.get $l8
                    f32.mul
                    local.set $l7
                    local.get $p3
                    local.get $l9
                    local.get $l8
                    f32.mul
                    f32.store offset=280
                    local.get $p3
                    local.get $p3
                    i32.load offset=280
                    i32.store offset=56
                    local.get $p3
                    local.get $l10
                    local.get $l8
                    f32.mul
                    f32.store offset=276
                    local.get $p3
                    local.get $l7
                    f32.store offset=272
                    local.get $p3
                    local.get $p3
                    i64.load offset=272
                    i64.store offset=48
                    local.get $p2
                    local.get $p3
                    i32.const 48
                    i32.add
                    i32.const 0
                    call $j1159 ;; UnityEngine.Transform$$set_localScale
                    local.get $p0
                    i32.load offset=8
                    i32.load offset=116
                    local.set $p2
                    i32.const 5142879
                    i32.load8_u
                    i32.eqz
                    if $I15
                      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                      call $j922
                      i32.const 5142879
                      i32.const 1
                      i32.store8
                    end
                    i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                    i32.load
                    i32.load offset=92
                    local.set $p1
                    local.get $p1
                    f32.load offset=20
                    local.set $l9
                    local.get $p1
                    f32.load offset=16
                    local.set $l10
                    local.get $p1
                    f32.load offset=12
                    local.set $l7
                    local.get $p0
                    i32.load offset=16
                    i32.load offset=24
                    i32.const 0
                    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                    i32.load
                    call $j947
                    f32.load offset=68
                    local.set $l8
                    local.get $l7
                    local.get $l8
                    f32.mul
                    local.set $l7
                    local.get $p3
                    local.get $l9
                    local.get $l8
                    f32.mul
                    f32.store offset=264
                    local.get $p3
                    local.get $p3
                    i32.load offset=264
                    i32.store offset=40
                    local.get $p3
                    local.get $l10
                    local.get $l8
                    f32.mul
                    f32.store offset=260
                    local.get $p3
                    local.get $l7
                    f32.store offset=256
                    local.get $p3
                    local.get $p3
                    i64.load offset=256
                    i64.store offset=32
                    local.get $p2
                    local.get $p3
                    i32.const 32
                    i32.add
                    i32.const 0
                    call $j1159 ;; UnityEngine.Transform$$set_localScale
                    i32.const 3955516 ;; GameTypeEnum_TypeInfo
                    i32.load
                    local.set $p2
                    local.get $p3
                    i32.const 240
                    i32.add
                    local.set $p1
                    local.get $p1
                    i32.const -1
                    i32.store offset=4
                    local.get $p1
                    local.get $p2
                    i32.store
                    local.get $p1
                    local.get $p3
                    i32.load offset=348
                    i32.store offset=8
                    local.get $p1
                    i32.const 0
                    call $j1009 ;; System.Enum$$ToString
                    local.set $p1
                    local.get $p3
                    local.get $p0
                    i32.load offset=16
                    i32.load offset=24
                    i32.const 0
                    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                    i32.load
                    call $j947
                    i32.load offset=12
                    i32.store offset=344
                    local.get $p3
                    i32.const 344
                    i32.add
                    i32.const 0
                    call $j1012 ;; System.Int32$$ToString
                    local.set $p2
                    i32.const 4063796 ;; 
                    i32.load
                    local.set $p0
                    local.get $p1
                    local.get $p2
                    local.get $p0
                    local.get $p0
                    local.get $p0
                    local.get $p0
                    i32.const 0
                    call $j1120 ;; GameManager$$StringAppend
                    local.set $p0
                    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                    i32.load
                    call $j923
                    local.get $p0
                    i32.const 0
                    call $j1051 ;; UnityEngine.Debug$$Log
                    br $B1
                  end
                  i32.const 4120260 ;; 今日无特殊关
                  i32.load
                  i32.const 0
                  i32.const 0
                  call $j1229 ;; Kunpo.Debugger$$LogError
                  br $B1
                end
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                i32.const 0
                call $j2521 ;; NetDataManager$$get_DailyBaseLevelIndex
                local.set $l5
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                local.get $l5
                i32.const 4063796 ;; 
                i32.load
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                i32.const 3959304 ;; NetInitManager_TypeInfo
                i32.load
                call $j923
                local.get $p3
                call $j3058 ;; NetInitManager$$IsHideAllLog
                i32.eqz
                if $I16
                  i32.const 3955516 ;; GameTypeEnum_TypeInfo
                  i32.load
                  local.set $p2
                  local.get $p3
                  i32.const 320
                  i32.add
                  local.set $p1
                  local.get $p1
                  i32.const -1
                  i32.store offset=4
                  local.get $p1
                  local.get $p2
                  i32.store
                  local.get $p1
                  local.get $p3
                  i32.load offset=348
                  i32.store offset=8
                  local.get $p1
                  i32.const 0
                  call $j1009 ;; System.Enum$$ToString
                  local.set $p1
                  local.get $p3
                  local.get $p0
                  i32.load offset=16
                  i32.load offset=24
                  i32.const 0
                  i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                  i32.load
                  call $j947
                  i32.load offset=12
                  i32.store offset=344
                  local.get $p1
                  local.set $p2
                  local.get $p3
                  i32.const 344
                  i32.add
                  i32.const 0
                  call $j1012 ;; System.Int32$$ToString
                  local.set $l4
                  i32.const 4063796 ;; 
                  i32.load
                  local.set $p1
                  local.get $p2
                  local.get $l4
                  local.get $p1
                  local.get $p1
                  local.get $p1
                  local.get $p1
                  i32.const 0
                  call $j1120 ;; GameManager$$StringAppend
                  local.set $p1
                  i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                  i32.load
                  call $j923
                  local.get $p1
                  i32.const 0
                  call $j1051 ;; UnityEngine.Debug$$Log
                end
                local.get $p0
                i32.load offset=8
                i32.load offset=88
                local.set $p2
                i32.const 5142879
                i32.load8_u
                i32.eqz
                if $I17
                  i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                  call $j922
                  i32.const 5142879
                  i32.const 1
                  i32.store8
                end
                i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                i32.load
                i32.load offset=92
                local.set $p1
                local.get $p1
                f32.load offset=20
                local.set $l9
                local.get $p1
                f32.load offset=16
                local.set $l10
                local.get $p1
                f32.load offset=12
                local.set $l7
                local.get $p0
                i32.load offset=16
                i32.load offset=24
                i32.const 0
                i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                i32.load
                call $j947
                f32.load offset=68
                local.set $l8
                local.get $l7
                local.get $l8
                f32.mul
                local.set $l7
                local.get $p3
                local.get $l9
                local.get $l8
                f32.mul
                f32.store offset=232
                local.get $p3
                local.get $p3
                i32.load offset=232
                i32.store offset=88
                local.get $p3
                local.get $l10
                local.get $l8
                f32.mul
                f32.store offset=228
                local.get $p3
                local.get $l7
                f32.store offset=224
                local.get $p3
                local.get $p3
                i64.load offset=224
                i64.store offset=80
                local.get $p2
                local.get $p3
                i32.const 80
                i32.add
                i32.const 0
                call $j1159 ;; UnityEngine.Transform$$set_localScale
                br $B1
              end
              local.get $p0
              i32.load offset=16
              local.set $p1
              i32.const 3959844 ;; PVPManager_TypeInfo
              i32.load
              call $j923
              local.get $p1
              i32.const 3959844 ;; PVPManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=24
              i32.store offset=24
              local.get $p3
              i32.const 7
              i32.store offset=320
              i32.const 3955516 ;; GameTypeEnum_TypeInfo
              i32.load
              local.get $p3
              i32.const 320
              i32.add
              call $j935
              local.set $p1
              local.get $p3
              local.get $p0
              i32.load offset=16
              i32.load offset=24
              i32.const 0
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              i32.store offset=288
              i32.const 3957596 ;; int_TypeInfo
              i32.load
              local.get $p3
              i32.const 288
              i32.add
              call $j935
              local.set $p2
              i32.const 4120672 ;; 关卡类型:{0},关卡id:{1}
              i32.load
              local.get $p1
              local.get $p2
              i32.const 0
              call $j1060 ;; System.String$$Format
              i32.const 3
              i32.const 0
              call $j1666 ;; GameManager$$LogInfo
              local.get $p0
              i32.load offset=8
              i32.load offset=88
              local.set $p2
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I18
                i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                call $j922
                i32.const 5142879
                i32.const 1
                i32.store8
              end
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.load
              i32.load offset=92
              local.set $p1
              local.get $p1
              f32.load offset=20
              local.set $l9
              local.get $p1
              f32.load offset=16
              local.set $l10
              local.get $p1
              f32.load offset=12
              local.set $l7
              local.get $p0
              i32.load offset=16
              i32.load offset=24
              i32.const 0
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              call $j947
              f32.load offset=68
              local.set $l8
              local.get $l7
              local.get $l8
              f32.mul
              local.set $l7
              local.get $p3
              local.get $l9
              local.get $l8
              f32.mul
              f32.store offset=216
              local.get $p3
              local.get $p3
              i32.load offset=216
              i32.store offset=128
              local.get $p3
              local.get $l10
              local.get $l8
              f32.mul
              f32.store offset=212
              local.get $p3
              local.get $l7
              f32.store offset=208
              local.get $p3
              local.get $p3
              i64.load offset=208
              i64.store offset=120
              local.get $p2
              local.get $p3
              i32.const 120
              i32.add
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
              br $B1
            end
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=4
            local.set $l5
            block $B19
              local.get $l5
              i32.const 4084592 ;; LevelSlot
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I20
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                i32.const 5142651
                i32.load8_u
                i32.eqz
                if $I21
                  i32.const 3959288 ;; NetDataManager_TypeInfo
                  call $j922
                  i32.const 5142651
                  i32.const 1
                  i32.store8
                end
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                local.set $l4
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=32
                i32.load offset=200
                local.set $p2
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $l4
                local.get $p2
                local.get $p2
                i32.const 0
                call $j2297 ;; ConfigManager$$GetActivityLevelData
                i32.load offset=12
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4079720 ;; GMLevel
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I22
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 3955276 ;; GMLevelManager_TypeInfo
                i32.load
                call $j923
                i32.const 5140205
                i32.load8_u
                i32.eqz
                if $I23
                  i32.const 3955276 ;; GMLevelManager_TypeInfo
                  call $j922
                  i32.const 5140205
                  i32.const 1
                  i32.store8
                end
                i32.const 3955276 ;; GMLevelManager_TypeInfo
                i32.load
                call $j923
                i32.const 3955276 ;; GMLevelManager_TypeInfo
                i32.load
                i32.load offset=92
                local.set $l4
                local.get $l4
                i32.load
                i64.extend_i32_u
                local.get $l4
                i32.load offset=4
                i64.extend_i32_u
                i64.const 32
                i64.shl
                i64.or
                local.set $l11
                i32.const 3958024 ;; LevelDataHelper_TypeInfo
                i32.load
                call $j923
                local.get $p3
                local.get $l11
                i64.store offset=112
                local.get $p3
                local.get $l11
                i64.store offset=200
                local.get $p2
                local.get $p3
                i32.const 112
                i32.add
                local.get $p1
                local.get $p3
                call $j4382 ;; LevelDataHelper$$GetLevelData
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4079716 ;; GMDiyLevel
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I24
                local.get $p0
                i32.load offset=16
                local.set $p1
                i32.const 5140213
                i32.load8_u
                i32.eqz
                if $I25
                  i32.const 3955272 ;; GMDiyLevelManager_TypeInfo
                  call $j922
                  i32.const 5140213
                  i32.const 1
                  i32.store8
                end
                local.get $p1
                i32.const 3955272 ;; GMDiyLevelManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=8
                i32.store offset=24
                br $B19
              end
              i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
              i32.load
              call $j923
              local.get $l5
              i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I26
                i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
                i32.load
                call $j923
                i32.const 5140207
                i32.load8_u
                i32.eqz
                if $I27
                  i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
                  call $j922
                  i32.const 5140207
                  i32.const 1
                  i32.store8
                end
                i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=8
                local.set $l4
                local.get $l4
                i32.load offset=12
                local.set $l6
                local.get $l4
                i32.load offset=16
                local.set $l4
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                local.get $l4
                local.get $l6
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              i32.const 5142656
              i32.load8_u
              i32.eqz
              if $I28
                i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
                call $j922
                i32.const 5142656
                i32.const 1
                i32.store8
              end
              local.get $l5
              i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=8
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I29
                i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=12
                local.set $p2
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                i32.const 0
                call $j2297 ;; ConfigManager$$GetActivityLevelData
                local.set $p2
                local.get $p0
                i32.load offset=16
                local.get $p2
                i32.load offset=8
                local.get $p2
                i32.load offset=12
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4076524 ;; DailyChallenge
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I30
                i32.const 3953492 ;; DailyChallengeMa_TypeInfo
                i32.load
                call $j923
                i32.const 5140208
                i32.load8_u
                i32.eqz
                if $I31
                  i32.const 3953492 ;; DailyChallengeMa_TypeInfo
                  call $j922
                  i32.const 5140208
                  i32.const 1
                  i32.store8
                end
                i32.const 3953492 ;; DailyChallengeMa_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                local.set $l4
                i32.const 3953492 ;; DailyChallengeMa_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=4
                i32.load offset=20
                local.set $p2
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $l4
                local.get $p2
                local.get $p2
                i32.const 0
                call $j2297 ;; ConfigManager$$GetActivityLevelData
                i32.load offset=12
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4075248 ;; CollegeExamSpLevel
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I32
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 4075248 ;; CollegeExamSpLevel
                i32.load
                local.set $l4
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                i32.const 19111
                local.get $l4
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4085312 ;; MajiangModeLevel
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I33
                i32.const 3958444 ;; MahjongModeHelper_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 4085312 ;; MajiangModeLevel
                i32.load
                local.set $l4
                i32.const 3958444 ;; MahjongModeHelper_TypeInfo
                i32.load
                i32.load offset=92
                i32.load
                local.set $l6
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                local.get $l6
                local.get $l4
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4094136 ;; TaoYuanSpLevel
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I34
                local.get $p0
                i32.load offset=16
                local.set $p2
                i32.const 4094136 ;; TaoYuanSpLevel
                i32.load
                local.set $l4
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                i32.const 19151
                local.get $l4
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              local.get $l5
              i32.const 4086068 ;; Monopoly
              i32.load
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I35
                i32.const 3959072 ;; MonopolyManager_TypeInfo
                i32.load
                call $j923
                i32.const 5140209
                i32.load8_u
                i32.eqz
                if $I36
                  i32.const 3959072 ;; MonopolyManager_TypeInfo
                  call $j922
                  i32.const 5140209
                  i32.const 1
                  i32.store8
                end
                i32.const 3959072 ;; MonopolyManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                local.set $l4
                i32.const 3959072 ;; MonopolyManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=12
                i32.load offset=8
                local.set $p2
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $l4
                local.get $p2
                local.get $p2
                i32.const 0
                call $j2297 ;; ConfigManager$$GetActivityLevelData
                i32.load offset=12
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
              i32.load
              call $j923
              local.get $l5
              i32.const 0
              call $j6444 ;; LongLevelActiveMa$$IsLongLevelName
              if $I37
                i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
                i32.load
                call $j923
                local.get $p3
                i32.const 320
                i32.add
                i32.const 0
                call $j22165 ;; LongLevelActiveMa$$GetLongLevelData
                local.get $p3
                i32.load offset=324
                local.set $p2
                local.get $p3
                i32.load offset=320
                local.set $l4
                local.get $p0
                i32.load offset=16
                local.set $l6
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $l6
                local.get $l4
                local.get $p2
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                br $B19
              end
              i32.const 3955840 ;; GroupBattleManager_TypeInfo
              i32.load
              call $j923
              i32.const 0
              call $j5748 ;; GroupBattleManager$$IsThisState
              if $I38
                i32.const 4125532 ;; 获取关卡
                i32.load
                i32.const 3
                i32.const 0
                call $j1407 ;; GameManager$$LogInColor
                i32.const 3955840 ;; GroupBattleManager_TypeInfo
                i32.load
                call $j923
                i32.const 5140214
                i32.load8_u
                i32.eqz
                if $I39
                  i32.const 3955840 ;; GroupBattleManager_TypeInfo
                  call $j922
                  i32.const 5140214
                  i32.const 1
                  i32.store8
                end
                i32.const 3955840 ;; GroupBattleManager_TypeInfo
                i32.load
                call $j923
                local.get $p0
                i32.load offset=16
                i32.const 3955840 ;; GroupBattleManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=12
                i32.store offset=24
                br $B19
              end
              i32.const 3953096 ;; ConfigManager_TypeInfo
              i32.load
              call $j923
              i32.const 4092740 ;; SpHardLevel
              i32.load
              i32.const 0
              call $j1731 ;; ConfigManager$$GetCommonInt
              local.set $l4
              i32.const 3962304 ;; SpLevelManager_TypeInfo
              i32.load
              call $j923
              local.get $p3
              i32.const 3962304 ;; SpLevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=4
              local.get $p3
              call $j22250 ;; LevelManager$$GetCurSpLevelGooseCount
              local.set $l6
              local.get $p0
              i32.load offset=16
              local.set $p2
              local.get $l4
              local.get $l6
              i32.le_s
              if $I40
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=60
                local.get $l5
                i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
                i32.load
                call $j1033
                local.set $l4
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                call $j923
                local.get $p2
                local.get $l4
                i32.const 1
                i32.add
                local.get $l5
                i32.const 0
                call $j2094 ;; ConfigManager$$GetLevelData
                local.get $p1
                i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
                i32.load
                call $j1068
                i32.store offset=24
                local.get $p0
                i32.load offset=16
                local.set $p2
                local.get $p2
                i32.load offset=24
                br_if $B19
              end
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=60
              local.get $l5
              i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
              i32.load
              call $j1033
              local.set $l4
              i32.const 3953096 ;; ConfigManager_TypeInfo
              i32.load
              call $j923
              local.get $p2
              local.get $l4
              local.get $l5
              i32.const 0
              call $j2094 ;; ConfigManager$$GetLevelData
              local.get $p1
              i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
              i32.load
              call $j1068
              i32.store offset=24
            end
            local.get $p3
            local.get $p0
            i32.load offset=16
            i32.load offset=24
            i32.const 0
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            call $j947
            i32.load offset=12
            i32.store offset=344
            local.get $p3
            i32.const 344
            i32.add
            i32.const 0
            call $j1012 ;; System.Int32$$ToString
            local.set $p2
            i32.const 4063796 ;; 
            i32.load
            local.set $p1
            local.get $l5
            local.get $p2
            local.get $p1
            local.get $p1
            local.get $p1
            local.get $p1
            i32.const 0
            call $j1120 ;; GameManager$$StringAppend
            i32.const 3
            i32.const 0
            call $j1666 ;; GameManager$$LogInfo
            local.get $p0
            i32.load offset=8
            i32.load offset=88
            local.set $p2
            i32.const 5142879
            i32.load8_u
            i32.eqz
            if $I41
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              call $j922
              i32.const 5142879
              i32.const 1
              i32.store8
            end
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            i32.load
            i32.load offset=92
            local.set $p1
            local.get $p1
            f32.load offset=20
            local.set $l9
            local.get $p1
            f32.load offset=16
            local.set $l10
            local.get $p1
            f32.load offset=12
            local.set $l7
            local.get $p0
            i32.load offset=16
            i32.load offset=24
            i32.const 0
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            call $j947
            f32.load offset=68
            local.set $l8
            local.get $l7
            local.get $l8
            f32.mul
            local.set $l7
            local.get $p3
            local.get $l9
            local.get $l8
            f32.mul
            f32.store offset=192
            local.get $p3
            local.get $p3
            i32.load offset=192
            i32.store offset=104
            local.get $p3
            local.get $l10
            local.get $l8
            f32.mul
            f32.store offset=188
            local.get $p3
            local.get $l7
            f32.store offset=184
            local.get $p3
            local.get $p3
            i64.load offset=184
            i64.store offset=96
            local.get $p2
            local.get $p3
            i32.const 96
            i32.add
            i32.const 0
            call $j1159 ;; UnityEngine.Transform$$set_localScale
            br $B1
          end
          local.get $p0
          i32.load offset=16
          local.set $p1
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=8
          i32.store offset=24
          i32.const 3959304 ;; NetInitManager_TypeInfo
          i32.load
          call $j923
          local.get $p3
          call $j3058 ;; NetInitManager$$IsHideAllLog
          i32.eqz
          if $I42
            i32.const 3955516 ;; GameTypeEnum_TypeInfo
            i32.load
            local.set $p2
            local.get $p3
            i32.const 320
            i32.add
            local.set $p1
            local.get $p1
            i32.const -1
            i32.store offset=4
            local.get $p1
            local.get $p2
            i32.store
            local.get $p1
            local.get $p3
            i32.load offset=348
            i32.store offset=8
            local.get $p1
            i32.const 0
            call $j1009 ;; System.Enum$$ToString
            local.set $p1
            local.get $p3
            local.get $p0
            i32.load offset=16
            i32.load offset=24
            i32.const 0
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            call $j947
            i32.load offset=12
            i32.store offset=344
            local.get $p1
            local.set $p2
            local.get $p3
            i32.const 344
            i32.add
            i32.const 0
            call $j1012 ;; System.Int32$$ToString
            local.set $l4
            i32.const 4063796 ;; 
            i32.load
            local.set $p1
            local.get $p2
            local.get $l4
            local.get $p1
            local.get $p1
            local.get $p1
            local.get $p1
            i32.const 0
            call $j1120 ;; GameManager$$StringAppend
            local.set $p1
            i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
            i32.load
            call $j923
            local.get $p1
            i32.const 0
            call $j1051 ;; UnityEngine.Debug$$Log
          end
          local.get $p0
          i32.load offset=8
          i32.load offset=88
          local.set $p2
          i32.const 5142879
          i32.load8_u
          i32.eqz
          if $I43
            i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
            call $j922
            i32.const 5142879
            i32.const 1
            i32.store8
          end
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          i32.load
          i32.load offset=92
          local.set $p1
          local.get $p1
          f32.load offset=20
          local.set $l9
          local.get $p1
          f32.load offset=16
          local.set $l10
          local.get $p1
          f32.load offset=12
          local.set $l7
          local.get $p0
          i32.load offset=16
          i32.load offset=24
          i32.const 0
          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
          i32.load
          call $j947
          f32.load offset=68
          local.set $l8
          local.get $l7
          local.get $l8
          f32.mul
          local.set $l7
          local.get $p3
          local.get $l9
          local.get $l8
          f32.mul
          f32.store offset=176
          local.get $p3
          local.get $p3
          i32.load offset=176
          i32.store offset=72
          local.get $p3
          local.get $l10
          local.get $l8
          f32.mul
          f32.store offset=172
          local.get $p3
          local.get $l7
          f32.store offset=168
          local.get $p3
          local.get $p3
          i64.load offset=168
          i64.store offset=64
          local.get $p2
          local.get $p3
          i32.const -64
          i32.sub
          i32.const 0
          call $j1159 ;; UnityEngine.Transform$$set_localScale
          br $B1
        end
        local.get $p0
        i32.load offset=16
        local.set $p1
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=16
        i32.store offset=24
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        local.get $p3
        call $j3058 ;; NetInitManager$$IsHideAllLog
        i32.eqz
        if $I44
          i32.const 3955516 ;; GameTypeEnum_TypeInfo
          i32.load
          local.set $p2
          local.get $p3
          i32.const 320
          i32.add
          local.set $p1
          local.get $p1
          i32.const -1
          i32.store offset=4
          local.get $p1
          local.get $p2
          i32.store
          local.get $p1
          local.get $p3
          i32.load offset=348
          i32.store offset=8
          local.get $p1
          i32.const 0
          call $j1009 ;; System.Enum$$ToString
          local.set $p1
          local.get $p3
          local.get $p0
          i32.load offset=16
          i32.load offset=24
          i32.const 0
          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
          i32.load
          call $j947
          i32.load offset=12
          i32.store offset=344
          local.get $p1
          local.set $p2
          local.get $p3
          i32.const 344
          i32.add
          i32.const 0
          call $j1012 ;; System.Int32$$ToString
          local.set $l4
          i32.const 4063796 ;; 
          i32.load
          local.set $p1
          local.get $p2
          local.get $l4
          local.get $p1
          local.get $p1
          local.get $p1
          local.get $p1
          i32.const 0
          call $j1120 ;; GameManager$$StringAppend
          local.set $p1
          i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 0
          call $j1051 ;; UnityEngine.Debug$$Log
        end
        local.get $p0
        i32.load offset=8
        i32.load offset=88
        local.set $p2
        i32.const 5142879
        i32.load8_u
        i32.eqz
        if $I45
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5142879
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p1
        local.get $p1
        f32.load offset=20
        local.set $l9
        local.get $p1
        f32.load offset=16
        local.set $l10
        local.get $p1
        f32.load offset=12
        local.set $l7
        local.get $p0
        i32.load offset=16
        i32.load offset=24
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        f32.load offset=68
        local.set $l8
        local.get $l7
        local.get $l8
        f32.mul
        local.set $l7
        local.get $p3
        local.get $l9
        local.get $l8
        f32.mul
        f32.store offset=160
        local.get $p3
        local.get $p3
        i32.load offset=160
        i32.store offset=144
        local.get $p3
        local.get $l10
        local.get $l8
        f32.mul
        f32.store offset=156
        local.get $p3
        local.get $l7
        f32.store offset=152
        local.get $p3
        local.get $p3
        i64.load offset=152
        i64.store offset=136
        local.get $p2
        local.get $p3
        i32.const 136
        i32.add
        i32.const 0
        call $j1159 ;; UnityEngine.Transform$$set_localScale
        br $B1
      end
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j8518 ;; SpModeLongTableMa$$IsCurModeLevel
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=8
      f32.const -0x1.ep+3 (;=-15;)
      f32.const 0x1.ep+3 (;=15;)
      local.get $p3
      i32.const 17930
      global.set $__wasm_split_waitTableId
      i32.const 17930
      call_indirect $primary.table (type $t52)
    end
    local.get $p3
    i32.const 352
    i32.add
    global.set $primary.global$0)
