  (func $j2931 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 5140308
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3998160 ;; Method$System.Collections.Generic.List<Action>.Add()
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4057812 ;; Method$ServerFileCreate.<>c.<CommonTimeComplete>b__46_0()
      call $j922
      i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
      call $j922
      i32.const 5140308
      i32.const 1
      i32.store8
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=20
      if $I2
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=32
        local.get $p0
        i32.load offset=20
        local.get $p0
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t0)
        return
      end
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=24
      local.get $p0
      i32.const 3998160 ;; Method$System.Collections.Generic.List<Action>.Add()
      i32.load
      call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=21
      br_if $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 1
      i32.store8 offset=21
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p1
      i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.set $p0
      local.get $p0
      i32.eqz
      if $I3
        i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
        i32.load
        call $j923
        i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $l2
        i32.const 3939040 ;; System.Action<bool>_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p0
        local.get $l2
        i32.const 4057812 ;; Method$ServerFileCreate.<>c.<CommonTimeComplete>b__46_0()
        i32.load
        i32.const 0
        call $j969
        i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p0
        i32.store offset=4
        i32.const 3971016 ;; ServerFileCreate.<>c_TypeInfo
        i32.load
        i32.load offset=92
        drop
      end
      local.get $p1
      local.get $p0
      local.get $p0
      call $j13780 ;; ServerFileCreate$$LoadTimeDataFile
    end)
