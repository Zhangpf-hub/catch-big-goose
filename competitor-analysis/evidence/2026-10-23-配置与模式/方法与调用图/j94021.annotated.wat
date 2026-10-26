  (func $j94021 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140001
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952324 ;; bool_TypeInfo
      call $j922
      i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
      call $j922
      i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
      call $j922
      i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4083892 ;; IsWin
      call $j922
      i32.const 5140001
      i32.const 1
      i32.store8
    end
    i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
    i32.load
    call $j967
    local.get $p1
    i32.const 0
    i32.store8 offset=15
    i32.const 3952324 ;; bool_TypeInfo
    i32.load
    local.get $p1
    i32.const 15
    i32.add
    call $j935
    local.set $p0
    local.get $l2
    i32.const 4083892 ;; IsWin
    i32.load
    local.get $p0
    i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
    i32.load
    call $j953
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 206
    local.set $p0
    block $B1
      block $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.eqz
        br_if $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B3
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 6
          i32.eq
          if $I4
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=4
            i32.const 0
            call $j2670 ;; SpLevelManager$$GetSpWindow
            local.set $p0
            local.get $p0
            br_if $B3
            br $B1
          end
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 852
          local.set $p0
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 20
          i32.eq
          br_if $B2
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.const 9
          i32.ne
          br_if $B1
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 0
          call $j2670 ;; SpLevelManager$$GetSpWindow
          local.set $p0
          local.get $p0
          i32.eqz
          br_if $B1
        end
        local.get $p0
        i32.load offset=16
        local.set $p0
      end
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $l2
      i32.const 0
      i32.const 0
      i32.const 0
      call $j1082 ;; Kunpo.KUIManager$$OpenUI
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)
