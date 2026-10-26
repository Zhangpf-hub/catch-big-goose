  (func $j43519 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    local.get $p1
    local.get $p0
    i32.store offset=12
    i32.const 5140173
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958348 ;; LoseWay_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
      call $j922
      i32.const 4121840 ;; 对战失败原因
      call $j922
      i32.const 5140173
      i32.const 1
      i32.store8
    end
    i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $l2
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $l2
    i32.const 0
    i32.const 0
    call $j980 ;; UnityEngine.Object$$op_Equality
    i32.eqz
    if $I1
      local.get $p0
      i32.const 2
      i32.le_u
      if $I2
        i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.get $p0
        i32.const 2
        i32.shl
        i32.const 1639088
        i32.add
        i32.load
        i32.const 0
        call $j13171 ;; UIOnlineGamePage$$EndOnlineGame
      end
      i32.const 3958348 ;; LoseWay_TypeInfo
      i32.load
      local.set $p0
      local.get $p1
      i32.const -1
      i32.store offset=4
      local.get $p1
      local.get $p0
      i32.store
      local.get $p1
      local.get $p1
      i32.load offset=12
      i32.store offset=8
      local.get $p1
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $p0
      i32.const 1
      i32.const 4121840 ;; 对战失败原因
      i32.load
      local.get $p0
      i32.const 0
      call $j962 ;; System.String$$Concat
      i32.const 0
      call $j1429 ;; GameManager$$LogInColor
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
