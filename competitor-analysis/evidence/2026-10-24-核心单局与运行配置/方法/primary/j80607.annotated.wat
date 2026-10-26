  (func $j80607 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i64)
    i32.const 5140325
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983348 ;; Method$System.Collections.Generic.Dictionary<string, List<string>>..ctor()
      call $j922
      i32.const 3988120 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>..ctor()
      call $j922
      i32.const 3988108 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>..ctor()
      call $j922
      i32.const 3988132 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>..ctor()
      call $j922
      i32.const 3943220 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>_TypeInfo
      call $j922
      i32.const 3943224 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>_TypeInfo
      call $j922
      i32.const 3943216 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>_TypeInfo
      call $j922
      i32.const 3941656 ;; System.Collections.Generic.Dictionary<string, List<string>>_TypeInfo
      call $j922
      i32.const 3961872 ;; ServerCommonData_TypeInfo
      call $j922
      i32.const 4069268 ;; 1.0
      call $j922
      i32.const 4114616 ;; shareADListFile.txt
      call $j922
      i32.const 4117896 ;; wx/TimeData/prod/
      call $j922
      i32.const 4071628 ;; ABTestData.config
      call $j922
      i32.const 4117892 ;; wx/TimeData/dev/
      call $j922
      i32.const 4091916 ;; ServerWarnFile.config
      call $j922
      i32.const 4108264 ;; https://cdn-zhuadae.lanfeitech.com/
      call $j922
      i32.const 4104444 ;; commonVarFile.txt
      call $j922
      i32.const 4104440 ;; commonTimeFile.passConfig
      call $j922
      i32.const 4108268 ;; https://cdn-zhuadae.lanfeitech.com/GMVersion
      call $j922
      i32.const 5140325
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 4108268 ;; https://cdn-zhuadae.lanfeitech.com/GMVersion
    i32.load
    i32.store offset=44
    local.get $p0
    i32.const 4069268 ;; 1.0
    i32.load
    i32.store offset=52
    local.get $p0
    i32.const 4114616 ;; shareADListFile.txt
    i32.load
    i32.store offset=56
    local.get $p0
    i32.const 4104444 ;; commonVarFile.txt
    i32.load
    i32.store offset=64
    i32.const 3961872 ;; ServerCommonData_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 257
    i32.store16 offset=44
    local.get $p1
    i32.const 1
    i32.store offset=32
    i64.const 4294967298
    local.set $l2
    local.get $p1
    local.get $l2
    i32.wrap_i64
    i32.store offset=24
    local.get $p1
    local.get $l2
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=28
    i64.const 7730941132803
    local.set $l2
    local.get $p1
    local.get $l2
    i32.wrap_i64
    i32.store offset=16
    local.get $p1
    local.get $l2
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=20
    local.get $p1
    i32.const 257
    i32.store16 offset=14
    local.get $p0
    local.get $p1
    i32.store offset=68
    local.get $p0
    i32.const 1
    i32.store8 offset=76
    local.get $p0
    i32.const 4108264 ;; https://cdn-zhuadae.lanfeitech.com/
    i32.load
    i32.store offset=80
    local.get $p0
    i32.const 4117892 ;; wx/TimeData/dev/
    i32.load
    i32.store offset=84
    local.get $p0
    i32.const 4117896 ;; wx/TimeData/prod/
    i32.load
    i32.store offset=88
    local.get $p0
    i32.const 4104440 ;; commonTimeFile.passConfig
    i32.load
    i32.store offset=92
    local.get $p0
    i32.const 4091916 ;; ServerWarnFile.config
    i32.load
    i32.store offset=100
    i32.const 3943224 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3988132 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $p1
    i32.store offset=108
    i32.const 3943216 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3988108 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $p1
    i32.store offset=112
    i32.const 3943220 ;; System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3988120 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $p1
    i32.store offset=116
    local.get $p0
    i32.const 4071628 ;; ABTestData.config
    i32.load
    i32.store offset=120
    i32.const 3941656 ;; System.Collections.Generic.Dictionary<string, List<string>>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3983348 ;; Method$System.Collections.Generic.Dictionary<string, List<string>>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $p1
    i32.store offset=128
    local.get $p0
    i32.const 0
    call $j1072) ;; CameraDepthActivation$$.ctor | Pixelize$$.ctor | PlaneClip$$.ctor | SimpleGPUInstancingExample$$.ctor
