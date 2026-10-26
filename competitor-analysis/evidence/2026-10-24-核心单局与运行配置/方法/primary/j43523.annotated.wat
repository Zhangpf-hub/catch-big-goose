  (func $j43523 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140061
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4125036 ;; 第3关加载完毕
      call $j922
      i32.const 5140061
      i32.const 1
      i32.store8
    end
    local.get $p1
    if $I1
      i32.const 4125036 ;; 第3关加载完毕
      i32.load
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      local.get $p0
      i32.const 0
      local.get $p1
      call $j43507 ;; LevelManager$$StartLoadAllSpLevel
    end)
