  (func $j94032 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5139985
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4084592 ;; LevelSlot
      call $j922
      i32.const 5139985
      i32.const 1
      i32.store8
    end
    i32.const 5142659
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 5142659
      i32.const 1
      i32.store8
    end
    i32.const 0
    local.set $p0
    block $B2
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      i32.const 1
      i32.sub
      i32.const 11
      i32.gt_u
      br_if $B2
      block $B3
        local.get $p1
        i32.const 6
        i32.ne
        if $I4
          local.get $p1
          br_if $B3
          i32.const 3958464 ;; MainLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j14562 ;; MainLevelManager$$get_FunctionId
          return
        end
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 10032
        local.set $p0
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4084592 ;; LevelSlot
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        br_if $B2
      end
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)
