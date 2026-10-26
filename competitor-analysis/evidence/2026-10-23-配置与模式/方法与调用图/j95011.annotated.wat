  (func $j95011 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 f32) (local $l4 f32) (local $l5 f32) (local $l6 f32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 f32) (local $l11 f32) (local $l12 i32) (local $l13 i32) (local $l14 i32) (local $l15 f64) (local $l16 f64) (local $l17 f64)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140157
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3962372 ;; SportManager_TypeInfo
      call $j922
      i32.const 3963584 ;; TimerManager_TypeInfo
      call $j922
      i32.const 4121116 ;; 加速度:
      call $j922
      i32.const 4065476 ;;  间隔:
      call $j922
      i32.const 4120488 ;; 修正值:
      call $j922
      i32.const 5140157
      i32.const 1
      i32.store8
    end
    local.get $p2
    i32.const 0
    i32.store offset=60
    local.get $p1
    f64.load offset=8
    local.set $l15
    local.get $p1
    f64.load offset=24
    local.set $l16
    local.get $p1
    f64.load offset=16
    local.set $l17
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    local.get $l17
    f32.demote_f64
    local.set $l4
    local.get $l16
    f32.demote_f64
    local.set $l5
    local.get $l15
    f32.demote_f64
    local.set $l6
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.set $p1
    local.get $p1
    if $I1
      local.get $p2
      local.get $l4
      f32.store offset=56
      local.get $p2
      local.get $p2
      i32.load offset=56
      i32.store offset=24
      local.get $p2
      local.get $l5
      f32.store offset=52
      local.get $p2
      local.get $l6
      f32.store offset=48
      local.get $p2
      local.get $p2
      i64.load offset=48
      i64.store offset=16
      local.get $p1
      i32.load offset=32
      local.get $p2
      i32.const 16
      i32.add
      local.get $p1
      i32.load offset=20
      local.get $p1
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t2)
    end
    block $B2
      i32.const 19
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      i32.load
      local.get $p0
      i32.load offset=384
      call $j951
      i32.eqz
      br_if $B2
      local.get $p0
      i32.const 0
      call $j1713 ;; UnityEngine.Time$$get_unscaledTime
      local.get $p0
      f32.load offset=768
      f32.sub
      f32.store offset=772
      local.get $p0
      i32.const 0
      call $j1713 ;; UnityEngine.Time$$get_unscaledTime
      f32.store offset=768
      local.get $p0
      f32.load offset=772
      local.set $l3
      f32.const 0x1.0e5604p-5 (;=0.033;)
      local.get $l3
      f32.const 0x1p+0 (;=1;)
      f32.min
      local.get $l3
      f32.const 0x1.0e5604p-5 (;=0.033;)
      f32.lt
      select
      f32.const 0x1.4p+2 (;=5;)
      f32.mul
      local.set $l3
      local.get $p0
      local.get $l3
      f32.store offset=776
      local.get $l3
      f32.const 0x1.8p+2 (;=6;)
      f32.mul
      local.set $l3
      local.get $p0
      local.get $l3
      f32.store offset=776
      local.get $l3
      i32.const 0
      call $j7033 ;; UnityEngine.Time$$get_fixedDeltaTime
      f32.div
      f32.const 0x1.47ae14p-6 (;=0.02;)
      f32.mul
      local.set $l3
      local.get $p0
      local.get $l3
      f32.store offset=776
      local.get $p0
      local.get $l3
      local.get $p0
      f32.load offset=760
      f32.mul
      f32.store offset=776
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=4
      i32.eqz
      br_if $B2
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=12
      br_if $B2
      i32.const 3963584 ;; TimerManager_TypeInfo
      i32.load
      call $j923
      i32.const 3963584 ;; TimerManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=48
      i32.eqz
      br_if $B2
      i32.const 5155399
      i32.load8_u
      i32.eqz
      if $I3
        i32.const 3958620 ;; System.Math_TypeInfo
        call $j922
        i32.const 5155399
        i32.const 1
        i32.store8
      end
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      call $j923
      local.get $p0
      f32.load offset=788
      local.get $l6
      local.get $l6
      f32.mul
      local.get $l5
      local.get $l5
      f32.mul
      f32.add
      local.get $l4
      local.get $l4
      f32.mul
      f32.add
      f32.sqrt
      f32.gt
      br_if $B2
      i32.const 5155399
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3958620 ;; System.Math_TypeInfo
        call $j922
        i32.const 5155399
        i32.const 1
        i32.store8
      end
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      call $j923
      local.get $l6
      local.get $l6
      f32.mul
      local.get $l5
      local.get $l5
      f32.mul
      f32.add
      local.get $l4
      local.get $l4
      f32.mul
      f32.add
      f32.sqrt
      local.set $l3
      block $B5
        local.get $l3
        f32.const 0x1.4f8b58p-17 (;=1e-05;)
        f32.gt
        if $I6
          local.get $l4
          local.get $l3
          f32.div
          local.set $l9
          local.get $l6
          local.get $l3
          f32.div
          local.set $l10
          local.get $l5
          local.get $l3
          f32.div
          local.set $l11
          br $B5
        end
        i32.const 5158080
        i32.load8_u
        i32.eqz
        if $I7
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5158080
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p1
        local.get $p1
        f32.load offset=8
        local.set $l9
        local.get $p1
        f32.load
        local.set $l10
        local.get $p1
        f32.load offset=4
        local.set $l11
      end
      i32.const 5155400
      i32.load8_u
      i32.eqz
      if $I8
        i32.const 3958620 ;; System.Math_TypeInfo
        call $j922
        i32.const 5155400
        i32.const 1
        i32.store8
      end
      local.get $p0
      i32.const 776
      i32.add
      local.set $l12
      local.get $p0
      i32.const 772
      i32.add
      local.set $l13
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      call $j923
      local.get $p0
      f32.load offset=792
      local.get $p0
      f32.load offset=764
      f32.mul
      local.set $l7
      local.get $l6
      local.get $l6
      f32.mul
      local.get $l5
      local.get $l5
      f32.mul
      f32.add
      local.get $l4
      local.get $l4
      f32.mul
      f32.add
      f32.sqrt
      local.get $p0
      f32.load offset=788
      f32.sub
      local.set $l3
      f32.const 0x0p+0 (;=0;)
      local.get $l7
      local.get $l3
      local.get $l3
      local.get $l7
      f32.gt
      select
      local.get $l3
      f32.const 0x0p+0 (;=0;)
      f32.lt
      select
      local.set $l3
      i32.const 0
      local.set $p1
      loop $L9
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $p1
        local.get $p0
        i32.load offset=152
        i32.load offset=12
        i32.lt_s
        if $I10
          local.get $p0
          i32.load offset=152
          local.get $p1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j21513 ;; ObjectUnit$$CanShake
          if $I11
            local.get $p0
            i32.load offset=152
            local.get $p1
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            local.set $l14
            local.get $p0
            f32.load offset=796
            local.set $l7
            local.get $p0
            f32.load offset=776
            local.set $l8
            local.get $p2
            local.get $l9
            local.get $l3
            f32.mul
            local.get $l7
            f32.mul
            local.get $l8
            f32.mul
            f32.store offset=40
            local.get $p2
            local.get $p2
            i32.load offset=40
            i32.store offset=8
            local.get $p2
            local.get $l11
            local.get $l3
            f32.mul
            local.get $l7
            f32.mul
            local.get $l8
            f32.mul
            f32.store offset=36
            local.get $p2
            local.get $l10
            local.get $l3
            f32.mul
            local.get $l7
            f32.mul
            local.get $l8
            f32.mul
            f32.store offset=32
            local.get $p2
            local.get $p2
            i64.load offset=32
            i64.store
            local.get $l14
            local.get $p2
            i32.const 0
            call $j14312 ;; ObjectUnit$$AddForce
          end
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L9
        end
      end
      local.get $p0
      i32.load offset=784
      local.set $p1
      local.get $p1
      local.get $p0
      i32.load offset=780
      i32.lt_s
      if $I12
        local.get $p0
        local.get $p1
        i32.const 1
        i32.add
        i32.store offset=784
        i32.const 5155400
        i32.load8_u
        i32.eqz
        if $I13
          i32.const 3958620 ;; System.Math_TypeInfo
          call $j922
          i32.const 5155400
          i32.const 1
          i32.store8
        end
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.load
        call $j923
        local.get $p2
        local.get $l6
        local.get $l6
        f32.mul
        local.get $l5
        local.get $l5
        f32.mul
        f32.add
        local.get $l4
        local.get $l4
        f32.mul
        f32.add
        f32.sqrt
        f32.store offset=60
        local.get $p2
        i32.const 60
        i32.add
        i32.const 0
        call $j1566 ;; System.Single$$ToString
        local.set $p1
        local.get $l12
        i32.const 0
        call $j1566 ;; System.Single$$ToString
        local.set $l12
        local.get $l13
        i32.const 0
        call $j1566 ;; System.Single$$ToString
        local.set $l13
        i32.const 4121116 ;; 加速度:
        i32.load
        local.get $p1
        i32.const 4120488 ;; 修正值:
        i32.load
        local.get $l12
        i32.const 4065476 ;;  间隔:
        i32.load
        local.get $l13
        i32.const 0
        call $j1120 ;; GameManager$$StringAppend
        local.set $p1
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        call $j1051 ;; UnityEngine.Debug$$Log
      end
      local.get $p0
      i32.const 0
      i32.store offset=804
      local.get $p0
      f32.load offset=772
      local.set $l4
      i32.const 3962372 ;; SportManager_TypeInfo
      i32.load
      call $j923
      local.get $l4
      i32.const 0
      call $j19946 ;; SportManager$$AddCal
    end
    local.get $p2
    i32.const -64
    i32.sub
    global.set $primary.global$0)
