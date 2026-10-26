  (func $j43512 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 f64) (local $l5 i32)
    i32.const 5140123
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5140123
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 5142651
    i32.load8_u
    i32.eqz
    if $I1
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
    local.set $p3
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.get $p1
    i32.store offset=56
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.set $l5
    local.get $p0
    f32.load offset=272
    f32.const 0x1.9p+6 (;=100;)
    f32.mul
    f64.promote_f32
    local.set $l4
    block $B2
      local.get $l4
      f64.abs
      f64.const 0x1p+31 (;=2.14748e+09;)
      f64.lt
      if $I3
        local.get $l4
        i32.trunc_f64_s
        local.set $p1
        br $B2
      end
      i32.const -2147483648
      local.set $p1
    end
    local.get $l5
    local.get $p1
    i32.store offset=48
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.set $l5
    local.get $p0
    f32.load offset=336
    f64.promote_f32
    local.set $l4
    block $B4
      local.get $l4
      f64.abs
      f64.const 0x1p+31 (;=2.14748e+09;)
      f64.lt
      if $I5
        local.get $l4
        i32.trunc_f64_s
        local.set $p1
        br $B4
      end
      i32.const -2147483648
      local.set $p1
    end
    local.get $l5
    local.get $p1
    i32.store offset=52
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.get $p2
    i32.store offset=60
    local.get $p3
    i32.load offset=36
    i32.load offset=32
    local.get $p3
    i32.load offset=124
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=16
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=20
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=24
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=28
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=32
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=24
    i32.load offset=36
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=48
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=52
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=56
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.load offset=60
    local.get $p0
    i32.load offset=196
    local.get $p0
    i32.load offset=200
    i32.sub
    f32.convert_i32_s
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=16
    i32.const 0
    call $j35772) ;; ThinkingManager$$ScreenBattleEnd
