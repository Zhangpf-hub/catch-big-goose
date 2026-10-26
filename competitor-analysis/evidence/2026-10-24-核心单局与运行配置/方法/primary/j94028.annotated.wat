  (func $j94028 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139988
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952908 ;; CollegeEntranceExamination2026Helper_TypeInfo
      call $j922
      i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
      call $j922
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
      call $j922
      i32.const 3983700 ;; Method$System.Collections.Generic.Dictionary<string, bool>.get_Item()
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3955276 ;; GMLevelManager_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958080 ;; LevelSlotMa_TypeInfo
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3958444 ;; MahjongModeHelper_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959072 ;; MonopolyManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3964436 ;; UITaoYuanSpHelper_TypeInfo
      call $j922
      i32.const 4076524 ;; DailyChallenge
      call $j922
      i32.const 4079716 ;; GMDiyLevel
      call $j922
      i32.const 4086068 ;; Monopoly
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
      i32.const 5139988
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.eqz
        if $I3
          i32.const 3958464 ;; MainLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 5140203
          i32.load8_u
          i32.eqz
          if $I4
            i32.const 3958464 ;; MainLevelManager_TypeInfo
            call $j922
            i32.const 5140203
            i32.const 1
            i32.store8
          end
          i32.const 3958464 ;; MainLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 3958464 ;; MainLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 1
          i32.eq
          if $I5
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load8_u offset=44
            i32.eqz
            br_if $B2
            br $B1
          end
          i32.const 3958464 ;; MainLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 5140204
          i32.load8_u
          i32.eqz
          if $I6
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
          local.set $l2
          local.get $l2
          i32.load offset=8
          i64.extend_i32_u
          local.get $l2
          i32.load offset=12
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          local.set $l6
          i32.const 3958048 ;; LevelLoaderManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          local.get $l6
          i64.store
          local.get $p1
          local.get $l6
          i64.store offset=56
          local.get $p1
          local.get $p1
          call $j7379 ;; LevelLoaderManager$$LoadIsCompleted
          i32.eqz
          br_if $B2
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=48
        local.set $l3
        i32.const 3955516 ;; GameTypeEnum_TypeInfo
        i32.load
        local.set $l2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l4
        local.get $p1
        i32.const 40
        i32.add
        local.set $p0
        local.get $p0
        i32.const -1
        i32.store offset=4
        local.get $p0
        local.get $l2
        i32.store
        local.get $p0
        local.get $l4
        i32.load offset=12
        i32.store offset=8
        local.get $l3
        local.get $p0
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
        i32.load
        call $j1040
        if $I7
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=48
          local.set $l3
          i32.const 3955516 ;; GameTypeEnum_TypeInfo
          i32.load
          local.set $l4
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          local.set $l5
          local.get $p1
          i32.const 40
          i32.add
          local.set $l2
          local.get $l2
          i32.const -1
          i32.store offset=4
          local.get $l2
          local.get $l4
          i32.store
          local.get $l2
          local.get $l5
          i32.load offset=12
          i32.store offset=8
          local.get $l3
          local.get $l2
          i32.const 0
          call $j1009 ;; System.Enum$$ToString
          i32.const 3983700 ;; Method$System.Collections.Generic.Dictionary<string, bool>.get_Item()
          i32.load
          call $j11243
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B8
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B8
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4084592 ;; LevelSlot
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B8
          i32.const 3958080 ;; LevelSlotMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 3958080 ;; LevelSlotMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=4
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B9
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B9
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4079720 ;; GMLevel
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B9
          i32.const 3955276 ;; GMLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 5140205
          i32.load8_u
          i32.eqz
          if $I10
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
          local.set $p0
          local.get $p0
          i32.load
          i64.extend_i32_u
          local.get $p0
          i32.load offset=4
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          local.set $l6
          i32.const 3958048 ;; LevelLoaderManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          local.get $l6
          i64.store offset=16
          local.get $p1
          local.get $l6
          i64.store offset=32
          i32.const 1
          local.set $p0
          local.get $p1
          i32.const 16
          i32.add
          local.get $p1
          call $j7379 ;; LevelLoaderManager$$LoadIsCompleted
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B11
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B11
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4079716 ;; GMDiyLevel
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B11
          i32.const 5140206
          i32.load8_u
          i32.eqz
          if $I12
            i32.const 3955272 ;; GMDiyLevelManager_TypeInfo
            call $j922
            i32.const 5140206
            i32.const 1
            i32.store8
          end
          i32.const 3955272 ;; GMDiyLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          local.set $p0
          local.get $p0
          i32.load
          i64.extend_i32_u
          local.get $p0
          i32.load offset=4
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          local.set $l6
          i32.const 3958048 ;; LevelLoaderManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          local.get $l6
          i64.store offset=8
          local.get $p1
          local.get $l6
          i64.store offset=24
          i32.const 1
          local.set $p0
          local.get $p1
          i32.const 8
          i32.add
          local.get $p1
          call $j7379 ;; LevelLoaderManager$$LoadIsCompleted
          br_if $B1
        end
        i32.const 0
        call $j2628 ;; Anniversary.AnniversaryHelper$$get_Instance
        i32.const 0
        call $j24734 ;; Anniversary.AnniversaryHelper$$IsInAnniveraryLevel
        if $I13
          i32.const 1
          local.set $p0
          i32.const 0
          call $j2628 ;; Anniversary.AnniversaryHelper$$get_Instance
          i32.const 0
          call $j7698 ;; Anniversary.AnniversaryHelper$$HasLoadComplete
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B14
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B14
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4076524 ;; DailyChallenge
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B14
          i32.const 3953492 ;; DailyChallengeMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 3953492 ;; DailyChallengeMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B15
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B15
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4075248 ;; CollegeExamSpLevel
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B15
          i32.const 1
          local.set $p0
          i32.const 3952908 ;; CollegeEntranceExamination2026Helper_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=1
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B16
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B16
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4085312 ;; MajiangModeLevel
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B16
          i32.const 3958444 ;; MahjongModeHelper_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 0
          call $j14568 ;; MahjongModeHelper$$get_HasLoadComplete
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B17
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B17
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4094136 ;; TaoYuanSpLevel
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B17
          i32.const 3964436 ;; UITaoYuanSpHelper_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 0
          call $j13102 ;; UITaoYuanSpHelper$$get_HasLoadComplete
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B18
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B18
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 4086068 ;; Monopoly
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B18
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 0
          call $j10728 ;; MonopolyManager$$HasLoadLevelCompelet
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B19
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B19
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          local.set $p0
          i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 0
          call $j6444 ;; LongLevelActiveMa$$IsLongLevelName
          i32.eqz
          br_if $B19
          i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=12
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B20
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B20
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          local.set $p0
          i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B20
          i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 0
          call $j47672 ;; DYDirectPlayManager$$HasCurLevelLoadComplete
          br_if $B1
        end
        i32.const 3955840 ;; GroupBattleManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j5748 ;; GroupBattleManager$$IsThisState
        if $I21
          i32.const 3955840 ;; GroupBattleManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          i32.const 0
          call $j22709 ;; GroupBattleManager$$HasCurLevelLoadComplete
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B22
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.ne
          br_if $B22
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=48
          local.set $p0
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
          i32.load
          call $j1040
          i32.eqz
          br_if $B22
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=48
          local.set $l2
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p0
          local.get $l2
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 3983700 ;; Method$System.Collections.Generic.Dictionary<string, bool>.get_Item()
          i32.load
          call $j11243
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 1
        local.set $p0
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 3
        i32.eq
        br_if $B1
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 20
        i32.eq
        if $I23
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          call $j923
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=4
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 9
        i32.eq
        if $I24
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j7161 ;; SeasonLevelMa$$HasCurLevelLoadComplete
          br_if $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 7
        i32.eq
        br_if $B1
      end
      i32.const 0
      local.set $p0
    end
    local.get $p1
    i32.const -64
    i32.sub
    global.set $primary.global$0
    local.get $p0
    return)
