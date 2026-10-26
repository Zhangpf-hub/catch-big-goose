  (func $j4380 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140079
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140079
      i32.const 1
      i32.store8
    end
    local.get $p0
    local.get $p0
    i32.load offset=152
    local.get $p0
    f32.load offset=260
    i32.const 1
    local.get $p0
    call $j22262 ;; LevelManager$$CaculateMaxHeight
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    call $j2087 ;; LevelManager$$HasTwoPlayer
    if $I1
      local.get $p0
      local.get $p0
      i32.load offset=168
      local.get $p0
      f32.load offset=324
      i32.const 2
      local.get $p0
      call $j22262 ;; LevelManager$$CaculateMaxHeight
    end)
