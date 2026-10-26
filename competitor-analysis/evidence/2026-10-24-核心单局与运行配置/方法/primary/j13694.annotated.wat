  (func $j13694 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32) (local $l6 i64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p4
    local.get $p4
    global.set $primary.global$0
    i32.const 5139653
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3939448 ;; System.Action<float>_TypeInfo
      call $j922
      i32.const 3993996 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.Add()
      call $j922
      i32.const 3994000 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.Contains()
      call $j922
      i32.const 3958172 ;; LoadManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4058836 ;; Method$SpLevelManager.<>c__DisplayClass26_0.<LoadSpLevel>b__0()
      call $j922
      i32.const 4058840 ;; Method$SpLevelManager.<>c__DisplayClass26_0.<LoadSpLevel>b__1()
      call $j922
      i32.const 3971576 ;; SpLevelManager.<>c__DisplayClass26_0_TypeInfo
      call $j922
      i32.const 4015476 ;; Method$System.ValueTuple<string, int>..ctor()
      call $j922
      i32.const 5139653
      i32.const 1
      i32.store8
    end
    i32.const 3971576 ;; SpLevelManager.<>c__DisplayClass26_0_TypeInfo
    i32.load
    call $j924
    local.set $l5
    local.get $l5
    local.get $p0
    i32.store offset=8
    local.get $l5
    local.get $p2
    i32.store offset=16
    local.get $l5
    local.get $p1
    i32.store offset=12
    local.get $l5
    local.get $p3
    i32.store offset=20
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $l5
    i32.load offset=12
    local.set $p0
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.set $p1
    local.get $l5
    i32.load offset=8
    local.set $p2
    local.get $p4
    i64.const 0
    i64.store offset=56
    local.get $p4
    i32.const 56
    i32.add
    local.get $p2
    local.get $p0
    i32.const 4015476 ;; Method$System.ValueTuple<string, int>..ctor()
    i32.load
    call $j2657
    local.get $p4
    i64.load offset=56
    local.set $l6
    local.get $p4
    local.get $l6
    i64.store offset=48
    local.get $p4
    local.get $l6
    i64.store offset=24
    block $B1
      local.get $p1
      local.get $p4
      i32.const 24
      i32.add
      i32.const 3994000 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.Contains()
      i32.load
      call $j1657
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=36
      local.set $p0
      local.get $l5
      i32.load offset=12
      local.set $p1
      local.get $l5
      i32.load offset=8
      local.set $p2
      local.get $p4
      i64.const 0
      i64.store offset=56
      local.get $p4
      i32.const 56
      i32.add
      local.get $p2
      local.get $p1
      i32.const 4015476 ;; Method$System.ValueTuple<string, int>..ctor()
      i32.load
      call $j2657
      local.get $p4
      i64.load offset=56
      local.set $l6
      local.get $p4
      local.get $l6
      i64.store offset=40
      local.get $p4
      local.get $l6
      i64.store offset=16
      local.get $p0
      local.get $p4
      i32.const 16
      i32.add
      i32.const 3994000 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.Contains()
      i32.load
      call $j1657
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      local.get $l5
      i32.load offset=12
      local.set $p1
      local.get $l5
      i32.load offset=8
      local.set $p2
      local.get $p4
      i64.const 0
      i64.store offset=56
      local.get $p4
      i32.const 56
      i32.add
      local.get $p2
      local.get $p1
      i32.const 4015476 ;; Method$System.ValueTuple<string, int>..ctor()
      i32.load
      call $j2657
      local.get $p4
      i64.load offset=56
      local.set $l6
      local.get $p4
      local.get $l6
      i64.store offset=32
      local.get $p4
      local.get $l6
      i64.store offset=8
      local.get $p0
      local.get $p4
      i32.const 8
      i32.add
      i32.const 3993996 ;; Method$System.Collections.Generic.HashSet<ValueTuple<string, int>>.Add()
      i32.load
      call $j1061
      drop
      local.get $l5
      i32.load offset=8
      local.set $p0
      local.get $l5
      i32.load offset=12
      local.set $p1
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      call $j924
      local.set $p2
      local.get $p2
      local.get $l5
      i32.const 4058836 ;; Method$SpLevelManager.<>c__DisplayClass26_0.<LoadSpLevel>b__0()
      i32.load
      i32.const 0
      call $j969
      i32.const 3939448 ;; System.Action<float>_TypeInfo
      i32.load
      call $j924
      local.set $p3
      local.get $p3
      local.get $l5
      i32.const 4058840 ;; Method$SpLevelManager.<>c__DisplayClass26_0.<LoadSpLevel>b__1()
      i32.load
      i32.const 0
      call $j969
      i32.const 3958172 ;; LoadManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      local.get $p0
      local.get $p2
      local.get $p3
      local.get $p4
      call $j10857 ;; LoadManager$$LoadLevel
    end
    local.get $p4
    i32.const -64
    i32.sub
    global.set $primary.global$0)
