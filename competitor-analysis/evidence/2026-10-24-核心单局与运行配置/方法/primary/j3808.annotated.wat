  (func $j3808 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    i32.const 5139646
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3985608 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.ContainsKey()
      call $j922
      i32.const 3985612 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.get_Item()
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4123172 ;; 无
      call $j922
      i32.const 4120988 ;; 副本窗口为空
      call $j922
      i32.const 4120984 ;; 副本的窗口
      call $j922
      i32.const 5139646
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      local.get $p0
      call $j5052 ;; SpLevelManager$$IsCurSpLevelSign
      i32.eqz
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p0
      i32.store offset=4
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      drop
      block $B2
        local.get $p2
        i32.eqz
        br_if $B2
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 103
        i32.const 0
        call $j1327 ;; Kunpo.KUIManager$$CloseUI
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load offset=48
        local.get $p0
        i32.const 3985608 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.ContainsKey()
        i32.load
        call $j1040
        if $I3
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.load offset=48
          local.get $p0
          i32.const 3985612 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.get_Item()
          i32.load
          call $j1033
          local.set $p2
          local.get $p2
          if $I4
            local.get $p2
            i32.load offset=8
            local.set $p0
            i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
            i32.load
            call $j923
            local.get $p0
            i32.const 0
            call $j1327 ;; Kunpo.KUIManager$$CloseUI
            br $B2
          end
          local.get $p0
          i32.const 4120988 ;; 副本窗口为空
          i32.load
          i32.const 0
          call $j962 ;; System.String$$Concat
          local.set $p0
          i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 0
          call $j1075 ;; UnityEngine.Debug$$LogWarning
          br $B2
        end
        i32.const 4123172 ;; 无
        i32.load
        local.get $p0
        i32.const 4120984 ;; 副本的窗口
        i32.load
        i32.const 0
        call $j1011 ;; System.String$$Concat
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p0
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p1
      i32.const 6
      i32.const 1
      local.get $p3
      i32.const 0
      call $j2956 ;; LevelManager$$StartGame
    end)
