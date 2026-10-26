  (func $j22250 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140090
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 4000752 ;; Method$System.Collections.Generic.List<GooseDataData>.get_Count()
      call $j922
      i32.const 4000756 ;; Method$System.Collections.Generic.List<GooseDataData>.get_Item()
      call $j922
      i32.const 4118996 ;; {0}GooseCount:{1}
      call $j922
      i32.const 5140090
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j6604 ;; ConfigManager$$GetTypeGooseList
    local.set $l4
    i32.const 0
    local.set $p0
    i32.const 0
    local.set $p2
    loop $L1
      i32.const 4000752 ;; Method$System.Collections.Generic.List<GooseDataData>.get_Count()
      i32.load
      drop
      local.get $p0
      local.get $l4
      i32.load offset=12
      i32.lt_s
      if $I2
        local.get $p2
        i32.const 1
        i32.add
        local.get $p2
        local.get $l4
        local.get $p0
        i32.const 4000756 ;; Method$System.Collections.Generic.List<GooseDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=8
        i32.const 0
        call $j6323 ;; RewardManager$$HasGetGoose
        select
        local.set $p2
        local.get $p0
        i32.const 1
        i32.add
        local.set $p0
        br $L1
      end
    end
    local.get $l3
    local.get $p2
    i32.store offset=12
    i32.const 3957596 ;; int_TypeInfo
    i32.load
    local.get $l3
    i32.const 12
    i32.add
    call $j935
    local.set $p0
    i32.const 3
    i32.const 4118996 ;; {0}GooseCount:{1}
    i32.load
    local.get $p1
    local.get $p0
    i32.const 0
    call $j1060 ;; System.String$$Format
    i32.const 0
    call $j1429 ;; GameManager$$LogInColor
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p2
    return)
