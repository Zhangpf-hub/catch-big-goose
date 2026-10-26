  (func $j43511 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 f32)
    i32.const 5140156
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4071620 ;; ABSL2LevelShake
      call $j922
      i32.const 4085244 ;; MahjongModeForceChange
      call $j922
      i32.const 4091380 ;; SL2NoTargetNormalForce
      call $j922
      i32.const 4094152 ;; TargetModeForceChange
      call $j922
      i32.const 4085312 ;; MajiangModeLevel
      call $j922
      i32.const 5140156
      i32.const 1
      i32.store8
    end
    block $B1
      block $B2
        i32.const 13
        i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
        i32.load
        local.get $p0
        i32.load offset=384
        call $j951
        i32.eqz
        br_if $B2
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        call $j923
        i32.const 4071620 ;; ABSL2LevelShake
        i32.load
        i32.const 4091380 ;; SL2NoTargetNormalForce
        i32.load
        i32.const 0
        call $j2475 ;; ABTestManager$$IsFeatureType
        br_if $B2
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 4094152 ;; TargetModeForceChange
        i32.load
        i32.const 0
        call $j5264 ;; ConfigManager$$GetCommonFloatArray
        f32.load offset=16
        f32.store offset=760
        i32.const 4094152 ;; TargetModeForceChange
        i32.load
        i32.const 0
        call $j5264 ;; ConfigManager$$GetCommonFloatArray
        f32.load offset=20
        local.set $l2
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B3
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B3
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4085312 ;; MajiangModeLevel
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B3
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        i32.const 4085244 ;; MahjongModeForceChange
        i32.load
        i32.const 0
        call $j5264 ;; ConfigManager$$GetCommonFloatArray
        local.set $p1
        local.get $p0
        local.get $p1
        f32.load offset=16
        f32.store offset=760
        local.get $p1
        f32.load offset=20
        local.set $l2
        br $B1
      end
      local.get $p0
      i32.const 1065353216
      i32.store offset=760
      f32.const 0x1p+0 (;=1;)
      local.set $l2
    end
    local.get $p0
    local.get $l2
    f32.store offset=764)
