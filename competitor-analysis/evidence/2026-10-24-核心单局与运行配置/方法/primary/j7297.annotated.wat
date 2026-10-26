  (func $j7297 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139815
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955736 ;; GooseHelper_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139815
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 5142653
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5142653
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    local.set $p1
    local.get $p1
    i32.const 0
    i32.store offset=36
    local.get $p1
    local.get $p0
    i32.store offset=32
    i32.const 3955736 ;; GooseHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j11025 ;; GooseHelper$$GetGooseMaxStarData
    local.set $p0
    block $B2
      local.get $p0
      i32.eqz
      br_if $B2
      local.get $p0
      i32.load offset=52
      i32.const 2
      i32.lt_s
      br_if $B2
      local.get $p0
      i32.load offset=8
      local.set $p0
      i32.const 3955736 ;; GooseHelper_TypeInfo
      i32.load
      call $j923
      local.get $p1
      local.get $p0
      i32.const 0
      call $j4103 ;; GooseHelper$$GetGooseShiningStar
      i32.store offset=36
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    call $j6394) ;; NetDataManager$$UploadPlayerPublicArchives
