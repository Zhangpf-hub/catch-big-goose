  (func $j72402 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140332
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4125660 ;; 获取时间文件失败
      call $j922
      i32.const 5140332
      i32.const 1
      i32.store8
    end
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    i32.const 4125660 ;; 获取时间文件失败
    i32.load
    i32.const 0
    call $j1050 ;; UnityEngine.Debug$$LogError
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I1
      local.get $p0
      i32.const 0
      i32.const 0
      call $j1184
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store8 offset=20)
