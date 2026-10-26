  (func $j72048 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140490
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3985868 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Add()
      call $j922
      i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
      call $j922
      i32.const 3985888 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.set_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4121064 ;; 加载头像网络错误,userid=
      call $j922
      i32.const 4117256 ;; url=
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4069136 ;; 0
      call $j922
      i32.const 5140490
      i32.const 1
      i32.store8
    end
    block $B1
      block $B2
        local.get $p0
        i32.load offset=8
        i32.const 0
        call $j2903 ;; UnityEngine.Networking.UnityWebRequest$$get_result
        i32.const 3
        i32.ne
        if $I3
          local.get $p0
          i32.load offset=8
          i32.const 0
          call $j2903 ;; UnityEngine.Networking.UnityWebRequest$$get_result
          i32.const 2
          i32.ne
          br_if $B2
        end
        local.get $p0
        i32.load offset=12
        i32.const 4069136 ;; 0
        i32.load
        i32.const 0
        call $j1138 ;; System.String$$op_Inequality
        if $I4
          i32.const 4063796 ;; 
          i32.load
          local.set $p1
          i32.const 4121064 ;; 加载头像网络错误,userid=
          i32.load
          local.get $p0
          i32.load offset=12
          i32.const 4117256 ;; url=
          i32.load
          local.get $p0
          i32.load offset=16
          local.get $p1
          local.get $p1
          i32.const 0
          call $j1120 ;; GameManager$$StringAppend
          local.set $p1
          i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 0
          call $j1075 ;; UnityEngine.Debug$$LogWarning
          local.get $p0
          i32.load offset=8
          i32.const 0
          call $j1782 ;; UnityEngine.Networking.UnityWebRequest$$get_error
          i32.const 0
          i32.const 0
          call $j1648 ;; Kunpo.Debugger$$LogWarning
        end
        local.get $p0
        i32.load offset=20
        local.set $p1
        local.get $p1
        i32.eqz
        br_if $B1
        local.get $p1
        i32.const 0
        i32.const 0
        call $j2630
        br $B1
      end
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j23415 ;; UnityEngine.Networking.DownloadHandlerTexture$$GetContent
      local.set $p1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=40
      local.get $p0
      i32.load offset=12
      i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
      i32.load
      call $j1040
      i32.eqz
      if $I5
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=40
        local.get $p0
        i32.load offset=12
        i32.const 0
        i32.const 3985868 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Add()
        i32.load
        call $j953
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=40
      local.get $p0
      i32.load offset=12
      local.get $p1
      i32.const 3985888 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.set_Item()
      i32.load
      call $j1070
      local.get $p0
      i32.load offset=20
      local.set $p2
      local.get $p2
      i32.eqz
      br_if $B1
      local.get $p2
      i32.const 1
      local.get $p1
      call $j2630
    end
    local.get $p0
    i32.load offset=8
    i32.const 0
    call $j2011) ;; UnityEngine.Networking.UnityWebRequest$$Dispose
