  (func $j43498 (type $t46) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 i32) (param $p4 i32)
    i32.const 5127096
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 5127096
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      i32.eqz
      br_if $B1
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p1
      i32.load offset=12
      i32.const 0
      i32.lt_s
      br_if $B1
      local.get $p0
      local.get $p0
      local.get $p1
      local.get $p2
      local.get $p0
      call $j43499 ;; LevelObjAnimManager$$CombieAnim
      i32.const 0
      call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      drop
      local.get $p0
      local.get $p3
      local.get $p0
      call $j14614 ;; LevelObjAnimManager$$RemoveDelayCoro
      local.get $p0
      local.get $p3
      local.get $p0
      local.get $p0
      local.get $p2
      local.get $p0
      i32.load offset=56
      f32.load offset=232
      f32.add
      local.get $p3
      local.get $p0
      call $j43497 ;; LevelObjAnimManager$$DelayToMoveOtherObj
      i32.const 0
      call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      local.get $p0
      call $j43501 ;; LevelObjAnimManager$$AddDelayCoro
    end)
