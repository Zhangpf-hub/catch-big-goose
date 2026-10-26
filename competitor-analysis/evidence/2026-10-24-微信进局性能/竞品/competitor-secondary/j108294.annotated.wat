  (func $j108294 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5121045
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4018056 ;; Method$Kunpo.AssetManager.Release<GameObject>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5121045
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 4018056 ;; Method$Kunpo.AssetManager.Release<GameObject>()
    i32.load
    call $j49958)
