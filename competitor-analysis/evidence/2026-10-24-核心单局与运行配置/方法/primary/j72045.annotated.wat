  (func $j72045 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    i32.const 5127067
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3939448 ;; System.Action<float>_TypeInfo
      call $j922
      i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
      call $j922
      i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
      call $j922
      i32.const 3937352 ;; UnityEngine.GameObject_var
      call $j922
      i32.const 4029164 ;; Method$LevelManager.LoadCompelet1()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 3963888 ;; System.Type_TypeInfo
      call $j922
      i32.const 4054892 ;; Method$LevelManager.<>c.<StartLoadMainBaseLevel1>b__98_1()
      call $j922
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      call $j922
      i32.const 5127067
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1065353216
    i32.store offset=52
    local.get $p0
    i32.load offset=8
    i32.const 0
    call $j43515 ;; LevelManager$$SceneCompelet
    local.get $p0
    i32.load offset=12
    i32.const 0
    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
    i32.load
    call $j947
    i32.load offset=24
    local.set $l3
    i32.const 0
    local.set $p1
    loop $L1
      local.get $l3
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I2
        local.get $l3
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.set $l4
        local.get $p0
        i32.load offset=16
        local.set $l5
        i32.const 3937352 ;; UnityEngine.GameObject_var
        i32.load
        local.set $p2
        i32.const 3963888 ;; System.Type_TypeInfo
        i32.load
        call $j923
        local.get $p2
        i32.const 0
        call $j943 ;; System.Type$$GetTypeFromHandle
        local.set $l6
        i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
        i32.load
        call $j924
        local.set $p2
        local.get $p2
        i32.const 1
        i32.store8 offset=20
        local.get $p2
        i32.const 1
        i32.store8 offset=12
        local.get $p2
        local.get $l4
        i32.store offset=8
        local.get $p2
        local.get $l6
        i32.store offset=16
        local.get $p2
        i32.const 0
        i32.store8 offset=20
        local.get $p2
        i32.const 1
        i32.store8 offset=12
        local.get $l5
        local.get $p2
        i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p0
    i32.load offset=8
    local.set $p1
    i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 0
    call $j2305 ;; Kunpo.AssetLoader$$.ctor
    local.get $p1
    local.get $p2
    i32.store offset=400
    local.get $p0
    i32.load offset=16
    local.set $p2
    local.get $p0
    i32.load offset=8
    local.set $p1
    local.get $p1
    i32.load offset=400
    local.set $l3
    i32.const 3939040 ;; System.Action<bool>_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    local.get $p1
    i32.const 4029164 ;; Method$LevelManager.LoadCompelet1()
    i32.load
    i32.const 0
    call $j969
    i32.const 3969160 ;; LevelManager.<>c_TypeInfo
    i32.load
    call $j923
    i32.const 3969160 ;; LevelManager.<>c_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    local.set $p1
    local.get $p1
    i32.eqz
    if $I3
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l5
      i32.const 3939448 ;; System.Action<float>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $l5
      i32.const 4054892 ;; Method$LevelManager.<>c.<StartLoadMainBaseLevel1>b__98_1()
      i32.load
      i32.const 0
      call $j969
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p1
      i32.store offset=12
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end
    local.get $l3
    local.get $p2
    local.get $l4
    local.get $p1
    i32.const 0
    call $j2708 ;; Kunpo.AssetLoader$$Load
    local.get $p0
    i32.load offset=8
    i32.const 0
    i32.store8 offset=416)
