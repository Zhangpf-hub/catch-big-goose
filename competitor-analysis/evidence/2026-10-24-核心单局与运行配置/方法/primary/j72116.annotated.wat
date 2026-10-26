  (func $j72116 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5139819
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4124888 ;; 省份数据
      call $j922
      i32.const 4124892 ;; 省份数据失败
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4125384 ;; 获取
      call $j922
      i32.const 4122664 ;; 成功获取
      call $j922
      i32.const 5139819
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p2
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p2
      local.get $p1
      i32.const 0
      call $j14370 ;; NetInitManager$$BuildServerProvinceData
      if $I2
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j1600 ;; NetInitManager$$CanShowSEventDetail
        if $I3
          i32.const 4063796 ;; 
          i32.load
          local.set $p1
          i32.const 4122664 ;; 成功获取
          i32.load
          local.get $p0
          i32.load offset=8
          i32.const 4124888 ;; 省份数据
          i32.load
          local.get $p1
          local.get $p1
          local.get $p1
          i32.const 0
          call $j1120 ;; GameManager$$StringAppend
          i32.const 0
          call $j1441 ;; UnityEngine.MonoBehaviour$$print
        end
        local.get $p0
        i32.load offset=12
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.const 1
        i32.const 0
        call $j1184
        return
      end
      i32.const 4063796 ;; 
      i32.load
      local.set $p1
      i32.const 4125384 ;; 获取
      i32.load
      local.get $p0
      i32.load offset=8
      i32.const 4124892 ;; 省份数据失败
      i32.load
      local.get $p1
      local.get $p1
      local.get $p1
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1441 ;; UnityEngine.MonoBehaviour$$print
      local.get $p0
      i32.load offset=12
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.const 0
      i32.const 0
      call $j1184
    end)
