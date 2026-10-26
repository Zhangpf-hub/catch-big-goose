  (func $j10706 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139724
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 4123508 ;; 时
      call $j922
      i32.const 4123496 ;; 日
      call $j922
      i32.const 4123704 ;; 月
      call $j922
      i32.const 5139724
      i32.const 1
      i32.store8
    end
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j2164 ;; NetInitManager$$ServerType
      i32.const 1
      i32.ne
      if $I2
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $l1
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $l1
        i32.const 0
        call $j1022 ;; UnityEngine.Object$$op_Implicit
        i32.eqz
        br_if $B1
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 0
        call $j2761 ;; NetInitManager$$UseEditor
        i32.eqz
        br_if $B1
      end
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1860 ;; System.DateTime$$get_Month
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l2
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1861 ;; System.DateTime$$get_Day
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l3
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i64.load offset=16
      i64.const 4611686018427387903
      i64.and
      i64.const 36000000000
      i64.div_u
      i32.wrap_i64
      i32.const 24
      i32.rem_u
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l4
      local.get $l1
      local.get $l2
      i32.const 4123704 ;; 月
      i32.load
      local.get $l3
      i32.const 4123496 ;; 日
      i32.load
      local.get $l4
      i32.const 4123508 ;; 时
      i32.load
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.store offset=152
      block $B3
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load8_u offset=145
        i32.eqz
        br_if $B3
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=148
        i32.eqz
        br_if $B3
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l1
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        local.get $l1
        i32.const 16
        i32.add
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=148
        f64.convert_i32_s
        i32.const 0
        call $j11277 ;; System.DateTime$$AddHours
        local.set $l5
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        local.get $l5
        i64.store offset=16
      end
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1860 ;; System.DateTime$$get_Month
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l2
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1861 ;; System.DateTime$$get_Day
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l3
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i64.load offset=16
      i64.const 4611686018427387903
      i64.and
      i64.const 36000000000
      i64.div_u
      i32.wrap_i64
      i32.const 24
      i32.rem_u
      i32.store offset=12
      local.get $p0
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l4
      local.get $l1
      local.get $l2
      i32.const 4123704 ;; 月
      i32.load
      local.get $l3
      i32.const 4123496 ;; 日
      i32.load
      local.get $l4
      i32.const 4123508 ;; 时
      i32.load
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.store offset=156
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
