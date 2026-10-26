  (func $j46547 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5139968
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957596 ;; int_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4034880 ;; Method$SaveManager.Load<int>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4077828 ;; EndlessLevelNum
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4126600 ;; 通关第{0}关，获得金币{1}
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4077820 ;; EndlessLevelGoldCount
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139968
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 1
    i32.add
    local.set $p0
    local.get $p0
    i32.const 4077828 ;; EndlessLevelNum
    i32.load
    i32.const 4034880 ;; Method$SaveManager.Load<int>()
    i32.load
    i32.const 5861
    call_indirect $primary.table (type $t2)
    i32.gt_s
    if $I1
      i32.const 4077828 ;; EndlessLevelNum
      i32.load
      local.get $p0
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.load
      i32.const 5862
      call_indirect $primary.table (type $t4)
      i32.const 4077820 ;; EndlessLevelGoldCount
      i32.load
      i32.const 4034880 ;; Method$SaveManager.Load<int>()
      i32.load
      i32.const 5861
      call_indirect $primary.table (type $t2)
      local.set $l3
      i32.const 4077820 ;; EndlessLevelGoldCount
      i32.load
      local.get $p1
      local.get $l3
      i32.add
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.load
      i32.const 5862
      call_indirect $primary.table (type $t4)
      local.get $p2
      local.get $p0
      i32.store offset=12
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $p2
      i32.const 12
      i32.add
      i32.const 1282
      call_indirect $primary.table (type $t2)
      local.set $p0
      local.get $p2
      local.get $p1
      i32.store offset=8
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $p2
      i32.const 8
      i32.add
      i32.const 1282
      call_indirect $primary.table (type $t2)
      local.set $p1
      i32.const 4126600 ;; 通关第{0}关，获得金币{1}
      i32.load
      local.get $p0
      local.get $p1
      i32.const 0
      i32.const 3235
      call_indirect $primary.table (type $t8)
      i32.const 3
      i32.const 0
      i32.const 17128
      call_indirect $primary.table (type $t4)
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
