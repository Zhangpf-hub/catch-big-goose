  (func $j14618 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140132
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958348 ;; LoseWay_TypeInfo
      call $j922
      i32.const 4121596 ;; 失败，时间已耗尽
      call $j922
      i32.const 4121600 ;; 失败，物品栏已满
      call $j922
      i32.const 5140132
      i32.const 1
      i32.store8
    end
    block $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.eqz
      if $I2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 1
        i32.store8 offset=36
      end
      local.get $p0
      i32.const 1
      local.get $p2
      call $j7376 ;; LevelManager$$LostTarget
      local.get $p0
      local.set $l3
      i32.const 3
      i32.const 15
      local.get $p1
      select
      i32.const 3
      i32.const 4
      local.get $p1
      select
      i32.const 13
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      i32.load
      local.get $p0
      i32.load offset=384
      call $j951
      select
      local.set $p0
      local.get $l3
      local.get $p0
      local.get $p2
      call $j14626 ;; LevelManager$$CanUseTool
      i32.eqz
      if $I3
        i32.const 4121596 ;; 失败，时间已耗尽
        i32.const 4121600 ;; 失败，物品栏已满
        local.get $p1
        select
        i32.load
        local.set $p0
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 605
        local.get $p0
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
        local.get $p1
        i32.const 1
        i32.xor
        local.set $p0
        i32.const 0
        local.get $p0
        i32.const 0
        call $j6516 ;; GameManager$$GameLose
        local.get $p2
        local.get $p0
        i32.store offset=12
        i32.const 3958348 ;; LoseWay_TypeInfo
        i32.load
        local.set $p0
        local.get $p2
        i32.const -1
        i32.store offset=4
        local.get $p2
        local.get $p0
        i32.store
        local.get $p2
        local.get $p2
        i32.load offset=12
        i32.store offset=8
        i32.const 1
        local.get $p2
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        i32.const 0
        call $j1429 ;; GameManager$$LogInColor
        br $B1
      end
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      local.set $p1
      local.get $p1
      i32.eqz
      br_if $B1
      local.get $p1
      local.get $p0
      i32.const 0
      call $j1561
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
