  (func $j15162 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5139963
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4120340 ;; 体力不足
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4123620 ;; 暂无关卡
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139963
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=16
    i32.eqz
    if $I1
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 4123620 ;; 暂无关卡
      i32.load
      i32.const 0
      i32.const 28506
      call_indirect $primary.table (type $t3)
      return
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    i32.eqz
    if $I2
      i32.const 2
      local.get $p0
      call $j23324 ;; EndlessLevelMa$$StartLevel
      return
    end
    local.get $p0
    call $j23327 ;; EndlessLevelMa$$GetEnergySave
    i32.const 0
    i32.ge_s
    if $I3
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 0
      local.get $p0
      call $j46548 ;; EndlessLevelMa$$AddEnergySave
      i32.const 2
      local.get $p0
      call $j23324 ;; EndlessLevelMa$$StartLevel
      return
    end
    i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 600
    i32.const 4120340 ;; 体力不足
    i32.load
    i32.const 0
    i32.const 5293
    call_indirect $primary.table (type $t4))
