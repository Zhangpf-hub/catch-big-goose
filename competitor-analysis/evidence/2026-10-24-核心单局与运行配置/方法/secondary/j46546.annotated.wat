  (func $j46546 (type $t1) (param $p0 i32) (result i32)
    i32.const 5139961
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3999976 ;; Method$System.Collections.Generic.List<EndlessLevelDataData>.get_Item()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4123264 ;; 无数据
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139961
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=20
    i32.eqz
    if $I1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 4123264 ;; 无数据
      i32.load
      i32.const 0
      i32.const 5660
      call_indirect $primary.table (type $t3)
      i32.const 0
      return
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=20
    i32.const 0
    i32.const 3999976 ;; Method$System.Collections.Generic.List<EndlessLevelDataData>.get_Item()
    i32.load
    i32.const 10930
    call_indirect $primary.table (type $t5)
    return)
