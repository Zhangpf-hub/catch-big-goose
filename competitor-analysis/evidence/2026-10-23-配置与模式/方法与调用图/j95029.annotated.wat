  (func $j95029 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140060
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4125032 ;; 第2关加载完毕
      call $j922
      i32.const 5140060
      i32.const 1
      i32.store8
    end
    local.get $p1
    if $I1
      i32.const 4125032 ;; 第2关加载完毕
      i32.load
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      local.get $p0
      i32.const 0
      i32.store8 offset=417
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 1
      i32.store8 offset=46
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      local.get $p1
      if $I2
        local.get $p1
        i32.load offset=32
        local.get $p1
        i32.load offset=20
        local.get $p1
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t0)
      end
      local.get $p0
      local.get $p0
      call $j43508 ;; LevelManager$$StartLoadAllMainLevelWithoutBase
    end
    block $B3
      local.get $p0
      i32.load8_u offset=419
      br_if $B3
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j1326 ;; NetworkConfig$$get_GameChannel
      i32.const 3
      i32.ne
      br_if $B3
      local.get $p0
      i32.const 1
      i32.store8 offset=419
      local.get $p0
      local.get $p0
      call $j43522 ;; LevelManager$$LoadOtherGameGIF
    end)
