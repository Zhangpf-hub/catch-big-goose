  (func $j91760 (type $t4) (param $p0 i32)
    i32.const 5139776
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3964444 ;; UITeamInfoPop_TypeInfo
      call $j922
      i32.const 3964448 ;; UITeamPop_TypeInfo
      call $j922
      i32.const 4113664 ;; refreshUITeamPop
      call $j922
      i32.const 4113660 ;; refreshUITeamInfoPop
      call $j922
      i32.const 5139776
      i32.const 1
      i32.store8
    end
    i32.const 3964448 ;; UITeamPop_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p0
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      i32.const 0
      call $j971 ;; UnityEngine.Object$$op_Inequality
      i32.eqz
      br_if $B1
      i32.const 3964448 ;; UITeamPop_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=124
      i32.const 2
      i32.ne
      if $I2
        i32.const 3964448 ;; UITeamPop_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=124
        i32.const 1
        i32.ne
        br_if $B1
      end
      i32.const 3964448 ;; UITeamPop_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j33513 ;; UITeamPop$$RefreshTeamInfo
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4113664 ;; refreshUITeamPop
      i32.load
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end
    i32.const 3964444 ;; UITeamInfoPop_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p0
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B3
      local.get $p0
      i32.const 0
      i32.const 0
      call $j971 ;; UnityEngine.Object$$op_Inequality
      i32.eqz
      br_if $B3
      i32.const 3964444 ;; UITeamInfoPop_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=124
      i32.const 2
      i32.ne
      if $I4
        i32.const 3964444 ;; UITeamInfoPop_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=124
        i32.const 1
        i32.ne
        br_if $B3
      end
      i32.const 3964444 ;; UITeamInfoPop_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j18612 ;; UITeamInfoPop$$RefreshTeamInfo
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4113660 ;; refreshUITeamInfoPop
      i32.load
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end)
