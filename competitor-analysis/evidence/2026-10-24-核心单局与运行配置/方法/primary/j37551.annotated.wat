  (func $j37551 (type $t4) (param $p0 i32)
    i32.const 5139640
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4065392 ;;  无关卡进度数据
      call $j922
      i32.const 5139640
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    i32.const 0
    call $j2269 ;; SpLevelManager$$GetSpLevelTodaySave
    local.set $p0
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=24
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    local.set $p0
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j23912 ;; ConfigManager$$GetSpLevelData
    local.set $p0
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=8
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=8
    i32.eqz
    if $I1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 4065392 ;;  无关卡进度数据
      i32.load
      i32.const 0
      call $j962 ;; System.String$$Concat
      local.set $p0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=12
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=20)
