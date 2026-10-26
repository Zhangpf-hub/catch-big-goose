  (func $j4382 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140022
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3979512 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.TryGetValue()
      call $j922
      i32.const 3979524 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.set_Item()
      call $j922
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 5140022
      i32.const 1
      i32.store8
    end
    local.get $p2
    i32.const 0
    i32.store offset=12
    block $B1
      local.get $p0
      local.get $p2
      call $j4381 ;; LevelIndexAndType$$get_IsExist
      i32.eqz
      br_if $B1
      local.get $p0
      local.get $p2
      call $j8918 ;; LevelIndexAndType$$get_IsEndlessLevel
      if $I2
        i32.const 3958024 ;; LevelDataHelper_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.load
        local.set $p0
        i32.const 3958024 ;; LevelDataHelper_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        local.get $p0
        local.get $p2
        i32.const 12
        i32.add
        i32.const 3979512 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.TryGetValue()
        i32.load
        call $j1164
        i32.eqz
        if $I3
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 0
          call $j9185 ;; ConfigManager$$GetEndlessLevelData
          local.set $p1
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          call $j923
          local.get $p2
          local.get $p1
          local.get $p2
          call $j11191 ;; EndlessLevelMa$$TranslateLevelData
          i32.store offset=12
          i32.const 3958024 ;; LevelDataHelper_TypeInfo
          i32.load
          call $j923
          i32.const 3958024 ;; LevelDataHelper_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=8
          local.get $p0
          local.get $p2
          i32.load offset=12
          i32.const 3979524 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.set_Item()
          i32.load
          call $j1608
        end
        local.get $p2
        i32.load offset=12
        local.set $l3
        br $B1
      end
      local.get $p0
      i32.load offset=4
      local.set $l3
      local.get $p0
      i32.load
      local.set $p0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $l3
      local.get $p1
      i32.const 0
      call $j48175 ;; ConfigManager$$GetLevelDataByLevel
      local.set $l3
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $l3
    return)
