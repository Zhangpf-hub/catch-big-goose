  (func $j95030 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140059
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
      call $j922
      i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
      call $j922
      i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
      call $j922
      i32.const 3986956 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.get_Item()
      call $j922
      i32.const 4029144 ;; Method$LevelManager.<LoadCompelet1>b__110_0()
      call $j922
      i32.const 4029148 ;; Method$LevelManager.<LoadCompelet1>b__110_1()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 4054896 ;; Method$LevelManager.<>c__DisplayClass110_0.<LoadCompelet1>b__2()
      call $j922
      i32.const 3969164 ;; LevelManager.<>c__DisplayClass110_0_TypeInfo
      call $j922
      i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
      call $j922
      i32.const 4075268 ;; CombieParticle
      call $j922
      i32.const 4125028 ;; 第1关加载完毕
      call $j922
      i32.const 4096680 ;; ToolClaw
      call $j922
      i32.const 5140059
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      i32.eqz
      br_if $B1
      local.get $p2
      i32.const 100
      i32.store offset=12
      i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
      i32.load
      local.set $l3
      local.get $p2
      i32.const -1
      i32.store offset=4
      local.get $p2
      local.get $l3
      i32.store
      local.get $p2
      local.get $p2
      i32.load offset=12
      i32.store offset=8
      local.get $p2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 1
      i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
      i32.load
      call $j1569
      drop
      i32.const 4125028 ;; 第1关加载完毕
      i32.load
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      local.get $p0
      i32.const 0
      i32.store8 offset=417
      local.get $p0
      local.get $p1
      call $j43506 ;; LevelManager$$StartLoadMainBaseLevel2
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 1
      i32.store8 offset=45
      local.get $p0
      i32.load offset=76
      local.set $p1
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.const 0
      call $j980 ;; UnityEngine.Object$$op_Equality
      if $I2
        i32.const 4075268 ;; CombieParticle
        i32.load
        i32.const 1
        i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
        i32.load
        call $j1569
        local.set $p1
        i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        local.get $p0
        i32.const 4029144 ;; Method$LevelManager.<LoadCompelet1>b__110_0()
        i32.load
        i32.const 0
        call $j969
        local.get $p1
        local.get $l3
        i32.const 0
        call $j1841 ;; Kunpo.AssetRequest$$add_Completed
      end
      local.get $p0
      i32.load offset=704
      local.set $p1
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.const 0
      call $j980 ;; UnityEngine.Object$$op_Equality
      if $I3
        i32.const 4096680 ;; ToolClaw
        i32.load
        i32.const 1
        i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
        i32.load
        call $j1569
        local.set $p1
        i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        local.get $p0
        i32.const 4029148 ;; Method$LevelManager.<LoadCompelet1>b__110_1()
        i32.load
        i32.const 0
        call $j969
        local.get $p1
        local.get $l3
        i32.const 0
        call $j1841 ;; Kunpo.AssetRequest$$add_Completed
      end
      i32.const 0
      local.set $p1
      loop $L4
        block $B5
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.load offset=12
          i32.ge_s
          br_if $B5
          local.get $p0
          i32.load offset=696
          local.set $l3
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          call $j923
          local.get $l3
          i32.const 3958084 ;; LevelToolMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
          i32.load
          call $j1084
          if $I6
            i32.const 3969164 ;; LevelManager.<>c__DisplayClass110_0_TypeInfo
            i32.load
            call $j924
            local.set $l3
            local.get $l3
            local.get $p0
            i32.store offset=12
            local.get $l3
            local.get $p1
            i32.store offset=8
            local.get $p0
            i32.load offset=696
            local.set $l4
            i32.const 3958084 ;; LevelToolMa_TypeInfo
            i32.load
            call $j923
            local.get $l4
            i32.const 3958084 ;; LevelToolMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=12
            local.get $l3
            i32.load offset=8
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            i32.const 3986956 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.get_Item()
            i32.load
            call $j1068
            i32.const 1
            i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
            i32.load
            call $j1569
            local.set $l4
            i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
            i32.load
            call $j924
            local.set $l5
            local.get $l5
            local.get $l3
            i32.const 4054896 ;; Method$LevelManager.<>c__DisplayClass110_0.<LoadCompelet1>b__2()
            i32.load
            i32.const 0
            call $j969
            local.get $l4
            local.get $l5
            i32.const 0
            call $j1841 ;; Kunpo.AssetRequest$$add_Completed
          end
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L4
        end
      end
      i32.const 0
      call $j5758 ;; GameManager$$IsStartGameDirection
      i32.eqz
      br_if $B1
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j38355 ;; SeasonLevelMa$$PreloadDiectionSeasonLevel
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
