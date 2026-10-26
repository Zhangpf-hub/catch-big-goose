  (func $j43524 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140072
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4099208 ;; VideoModeShakeForce
      call $j922
      i32.const 5140072
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 1
    local.get $p0
    call $j10883 ;; LevelManager$$GetTouchButton
    if $I1
      local.get $p0
      i32.const 1
      local.get $p0
      call $j14625 ;; LevelManager$$CheckClickRay
    end
    block $B2
      local.get $p0
      i32.const 2
      local.get $p0
      call $j10883 ;; LevelManager$$GetTouchButton
      i32.eqz
      br_if $B2
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      call $j2087 ;; LevelManager$$HasTwoPlayer
      i32.eqz
      br_if $B2
      local.get $p0
      i32.const 2
      local.get $p0
      call $j14625 ;; LevelManager$$CheckClickRay
    end
    block $B3
      local.get $p0
      i32.const 1
      local.get $p0
      call $j10883 ;; LevelManager$$GetTouchButton
      br_if $B3
      local.get $p0
      i32.load8_u offset=420
      i32.eqz
      br_if $B3
      local.get $p0
      i32.const 0
      i32.store8 offset=420
      local.get $p0
      i32.const 1
      local.get $p0
      call $j22244 ;; LevelManager$$GetTarget
    end
    block $B4
      local.get $p0
      i32.const 2
      local.get $p0
      call $j10883 ;; LevelManager$$GetTouchButton
      br_if $B4
      local.get $p0
      i32.load8_u offset=421
      i32.eqz
      br_if $B4
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      call $j2087 ;; LevelManager$$HasTwoPlayer
      i32.eqz
      br_if $B4
      local.get $p0
      i32.const 0
      i32.store8 offset=421
      local.get $p0
      i32.const 2
      local.get $p0
      call $j22244 ;; LevelManager$$GetTarget
    end)
