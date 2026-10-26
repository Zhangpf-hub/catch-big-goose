  (func $j14623 (type $t84) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 f32) (param $p4 f32) (param $p5 i32)
    i32.const 5140144
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4026584 ;; Method$UnityEngine.GameObject.GetComponent<ToolClaw>()
      call $j922
      i32.const 3959572 ;; ObjectPoolMa_TypeInfo
      call $j922
      i32.const 4096680 ;; ToolClaw
      call $j922
      i32.const 5140144
      i32.const 1
      i32.store8
    end
    i32.const 3959572 ;; ObjectPoolMa_TypeInfo
    i32.load
    call $j923
    i32.const 4096680 ;; ToolClaw
    i32.load
    i32.const 0
    i32.const 0
    call $j4055 ;; ObjectPoolMa$$GetObjByName
    i32.const 4026584 ;; Method$UnityEngine.GameObject.GetComponent<ToolClaw>()
    i32.load
    call $j1136
    local.get $p1
    local.get $p2
    local.get $p3
    local.get $p4
    i32.const 0
    i32.const 18425
    global.set $__wasm_split_waitTableId
    i32.const 18425
    call_indirect $primary.table (type $t84))
