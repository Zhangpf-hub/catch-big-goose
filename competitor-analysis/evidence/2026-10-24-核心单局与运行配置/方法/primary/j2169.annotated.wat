  (func $j2169 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 5140108
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994404 ;; Method$System.Collections.Generic.HashSet<string>.Clear()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 5140108
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=380
    i32.load offset=16
    i32.const 3994404 ;; Method$System.Collections.Generic.HashSet<string>.Clear()
    i32.load
    call $j1524
    i32.const 0
    local.set $p1
    loop $L1
      block $B2
        local.get $p0
        i32.load offset=140
        local.set $l2
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $p0
        i32.load offset=140
        i32.load offset=12
        local.get $p1
        i32.le_s
        br_if $B2
        local.get $l2
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        i32.const 0
        i32.const 0
        call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
        drop
        i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
        i32.load
        call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
        local.get $p0
        i32.load offset=140
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j4698 ;; LevelObjectPool$$Recycle
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $l2
    i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
    i32.load
    call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
    local.get $p0
    i32.load offset=152
    i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
    i32.load
    call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
    local.get $p0
    i32.load offset=148
    i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
    i32.load
    call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
    local.get $p0
    i32.const 0
    i32.store offset=212
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    call $j2087 ;; LevelManager$$HasTwoPlayer
    if $I3
      i32.const 0
      local.set $p1
      loop $L4
        block $B5
          local.get $p0
          i32.load offset=156
          local.set $l2
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $p0
          i32.load offset=156
          i32.load offset=12
          local.get $p1
          i32.le_s
          br_if $B5
          local.get $l2
          local.get $p1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          i32.const 0
          i32.const 0
          call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
          drop
          i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
          i32.load
          call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
          local.get $p0
          i32.load offset=156
          local.get $p1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j4698 ;; LevelObjectPool$$Recycle
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L4
        end
      end
      local.get $l2
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      i32.load
      call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
      local.get $p0
      i32.load offset=168
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      i32.load
      call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
      local.get $p0
      i32.load offset=164
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      i32.load
      call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
      local.get $p0
      i32.const 0
      i32.store offset=276
    end
    i32.const 0
    local.set $p1
    loop $L6
      local.get $p0
      i32.load offset=72
      local.set $l2
      local.get $l2
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I7
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 0
        i32.const 0
        call $j3070 ;; HighlightPlus.HighlightEffect$$SetHighlighted
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L6
      end
    end
    i32.const 0
    local.set $p1
    loop $L8
      local.get $p0
      i32.load offset=660
      local.set $l2
      local.get $l2
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I9
        local.get $l2
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 0
        i32.const 0
        call $j3070 ;; HighlightPlus.HighlightEffect$$SetHighlighted
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L8
      end
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    i32.const 7
    i32.eq
    if $I10
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store offset=32
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end)
