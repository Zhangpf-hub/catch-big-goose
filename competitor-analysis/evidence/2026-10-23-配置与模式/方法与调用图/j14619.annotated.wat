  (func $j14619 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32) (local $l6 i32) (local $l7 i32)
    i32.const 5140063
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
      call $j922
      i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3979504 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.ContainsKey()
      call $j922
      i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
      call $j922
      i32.const 3937352 ;; UnityEngine.GameObject_var
      call $j922
      i32.const 4001960 ;; Method$System.Collections.Generic.List<LevelDataData>.Add()
      call $j922
      i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
      call $j922
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      call $j922
      i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
      call $j922
      i32.const 4001956 ;; Method$System.Collections.Generic.List<LevelDataData>..ctor()
      call $j922
      i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
      call $j922
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      call $j922
      i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
      call $j922
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
      call $j922
      i32.const 3947056 ;; System.Collections.Generic.List<LevelDataData>_TypeInfo
      call $j922
      i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
      call $j922
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      call $j922
      i32.const 3963888 ;; System.Type_TypeInfo
      call $j922
      i32.const 4054904 ;; Method$LevelManager.<>c__DisplayClass115_0.<LoadSpLevelObj>b__0()
      call $j922
      i32.const 3969172 ;; LevelManager.<>c__DisplayClass115_0_TypeInfo
      call $j922
      i32.const 5140063
      i32.const 1
      i32.store8
    end
    i32.const 3969172 ;; LevelManager.<>c__DisplayClass115_0_TypeInfo
    i32.load
    call $j924
    local.set $l5
    local.get $l5
    local.get $p1
    i32.store offset=8
    local.get $l5
    local.get $p3
    i32.store offset=12
    i32.const 3947056 ;; System.Collections.Generic.List<LevelDataData>_TypeInfo
    i32.load
    call $j924
    local.set $p4
    local.get $p4
    i32.const 4001956 ;; Method$System.Collections.Generic.List<LevelDataData>..ctor()
    i32.load
    call $j965
    local.get $l5
    i32.load offset=8
    local.set $p1
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p2
    local.get $p1
    i32.const 0
    call $j2094 ;; ConfigManager$$GetLevelData
    local.set $p2
    i32.const 0
    local.set $p1
    loop $L1
      local.get $p1
      i32.const 5
      i32.lt_s
      if $I2
        local.get $p2
        local.get $p1
        i32.const 3979504 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.ContainsKey()
        i32.load
        call $j1084
        if $I3
          local.get $p4
          local.get $p2
          local.get $p1
          i32.const 3979520 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>.get_Item()
          i32.load
          call $j1068
          i32.const 0
          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
          i32.load
          call $j947
          i32.const 4001960 ;; Method$System.Collections.Generic.List<LevelDataData>.Add()
          i32.load
          call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        end
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
    i32.load
    drop
    block $B4
      local.get $p4
      i32.load offset=12
      i32.eqz
      if $I5
        local.get $l5
        i32.load offset=12
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B4
        local.get $p0
        i32.const 0
        i32.const 0
        call $j1184
        return
      end
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      i32.load
      call $j924
      local.set $p2
      local.get $p2
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      i32.load
      call $j965
      i32.const 0
      local.set $p3
      loop $L6
        block $B7
          i32.const 0
          local.set $p1
          i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
          i32.load
          drop
          local.get $p3
          local.get $p4
          i32.load offset=12
          i32.ge_s
          br_if $B7
          loop $L8
            block $B9
              local.get $p4
              local.get $p3
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              call $j947
              i32.load offset=24
              i32.load offset=12
              local.set $l7
              local.get $p4
              local.get $p3
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              call $j947
              local.set $l6
              local.get $p1
              local.get $l7
              i32.ge_s
              br_if $B9
              local.get $p2
              local.get $l6
              i32.load offset=24
              local.get $p1
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
              i32.load
              call $j1262
              i32.eqz
              if $I10
                local.get $p2
                local.get $p4
                local.get $p3
                i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
                i32.load
                call $j947
                i32.load offset=24
                local.get $p1
                i32.const 2
                i32.shl
                i32.add
                i32.load offset=16
                i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
                i32.load
                call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
              end
              local.get $p1
              i32.const 1
              i32.add
              local.set $p1
              br $L8
            end
          end
          local.get $p2
          local.get $l6
          i32.load offset=64
          i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
          i32.load
          call $j1262
          i32.eqz
          if $I11
            local.get $p2
            local.get $p4
            local.get $p3
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            call $j947
            i32.load offset=64
            i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
            i32.load
            call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
          end
          local.get $p3
          i32.const 1
          i32.add
          local.set $p3
          br $L6
        end
      end
      i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
      i32.load
      call $j924
      local.set $p4
      local.get $p4
      i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
      i32.load
      call $j965
      loop $L12
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        local.get $p1
        local.get $p2
        i32.load offset=12
        i32.lt_s
        if $I13
          local.get $p2
          local.get $p1
          i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
          i32.load
          call $j947
          local.set $l6
          i32.const 3937352 ;; UnityEngine.GameObject_var
          i32.load
          local.set $p3
          i32.const 3963888 ;; System.Type_TypeInfo
          i32.load
          call $j923
          local.get $p3
          i32.const 0
          call $j943 ;; System.Type$$GetTypeFromHandle
          local.set $l7
          i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
          i32.load
          call $j924
          local.set $p3
          local.get $p3
          i32.const 1
          i32.store8 offset=20
          local.get $p3
          i32.const 1
          i32.store8 offset=12
          local.get $p3
          local.get $l6
          i32.store offset=8
          local.get $p3
          local.get $l7
          i32.store offset=16
          local.get $p3
          i32.const 0
          i32.store8 offset=20
          local.get $p3
          i32.const 1
          i32.store8 offset=12
          local.get $p4
          local.get $p3
          i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
          i32.load
          call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L12
        end
      end
      i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      i32.const 0
      call $j2305 ;; Kunpo.AssetLoader$$.ctor
      local.get $p0
      local.get $p1
      i32.store offset=400
      local.get $p0
      i32.load offset=400
      local.set $p0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $l5
      i32.const 4054904 ;; Method$LevelManager.<>c__DisplayClass115_0.<LoadSpLevelObj>b__0()
      i32.load
      i32.const 0
      call $j969
      local.get $p0
      local.get $p4
      local.get $p1
      i32.const 0
      i32.const 0
      call $j2708 ;; Kunpo.AssetLoader$$Load
    end)
