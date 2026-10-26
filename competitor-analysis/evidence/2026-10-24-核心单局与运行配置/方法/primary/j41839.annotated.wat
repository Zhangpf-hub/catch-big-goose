  (func $j41839 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i64)
    i32.const 5139723
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3985872 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Clear()
      call $j922
      i32.const 4031356 ;; Method$NetDataManager.ResetDaliySaveAndLevel()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4045788 ;; Method$ValueManager.ResetDaliyLocalSave()
      call $j922
      i32.const 5139723
      i32.const 1
      i32.store8
    end
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=84
    local.set $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 0
    i32.const 4045788 ;; Method$ValueManager.ResetDaliyLocalSave()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    local.get $p0
    local.get $l1
    i32.const 0
    call $j1045 ;; System.Delegate$$Combine
    local.set $p0
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    local.set $l1
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=84
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    drop
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=84
    local.set $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 0
    i32.const 4031356 ;; Method$NetDataManager.ResetDaliySaveAndLevel()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    local.get $p0
    local.get $l1
    i32.const 0
    call $j1045 ;; System.Delegate$$Combine
    local.set $p0
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    local.set $l1
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=84
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.const 3985872 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Clear()
    i32.load
    call $j1200
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 12
    i32.const 0
    call $j9186 ;; ConfigManager$$GetCommonString
    local.set $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=76
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    call $j21661 ;; NetDataManager$$ResetGameSumTime
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store8 offset=8
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=132
    local.set $p0
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j2206 ;; NetworkHelper$$TimeStampToTime
    local.set $l2
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l2
    i64.store offset=16
    local.get $p0
    call $j10706 ;; NetDataManager$$FakeTimeOffset
    local.get $p0
    call $j21660 ;; NetDataManager$$SetLevelData
    local.get $p0
    call $j41850 ;; NetDataManager$$GetNetDataComplete
    i32.const 0
    call $j43654 ;; KuaiShouAdManager$$SendDay2
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j1326 ;; NetworkConfig$$get_GameChannel
    i32.const 3
    i32.eq
    if $I1
      i32.const 0
      call $j7040 ;; TikTokToWXAdManager$$get_Instance
      i32.const 0
      call $j35503 ;; TikTokToWXAdManager$$AfterEnterGame
    end)
