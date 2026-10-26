  (func $j94029 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    local.get $p0
    local.get $p2
    i32.store offset=12
    i32.const 5140008
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3959072 ;; MonopolyManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3963668 ;; ToolType_TypeInfo
      call $j922
      i32.const 4123284 ;; 无此副本hotfix
      call $j922
      i32.const 4076524 ;; DailyChallenge
      call $j922
      i32.const 4086068 ;; Monopoly
      call $j922
      i32.const 4084592 ;; LevelSlot
      call $j922
      i32.const 5140008
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j4012 ;; SpLevelManager$$CurLevelIsSpLevel
      if $I2
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
        if $I3
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 5142651
          i32.load8_u
          i32.eqz
          if $I4
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
          i32.load offset=200
          local.set $p3
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p2
          local.get $p3
          i32.const 0
          call $j2297 ;; ConfigManager$$GetActivityLevelData
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=24
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B1
          local.get $p1
          i32.eqz
          if $I5
            local.get $p3
            i32.load offset=20
            local.set $p2
            br $B1
          end
          local.get $p3
          i32.load offset=16
          local.set $p2
          br $B1
        end
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
        if $I6
          i32.const 3953492 ;; DailyChallengeMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p2
          i32.const 0
          call $j7574 ;; DailyChallengeMa$$GetCurLevelInfo
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=24
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B1
          local.get $p1
          i32.eqz
          if $I7
            local.get $p3
            i32.load offset=20
            local.set $p2
            br $B1
          end
          local.get $p3
          i32.load offset=16
          local.set $p2
          br $B1
        end
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
        if $I8
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          i32.load
          call $j923
          i32.const 5140209
          i32.load8_u
          i32.eqz
          if $I9
            i32.const 3959072 ;; MonopolyManager_TypeInfo
            call $j922
            i32.const 5140209
            i32.const 1
            i32.store8
          end
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p2
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=24
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B1
          local.get $p1
          i32.eqz
          if $I10
            local.get $p3
            i32.load offset=20
            local.set $p2
            br $B1
          end
          local.get $p3
          i32.load offset=16
          local.set $p2
          br $B1
        end
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $p2
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        local.get $p2
        i32.const 0
        call $j6444 ;; LongLevelActiveMa$$IsLongLevelName
        if $I11
          i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p2
          i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=20
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=36
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B1
          local.get $p1
          i32.eqz
          if $I12
            local.get $p3
            i32.load offset=20
            local.set $p2
            br $B1
          end
          local.get $p3
          i32.load offset=16
          local.set $p2
          br $B1
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
        if $I13
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          call $j923
          i32.const 5140216
          i32.load8_u
          i32.eqz
          if $I14
            i32.const 3961680 ;; SeasonLevelMa_TypeInfo
            call $j922
            i32.const 5140216
            i32.const 1
            i32.store8
          end
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.set $p2
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=24
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=52
          local.set $p3
          local.get $p3
          i32.eqz
          br_if $B1
          local.get $p3
          i32.load offset=12
          i32.const 2
          i32.lt_s
          br_if $B1
          local.get $p3
          local.get $p1
          i32.const 1
          i32.xor
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          local.set $p2
          br $B1
        end
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $p2
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        local.get $p0
        local.get $p2
        i32.const 0
        call $j20228 ;; ServerFileCreate$$GetSpLevelData
        block $B15
          local.get $p0
          i32.load
          i32.const 1
          i32.and
          if $I16
            local.get $p0
            i32.load offset=8
            local.get $p0
            i32.load offset=4
            local.get $p1
            select
            local.set $p2
            br $B15
          end
          i32.const 4123284 ;; 无此副本hotfix
          i32.load
          i32.const 5
          i32.const 0
          call $j1666 ;; GameManager$$LogInfo
          i32.const 3961880 ;; ServerFileCreate_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 0
          call $j13781 ;; ServerFileCreate$$GetFruitSpLevelData
          local.get $p0
          i32.const 8
          i32.add
          local.get $p0
          i32.const 4
          i32.or
          local.get $p1
          select
          i32.load
          local.set $p2
        end
        i32.const 3955840 ;; GroupBattleManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j5748 ;; GroupBattleManager$$IsThisState
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=12
        local.set $p1
        local.get $p0
        i32.const 16
        i32.add
        global.set $primary.global$0
        i32.const 0
        local.get $p2
        local.get $p1
        i32.const 3
        i32.eq
        select
        return
      end
      i32.const 3963668 ;; ToolType_TypeInfo
      i32.load
      local.set $p1
      local.get $p0
      i32.const -1
      i32.store offset=4
      local.get $p0
      local.get $p1
      i32.store
      local.get $p0
      local.get $p0
      i32.load offset=12
      i32.store offset=8
      local.get $p0
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $p1
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j4793 ;; ConfigManager$$GetGameToolData
      i32.load offset=24
      local.set $p2
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p2
    return)
