;; LevelManager$$GetMainLevelABOffsetGroupCount
;; Function-table index: 17832; signature checked. Compiled WASM, not C# source.
  (func $j22248 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140095
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957596
      call $j922
      i32.const 3959304
      call $j922
      i32.const 4121948
      call $j922
      i32.const 5140095
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=448
    local.set $p0
    block $B1
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=12
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=12
      local.get $p1
      i32.le_s
      br_if $B1
      local.get $p0
      local.get $p1
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      local.set $l3
      i32.const 3959304
      i32.load
      call $j923
      local.get $p2
      call $j1600
      i32.eqz
      br_if $B1
      local.get $p2
      local.get $p1
      i32.store offset=12
      i32.const 3957596
      i32.load
      local.get $p2
      i32.const 12
      i32.add
      call $j935
      local.set $p0
      local.get $p2
      local.get $l3
      i32.store offset=8
      i32.const 3957596
      i32.load
      local.get $p2
      i32.const 8
      i32.add
      call $j935
      local.set $p1
      i32.const 5
      i32.const 4121948
      i32.load
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1060
      i32.const 0
      call $j1429
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $l3
    return)
