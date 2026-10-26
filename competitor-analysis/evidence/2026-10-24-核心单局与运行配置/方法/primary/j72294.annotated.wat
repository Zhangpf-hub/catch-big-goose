  (func $j72294 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140336
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3983236 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Add()
      call $j922
      i32.const 3983244 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.ContainsKey()
      call $j922
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4125712 ;; 获取热更数据配置成功 
      call $j922
      i32.const 4125924 ;; 表重合
      call $j922
      i32.const 5140336
      i32.const 1
      i32.store8
    end
    i32.const 4125712 ;; 获取热更数据配置成功 
    i32.load
    local.get $p0
    i32.load offset=12
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.set $p2
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i32.const 0
    call $j1051 ;; UnityEngine.Debug$$Log
    i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j1163 ;; LitJson.JsonMapper$$ToJson
    local.set $p1
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j1600 ;; NetInitManager$$CanShowSEventDetail
    if $I1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    local.get $p0
    local.get $p1
    local.get $p0
    call $j38169 ;; ServerFileCreate$$ParseHotFixScriptable
    local.set $p1
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    local.get $p0
    i32.load offset=12
    i32.const 3983244 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.ContainsKey()
    i32.load
    call $j1040
    local.set $p2
    block $B2
      local.get $p1
      if $I3
        local.get $p2
        i32.eqz
        if $I4
          i32.const 3961880 ;; ServerFileCreate_TypeInfo
          i32.load
          call $j923
          i32.const 3961880 ;; ServerFileCreate_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          local.get $p0
          i32.load offset=12
          local.get $p1
          i32.const 3983236 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Add()
          i32.load
          call $j953
          br $B2
        end
        local.get $p0
        i32.load offset=12
        i32.const 4125924 ;; 表重合
        i32.load
        i32.const 0
        call $j962 ;; System.String$$Concat
        local.set $p1
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
        br $B2
      end
      local.get $p2
      i32.eqz
      if $I5
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        local.get $p0
        i32.load offset=12
        local.get $p0
        i32.load offset=8
        i32.load offset=12
        i32.const 3983236 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Add()
        i32.load
        call $j953
        br $B2
      end
      local.get $p0
      i32.load offset=12
      i32.const 4125924 ;; 表重合
      i32.load
      i32.const 0
      call $j962 ;; System.String$$Concat
      local.set $p1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end
    local.get $p0
    i32.load offset=16
    i32.const 1
    i32.store8 offset=12)
