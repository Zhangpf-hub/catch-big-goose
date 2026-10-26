  (func $j46542 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5139969
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4077828 ;; EndlessLevelNum
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139969
      i32.const 1
      i32.store8
    end
    i32.const 4077828 ;; EndlessLevelNum
    i32.load
    local.get $p0
    i32.const 4034896 ;; Method$SaveManager.Save<int>()
    i32.load
    i32.const 5862
    call_indirect $primary.table (type $t4))
