;; LevelManager$$GetTimeABIndex
;; Function-table index: 17827; signature checked. Compiled WASM, not C# source.
  (func $j43532 (type $t3) (param $p0 i32) (result i32)
    i32.const 5140091
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296
      call $j922
      i32.const 5140091
      i32.const 1
      i32.store8
    end
    i32.const 3951296
    i32.load
    call $j923
    i32.const 0
    call $j15948
    i32.const 1
    i32.sub
    local.set $p0
    local.get $p0
    i32.const 2
    i32.le_u
    if $I1
      local.get $p0
      i32.const 2
      i32.shl
      i32.const 1639100
      i32.add
      i32.load
      return
    end
    i32.const 0
    return)
