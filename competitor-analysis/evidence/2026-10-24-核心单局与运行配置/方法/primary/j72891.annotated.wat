  (func $j72891 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127071
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962376 ;; UnityEngine.Sprite_TypeInfo
      call $j922
      i32.const 5127071
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p2
    local.get $p1
    i32.const 0
    call $j2065 ;; Kunpo.AssetRequest$$get_Result
    local.set $p1
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p2
    i32.const 1
    local.get $p1
    i32.const 3962376 ;; UnityEngine.Sprite_TypeInfo
    i32.load
    call $j968
    local.get $p0
    i32.const 0
    call $j22256) ;; LevelManager$$CompeletLoadEndAnim
