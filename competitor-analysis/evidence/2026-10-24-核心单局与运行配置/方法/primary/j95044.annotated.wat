  (func $j95044 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140175
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3964268 ;; UINewYearGamePage_TypeInfo
      call $j922
      i32.const 5140175
      i32.const 1
      i32.store8
    end
    block $B1
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B1
      local.get $p0
      local.get $p1
      local.get $p0
      i32.load offset=860
      i32.add
      i32.store offset=860
      i32.const 0
      local.set $p1
      i32.const 0
      local.set $p2
      loop $L2
        block $B3
          local.get $p0
          i32.load offset=856
          local.set $l3
          local.get $p1
          local.get $l3
          i32.load offset=12
          i32.ge_s
          br_if $B3
          local.get $p0
          i32.load offset=860
          local.get $l3
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=16
          i32.lt_s
          br_if $B3
          local.get $p0
          i32.load offset=856
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=8
          local.set $p2
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L2
        end
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3959288 ;; NetDataManager_TypeInfo
        call $j922
        i32.const 5142651
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
      i32.load offset=160
      local.get $p2
      i32.lt_s
      if $I5
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 5142651
        i32.load8_u
        i32.eqz
        if $I6
          i32.const 3959288 ;; NetDataManager_TypeInfo
          call $j922
          i32.const 5142651
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
        local.get $p2
        i32.store offset=160
        i32.const 0
        call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
      end
      local.get $p0
      i32.load offset=864
      local.get $p2
      i32.lt_s
      if $I7
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p2
        i32.store offset=84
        local.get $p0
        i32.load offset=856
        local.get $p0
        i32.load offset=864
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=20
        local.set $p1
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        local.get $p1
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
        local.get $p0
        local.get $p2
        i32.store offset=864
      end
      i32.const 3964268 ;; UINewYearGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p1
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.const 0
      call $j980 ;; UnityEngine.Object$$op_Equality
      br_if $B1
      local.get $p2
      i32.eqz
      if $I8
        i32.const 3964268 ;; UINewYearGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 0
        local.get $p0
        i32.load offset=860
        f32.convert_i32_s
        local.get $p0
        i32.load offset=856
        i32.load offset=16
        i32.load offset=12
        f32.convert_i32_s
        f32.div
        i32.const 0
        call $j13174 ;; UINewYearGamePage$$SetCurProgress
        return
      end
      local.get $p2
      local.get $p0
      i32.load offset=856
      i32.load offset=12
      i32.ge_s
      br_if $B1
      i32.const 3964268 ;; UINewYearGamePage_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p2
      local.get $p0
      i32.load offset=860
      local.get $p0
      i32.load offset=856
      local.get $p2
      i32.const 1
      i32.sub
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      i32.load offset=16
      i32.sub
      f32.convert_i32_s
      local.get $p0
      i32.load offset=856
      local.get $p2
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      i32.load offset=12
      f32.convert_i32_s
      f32.div
      i32.const 0
      call $j13174 ;; UINewYearGamePage$$SetCurProgress
    end)
