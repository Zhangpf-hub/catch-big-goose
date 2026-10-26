  (func $j43534 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140180
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4077460 ;; Easy80
      call $j922
      i32.const 4118684 ;; {0} AB偏移 {1}
      call $j922
      i32.const 4071596 ;; ABEasySpLevel AB偏移 无改变
      call $j922
      i32.const 4071592 ;; ABEasySpLevel
      call $j922
      i32.const 4081156 ;; HeartbeatSpLevel
      call $j922
      i32.const 4092756 ;; SpLevelHardControl
      call $j922
      i32.const 4077464 ;; Easy90
      call $j922
      i32.const 4121940 ;; 层{0}的种类偏移为{1}
      call $j922
      i32.const 4077456 ;; Easy70
      call $j922
      i32.const 5140180
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 0
    i32.store offset=12
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B2
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4081156 ;; HeartbeatSpLevel
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p2
        local.get $p1
        i32.const 1
        i32.gt_u
        br_if $B2
        local.get $p2
        i32.load offset=28
        i32.const 2
        i32.ne
        br_if $B2
        i32.const 0
        local.set $p2
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        i32.const 4092756 ;; SpLevelHardControl
        i32.load
        i32.const 0
        call $j5263 ;; ConfigManager$$GetCommonString
        local.set $l3
        local.get $l3
        i32.load offset=12
        i32.eqz
        br_if $B2
        i32.const 3951300 ;; ABTestManager_TypeInfo
        i32.load
        call $j923
        i32.const 4071592 ;; ABEasySpLevel
        i32.load
        i32.const 0
        call $j11647 ;; ABTestManager$$GetFeatureType
        local.set $l4
        block $B3
          local.get $l4
          i32.const 4077456 ;; Easy70
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          br_if $B3
          i32.const 1
          local.set $p2
          local.get $l4
          i32.const 4077460 ;; Easy80
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          br_if $B3
          i32.const 2
          local.set $p2
          local.get $l4
          i32.const 4077464 ;; Easy90
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B2
        end
        local.get $l3
        i32.load offset=12
        local.get $p2
        i32.le_s
        br_if $B2
        local.get $l3
        local.get $p2
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 124
        i32.const 0
        i32.const 0
        call $j1545 ;; System.String$$Split
        local.set $p2
        local.get $p2
        i32.load offset=12
        local.get $p1
        i32.le_s
        br_if $B2
        local.get $p2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.get $p0
        i32.const 12
        i32.add
        i32.const 0
        call $j1399 ;; System.Int32$$TryParse
        i32.eqz
        br_if $B2
        local.get $p0
        local.get $p0
        i32.load offset=12
        i32.store offset=8
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $p0
        i32.const 8
        i32.add
        call $j935
        local.set $p2
        i32.const 4118684 ;; {0} AB偏移 {1}
        i32.load
        i32.const 4071592 ;; ABEasySpLevel
        i32.load
        local.get $p2
        i32.const 0
        call $j1060 ;; System.String$$Format
        i32.const 3
        i32.const 0
        call $j1407 ;; GameManager$$LogInColor
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        call $j1600 ;; NetInitManager$$CanShowSEventDetail
        if $I4
          local.get $p0
          local.get $p1
          i32.store offset=8
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $p0
          i32.const 8
          i32.add
          call $j935
          local.set $p1
          local.get $p0
          local.get $p0
          i32.load offset=12
          i32.store offset=4
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $p0
          i32.const 4
          i32.add
          call $j935
          local.set $p2
          i32.const 5
          i32.const 4121940 ;; 层{0}的种类偏移为{1}
          i32.load
          local.get $p1
          local.get $p2
          i32.const 0
          call $j1060 ;; System.String$$Format
          i32.const 0
          call $j1429 ;; GameManager$$LogInColor
        end
        local.get $p0
        i32.load offset=12
        local.set $p1
        br $B1
      end
      i32.const 0
      local.set $p1
      i32.const 4071596 ;; ABEasySpLevel AB偏移 无改变
      i32.load
      i32.const 3
      i32.const 0
      call $j1407 ;; GameManager$$LogInColor
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p1
    return)
