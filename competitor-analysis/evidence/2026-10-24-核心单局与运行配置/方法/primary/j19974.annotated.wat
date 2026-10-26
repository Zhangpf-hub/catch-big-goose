  (func $j19974 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139650
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3964256 ;; UIManager_TypeInfo
      call $j922
      i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
      call $j922
      i32.const 5139650
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j2670 ;; SpLevelManager$$GetSpWindow
    local.set $p0
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=28
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    if $I1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
      i32.load
      local.set $p0
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      local.set $l2
      local.get $p1
      i32.const -1
      i32.store offset=4
      local.get $p1
      local.get $p0
      i32.store
      local.get $p1
      local.get $l2
      i32.load offset=12
      i32.store offset=8
      local.get $p1
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $p0
      i32.const 3964256 ;; UIManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j34024 ;; UIManager$$IsWindowInstance
      local.set $l2
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $l2
    return)
