  (func $j94039 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5139983
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952576 ;; CameraControl_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139983
      i32.const 1
      i32.store8
    end
    i32.const 3952576 ;; CameraControl_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 0
    call $j24228) ;; CameraControl$$ResetCameraPos
