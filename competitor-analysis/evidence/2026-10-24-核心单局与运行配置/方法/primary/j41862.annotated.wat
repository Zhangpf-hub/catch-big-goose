  (func $j41862 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139782
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4119984 ;; 不存在该大鹅{0}
      call $j922
      i32.const 5139782
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      call $j1293 ;; ConfigManager$$GetGoose
      i32.eqz
      if $I2
        local.get $p1
        local.get $p0
        i32.store offset=12
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $p1
        i32.const 12
        i32.add
        call $j935
        local.set $p0
        i32.const 4119984 ;; 不存在该大鹅{0}
        i32.load
        local.get $p0
        i32.const 0
        call $j1006 ;; System.String$$Format
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
        br $B1
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $l2
      local.get $l2
      local.get $l2
      i32.load offset=152
      i32.const 1
      i32.add
      i32.store offset=152
      local.get $p0
      call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
      local.get $p0
      local.get $p0
      call $j7297 ;; NetDataManager$$UpdateDefaultGoose
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
