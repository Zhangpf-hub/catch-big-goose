  (func $j14179 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 5133540
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
      call $j922
      i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
      call $j922
      i32.const 4057184 ;; Method$PrepareLoadMa.<>c__DisplayClass9_0.<PreLoadTempObj>b__0()
      call $j922
      i32.const 3970612 ;; PrepareLoadMa.<>c__DisplayClass9_0_TypeInfo
      call $j922
      i32.const 5133540
      i32.const 1
      i32.store8
    end
    i32.const 3970612 ;; PrepareLoadMa.<>c__DisplayClass9_0_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.store offset=8
    local.get $p1
    i32.load offset=8
    i32.const 1
    i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
    i32.load
    call $j1569
    local.set $p0
    i32.const 3939016 ;; System.Action<AssetRequest>_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    local.get $p1
    i32.const 4057184 ;; Method$PrepareLoadMa.<>c__DisplayClass9_0.<PreLoadTempObj>b__0()
    i32.load
    i32.const 0
    call $j969
    local.get $p0
    local.get $l2
    i32.const 0
    call $j1841) ;; Kunpo.AssetRequest$$add_Completed
