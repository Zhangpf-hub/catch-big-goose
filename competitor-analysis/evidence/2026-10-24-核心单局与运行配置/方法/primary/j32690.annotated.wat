  (func $j32690 (type $t47) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result f32)
    (local $l4 i32) (local $l5 f32) (local $l6 f32) (local $l7 f32) (local $l8 f32)
    i32.const 5131888
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3996096 ;; Method$Kunpo.KFakeRandom<int>.AddItem()
      call $j922
      i32.const 3996112 ;; Method$Kunpo.KFakeRandom<int>.Roll()
      call $j922
      i32.const 3996092 ;; Method$Kunpo.KFakeRandom<int>..ctor()
      call $j922
      i32.const 3946100 ;; Kunpo.KFakeRandom<int>_TypeInfo
      call $j922
      i32.const 3964920 ;; ValueManager_TypeInfo
      call $j922
      i32.const 5131888
      i32.const 1
      i32.store8
    end
    i32.const 3946100 ;; Kunpo.KFakeRandom<int>_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    i32.const 3996092 ;; Method$Kunpo.KFakeRandom<int>..ctor()
    i32.load
    call $j1878
    i32.const 0
    local.set $p3
    loop $L1
      local.get $p0
      i32.load offset=12
      local.get $p3
      i32.gt_s
      if $I2
        local.get $l4
        local.get $p2
        local.get $p3
        i32.const 12
        i32.mul
        i32.add
        f32.load offset=16
        local.get $p2
        local.get $p3
        i32.const 12
        i32.mul
        i32.add
        f32.load offset=20
        f32.add
        local.get $p2
        local.get $p3
        i32.const 12
        i32.mul
        i32.add
        f32.load offset=24
        f32.mul
        local.get $p3
        i32.const 3996096 ;; Method$Kunpo.KFakeRandom<int>.AddItem()
        i32.load
        call $j1790
        local.get $p3
        i32.const 1
        i32.add
        local.set $p3
        br $L1
      end
    end
    local.get $l4
    i32.const 3996112 ;; Method$Kunpo.KFakeRandom<int>.Roll()
    i32.load
    call $j2054
    local.set $p3
    local.get $p0
    local.get $p3
    i32.const 2
    i32.shl
    i32.add
    f32.load offset=16
    local.set $l5
    local.get $p1
    local.get $p3
    i32.const 2
    i32.shl
    i32.add
    f32.load offset=16
    local.set $l6
    local.get $p2
    local.get $p3
    i32.const 12
    i32.mul
    i32.add
    f32.load offset=16
    local.set $l7
    local.get $p2
    local.get $p3
    i32.const 12
    i32.mul
    i32.add
    f32.load offset=20
    local.set $l8
    i32.const 3964920 ;; ValueManager_TypeInfo
    i32.load
    call $j923
    local.get $l5
    local.get $l6
    local.get $l7
    local.get $l8
    local.get $p3
    call $j18335 ;; ValueManager$$GetWeightRandom
    return)
