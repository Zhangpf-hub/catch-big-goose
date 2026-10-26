  (func $j14626 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140135
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3986940 ;; Method$System.Collections.Generic.Dictionary<ToolType, int>.get_Item()
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
      call $j922
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3964096 ;; UIDebugPop_TypeInfo
      call $j922
      i32.const 4124308 ;; 没有可以丢回的物品
      call $j922
      i32.const 4124988 ;; 空位不足
      call $j922
      i32.const 4123108 ;; 放置栏不能没有物品
      call $j922
      i32.const 4124384 ;; 没有足够的物体可以消除
      call $j922
      i32.const 4120436 ;; 使用次数已达上限
      call $j922
      i32.const 5140135
      i32.const 1
      i32.store8
    end
    i32.const 3958084 ;; LevelToolMa_TypeInfo
    i32.load
    call $j923
    local.get $l3
    i32.const 8
    i32.add
    i32.const 0
    call $j43480 ;; LevelToolMa$$GetToolInfo
    block $B1
      block $B2
        block $B3
          local.get $l3
          i32.load offset=8
          local.get $p1
          i32.const 3986940 ;; Method$System.Collections.Generic.Dictionary<ToolType, int>.get_Item()
          i32.load
          call $j1068
          i32.const 0
          i32.gt_s
          br_if $B3
          i32.const 3964096 ;; UIDebugPop_TypeInfo
          i32.load
          i32.load offset=92
          i32.load8_u offset=8
          br_if $B3
          i32.const 4120436 ;; 使用次数已达上限
          local.set $p0
          br $B2
        end
        i32.const 1
        local.set $p2
        block $B4
          block $B5
            block $B6
              block $B7
                local.get $p1
                br_table $B6 $B5 $B1 $B1 $B1 $B4 $B7
              end
              local.get $p1
              i32.const 10
              i32.ne
              br_if $B1
            end
            local.get $p0
            i32.const 1
            local.get $p0
            call $j10884 ;; LevelManager$$GetContentCount
            i32.const 1
            i32.ge_s
            br_if $B1
            i32.const 4124308 ;; 没有可以丢回的物品
            local.set $p0
            br $B2
          end
          i32.const 0
          local.set $p2
          local.get $p0
          i32.const 1
          local.get $p0
          call $j10884 ;; LevelManager$$GetContentCount
          i32.const 0
          i32.le_s
          if $I8
            local.get $p0
            i32.const 1
            local.get $p0
            call $j10884 ;; LevelManager$$GetContentCount
            i32.const 1
            i32.ge_s
            br_if $B1
            i32.const 4123108 ;; 放置栏不能没有物品
            local.set $p0
            br $B2
          end
          i32.const 1
          local.set $p2
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
          i32.load
          drop
          local.get $p0
          i32.load offset=148
          i32.load offset=12
          local.get $p0
          i32.load offset=144
          i32.load offset=12
          i32.const 1
          i32.sub
          i32.ne
          br_if $B1
          local.get $p0
          i32.load offset=148
          i32.const 0
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.load offset=12
          local.set $p1
          loop $L9
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $p2
            local.get $p0
            i32.load offset=148
            i32.load offset=12
            i32.lt_s
            if $I10
              local.get $p1
              local.get $p0
              i32.load offset=148
              local.get $p2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              if $I11
                i32.const 1
                local.set $p2
                br $B1
              end
              local.get $p0
              i32.load offset=148
              local.get $p2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              local.set $p1
              local.get $p2
              i32.const 1
              i32.add
              local.set $p2
              br $L9
            end
          end
          i32.const 4124988 ;; 空位不足
          local.set $p0
          br $B2
        end
        local.get $p0
        i32.const 1
        local.get $p0
        call $j22246 ;; LevelManager$$GetObjHasThree
        local.set $p0
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        local.get $p0
        i32.load offset=12
        br_if $B1
        i32.const 4124384 ;; 没有足够的物体可以消除
        local.set $p0
      end
      i32.const 0
      local.set $p2
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 600
      local.get $p0
      i32.load
      i32.const 0
      call $j1145 ;; Kunpo.KUIManager$$OpenATip
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p2
    return)
