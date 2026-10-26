  (func $j10705 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    i32.const 5139795
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3964256 ;; UIManager_TypeInfo
      call $j922
      i32.const 5139795
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load8_u offset=12
      local.get $p1
      i32.eq
      br_if $B1
      local.get $p0
      local.get $p1
      i32.store8 offset=12
      i32.const 3964256 ;; UIManager_TypeInfo
      i32.load
      call $j923
      i32.const 3964256 ;; UIManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p0
      local.get $p1
      if $I2
        local.get $p0
        i32.const 0
        i32.const 0
        call $j1281 ;; UIManager$$EnableControl
        return
      end
      local.get $p0
      i32.const 1
      i32.const 0
      call $j1281 ;; UIManager$$EnableControl
      local.get $p2
      i32.eqz
      br_if $B1
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 600
      i32.const 0
      call $j1327 ;; Kunpo.KUIManager$$CloseUI
    end)
