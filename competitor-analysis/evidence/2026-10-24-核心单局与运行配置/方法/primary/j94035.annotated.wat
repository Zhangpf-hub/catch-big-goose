  (func $j94035 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5140007
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4076524 ;; DailyChallenge
      call $j922
      i32.const 4085312 ;; MajiangModeLevel
      call $j922
      i32.const 4094136 ;; TaoYuanSpLevel
      call $j922
      i32.const 4084592 ;; LevelSlot
      call $j922
      i32.const 5140007
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    i32.const 3
    i32.eq
    if $I1
      i32.const 201
      i32.const 202
      local.get $p1
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
    i32.const 4
    i32.eq
    if $I2
      i32.const 101
      i32.const 102
      local.get $p1
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
    i32.const 5
    i32.eq
    if $I3
      i32.const 301
      i32.const 302
      local.get $p1
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
    i32.const 6
    i32.eq
    if $I4
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
      if $I5
        i32.const 22
        i32.const 23
        local.get $p1
        select
        return
      end
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.set $p0
      i32.const 5142656
      i32.load8_u
      i32.eqz
      if $I6
        i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
        call $j922
        i32.const 5142656
        i32.const 1
        i32.store8
      end
      local.get $p0
      i32.const 3951612 ;; Anniversary.AnniversaryHelper_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      if $I7
        i32.const 811
        i32.const 812
        local.get $p1
        select
        return
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
      if $I8
        i32.const 751
        i32.const 752
        local.get $p1
        select
        return
      end
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
      if $I9
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.const 2
        i32.eq
        if $I10
          i32.const 34
          i32.const 35
          local.get $p1
          select
          return
        end
        i32.const 31
        i32.const 32
        local.get $p1
        select
        return
      end
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.set $p0
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      if $I11
        i32.const 820
        i32.const 821
        local.get $p1
        select
        return
      end
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
      if $I12
        i32.const 921
        i32.const 922
        local.get $p1
        select
        return
      end
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
      if $I13
        i32.const 931
        i32.const 932
        local.get $p1
        select
        return
      end
      i32.const 304
      i32.const 305
      local.get $p1
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
    if $I14
      i32.const 351
      i32.const 352
      local.get $p1
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
    i32.const 9
    i32.eq
    if $I15
      i32.const 361
      i32.const 362
      local.get $p1
      select
      return
    end
    local.get $p1
    i32.const 1
    i32.xor
    return)
