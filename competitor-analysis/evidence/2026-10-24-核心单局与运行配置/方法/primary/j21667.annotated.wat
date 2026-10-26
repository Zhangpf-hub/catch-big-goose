  (func $j21667 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32)
    i32.const 5139744
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3949732 ;; bool[]_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3984884 ;; Method$System.Collections.Generic.Dictionary<string, LongLevelSaveData>..ctor()
      call $j922
      i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
      call $j922
      i32.const 3984716 ;; Method$System.Collections.Generic.Dictionary<string, int>..ctor()
      call $j922
      i32.const 3983424 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>..ctor()
      call $j922
      i32.const 3941672 ;; System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>_TypeInfo
      call $j922
      i32.const 3942156 ;; System.Collections.Generic.Dictionary<string, int>_TypeInfo
      call $j922
      i32.const 3942204 ;; System.Collections.Generic.Dictionary<string, LongLevelSaveData>_TypeInfo
      call $j922
      i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
      call $j922
      i32.const 3950212 ;; int[]_TypeInfo
      call $j922
      i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
      call $j922
      i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 3959696 ;; OnlineLevelManager_TypeInfo
      call $j922
      i32.const 3950520 ;; OnlineRivalData[]_TypeInfo
      call $j922
      i32.const 3959700 ;; OnlineRivalData_TypeInfo
      call $j922
      i32.const 3964812 ;; UserRecord_TypeInfo
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5139744
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
    i32.load offset=36
    local.set $p1
    local.get $p1
    i32.eqz
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.const 3964812 ;; UserRecord_TypeInfo
      i32.load
      call $j924
      i32.store offset=36
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=92
      if $I3
        local.get $p1
        i32.eqz
        local.set $l3
        br $B2
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $l2
      i32.const 3950212 ;; int[]_TypeInfo
      i32.load
      i32.const 3
      call $j939
      local.set $p1
      local.get $p1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1527 ;; System.DateTime$$get_Year
      i32.store offset=16
      i32.const 1
      local.set $l3
      local.get $p1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1860 ;; System.DateTime$$get_Month
      i32.store offset=20
      local.get $p1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1861 ;; System.DateTime$$get_Day
      i32.store offset=24
      local.get $l2
      local.get $p1
      i32.store offset=92
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=12
    i32.eqz
    if $I4
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      i32.const 1
      local.set $l3
      i32.const 3950212 ;; int[]_TypeInfo
      i32.load
      i32.const 1
      call $j939
      local.set $l2
      local.get $l2
      i32.const 1
      i32.store offset=16
      local.get $p1
      local.get $l2
      i32.store offset=12
    end
    i32.const 0
    local.set $p1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=16
    i32.eqz
    if $I5
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $l4
      i32.const 3950212 ;; int[]_TypeInfo
      i32.load
      i32.const 3
      call $j939
      local.set $l2
      local.get $l2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1527 ;; System.DateTime$$get_Year
      i32.store offset=16
      i32.const 1
      local.set $l3
      local.get $l2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1860 ;; System.DateTime$$get_Month
      i32.store offset=20
      local.get $l2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1861 ;; System.DateTime$$get_Day
      i32.store offset=24
      local.get $l4
      local.get $l2
      i32.store offset=16
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B6
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      i32.eqz
      if $I7
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        local.set $p1
        i32.const 3942156 ;; System.Collections.Generic.Dictionary<string, int>_TypeInfo
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 3984716 ;; Method$System.Collections.Generic.Dictionary<string, int>..ctor()
        i32.load
        call $j967
        local.get $p1
        local.get $l3
        i32.store offset=28
        i32.const 1
        local.set $l3
        i32.const 0
        local.set $p1
        loop $L8
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=76
          i32.load offset=12
          i32.ge_s
          br_if $B6
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=76
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          local.get $p1
          call $j8813 ;; NetDataManager$$InitNewRes
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L8
        end
        unreachable
      end
      loop $L9
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=76
        i32.load offset=12
        i32.ge_s
        br_if $B6
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.load offset=28
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=76
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
        i32.load
        call $j1040
        i32.eqz
        if $I10
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=76
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          local.get $p1
          call $j8813 ;; NetDataManager$$InitNewRes
          i32.const 1
          local.set $l3
        end
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L9
      end
      unreachable
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B11
      block $B12
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.load offset=32
        i32.eqz
        if $I13
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          call $j923
          i32.const 5139832
          i32.load8_u
          i32.eqz
          if $I14
            i32.const 3953096 ;; ConfigManager_TypeInfo
            call $j922
            i32.const 5139832
            i32.const 1
            i32.store8
          end
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          call $j923
          i32.const 3949732 ;; bool[]_TypeInfo
          i32.load
          i32.const 3953096 ;; ConfigManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=136
          i32.load offset=12
          call $j939
          local.set $l3
          local.get $l3
          i32.const 1
          i32.store8 offset=16
          i32.const 1
          local.set $p1
          loop $L15
            local.get $l3
            i32.load offset=12
            local.get $p1
            i32.gt_s
            if $I16
              local.get $p1
              local.get $l3
              i32.add
              i32.const 0
              i32.store8 offset=16
              local.get $p1
              i32.const 1
              i32.add
              local.set $p1
              br $L15
            end
          end
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          local.get $l3
          i32.store offset=32
          br $B12
        end
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.load offset=32
        local.set $p1
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        i32.const 5139832
        i32.load8_u
        i32.eqz
        if $I17
          i32.const 3953096 ;; ConfigManager_TypeInfo
          call $j922
          i32.const 5139832
          i32.const 1
          i32.store8
        end
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.load offset=12
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=136
        i32.load offset=12
        i32.ge_s
        br_if $B11
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        i32.const 5139832
        i32.load8_u
        i32.eqz
        if $I18
          i32.const 3953096 ;; ConfigManager_TypeInfo
          call $j922
          i32.const 5139832
          i32.const 1
          i32.store8
        end
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        i32.const 3949732 ;; bool[]_TypeInfo
        i32.load
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=136
        i32.load offset=12
        call $j939
        local.set $l3
        i32.const 0
        local.set $p1
        loop $L19
          block $B20
            local.get $l3
            i32.load offset=12
            local.set $l4
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=32
            local.set $l2
            local.get $p1
            local.get $l4
            i32.ge_s
            br_if $B20
            local.get $p1
            local.get $l3
            i32.add
            local.set $l4
            local.get $l2
            i32.load offset=32
            i32.load offset=12
            local.get $p1
            i32.gt_s
            if $I21
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              local.get $p1
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=32
              i32.load offset=32
              i32.add
              i32.load8_u offset=16
              local.set $l2
            else
              i32.const 0
              local.set $l2
            end
            local.get $l4
            local.get $l2
            i32.store8 offset=16
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L19
          end
        end
        local.get $l2
        local.get $l3
        i32.store offset=32
      end
      i32.const 1
      local.set $l3
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 5139833
    i32.load8_u
    i32.eqz
    if $I22
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 5139833
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=40
    i32.eqz
    if $I23
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      i32.const 3941672 ;; System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>_TypeInfo
      i32.load
      call $j924
      local.set $l3
      local.get $l3
      i32.const 3983424 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>..ctor()
      i32.load
      call $j967
      local.get $p1
      local.get $l3
      i32.store offset=40
      i32.const 1
      local.set $l3
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B24
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=52
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      i32.eqz
      br_if $B24
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=80
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      call $j1138 ;; System.String$$op_Inequality
      i32.eqz
      br_if $B24
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=80
      i32.store offset=52
      i32.const 1
      local.set $l3
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=140
    local.set $l2
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p1
    block $B25
      block $B26
        local.get $l2
        i32.eqz
        if $I27
          i32.const 3959696 ;; OnlineLevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3950520 ;; OnlineRivalData[]_TypeInfo
          i32.load
          i32.const 3959696 ;; OnlineLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          call $j939
          i32.store offset=140
          br $B26
        end
        local.get $p1
        i32.load offset=140
        local.set $p1
        i32.const 3959696 ;; OnlineLevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.load offset=12
        i32.const 3959696 ;; OnlineLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.ge_s
        br_if $B25
        i32.const 3959696 ;; OnlineLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3950520 ;; OnlineRivalData[]_TypeInfo
        i32.load
        i32.const 3959696 ;; OnlineLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        call $j939
        local.set $l3
        i32.const 0
        local.set $p1
        loop $L28
          block $B29
            local.get $l3
            i32.load offset=12
            local.set $l4
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=32
            local.set $l2
            local.get $p1
            local.get $l4
            i32.ge_s
            br_if $B29
            block $B30
              block $B31
                local.get $p1
                local.get $l2
                i32.load offset=140
                i32.load offset=12
                i32.ge_s
                br_if $B31
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=32
                i32.load offset=140
                local.get $p1
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                i32.eqz
                br_if $B31
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                call $j923
                i32.const 3959288 ;; NetDataManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=32
                i32.load offset=140
                local.get $p1
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                local.set $l2
                br $B30
              end
              i32.const 3959700 ;; OnlineRivalData_TypeInfo
              i32.load
              call $j924
              local.set $l2
              local.get $l2
              i32.const 0
              call $j21479 ;; OnlineRivalData$$.ctor
            end
            local.get $l3
            local.get $l2
            call $j930
            local.get $l3
            local.get $p1
            i32.const 2
            i32.shl
            i32.add
            local.get $l2
            i32.store offset=16
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L28
          end
        end
        local.get $l2
        local.get $l3
        i32.store offset=140
      end
      i32.const 1
      local.set $l3
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=180
    i32.eqz
    if $I32
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
      i32.load
      call $j967
      local.get $p1
      local.get $l2
      i32.store offset=180
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=88
    i32.eqz
    if $I33
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p1
      i32.const 3942204 ;; System.Collections.Generic.Dictionary<string, LongLevelSaveData>_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      i32.const 3984884 ;; Method$System.Collections.Generic.Dictionary<string, LongLevelSaveData>..ctor()
      i32.load
      call $j967
      local.get $p1
      local.get $l2
      i32.store offset=88
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p1
    local.get $p1
    i32.load offset=108
    i32.eqz
    if $I34
      i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
      i32.load
      call $j965
      local.get $p1
      local.get $l2
      i32.store offset=108
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p1
    local.get $p1
    i32.load offset=112
    i32.eqz
    if $I35
      i32.const 3946992 ;; System.Collections.Generic.List<int>_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      i32.const 4001580 ;; Method$System.Collections.Generic.List<int>..ctor()
      i32.load
      call $j965
      local.get $p1
      i32.const 112
      i32.add
      local.set $p1
      local.get $p1
      local.get $l2
      i32.store
    end
    local.get $p0
    local.get $l3
    i32.or
    i32.const 1
    i32.and
    if $I36
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
    end
    i32.const 0
    call $j8923 ;; LaunchManager$$GetFeedGameChannel
    i32.eqz
    if $I37
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      call $j14380 ;; NetDataManager$$CheckNextDay
    end)
