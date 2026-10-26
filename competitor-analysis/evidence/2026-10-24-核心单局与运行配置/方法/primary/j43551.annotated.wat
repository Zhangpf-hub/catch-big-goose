  (func $j43551 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140085
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953492 ;; DailyChallengeMa_TypeInfo
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3955840 ;; GroupBattleManager_TypeInfo
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 3958080 ;; LevelSlotMa_TypeInfo
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3959832 ;; PVPLoadManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4124536 ;; 清理副本关物品
      call $j922
      i32.const 5140085
      i32.const 1
      i32.store8
    end
    i32.const 4124536 ;; 清理副本关物品
    i32.load
    i32.const 0
    call $j1441 ;; UnityEngine.MonoBehaviour$$print
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j37554 ;; SpLevelManager$$CleanBaseSpLevel
    i32.const 0
    call $j37553 ;; SpLevelManager$$CleanOtherSpLevel
    i32.const 3958080 ;; LevelSlotMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j14611 ;; LevelSlotMa$$CleanNoUseObj
    i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j22166 ;; LongLevelActiveMa$$CleanNoUseObj
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j23328 ;; EndlessLevelMa$$CleanNoUseObj
    i32.const 3953492 ;; DailyChallengeMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j23734 ;; DailyChallengeMa$$CleanNoUseObj
    i32.const 3959832 ;; PVPLoadManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j21450 ;; PVPLoadManager$$CleanNoUseObj
    i32.const 3961680 ;; SeasonLevelMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j20296 ;; SeasonLevelMa$$CleanNoUseObj
    i32.const 3955840 ;; GroupBattleManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j22712 ;; GroupBattleManager$$CleanNoUseObj
    i32.const 0
    call $j48496 ;; CollegeEntranceExamination2026Helper$$CleanNoUseObj
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j43558) ;; LevelLoaderManager$$ClearAllLoadedLevel
