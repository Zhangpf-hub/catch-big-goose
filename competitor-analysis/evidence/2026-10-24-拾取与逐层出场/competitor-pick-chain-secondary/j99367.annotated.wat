  (func $j99367 (type $t0) (param $p0 i32)
    i32.const 5128610
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985560 ;; Method$System.Collections.Generic.Dictionary<string, float>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3942564 ;; System.Collections.Generic.Dictionary<string, float>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3955276 ;; GMLevelManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5128610
      i32.const 1
      i32.store8
    end
    i32.const 3942564 ;; System.Collections.Generic.Dictionary<string, float>_TypeInfo
    i32.load
    i32.const 137618
    call_indirect $primary.table (type $t1)
    local.set $p0
    local.get $p0
    i32.const 3985560 ;; Method$System.Collections.Generic.Dictionary<string, float>..ctor()
    i32.load
    i32.const 10215
    call_indirect $primary.table (type $t3)
    i32.const 3955276 ;; GMLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=8
    i32.const 3955276 ;; GMLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop)
