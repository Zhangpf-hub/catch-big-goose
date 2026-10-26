  (func $j21670 (type $t4) (param $p0 i32)
    (local $l1 f64) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 f32)
    i32.const 5139742
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139742
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $p0
      local.get $p0
      i32.load offset=44
      local.set $l3
      i32.const 0
      call $j1713 ;; UnityEngine.Time$$get_unscaledTime
      local.set $l5
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=72
      local.set $l4
      local.get $l5
      f64.promote_f32
      local.set $l1
      block $B2
        local.get $l1
        f64.abs
        f64.const 0x1p+31 (;=2.14748e+09;)
        f64.lt
        if $I3
          local.get $l1
          i32.trunc_f64_s
          local.set $l2
          br $B2
        end
        i32.const -2147483648
        local.set $l2
      end
      local.get $p0
      local.get $l2
      local.get $l4
      i32.sub
      local.get $l3
      i32.add
      i32.store offset=44
    end)
