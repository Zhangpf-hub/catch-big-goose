  (func $j94031 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140005
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 5140005
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
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      call $j923
      i32.const 27
      i32.const 0
      call $j3510 ;; ConfigManager$$GetCommonInt
      return
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
    if $I2
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j21443 ;; PVPManager$$GetLevelMaxTime
      return
    end
    i32.const 3955840 ;; GroupBattleManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j5748 ;; GroupBattleManager$$IsThisState
    if $I3
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      call $j923
      i32.const 5140215
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3955840 ;; GroupBattleManager_TypeInfo
        call $j922
        i32.const 5140215
        i32.const 1
        i32.store8
      end
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      call $j923
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=24
      local.set $p0
      local.get $p0
      i32.const 1
      local.get $p0
      i32.const 1
      i32.gt_s
      select
      return
    end
    local.get $p0
    i32.load offset=16
    i32.load offset=24
    i32.const 0
    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
    i32.load
    call $j947
    i32.load offset=56
    i32.load offset=16
    return)
