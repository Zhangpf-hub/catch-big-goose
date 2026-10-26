  (func $j73527 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139821
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3982664 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>.TryGetValue()
      call $j922
      i32.const 4028412 ;; Method$JsonHelper.GetVal<string>()
      call $j922
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4124888 ;; 省份数据
      call $j922
      i32.const 4080320 ;; GetMultipleProvinceData Success 
      call $j922
      i32.const 4113528 ;; rank_tbs
      call $j922
      i32.const 4108408 ;; id
      call $j922
      i32.const 4124892 ;; 省份数据失败
      call $j922
      i32.const 4113524 ;; rank_tb
      call $j922
      i32.const 4080324 ;; GetMultipleProvinceData rank_tbs is null
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4125384 ;; 获取
      call $j922
      i32.const 4122664 ;; 成功获取
      call $j922
      i32.const 5139821
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 0
    i32.store offset=12
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j1600 ;; NetInitManager$$CanShowSEventDetail
    if $I1
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1163 ;; LitJson.JsonMapper$$ToJson
      local.set $p2
      i32.const 4080320 ;; GetMultipleProvinceData Success 
      i32.load
      local.get $p2
      i32.const 0
      call $j962 ;; System.String$$Concat
      i32.const 0
      i32.const 0
      call $j1221 ;; Kunpo.Debugger$$Log
    end
    block $B2
      local.get $p1
      i32.const 4113528 ;; rank_tbs
      i32.load
      i32.const 0
      call $j1273 ;; LitJson.JsonData$$ContainsKey
      if $I3
        local.get $p1
        i32.const 4113528 ;; rank_tbs
        i32.load
        i32.const 0
        call $j1155 ;; LitJson.JsonData$$get_Item
        local.set $l4
        i32.const 0
        local.set $p1
        loop $L4
          local.get $l4
          i32.const 0
          call $j1421 ;; LitJson.JsonData$$get_Count
          local.get $p1
          i32.le_s
          br_if $B2
          local.get $l4
          local.get $p1
          i32.const 0
          call $j1512 ;; LitJson.JsonData$$get_Item
          local.set $l3
          local.get $l3
          i32.const 4113524 ;; rank_tb
          i32.load
          i32.const 0
          call $j1155 ;; LitJson.JsonData$$get_Item
          drop
          local.get $l3
          i32.const 4108408 ;; id
          i32.load
          i32.const 0
          i32.const 4028412 ;; Method$JsonHelper.GetVal<string>()
          i32.load
          call $j1267
          local.set $p2
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=88
          local.get $p2
          local.get $p0
          i32.const 12
          i32.add
          i32.const 3982664 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>.TryGetValue()
          i32.load
          call $j1052
          drop
          i32.const 3959304 ;; NetInitManager_TypeInfo
          i32.load
          call $j923
          block $B5
            local.get $p2
            local.get $l3
            i32.const 0
            call $j14370 ;; NetInitManager$$BuildServerProvinceData
            if $I6
              i32.const 3959304 ;; NetInitManager_TypeInfo
              i32.load
              call $j923
              i32.const 0
              call $j1600 ;; NetInitManager$$CanShowSEventDetail
              if $I7
                local.get $p2
                local.set $l3
                i32.const 4063796 ;; 
                i32.load
                local.set $p2
                i32.const 4122664 ;; 成功获取
                i32.load
                local.get $l3
                i32.const 4124888 ;; 省份数据
                i32.load
                local.get $p2
                local.get $p2
                local.get $p2
                i32.const 0
                call $j1120 ;; GameManager$$StringAppend
                i32.const 0
                call $j1441 ;; UnityEngine.MonoBehaviour$$print
              end
              local.get $p0
              i32.load offset=12
              local.set $p2
              local.get $p2
              i32.eqz
              br_if $B5
              local.get $p2
              i32.const 1
              i32.const 0
              call $j1184
              br $B5
            end
            local.get $p2
            local.set $l3
            i32.const 4063796 ;; 
            i32.load
            local.set $p2
            i32.const 4125384 ;; 获取
            i32.load
            local.get $l3
            i32.const 4124892 ;; 省份数据失败
            i32.load
            local.get $p2
            local.get $p2
            local.get $p2
            i32.const 0
            call $j1120 ;; GameManager$$StringAppend
            i32.const 0
            call $j1441 ;; UnityEngine.MonoBehaviour$$print
            local.get $p0
            i32.load offset=12
            local.set $p2
            local.get $p2
            i32.eqz
            br_if $B5
            local.get $p2
            i32.const 0
            i32.const 0
            call $j1184
          end
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L4
        end
        unreachable
      end
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4080324 ;; GetMultipleProvinceData rank_tbs is null
      i32.load
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
