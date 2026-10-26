  (func $j74292 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 f32)
    i32.const 5127108
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
      call $j922
      i32.const 5127108
      i32.const 1
      i32.store8
    end
    block $B1
      block $B2
        block $B3
          local.get $p0
          i32.load offset=8
          br_table $B3 $B2 $B1
        end
        local.get $p0
        i32.const -1
        i32.store offset=8
        local.get $p0
        f32.load offset=16
        local.set $l2
        i32.const 3965456 ;; UnityEngine.WaitForSecondsRealtime_TypeInfo
        i32.load
        call $j924
        local.set $p1
        local.get $p1
        i32.const -1082130432
        i32.store offset=12
        local.get $p1
        local.get $l2
        f32.store offset=8
        local.get $p0
        local.get $p1
        i32.store offset=12
        local.get $p0
        i32.const 1
        i32.store offset=8
        i32.const 1
        return
      end
      local.get $p0
      i32.load offset=20
      local.set $p1
      local.get $p0
      i32.const -1
      i32.store offset=8
      local.get $p1
      local.get $p0
      i32.load offset=24
      local.get $p0
      call $j10875 ;; LevelObjAnimManager$$SortContentObj
      local.get $p1
      local.get $p0
      i32.load offset=24
      local.get $p0
      call $j14614 ;; LevelObjAnimManager$$RemoveDelayCoro
    end
    i32.const 0
    return)
