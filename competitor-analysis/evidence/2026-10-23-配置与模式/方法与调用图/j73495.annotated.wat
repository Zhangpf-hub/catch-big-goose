  (func $j73495 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140011
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 4121468 ;; 场景加载错误
      call $j922
      i32.const 5140011
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.eqz
    if $I1
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 4121468 ;; 场景加载错误
      i32.load
      i32.const 0
      call $j1433 ;; Kunpo.KUIManager$$OpenNormalWarn
    end)
