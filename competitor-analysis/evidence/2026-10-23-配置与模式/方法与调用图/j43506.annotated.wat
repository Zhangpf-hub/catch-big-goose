  (func $j43506 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140052
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 4029168 ;; Method$LevelManager.LoadCompelet2()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4122392 ;; 开始加载主线基础关第二关
      call $j922
      i32.const 5140052
      i32.const 1
      i32.store8
    end
    i32.const 4122392 ;; 开始加载主线基础关第二关
    i32.load
    i32.const 0
    call $j1441 ;; UnityEngine.MonoBehaviour$$print
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 8
    i32.add
    i32.const 0
    call $j2521 ;; NetDataManager$$get_DailyBaseLevelIndex
    local.get $p1
    call $j3322 ;; LevelIndexAndType$$MainLevel
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    local.get $p1
    i64.load offset=8
    i64.store
    local.get $p1
    local.get $p1
    call $j5156 ;; LevelLoaderManager$$GetLevelLoader
    local.set $l3
    i32.const 3939040 ;; System.Action<bool>_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    local.get $p0
    i32.const 4029168 ;; Method$LevelManager.LoadCompelet2()
    i32.load
    i32.const 0
    call $j969
    local.get $l3
    local.get $l2
    local.get $p1
    call $j4700 ;; LevelLoader$$Load
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
