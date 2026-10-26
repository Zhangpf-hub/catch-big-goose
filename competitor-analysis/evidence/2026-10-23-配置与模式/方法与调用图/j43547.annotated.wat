  (func $j43547 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    i32.const 5140058
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
      call $j922
      i32.const 3950260 ;; LevelBGItem[]_TypeInfo
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4120860 ;; 创建PVP场景
      call $j922
      i32.const 4120872 ;; 创建主场景
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4120884 ;; 创建对战场景
      call $j922
      i32.const 4120876 ;; 创建副本场景
      call $j922
      i32.const 5140058
      i32.const 1
      i32.store8
    end
    local.get $l4
    i32.const 0
    i32.store offset=28
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        block $B3
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.eqz
          if $I4
            i32.const 3958464 ;; MainLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 5140204
            i32.load8_u
            i32.eqz
            if $I5
              i32.const 3958464 ;; MainLevelManager_TypeInfo
              call $j922
              i32.const 5140204
              i32.const 1
              i32.store8
            end
            i32.const 3958464 ;; MainLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958464 ;; MainLevelManager_TypeInfo
            i32.load
            i32.load offset=92
            local.set $p1
            local.get $p1
            i32.load offset=8
            i64.extend_i32_u
            local.get $p1
            i32.load offset=12
            i64.extend_i32_u
            i64.const 32
            i64.shl
            i64.or
            local.set $l5
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=28
            local.set $l2
            i32.const 3958024 ;; LevelDataHelper_TypeInfo
            i32.load
            call $j923
            local.get $l4
            local.get $l5
            i64.store offset=8
            local.get $l4
            local.get $l5
            i64.store offset=16
            i32.const 4120872 ;; 创建主场景
            local.set $p1
            local.get $l4
            i32.const 8
            i32.add
            local.get $l2
            i32.const 4120872 ;; 创建主场景
            call $j4382 ;; LevelDataHelper$$GetLevelData
            local.set $l3
            br $B3
          end
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 3
          i32.eq
          if $I6
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j2521 ;; NetDataManager$$get_DailyBaseLevelIndex
            local.set $l2
            i32.const 3953096 ;; ConfigManager_TypeInfo
            i32.load
            call $j923
            i32.const 4120860 ;; 创建PVP场景
            local.set $p1
            local.get $l2
            i32.const 4063796 ;; 
            i32.load
            i32.const 0
            call $j2094 ;; ConfigManager$$GetLevelData
            i32.const 1
            i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
            i32.load
            call $j1068
            local.set $l3
            br $B3
          end
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j4012 ;; SpLevelManager$$CurLevelIsSpLevel
          i32.eqz
          if $I7
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=12
            i32.const 7
            i32.ne
            br_if $B2
          end
          i32.const 4120876 ;; 创建副本场景
          local.set $p1
          local.get $p0
          i32.load offset=380
          i32.load offset=24
          local.set $l3
        end
        local.get $p0
        local.get $l3
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=64
        local.get $p1
        call $j43548 ;; LevelManager$$CreateMainSceneBg
        drop
        local.get $p1
        i32.load
        i32.const 0
        i32.const 0
        call $j1221 ;; Kunpo.Debugger$$Log
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 1
      i32.ne
      br_if $B1
      local.get $p0
      i32.load offset=52
      i32.eqz
      if $I8
        local.get $p0
        i32.const 3950260 ;; LevelBGItem[]_TypeInfo
        i32.load
        i32.const 2
        call $j939
        i32.store offset=52
      end
      i32.const 0
      local.set $p1
      loop $L9
        local.get $p1
        local.get $p0
        i32.load offset=52
        i32.load offset=12
        i32.ge_s
        br_if $B1
        local.get $p0
        i32.load offset=380
        i32.load offset=24
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=64
        local.set $l3
        local.get $p0
        i32.load offset=52
        local.set $l2
        local.get $p1
        local.get $l3
        local.get $p0
        i32.load offset=120
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.get $p1
        call $j22254 ;; LevelManager$$CreateSceneBg
        local.set $l3
        local.get $l2
        local.get $l3
        call $j930
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        local.get $l3
        i32.store offset=16
        local.get $l4
        local.get $p1
        i32.const 1
        i32.add
        i32.store offset=28
        local.get $l4
        i32.const 28
        i32.add
        i32.const 0
        call $j1012 ;; System.Int32$$ToString
        local.set $l2
        local.get $l2
        local.set $l3
        i32.const 4063796 ;; 
        i32.load
        local.set $l2
        i32.const 4120884 ;; 创建对战场景
        i32.load
        local.get $l3
        local.get $l2
        local.get $l2
        local.get $l2
        local.get $l2
        i32.const 0
        call $j1120 ;; GameManager$$StringAppend
        i32.const 0
        i32.const 0
        call $j1221 ;; Kunpo.Debugger$$Log
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L9
      end
      unreachable
    end
    i32.const 5140221
    i32.load8_u
    i32.eqz
    if $I10
      i32.const 3958068 ;; LevelSkinController_TypeInfo
      call $j922
      i32.const 5140221
      i32.const 1
      i32.store8
    end
    i32.const 3958068 ;; LevelSkinController_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.get $p0
    i32.load offset=380
    i32.load offset=24
    i32.const 0
    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
    i32.load
    call $j947
    i32.load offset=16
    local.get $p0
    i32.load offset=380
    i32.load offset=24
    i32.const 0
    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
    i32.load
    call $j947
    i32.load offset=12
    i32.const 0
    call $j43489 ;; LevelSkinController$$SetContentBg
    local.get $l4
    i32.const 32
    i32.add
    global.set $primary.global$0)
