  (func $j72886 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140502
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 4064256 ;;  
      call $j922
      i32.const 4076760 ;; DecodeGameClueData: 
      call $j922
      i32.const 5140502
      i32.const 1
      i32.store8
    end
    i32.const 4076760 ;; DecodeGameClueData: 
    i32.load
    local.get $p1
    i32.load
    i32.const 4064256 ;;  
    i32.load
    local.get $p1
    i32.load offset=4
    i32.const 0
    call $j1151 ;; System.String$$Concat
    local.set $p1
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j1050 ;; UnityEngine.Debug$$LogError
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I1
      local.get $p0
      i32.load offset=32
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
    end)
