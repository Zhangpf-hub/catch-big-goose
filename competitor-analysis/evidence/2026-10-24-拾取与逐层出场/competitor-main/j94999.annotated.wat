  (func $j94999 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5127091
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4020452 ;; Method$UnityEngine.Component.GetComponent<PlateContentItem>()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003436 ;; Method$System.Collections.Generic.List<PlateContentItem>.Add()
      call $j922
      i32.const 4003432 ;; Method$System.Collections.Generic.List<PlateContentItem>..ctor()
      call $j922
      i32.const 3947360 ;; System.Collections.Generic.List<PlateContentItem>_TypeInfo
      call $j922
      i32.const 5127091
      i32.const 1
      i32.store8
    end
    i32.const 3947360 ;; System.Collections.Generic.List<PlateContentItem>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4003432 ;; Method$System.Collections.Generic.List<PlateContentItem>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=32
    i32.const 0
    local.set $p1
    loop $L1
      local.get $p0
      i32.load offset=20
      i32.const 0
      call $j1462 ;; UnityEngine.Transform$$get_childCount
      local.get $p1
      i32.gt_s
      if $I2
        local.get $p0
        i32.load offset=32
        local.get $p0
        i32.load offset=20
        local.get $p1
        i32.const 0
        call $j1321 ;; UnityEngine.Transform$$GetChild
        i32.const 4020452 ;; Method$UnityEngine.Component.GetComponent<PlateContentItem>()
        i32.load
        call $j1133
        i32.const 4003436 ;; Method$System.Collections.Generic.List<PlateContentItem>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p0
    i32.load offset=12
    local.set $p1
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=81
    i32.eqz
    i32.const 0
    call $j952 ;; UnityEngine.GameObject$$SetActive
    local.get $p0
    i32.load offset=16
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=81
    i32.const 0
    call $j952) ;; UnityEngine.GameObject$$SetActive
