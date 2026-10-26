  (func $j94030 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139999
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3959072 ;; MonopolyManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 4090992 ;; ResumeAddTime
      call $j922
      i32.const 5139999
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 4090992 ;; ResumeAddTime
    i32.load
    i32.const 0
    call $j4793 ;; ConfigManager$$GetGameToolData
    i32.load offset=28
    i32.const 60
    i32.mul
    local.set $p1
    i32.const 3953492 ;; DailyChallengeMa_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j15354 ;; DailyChallengeMa$$CurIsDailyCLevel
      if $I2
        i32.const 3953492 ;; DailyChallengeMa_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j7574 ;; DailyChallengeMa$$GetCurLevelInfo
        i32.eqz
        br_if $B1
        i32.const 3953492 ;; DailyChallengeMa_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j7574 ;; DailyChallengeMa$$GetCurLevelInfo
        i32.load offset=40
        local.set $p0
        local.get $p0
        local.get $p1
        local.get $p0
        i32.const 0
        i32.gt_s
        select
        return
      end
      i32.const 3959072 ;; MonopolyManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j14432 ;; MonopolyManager$$IsThisTypeLevel
      if $I3
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        call $j923
        i32.const 5140209
        i32.load8_u
        i32.eqz
        if $I4
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          call $j922
          i32.const 5140209
          i32.const 1
          i32.store8
        end
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.eqz
        br_if $B1
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        call $j923
        i32.const 5140209
        i32.load8_u
        i32.eqz
        if $I5
          i32.const 3959072 ;; MonopolyManager_TypeInfo
          call $j922
          i32.const 5140209
          i32.const 1
          i32.store8
        end
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959072 ;; MonopolyManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.load offset=40
        local.set $p0
        local.get $p0
        local.get $p1
        local.get $p0
        i32.const 0
        i32.gt_s
        select
        return
      end
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j14579 ;; LongLevelActiveMa$$CurIsLongLevel
      if $I6
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.eqz
        br_if $B1
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.load offset=40
        local.set $p0
        local.get $p0
        local.get $p1
        local.get $p0
        i32.const 0
        i32.gt_s
        select
        return
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 20
      i32.eq
      if $I7
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 60
        return
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
      if $I8
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j20292 ;; SeasonLevelMa$$ResumeAddTime
        return
      end
      local.get $p0
      i32.load offset=16
      i32.load offset=24
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
      i32.load
      drop
      local.get $p0
      i32.load offset=12
      i32.const 1
      i32.lt_s
      br_if $B1
      local.get $p0
      i32.const 0
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=72
      i32.const 1
      i32.lt_s
      br_if $B1
      local.get $p0
      i32.const 0
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=72
      i32.const 60
      i32.mul
      local.set $p1
    end
    local.get $p1
    return)
