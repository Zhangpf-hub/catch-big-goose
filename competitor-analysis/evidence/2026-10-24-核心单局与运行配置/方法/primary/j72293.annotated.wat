  (func $j72293 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140337
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3983236 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.Add()
      call $j922
      i32.const 3983244 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.ContainsKey()
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4125708 ;; 获取热更数据配置失败 
      call $j922
      i32.const 4125924 ;; 表重合
      call $j922
      i32.const 4125716 ;; 获取热更新数据
      call $j922
      i32.const 4121588 ;; 失败
      call $j922
      i32.const 5140337
      i32.const 1
      i32.store8
    end
    i32.const 4125716 ;; 获取热更新数据
    i32.load
    local.get $p0
    i32.load offset=12
    i32.const 4121588 ;; 失败
    i32.load
    i32.const 0
    call $j1011 ;; System.String$$Concat
    i32.const 0
    call $j2817 ;; ThinkingManager$$TestError
    i32.const 4125708 ;; 获取热更数据配置失败 
    i32.load
    local.get $p0
    i32.load offset=12
    i32.const 0
    call $j962 ;; System.String$$Concat
    local.set $p1
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j1050 ;; UnityEngine.Debug$$LogError
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.get $p0
      i32.load offset=12
      i32.const 3983244 ;; Method$System.Collections.Generic.Dictionary<string, List<HotFixData>>.ContainsKey()
      i32.load
      call $j1040
      i32.eqz
      if $I2
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
        br $B1
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
