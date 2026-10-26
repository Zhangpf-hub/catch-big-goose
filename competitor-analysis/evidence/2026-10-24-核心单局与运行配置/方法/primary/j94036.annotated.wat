  (func $j94036 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 f64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140002
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4085272 ;; MainLevelLose
      call $j922
      i32.const 4123248 ;; 无尽关卡失败
      call $j922
      i32.const 4126344 ;; 赛季关卡失败
      call $j922
      i32.const 4085024 ;; Lose
      call $j922
      i32.const 4113364 ;; pvpLevelLose
      call $j922
      i32.const 4112392 ;; onlineLevelLose
      call $j922
      i32.const 5140002
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    local.set $p0
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 3
      i32.eq
      if $I2
        local.get $p2
        local.get $p2
        call $j43519 ;; LevelManager$$OnlineGameLose
        i32.const 5
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        i32.const 4112392 ;; onlineLevelLose
        i32.load
        i32.const 0
        call $j1051 ;; UnityEngine.Debug$$Log
        br $B1
      end
      local.get $p2
      i32.const 1
      i32.add
      i32.const 0
      local.get $p2
      i32.const 3
      i32.lt_u
      select
      local.set $p0
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      local.set $l4
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p3
      local.get $l4
      i32.const 6
      i32.eq
      if $I3
        local.get $p3
        i32.load
        local.set $p2
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $l4
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=28
        local.set $l5
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        f32.load offset=272
        f32.const 0x1.9p+6 (;=100;)
        f32.mul
        f64.promote_f32
        local.set $l7
        block $B4
          local.get $l7
          f64.abs
          f64.const 0x1p+31 (;=2.14748e+09;)
          f64.lt
          if $I5
            local.get $l7
            i32.trunc_f64_s
            local.set $p3
            br $B4
          end
          i32.const -2147483648
          local.set $p3
        end
        local.get $p2
        local.get $l4
        i32.const 0
        local.get $l5
        local.get $p3
        local.get $p0
        local.get $p2
        call $j7375 ;; LevelManager$$SetSpLevelRecord
        i32.const 5
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4085024 ;; Lose
        i32.load
        i32.const 0
        call $j962 ;; System.String$$Concat
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1051 ;; UnityEngine.Debug$$Log
        br $B1
      end
      local.get $p3
      i32.load offset=12
      local.set $l4
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p3
      local.get $l4
      i32.const 20
      i32.eq
      if $I6
        local.get $p3
        i32.load
        local.set $l5
        i32.const 3955516 ;; GameTypeEnum_TypeInfo
        i32.load
        local.set $p3
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l4
        local.get $p1
        i32.const -1
        i32.store offset=4
        local.get $p1
        local.get $p3
        i32.store
        local.get $p1
        local.get $l4
        i32.load offset=12
        i32.store offset=8
        local.get $p1
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        local.set $l4
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=28
        local.set $l6
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        f32.load offset=272
        f32.const 0x1.9p+6 (;=100;)
        f32.mul
        f64.promote_f32
        local.set $l7
        block $B7
          local.get $l7
          f64.abs
          f64.const 0x1p+31 (;=2.14748e+09;)
          f64.lt
          if $I8
            local.get $l7
            i32.trunc_f64_s
            local.set $p3
            br $B7
          end
          i32.const -2147483648
          local.set $p3
        end
        local.get $l5
        local.get $l4
        i32.const 0
        local.get $l6
        local.get $p3
        local.get $p0
        local.get $p2
        call $j7375 ;; LevelManager$$SetSpLevelRecord
        i32.const 5
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        i32.const 4123248 ;; 无尽关卡失败
        i32.load
        i32.const 3
        i32.const 0
        call $j1666 ;; GameManager$$LogInfo
        br $B1
      end
      local.get $p3
      i32.load offset=12
      local.set $l4
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p3
      local.get $l4
      i32.const 9
      i32.eq
      if $I9
        local.get $p3
        i32.load
        local.set $p2
        i32.const 3955516 ;; GameTypeEnum_TypeInfo
        i32.load
        local.set $p3
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l4
        local.get $p1
        i32.const -1
        i32.store offset=4
        local.get $p1
        local.get $p3
        i32.store
        local.get $p1
        local.get $l4
        i32.load offset=12
        i32.store offset=8
        local.get $p1
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        local.set $p3
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j3819 ;; SeasonLevelMa$$GetLevel
        local.set $l5
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        f32.load offset=272
        f32.const 0x1.9p+6 (;=100;)
        f32.mul
        f64.promote_f32
        local.set $l7
        block $B10
          local.get $l7
          f64.abs
          f64.const 0x1p+31 (;=2.14748e+09;)
          f64.lt
          if $I11
            local.get $l7
            i32.trunc_f64_s
            local.set $l4
            br $B10
          end
          i32.const -2147483648
          local.set $l4
        end
        local.get $p2
        local.get $p3
        i32.const 0
        local.get $l5
        local.get $l4
        local.get $p0
        local.get $p2
        call $j7375 ;; LevelManager$$SetSpLevelRecord
        i32.const 5
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        i32.const 4126344 ;; 赛季关卡失败
        i32.load
        i32.const 3
        i32.const 0
        call $j1666 ;; GameManager$$LogInfo
        i32.const 0
        call $j7466 ;; GameManager$$EndMainGameOnce
        br $B1
      end
      local.get $p3
      i32.load offset=12
      i32.const 7
      i32.eq
      if $I12
        i32.const 3959844 ;; PVPManager_TypeInfo
        i32.load
        call $j923
        local.get $p2
        i32.const 0
        call $j41312 ;; PVPManager$$PVPGameTempLose
        i32.const 5
        i32.const 0
        call $j1601 ;; GameManager$$SetGameState
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        i32.const 4113364 ;; pvpLevelLose
        i32.load
        i32.const 0
        call $j1051 ;; UnityEngine.Debug$$Log
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l4
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      local.set $l5
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      f32.load offset=272
      f32.const 0x1.9p+6 (;=100;)
      f32.mul
      f64.promote_f32
      local.set $l7
      block $B13
        local.get $l7
        f64.abs
        f64.const 0x1p+31 (;=2.14748e+09;)
        f64.lt
        if $I14
          local.get $l7
          i32.trunc_f64_s
          local.set $p3
          br $B13
        end
        i32.const -2147483648
        local.set $p3
      end
      local.get $l4
      i32.const 0
      local.get $l5
      local.get $p3
      local.get $p0
      local.get $p2
      call $j8917 ;; LevelManager$$SetMainLevelRecord
      i32.const 5
      i32.const 0
      call $j1601 ;; GameManager$$SetGameState
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4085272 ;; MainLevelLose
      i32.load
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      i32.const 0
      call $j7466 ;; GameManager$$EndMainGameOnce
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
