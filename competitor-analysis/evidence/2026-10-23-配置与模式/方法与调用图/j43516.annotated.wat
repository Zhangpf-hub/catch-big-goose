  (func $j43516 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32)
    i32.const 5140067
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
      call $j922
      i32.const 4017972 ;; Method$Kunpo.AssetManager.LoadAsset<Sprite>()
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3999956 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Count()
      call $j922
      i32.const 3999960 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Item()
      call $j922
      i32.const 3963800 ;; TranslateMa_TypeInfo
      call $j922
      i32.const 4054908 ;; Method$LevelManager.<>c__DisplayClass123_0.<ResetEndAnim>b__0()
      call $j922
      i32.const 4054912 ;; Method$LevelManager.<>c__DisplayClass123_0.<ResetEndAnim>b__1()
      call $j922
      i32.const 3969176 ;; LevelManager.<>c__DisplayClass123_0_TypeInfo
      call $j922
      i32.const 4077680 ;; EndAnimData_
      call $j922
      i32.const 5140067
      i32.const 1
      i32.store8
    end
    i32.const 3969176 ;; LevelManager.<>c__DisplayClass123_0_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.store offset=8
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 1
    i32.const 0
    call $j15437 ;; ConfigManager$$GetEndAnimList
    local.set $p0
    i32.const 0
    i32.const 0
    call $j15437 ;; ConfigManager$$GetEndAnimList
    local.set $l2
    i32.const 3999956 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Count()
    i32.load
    drop
    local.get $p0
    i32.const 0
    local.get $p0
    i32.load offset=12
    i32.const 0
    call $j1479 ;; UnityEngine.Random$$Range
    i32.const 3999960 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Item()
    i32.load
    call $j947
    local.set $p0
    local.get $p0
    i32.load offset=16
    local.set $l3
    local.get $p0
    i32.load offset=8
    local.set $p0
    i32.const 4077680 ;; EndAnimData_
    i32.load
    local.get $p0
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.set $l4
    i32.const 3963800 ;; TranslateMa_TypeInfo
    i32.load
    call $j923
    local.get $p1
    local.get $l4
    local.get $l3
    i32.const 0
    i32.const 0
    call $j1266 ;; TranslateMa$$GetTransString
    i32.store offset=12
    i32.const 3999956 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Count()
    i32.load
    drop
    local.get $l2
    i32.const 0
    local.get $l2
    i32.load offset=12
    i32.const 0
    call $j1479 ;; UnityEngine.Random$$Range
    i32.const 3999960 ;; Method$System.Collections.Generic.List<EndAnimDataData>.get_Item()
    i32.load
    call $j947
    local.set $l2
    local.get $l2
    i32.load offset=16
    local.set $l3
    local.get $l2
    i32.load offset=8
    local.set $l2
    local.get $p1
    i32.const 4077680 ;; EndAnimData_
    i32.load
    local.get $l2
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.get $l3
    i32.const 0
    i32.const 0
    call $j1266 ;; TranslateMa$$GetTransString
    i32.store offset=16
    local.get $p0
    i32.const 1
    i32.const 4017972 ;; Method$Kunpo.AssetManager.LoadAsset<Sprite>()
    i32.load
    call $j1569
    local.set $p0
    i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p1
    i32.const 4054908 ;; Method$LevelManager.<>c__DisplayClass123_0.<ResetEndAnim>b__0()
    i32.load
    i32.const 0
    call $j969
    local.get $p0
    local.get $l3
    i32.const 0
    call $j1841 ;; Kunpo.AssetRequest$$add_Completed
    local.get $l2
    i32.const 1
    i32.const 4017972 ;; Method$Kunpo.AssetManager.LoadAsset<Sprite>()
    i32.load
    call $j1569
    local.set $p0
    i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    local.get $p1
    i32.const 4054912 ;; Method$LevelManager.<>c__DisplayClass123_0.<ResetEndAnim>b__1()
    i32.load
    i32.const 0
    call $j969
    local.get $p0
    local.get $l2
    i32.const 0
    call $j1841) ;; Kunpo.AssetRequest$$add_Completed
