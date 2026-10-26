  (func $j22260 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140064
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983684 ;; Method$System.Collections.Generic.Dictionary<string, bool>.Clear()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4126708 ;; 重新加载关卡
      call $j922
      i32.const 5140064
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=68
    if $I1
      i32.const 4126708 ;; 重新加载关卡
      i32.load
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store8 offset=44
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store8 offset=45
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store8 offset=46
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=48
      i32.const 3983684 ;; Method$System.Collections.Generic.Dictionary<string, bool>.Clear()
      i32.load
      call $j1200
      local.get $p0
      i32.const 1
      local.get $p0
      call $j22235 ;; LevelManager$$StartLoadMainBaseLevel1
    end)
