  (func $j41840 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    local.get $p1
    local.get $p0
    i32.store offset=12
    i32.const 5139771
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4005472 ;; Method$System.Collections.Generic.List<TeamMemberData>.get_Count()
      call $j922
      i32.const 4005476 ;; Method$System.Collections.Generic.List<TeamMemberData>.get_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4126460 ;; 输入的值超出TeamMemberData个数:
      call $j922
      i32.const 5139771
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B1
      block $B2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=64
        i32.load offset=20
        i32.eqz
        br_if $B2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 4005472 ;; Method$System.Collections.Generic.List<TeamMemberData>.get_Count()
        i32.load
        drop
        local.get $p0
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=64
        i32.load offset=20
        i32.load offset=32
        i32.load offset=8
        i32.load offset=12
        i32.gt_s
        br_if $B2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=64
        i32.load offset=20
        i32.load offset=32
        i32.load offset=8
        local.get $p0
        i32.const 1
        i32.sub
        i32.const 4005476 ;; Method$System.Collections.Generic.List<TeamMemberData>.get_Item()
        i32.load
        call $j947
        local.set $p0
        br $B1
      end
      i32.const 0
      local.set $p0
      local.get $p1
      i32.const 12
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l2
      i32.const 4126460 ;; 输入的值超出TeamMemberData个数:
      i32.load
      local.get $l2
      i32.const 0
      call $j962 ;; System.String$$Concat
      i32.const 0
      i32.const 0
      call $j1229 ;; Kunpo.Debugger$$LogError
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)
