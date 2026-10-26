  (func $j22235 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i64) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140051
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939028 ;; System.Action<AsyncOperationHandle>_TypeInfo
      call $j922
      i32.const 4016184 ;; Method$UnityEngine.AddressableAssets.Addressables.LoadAssetAsync<GameObject>()
      call $j922
      i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
      call $j922
      i32.const 3976076 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<GameObject>.op_Implicit()
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4054920 ;; Method$LevelManager.<>c__DisplayClass98_0.<StartLoadMainBaseLevel1>b__0()
      call $j922
      i32.const 3969184 ;; LevelManager.<>c__DisplayClass98_0_TypeInfo
      call $j922
      i32.const 4122388 ;; 开始加载主线基础关第一关
      call $j922
      i32.const 4106928 ;; firstScene
      call $j922
      i32.const 5140051
      i32.const 1
      i32.store8
    end
    i32.const 3969184 ;; LevelManager.<>c__DisplayClass98_0_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    local.get $p0
    i32.store offset=8
    block $B1
      local.get $p1
      i32.eqz
      if $I2
        local.get $p0
        i32.load8_u offset=417
        br_if $B1
      end
      local.get $p0
      i32.const 1
      i32.store8 offset=417
      i32.const 4122388 ;; 开始加载主线基础关第一关
      i32.load
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I3
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
      local.set $p1
      i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
      i32.load
      call $j924
      local.set $l5
      local.get $l5
      i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
      i32.load
      call $j965
      local.get $l4
      local.get $l5
      i32.store offset=16
      local.get $p2
      i32.const 72
      i32.add
      i32.const 1
      i32.const 0
      call $j7298 ;; NetDataManager$$GetMainLevelIndex
      local.get $p2
      call $j3322 ;; LevelIndexAndType$$MainLevel
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      i32.load
      call $j923
      local.get $p2
      local.get $p2
      i64.load offset=72
      i64.store offset=16
      local.get $l4
      local.get $p2
      i32.const 16
      i32.add
      i32.const 1
      local.get $p2
      call $j4382 ;; LevelDataHelper$$GetLevelData
      i32.store offset=12
      block $B4
        local.get $p1
        i32.load offset=36
        i32.load offset=8
        br_if $B4
        i32.const 4106928 ;; firstScene
        i32.load
        i32.const 0
        call $j1606 ;; PlayerPrefs$$HasKey
        br_if $B4
        i32.const 4106928 ;; firstScene
        i32.load
        i32.const 1
        i32.const 0
        call $j1385 ;; PlayerPrefs$$SetInt
        local.get $l4
        i32.load offset=12
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=64
        i32.const 0
        call $j35836 ;; ThinkingManager$$FirstScene
      end
      local.get $l4
      i32.load offset=12
      i32.const 0
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=64
      local.set $p1
      i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
      i32.load
      call $j923
      local.get $p2
      i32.const 56
      i32.add
      local.get $p1
      i32.const 4016184 ;; Method$UnityEngine.AddressableAssets.Addressables.LoadAssetAsync<GameObject>()
      i32.load
      call $j15915
      local.get $p2
      i32.const -64
      i32.sub
      local.set $p1
      local.get $p1
      i64.load
      local.set $l3
      local.get $p2
      local.get $l3
      i64.store offset=32
      local.get $p2
      local.get $l3
      i64.store offset=8
      local.get $p2
      i64.load offset=56
      local.set $l3
      local.get $p2
      local.get $l3
      i64.store offset=24
      local.get $p2
      local.get $l3
      i64.store
      local.get $p2
      i32.const 40
      i32.add
      local.get $p2
      i32.const 3976076 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<GameObject>.op_Implicit()
      i32.load
      call $j1938
      local.get $p1
      local.set $l5
      local.get $p2
      i32.load offset=48
      local.set $p1
      local.get $l5
      local.get $p1
      i32.store
      local.get $p2
      i64.load offset=40
      local.set $l3
      local.get $p2
      local.get $l3
      i64.store offset=56
      local.get $p0
      local.get $p1
      i32.store offset=412
      local.get $p0
      local.get $l3
      i32.wrap_i64
      i32.store offset=404
      local.get $p0
      local.get $l3
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      i32.store offset=408
      local.get $p0
      i32.const 404
      i32.add
      local.set $p1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=52
      local.get $p0
      i32.const 1
      i32.store8 offset=416
      i32.const 3939028 ;; System.Action<AsyncOperationHandle>_TypeInfo
      i32.load
      call $j924
      local.set $p0
      local.get $p0
      local.get $l4
      i32.const 4054920 ;; Method$LevelManager.<>c__DisplayClass98_0.<StartLoadMainBaseLevel1>b__0()
      i32.load
      i32.const 0
      call $j969
      local.get $p1
      local.get $p0
      i32.const 0
      call $j4169 ;; UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle$$add_Completed
    end
    local.get $p2
    i32.const 80
    i32.add
    global.set $primary.global$0)
