  (func $j91752 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139816
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985864 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>..ctor()
      call $j922
      i32.const 3982656 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>..ctor()
      call $j922
      i32.const 3984716 ;; Method$System.Collections.Generic.Dictionary<string, int>..ctor()
      call $j922
      i32.const 3941504 ;; System.Collections.Generic.Dictionary<string, Action<bool>>_TypeInfo
      call $j922
      i32.const 3942156 ;; System.Collections.Generic.Dictionary<string, int>_TypeInfo
      call $j922
      i32.const 3942656 ;; System.Collections.Generic.Dictionary<string, Texture2D>_TypeInfo
      call $j922
      i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
      call $j922
      i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
      call $j922
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      call $j922
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4015420 ;; Method$System.ValueTuple<bool, bool>..ctor()
      call $j922
      i32.const 5139816
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 35
    i32.store offset=4
    i32.const 3942656 ;; System.Collections.Generic.Dictionary<string, Texture2D>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 3985864 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>..ctor()
    i32.load
    call $j967
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=40
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
    i32.load
    call $j1214
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=44
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const -1
    i32.store offset=52
    i32.const 3942156 ;; System.Collections.Generic.Dictionary<string, int>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 3984716 ;; Method$System.Collections.Generic.Dictionary<string, int>..ctor()
    i32.load
    call $j967
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=60
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store8 offset=68
    local.get $p0
    i32.const 0
    i32.store16 offset=14
    local.get $p0
    i32.const 14
    i32.add
    i32.const 0
    i32.const 0
    i32.const 4015420 ;; Method$System.ValueTuple<bool, bool>..ctor()
    i32.load
    call $j8252
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.set $l1
    local.get $p0
    i32.load16_u offset=14
    local.set $l2
    local.get $l1
    local.get $l2
    i32.store8 offset=69
    local.get $l1
    local.get $l2
    i32.const 8
    i32.shr_u
    i32.store8 offset=70
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store8 offset=80
    i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
    i32.load
    call $j965
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=84
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3941504 ;; System.Collections.Generic.Dictionary<string, Action<bool>>_TypeInfo
    i32.load
    call $j924
    local.set $l1
    local.get $l1
    i32.const 3982656 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>..ctor()
    i32.load
    call $j967
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=88
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=92
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store8 offset=96
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
