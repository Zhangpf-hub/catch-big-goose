  (func $j43529 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 5140088
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5140088
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        i32.const 0
        call $j2087 ;; LevelManager$$HasTwoPlayer
        if $I3
          i32.const 0
          local.set $p1
          br $B2
        end
        local.get $p0
        i32.load offset=48
        i32.load offset=28
        local.set $p1
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        if $I4
          local.get $p0
          i32.load offset=48
          i32.load offset=28
          local.set $p1
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=28
          i32.const 1
          i32.eq
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
        end
        local.get $p0
        i32.load offset=48
        i32.load offset=24
        local.set $p1
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        if $I5
          local.get $p0
          i32.load offset=48
          i32.load offset=24
          local.set $p1
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=28
          i32.const 2
          i32.eq
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
        end
        local.get $p0
        i32.load offset=48
        i32.load offset=32
        local.set $p1
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=48
        i32.load offset=32
        i32.const 0
        i32.const 0
        call $j952 ;; UnityEngine.GameObject$$SetActive
        return
      end
      loop $L6
        local.get $p1
        i32.const 2
        i32.ge_s
        br_if $B1
        local.get $p0
        i32.load offset=52
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=28
        local.set $l2
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $l2
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        if $I7
          local.get $p0
          i32.load offset=52
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=28
          i32.const 0
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
        end
        local.get $p0
        i32.load offset=52
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=24
        local.set $l2
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $l2
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        if $I8
          local.get $p0
          i32.load offset=52
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=24
          i32.const 0
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
        end
        local.get $p0
        i32.load offset=52
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.load offset=32
        local.set $l2
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $l2
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        if $I9
          local.get $p0
          i32.load offset=52
          local.get $p1
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.load offset=32
          i32.const 1
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
        end
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L6
      end
      unreachable
    end)
