  (func $j22237 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32)
    i32.const 5140118
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 5140118
      i32.const 1
      i32.store8
    end
    block $B1
      i32.const 13
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      i32.load
      local.get $p0
      i32.load offset=384
      call $j951
      i32.eqz
      br_if $B1
      i32.const 0
      local.set $p2
      loop $L2
        local.get $p0
        i32.load offset=380
        i32.load offset=20
        i32.load offset=12
        local.get $l4
        i32.gt_s
        if $I3
          block $B4
            local.get $p1
            if $I5
              i32.const 0
              local.set $l3
              local.get $p1
              i32.load offset=8
              br_if $B4
            end
            i32.const 1
            local.set $l3
          end
          block $B6
            local.get $l3
            i32.eqz
            if $I7
              local.get $p0
              i32.load offset=380
              i32.load offset=20
              local.get $l4
              i32.const 3
              i32.shl
              i32.add
              i32.const 16
              i32.add
              i32.load
              local.get $p1
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              i32.eqz
              br_if $B6
            end
            local.get $p0
            i32.load offset=380
            i32.load offset=20
            local.get $l4
            i32.const 3
            i32.shl
            i32.add
            i32.const 16
            i32.add
            i32.load
            local.set $l5
            i32.const 0
            local.set $p2
            i32.const 0
            local.set $l3
            loop $L8
              i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
              i32.load
              drop
              local.get $p2
              local.get $p0
              i32.load offset=152
              i32.load offset=12
              i32.lt_s
              if $I9
                local.get $l3
                i32.const 1
                i32.add
                local.get $l3
                local.get $p0
                i32.load offset=152
                local.get $p2
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.load offset=12
                local.get $l5
                i32.const 0
                call $j949 ;; System.String$$op_Equality
                select
                local.set $l3
                local.get $p2
                i32.const 1
                i32.add
                local.set $p2
                br $L8
              end
            end
            local.get $p0
            i32.load offset=380
            i32.load offset=20
            local.get $l4
            i32.const 3
            i32.shl
            i32.add
            i32.const 16
            i32.add
            local.get $l3
            i32.store offset=4
            i32.const 1
            local.set $p2
          end
          local.get $l4
          i32.const 1
          i32.add
          local.set $l4
          br $L2
        end
      end
      local.get $p2
      i32.const 1
      i32.and
      i32.eqz
      br_if $B1
      i32.const 14
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      i32.load
      local.get $p0
      i32.load offset=384
      call $j1098
    end)
