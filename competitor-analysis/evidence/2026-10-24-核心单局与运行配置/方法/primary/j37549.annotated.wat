  (func $j37549 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139642
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4004708 ;; Method$System.Collections.Generic.List<SpLevelDataData>.get_Count()
      call $j922
      i32.const 4004712 ;; Method$System.Collections.Generic.List<SpLevelDataData>.get_Item()
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 5139642
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 5
        i32.eq
        if $I3
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 304
          local.set $p1
          br $B2
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B1
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.get $p0
        call $j2670 ;; SpLevelManager$$GetSpWindow
        i32.eqz
        br_if $B1
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 4004708 ;; Method$System.Collections.Generic.List<SpLevelDataData>.get_Count()
        i32.load
        drop
        local.get $p0
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        i32.load offset=12
        i32.gt_s
        br_if $B1
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.get $p0
        call $j2670 ;; SpLevelManager$$GetSpWindow
        i32.load offset=24
        local.set $p1
      end
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      local.get $p0
      i32.const 1
      i32.sub
      i32.const 4004712 ;; Method$System.Collections.Generic.List<SpLevelDataData>.get_Item()
      i32.load
      call $j947
      i32.load offset=24
      local.set $p0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      local.get $p0
      i32.const 0
      call $j1145 ;; Kunpo.KUIManager$$OpenATip
    end)
