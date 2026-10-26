  (func $j74199 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32)
    i32.const 5127078
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3955472 ;; GameManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3963584 ;; TimerManager_TypeInfo
      call $j922
      i32.const 5127078
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=16
    local.set $p1
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              local.get $p0
              i32.load offset=8
              br_table $B5 $B4 $B3 $B1
            end
            local.get $p0
            i32.const -1
            i32.store offset=8
            br $B2
          end
          local.get $p0
          i32.const -1
          i32.store offset=8
          br $B2
        end
        local.get $p0
        i32.const -1
        i32.store offset=8
        i32.const 3955472 ;; GameManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=4
        i32.eqz
        br_if $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=36
        br_if $B2
        local.get $p1
        local.get $p1
        i32.load offset=200
        i32.const 1
        i32.sub
        i32.store offset=200
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        call $j923
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        local.set $l2
        local.get $l2
        i32.eqz
        br_if $B2
        local.get $l2
        local.get $p1
        i32.load offset=200
        i32.const 0
        call $j1561
      end
      local.get $p1
      i32.load8_u offset=56
      local.set $p1
      i32.const 3963584 ;; TimerManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3963584 ;; TimerManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=8
      i32.store offset=12
      i32.const 1
      local.set $l2
      local.get $p0
      i32.const 1
      i32.const 2
      local.get $p1
      select
      i32.store offset=8
    end
    local.get $l2
    return)
