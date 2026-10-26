  (func $j95020 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140069
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 5140069
      i32.const 1
      i32.store8
    end
    i32.const 0
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $p0
    i32.load offset=384
    local.get $p1
    call $j1076)
