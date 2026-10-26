  (func $j21668 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139735
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4015420 ;; Method$System.ValueTuple<bool, bool>..ctor()
      call $j922
      i32.const 5139735
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=69
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        call $j6394 ;; NetDataManager$$UploadPlayerPublicArchives
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=70
        if $I3
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          local.get $p1
          call $j4349 ;; NetDataManager$$UploadPlayerServerData
        end
        local.get $p1
        i32.const 0
        i32.store16 offset=14
        local.get $p1
        i32.const 14
        i32.add
        i32.const 0
        i32.const 0
        i32.const 4015420 ;; Method$System.ValueTuple<bool, bool>..ctor()
        i32.load
        call $j8252
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p0
        local.get $p1
        i32.load16_u offset=14
        local.set $l2
        local.get $p0
        local.get $l2
        i32.store8 offset=69
        local.get $p0
        local.get $l2
        i32.const 8
        i32.shr_u
        i32.store8 offset=70
        br $B1
      end
      local.get $p0
      i32.eqz
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      call $j6394 ;; NetDataManager$$UploadPlayerPublicArchives
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
