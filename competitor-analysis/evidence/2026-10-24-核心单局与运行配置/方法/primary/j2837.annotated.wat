  (func $j2837 (type $t3) (param $p0 i32) (result i32)
    (local $l1 i32)
    i32.const 5139763
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4108992 ;; ios
      call $j922
      i32.const 5139763
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=36
    i32.eqz
    if $I1
      i32.const 5142650
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3952992 ;; CommonArchive_TypeInfo
        call $j922
        i32.const 5142650
        i32.const 1
        i32.store8
      end
      i32.const 3952992 ;; CommonArchive_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j48359 ;; CommonArchive$$GetPlayerLocalData
      local.set $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p0
      i32.store offset=36
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=36
      i32.load offset=28
      local.set $p0
      block $B3
        local.get $p0
        if $I4
          i32.const 0
          local.set $l1
          local.get $p0
          i32.load offset=8
          br_if $B3
        end
        i32.const 1
        local.set $l1
      end
      block $B5
        local.get $l1
        i32.eqz
        if $I6
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=36
          i32.load offset=28
          local.set $p0
          i32.const 3959324 ;; NetworkConfig_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 3959324 ;; NetworkConfig_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=16
          i32.const 0
          call $j1138 ;; System.String$$op_Inequality
          i32.eqz
          br_if $B5
        end
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        call $j923
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=12
        i32.eqz
        br_if $B5
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        call $j923
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=16
        local.set $p0
        block $B7
          local.get $p0
          if $I8
            i32.const 0
            local.set $l1
            local.get $p0
            i32.load offset=8
            br_if $B7
          end
          i32.const 1
          local.set $l1
        end
        local.get $l1
        br_if $B5
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=36
        local.set $p0
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=16
        i32.store offset=28
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=16
        i32.const 4108992 ;; ios
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        local.set $p0
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=36
        local.get $p0
        i32.store8 offset=12
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        call $j6395 ;; NetDataManager$$SaveLocalData
      end
      i32.const 0
      call $j14936 ;; GameManager$$SetFrameLimit
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=36
    return)
