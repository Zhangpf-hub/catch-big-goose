  (func $j79161 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139660
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
      call $j922
      i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
      call $j922
      i32.const 5139660
      i32.const 1
      i32.store8
    end
    i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
    i32.load
    call $j1214
    local.get $p0
    local.get $p1
    i32.store offset=44
    local.get $p0
    i32.const 0
    call $j1072) ;; CameraDepthActivation$$.ctor | Pixelize$$.ctor | PlaneClip$$.ctor | SimpleGPUInstancingExample$$.ctor
