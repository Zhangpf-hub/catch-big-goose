  (func $j5052 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139649
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4123836 ;; 未注册 
      call $j922
      i32.const 4065368 ;;  副本的名字
      call $j922
      i32.const 4115116 ;; spLevelManager Instance = null
      call $j922
      i32.const 5139649
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p1
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        local.get $p1
        i32.const 0
        i32.const 0
        call $j980 ;; UnityEngine.Object$$op_Equality
        if $I3
          i32.const 4115116 ;; spLevelManager Instance = null
          i32.load
          local.set $p0
          br $B2
        end
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 1
        local.set $p1
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=44
        local.get $p0
        i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
        i32.load
        call $j1657
        br_if $B1
        i32.const 4123836 ;; 未注册 
        i32.load
        local.get $p0
        i32.const 4065368 ;;  副本的名字
        i32.load
        i32.const 0
        call $j1011 ;; System.String$$Concat
        local.set $p0
      end
      i32.const 0
      local.set $p1
      i32.const 1
      local.get $p0
      i32.const 0
      call $j1429 ;; GameManager$$LogInColor
    end
    local.get $p1
    return)
