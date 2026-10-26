  (func $j22258 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32)
    i32.const 5140048
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3939012 ;; System.Action<SubscribeStateData[]>_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 3950212 ;; int[]_TypeInfo
      call $j922
      i32.const 4005208 ;; Method$System.Collections.Generic.List<SubscribeStateData>..ctor()
      call $j922
      i32.const 3947732 ;; System.Collections.Generic.List<SubscribeStateData>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4054860 ;; Method$LevelManager.<>c.<CheckSubmit>b__84_0()
      call $j922
      i32.const 4054864 ;; Method$LevelManager.<>c.<CheckSubmit>b__84_1()
      call $j922
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      call $j922
      i32.const 5140048
      i32.const 1
      i32.store8
    end
    i32.const 3951296 ;; ABPackManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j11649 ;; ABPackManager$$get_ShowSubmitABType
      i32.const 1
      i32.ne
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=68
      i32.eqz
      br_if $B1
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j1326 ;; NetworkConfig$$get_GameChannel
      i32.const 3
      i32.ne
      br_if $B1
      i32.const 3950212 ;; int[]_TypeInfo
      i32.load
      i32.const 1
      call $j939
      local.set $l2
      local.get $l2
      local.get $p0
      i32.load offset=356
      i32.store offset=16
      i32.const 3947732 ;; System.Collections.Generic.List<SubscribeStateData>_TypeInfo
      i32.load
      call $j924
      local.set $p0
      local.get $p0
      i32.const 4005208 ;; Method$System.Collections.Generic.List<SubscribeStateData>..ctor()
      i32.load
      call $j965
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p0
      i32.store offset=12
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      i32.load offset=92
      drop
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.set $p0
      local.get $p0
      i32.eqz
      if $I2
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        call $j923
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $p1
        i32.const 3939012 ;; System.Action<SubscribeStateData[]>_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p0
        local.get $p1
        i32.const 4054860 ;; Method$LevelManager.<>c.<CheckSubmit>b__84_0()
        i32.load
        i32.const 0
        call $j969
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p0
        i32.store offset=4
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        drop
      end
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      local.set $p1
      local.get $p1
      i32.eqz
      if $I3
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        call $j923
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $l3
        i32.const 3951352 ;; System.Action_TypeInfo
        i32.load
        call $j924
        local.set $p1
        local.get $p1
        local.get $l3
        i32.const 4054864 ;; Method$LevelManager.<>c.<CheckSubmit>b__84_1()
        i32.load
        i32.const 0
        call $j994 ;; System.Action$$.ctor
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p1
        i32.store offset=8
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        drop
      end
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      local.get $l2
      local.get $p0
      local.get $p1
      i32.const 0
      call $j21610 ;; NetworkHelper$$SubscribeState
    end)
