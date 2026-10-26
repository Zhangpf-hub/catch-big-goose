  (func $j94034 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139998
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 4029628 ;; Method$MainLevelModeCtrl.<IGetAllLevelObj>b__28_0()
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4055256 ;; Method$MainLevelModeCtrl.<>c.<IGetAllLevelObj>b__28_1()
      call $j922
      i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
      call $j922
      i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
      call $j922
      i32.const 4124540 ;; 清空胜利
      call $j922
      i32.const 4126492 ;; 进入最后一关
      call $j922
      i32.const 4126488 ;; 进入下一个场景
      call $j922
      i32.const 4121204 ;; 即将进入新场景！
      call $j922
      i32.const 5139998
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.eqz
      if $I2
        block $B3
          i32.const 0
          call $j5758 ;; GameManager$$IsStartGameDirection
          i32.eqz
          br_if $B3
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j13811 ;; SeasonLevelMa$$IsDirectionSeasonLevelFork
          i32.eqz
          br_if $B3
          i32.const 3939040 ;; System.Action<bool>_TypeInfo
          i32.load
          call $j924
          local.set $l2
          local.get $l2
          local.get $p0
          i32.const 4029628 ;; Method$MainLevelModeCtrl.<IGetAllLevelObj>b__28_0()
          i32.load
          i32.const 0
          call $j969
          i32.const 3961680 ;; SeasonLevelMa_TypeInfo
          i32.load
          call $j923
          local.get $l2
          i32.const 0
          call $j20298 ;; SeasonLevelMa$$CanDirectToSeasonLevel
          i32.const 0
          call $j7466 ;; GameManager$$EndMainGameOnce
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=28
        i32.const 1
        i32.eq
        if $I4
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          i32.const 600
          i32.const 4126492 ;; 进入最后一关
          i32.load
          f32.const 0x1p+0 (;=1;)
          f32.const 0x0p+0 (;=0;)
          i32.const 0
          call $j1952 ;; Kunpo.KUIManager$$OpenATip
          local.get $p0
          i32.load offset=8
          i32.const 1
          i32.const 1
          i32.const 100
          i32.const 0
          local.get $p1
          call $j8917 ;; LevelManager$$SetMainLevelRecord
          i32.const 3
          i32.const 0
          call $j1601 ;; GameManager$$SetGameState
          local.get $p0
          i32.load offset=8
          i32.const 2
          i32.const 0
          i32.const 0
          i32.const 0
          local.get $p1
          call $j2956 ;; LevelManager$$StartGame
          i32.const 0
          call $j7466 ;; GameManager$$EndMainGameOnce
          br $B1
        end
        local.get $p0
        i32.load offset=8
        i32.const 1
        i32.const 2
        i32.const 100
        i32.const 0
        local.get $p1
        call $j8917 ;; LevelManager$$SetMainLevelRecord
        i32.const 0
        call $j4735 ;; GameManager$$GameWin
        br $B1
      end
      i32.const 3953480 ;; DYDirectPlayManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j11300 ;; DYDirectPlayManager$$IsThisState
      if $I5
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 1
        i32.const 0
        i32.const 0
        i32.const 0
        call $j3660 ;; MainLevelManager$$StartGame
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      local.set $l3
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l2
      local.get $l3
      i32.const 3
      i32.eq
      if $I6
        local.get $l2
        i32.load offset=28
        i32.const 2
        i32.ne
        br_if $B1
        i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 100
        i32.const 1
        i32.const 0
        call $j6156 ;; UIOnlineGamePage$$SetMyProgress
        i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 101
        i32.const 0
        call $j13171 ;; UIOnlineGamePage$$EndOnlineGame
        i32.const 0
        call $j4735 ;; GameManager$$GameWin
        i32.const 2
        i32.const 4124540 ;; 清空胜利
        i32.load
        i32.const 0
        call $j1429 ;; GameManager$$LogInColor
        br $B1
      end
      local.get $l2
      i32.load offset=12
      i32.const 6
      i32.eq
      if $I7
        i32.const 3955840 ;; GroupBattleManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j5748 ;; GroupBattleManager$$IsThisState
        if $I8
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          i32.const 4121204 ;; 即将进入新场景！
          i32.load
          i32.const 0
          call $j1433 ;; Kunpo.KUIManager$$OpenNormalWarn
          i32.const 2
          i32.const 4126488 ;; 进入下一个场景
          i32.load
          i32.const 0
          call $j1429 ;; GameManager$$LogInColor
          i32.const 3955840 ;; GroupBattleManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j44799 ;; GroupBattleManager$$AddTime
          i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
          i32.load
          call $j923
          i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          local.set $p0
          local.get $p0
          i32.eqz
          if $I9
            i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
            i32.load
            call $j923
            i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            local.set $l2
            i32.const 3939040 ;; System.Action<bool>_TypeInfo
            i32.load
            call $j924
            local.set $p0
            local.get $p0
            local.get $l2
            i32.const 4055256 ;; Method$MainLevelModeCtrl.<>c.<IGetAllLevelObj>b__28_1()
            i32.load
            i32.const 0
            call $j969
            i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
            i32.load
            i32.load offset=92
            local.get $p0
            i32.store offset=4
            i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
            i32.load
            i32.load offset=92
            drop
          end
          i32.const 3955840 ;; GroupBattleManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 0
          call $j44792 ;; GroupBattleManager$$OpenNextLevel
          br $B1
        end
        i32.const 0
        call $j4735 ;; GameManager$$GameWin
        i32.const 2
        i32.const 4124540 ;; 清空胜利
        i32.load
        i32.const 0
        call $j1429 ;; GameManager$$LogInColor
        local.get $p0
        i32.load offset=8
        local.set $p0
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 1
        i32.const 2
        i32.const 100
        i32.const 0
        local.get $p1
        call $j7375 ;; LevelManager$$SetSpLevelRecord
        br $B1
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
      if $I10
        i32.const 0
        call $j4735 ;; GameManager$$GameWin
        i32.const 2
        i32.const 4124540 ;; 清空胜利
        i32.load
        i32.const 0
        call $j1429 ;; GameManager$$LogInColor
        local.get $p0
        i32.load offset=8
        local.set $p0
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        local.set $l3
        i32.const 3955516 ;; GameTypeEnum_TypeInfo
        i32.load
        local.set $p0
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l2
        local.get $p1
        i32.const -1
        i32.store offset=4
        local.get $p1
        local.get $p0
        i32.store
        local.get $p1
        local.get $l2
        i32.load offset=12
        i32.store offset=8
        local.get $l3
        local.get $p1
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        i32.const 1
        i32.const 2
        i32.const 100
        i32.const 0
        local.get $p1
        call $j7375 ;; LevelManager$$SetSpLevelRecord
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
      if $I11
        i32.const 0
        call $j4735 ;; GameManager$$GameWin
        i32.const 2
        i32.const 4124540 ;; 清空胜利
        i32.load
        i32.const 0
        call $j1429 ;; GameManager$$LogInColor
        local.get $p0
        i32.load offset=8
        local.set $p0
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        local.set $l3
        i32.const 3955516 ;; GameTypeEnum_TypeInfo
        i32.load
        local.set $p0
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l2
        local.get $p1
        i32.const -1
        i32.store offset=4
        local.get $p1
        local.get $p0
        i32.store
        local.get $p1
        local.get $l2
        i32.load offset=12
        i32.store offset=8
        local.get $l3
        local.get $p1
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        i32.const 1
        i32.const 2
        i32.const 100
        i32.const 0
        local.get $p1
        call $j7375 ;; LevelManager$$SetSpLevelRecord
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 7
      i32.ne
      br_if $B1
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 101
      i32.const 0
      call $j7278 ;; PVPManager$$UploadPVPGameEnd
      i32.const 2
      i32.const 4124540 ;; 清空胜利
      i32.load
      i32.const 0
      call $j1429 ;; GameManager$$LogInColor
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
