  (func $j21662 (type $t4) (param $p0 i32)
    (local $l1 i32)
    i32.const 5139754
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952628 ;; CardCollecting.CardCollectingHelper_TypeInfo
      call $j922
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
      call $j922
      i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
      call $j922
      i32.const 3950212 ;; int[]_TypeInfo
      call $j922
      i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
      call $j922
      i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
      call $j922
      i32.const 3958880 ;; MiniArchiveManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959696 ;; OnlineLevelManager_TypeInfo
      call $j922
      i32.const 3950520 ;; OnlineRivalData[]_TypeInfo
      call $j922
      i32.const 5139754
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
    local.set $l1
    i32.const 3950212 ;; int[]_TypeInfo
    i32.load
    i32.const 3
    call $j939
    local.set $p0
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 16
    i32.add
    i32.const 0
    call $j1527 ;; System.DateTime$$get_Year
    i32.store offset=16
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 16
    i32.add
    i32.const 0
    call $j1860 ;; System.DateTime$$get_Month
    i32.store offset=20
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 16
    i32.add
    i32.const 0
    call $j1861 ;; System.DateTime$$get_Day
    i32.store offset=24
    local.get $l1
    local.get $p0
    i32.store offset=92
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=96
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=100
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p0
    i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $l1
    i32.store offset=108
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p0
    i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $l1
    i32.store offset=112
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=116
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=120
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=124
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=128
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=132
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=136
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p0
    i32.const 3959696 ;; OnlineLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 3950520 ;; OnlineRivalData[]_TypeInfo
    i32.load
    i32.const 3959696 ;; OnlineLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    call $j939
    i32.store offset=140
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=144
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=148
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=152
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=156
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=160
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=164
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=168
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=172
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=176
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=184
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=188
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=192
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=196
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.const 0
    i32.store offset=200
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p0
    i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $l1
    i32.store offset=180
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.const 0
      i32.store offset=32
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=36
    i32.const 0
    i32.store offset=24
    local.get $p0
    call $j41835 ;; NetDataManager$$RefillOnlineBaseTicketOnCrossDay
    local.get $p0
    call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    if $I2
      i32.const 0
      call $j6324 ;; RewardManager$$GetGooseOwnedCount
      i32.const 0
      call $j19389 ;; ThinkingManager$$SetGetGooseCount
    end
    i32.const 3958880 ;; MiniArchiveManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j42336 ;; MiniArchiveManager$$OnCrossDay
    i32.const 3952628 ;; CardCollecting.CardCollectingHelper_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j6617 ;; CardCollecting.CardCollectingHelper$$IsOpen
    if $I3
      i32.const 3952628 ;; CardCollecting.CardCollectingHelper_TypeInfo
      i32.load
      call $j923
      i32.const 0
      i32.const 1
      i32.const 0
      call $j5856 ;; CardCollecting.CardCollectingHelper$$TryCrossActivity
    end
    i32.const 0
    call $j6669 ;; Anniversary.AnniversaryHelper$$IsOpen
    if $I4
      i32.const 0
      call $j2628 ;; Anniversary.AnniversaryHelper$$get_Instance
      i32.const 0
      call $j50212 ;; Anniversary.AnniversaryHelper$$UpdateCrossDay
    end
    i32.const 3953492 ;; DailyChallengeMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j47658) ;; DailyChallengeMa$$ResetDailySaveData
