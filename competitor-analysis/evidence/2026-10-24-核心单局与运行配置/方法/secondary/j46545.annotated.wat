  (func $j46545 (type $t1) (param $p0 i32) (result i32)
    i32.const 5139970
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4034880 ;; Method$SaveManager.Load<int>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4077820 ;; EndlessLevelGoldCount
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139970
      i32.const 1
      i32.store8
    end
    i32.const 4077820 ;; EndlessLevelGoldCount
    i32.load
    i32.const 0
    i32.const 16376
    call_indirect $primary.table (type $t2)
    i32.eqz
    if $I1
      i32.const 4077820 ;; EndlessLevelGoldCount
      i32.load
      i32.const 0
      i32.const 4034896 ;; Method$SaveManager.Save<int>()
      i32.load
      i32.const 5862
      call_indirect $primary.table (type $t4)
    end
    i32.const 4077820 ;; EndlessLevelGoldCount
    i32.load
    i32.const 4034880 ;; Method$SaveManager.Load<int>()
    i32.load
    i32.const 5861
    call_indirect $primary.table (type $t2)
    return)
