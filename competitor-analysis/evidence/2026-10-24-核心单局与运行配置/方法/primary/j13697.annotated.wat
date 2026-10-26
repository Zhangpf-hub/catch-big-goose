  (func $j13697 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    i32.const 5139658
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4123840 ;; 未注册该副本
      call $j922
      i32.const 4123380 ;; 无该关卡
      call $j922
      i32.const 5139658
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j5052 ;; SpLevelManager$$IsCurSpLevelSign
    i32.eqz
    if $I1
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 600
      i32.const 4123840 ;; 未注册该副本
      i32.load
      i32.const 0
      call $j1145 ;; Kunpo.KUIManager$$OpenATip
      i32.const 0
      return
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    local.get $p0
    i32.const 0
    call $j2094 ;; ConfigManager$$GetLevelData
    i32.eqz
    if $I2
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 600
      i32.const 4123380 ;; 无该关卡
      i32.load
      i32.const 0
      call $j1145 ;; Kunpo.KUIManager$$OpenATip
      i32.const 0
      return
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=60
    local.get $p0
    i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
    i32.load
    call $j1040
    i32.eqz
    if $I3
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=60
      local.get $p0
      local.get $p1
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      i32.load
      call $j1228
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p0
      local.get $p1
      i32.const 0
      i32.const 0
      call $j14619 ;; LevelManager$$LoadSpLevelObj
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j2670 ;; SpLevelManager$$GetSpWindow
    local.set $p0
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=28
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    block $B4
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.eqz
      br_if $B4
      local.get $p2
      i32.eqz
      br_if $B4
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.load offset=8
      local.set $p0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      i32.const 0
      i32.const 0
      i32.const 0
      call $j1082 ;; Kunpo.KUIManager$$OpenUI
    end
    i32.const 1
    return)
