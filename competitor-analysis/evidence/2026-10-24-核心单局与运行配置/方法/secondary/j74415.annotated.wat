  (func $j74415 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32)
    i32.const 5127083
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3996236 ;; Method$Kunpo.KFakeRandom<string>.AddItem()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3996240 ;; Method$Kunpo.KFakeRandom<string>.Roll()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3996232 ;; Method$Kunpo.KFakeRandom<string>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3946140 ;; Kunpo.KFakeRandom<string>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4121676 ;; 娃娃机道具配置错误
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5127083
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=16
    local.set $l4
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  local.get $p0
                  i32.load offset=8
                  br_table $B7 $B5 $B6 $B1
                end
                local.get $p0
                i32.const -1
                i32.store offset=8
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                local.get $p0
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=28
                i32.store offset=20
                i32.const 3953096 ;; ConfigManager_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                local.get $p0
                i32.const 11
                i32.const 0
                i32.const 16902
                call_indirect $primary.table (type $t2)
                i32.store offset=24
                i32.const 3959844 ;; PVPManager_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                i32.const 0
                i32.const 19270
                call_indirect $primary.table (type $t1)
                i32.eqz
                br_if $B3
                i32.const 0
                local.set $p1
                i32.const 3959844 ;; PVPManager_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                i32.const 3000101
                i32.const 0
                i32.const 19319
                call_indirect $primary.table (type $t2)
                local.set $l2
                block $B8
                  local.get $l2
                  i32.eqz
                  if $I9
                    i32.const 40
                    i32.load
                    local.set $p1
                    br $B8
                  end
                  local.get $l2
                  i32.load offset=40
                  local.set $l2
                  local.get $l2
                  i32.eqz
                  br_if $B8
                  local.get $l2
                  i32.load offset=12
                  i32.const 1
                  i32.ge_s
                  br_if $B4
                  local.get $l2
                  local.set $p1
                end
                i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                local.get $p1
                i32.const 0
                i32.const 5965
                call_indirect $primary.table (type $t2)
                i32.const 0
                i32.const 7400
                call_indirect $primary.table (type $t3)
                i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
                i32.load
                i32.const 735
                call_indirect $primary.table (type $t0)
                i32.const 4121676 ;; 娃娃机道具配置错误
                i32.load
                i32.const 0
                i32.const 5660
                call_indirect $primary.table (type $t3)
                br $B3
              end
              local.get $p0
              i32.const -1
              i32.store offset=8
              local.get $l4
              local.get $p0
              i32.load offset=20
              i32.const 1
              i32.const 0
              i32.const 17863
              call_indirect $primary.table (type $t6)
              local.get $p0
              i32.load offset=28
              i32.const 1
              i32.add
              local.set $l5
              br $B3
            end
            local.get $p0
            i32.const -1
            i32.store offset=8
            i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
            i32.load
            i32.const 137618
            call_indirect $primary.table (type $t1)
            local.set $p1
            local.get $p1
            f32.const 0x1p-1 (;=0.5;)
            f32.store offset=8
            local.get $p0
            local.get $p1
            i32.store offset=12
            i32.const 2
            local.set $p1
            br $B2
          end
          local.get $l2
          i32.load offset=16
          local.get $p0
          i32.const 24
          i32.add
          i32.const 0
          i32.const 2331
          call_indirect $primary.table (type $t5)
          drop
        end
        local.get $p0
        local.get $l5
        i32.store offset=28
        local.get $l5
        local.get $p0
        i32.load offset=24
        i32.ge_s
        br_if $B1
        local.get $l4
        i32.const 0
        i32.const 0
        i32.const 17895
        call_indirect $primary.table (type $t5)
        local.set $p1
        local.get $l4
        i32.const 0
        i32.const 0
        i32.const 17896
        call_indirect $primary.table (type $t5)
        local.set $l5
        local.get $l5
        local.set $l2
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        local.get $l2
        i32.load offset=12
        i32.eqz
        br_if $B1
        i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $l2
        local.get $l2
        i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
        i32.load
        i32.const 9529
        call_indirect $primary.table (type $t3)
        loop $L10
          i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
          i32.load
          drop
          local.get $l3
          local.get $p1
          i32.load offset=12
          i32.lt_s
          if $I11
            local.get $l5
            local.get $p1
            local.get $l3
            i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
            i32.load
            i32.const 10930
            call_indirect $primary.table (type $t5)
            i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
            i32.load
            i32.const 5419
            call_indirect $primary.table (type $t5)
            if $I12
              local.get $l2
              local.get $p1
              local.get $l3
              i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
              i32.load
              i32.const 101753
              call_indirect $primary.table (type $t4)
            end
            local.get $l3
            i32.const 1
            i32.add
            local.set $l3
            br $L10
          end
        end
        i32.const 3946140 ;; Kunpo.KFakeRandom<string>_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $l6
        local.get $l6
        i32.const 3996232 ;; Method$Kunpo.KFakeRandom<string>..ctor()
        i32.load
        i32.const 137984
        call_indirect $primary.table (type $t3)
        local.get $l2
        local.get $l5
        local.get $l2
        select
        local.set $p1
        i32.const 0
        local.set $l3
        loop $L13
          block $B14
            i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
            i32.load
            drop
            local.get $p1
            i32.load offset=12
            local.set $l2
            local.get $l3
            i32.const 4
            i32.gt_s
            br_if $B14
            local.get $l3
            local.get $l2
            i32.ge_s
            br_if $B14
            i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
            i32.load
            drop
            local.get $l6
            local.get $p1
            i32.load offset=12
            local.get $l3
            i32.sub
            f32.convert_i32_s
            f32.const 0x1.99999ap-4 (;=0.1;)
            f32.mul
            f32.const 0x1p+0 (;=1;)
            f32.add
            local.get $p1
            local.get $l3
            i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
            i32.load
            i32.const 10930
            call_indirect $primary.table (type $t5)
            i32.const 3996236 ;; Method$Kunpo.KFakeRandom<string>.AddItem()
            i32.load
            i32.const 5700
            call_indirect $primary.table (type $t33)
            local.get $l3
            i32.const 1
            i32.add
            local.set $l3
            br $L13
          end
        end
        local.get $l6
        i32.const 3996240 ;; Method$Kunpo.KFakeRandom<string>.Roll()
        i32.load
        i32.const 138055
        call_indirect $primary.table (type $t2)
        local.set $l6
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $l4
        i32.load offset=152
        i32.load offset=12
        i32.const 1
        i32.sub
        local.set $l3
        i32.const 0
        local.set $l2
        loop $L15
          block $B16
            local.get $l3
            i32.const -1
            i32.le_s
            br_if $B16
            block $B17
              local.get $l4
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              i32.load offset=12
              local.get $l6
              i32.const 0
              i32.const 1023
              call_indirect $primary.table (type $t5)
              i32.eqz
              br_if $B17
              local.get $l4
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              i32.load8_u offset=19
              br_if $B17
              local.get $l4
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              local.set $p1
              i32.const 0
              local.set $l5
              block $B18
                local.get $p1
                i32.load8_u offset=16
                i32.eqz
                br_if $B18
                local.get $p1
                i32.load8_u offset=17
                br_if $B18
                local.get $p1
                i32.load8_u offset=92
                i32.const 0
                i32.ne
                local.set $l5
              end
              local.get $l5
              i32.eqz
              br_if $B17
              local.get $l4
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              local.set $p1
              local.get $p1
              i32.const 0
              local.get $l4
              f32.load offset=568
              local.get $l3
              i32.const 18208
              call_indirect $primary.table (type $t23)
              local.get $l4
              local.get $p1
              f32.const 0x1p-1 (;=0.5;)
              f32.const 0x1.99999ap-3 (;=0.2;)
              f32.const 0x1p+0 (;=1;)
              i32.const 0
              i32.const 17891
              call_indirect $primary.table (type $t89)
              local.get $l4
              i32.load offset=140
              local.get $p1
              i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
              i32.load
              i32.const 10690
              call_indirect $primary.table (type $t5)
              drop
              local.get $l4
              i32.load offset=152
              local.get $p1
              i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
              i32.load
              i32.const 10690
              call_indirect $primary.table (type $t5)
              drop
              local.get $l2
              i32.const 1
              i32.add
              local.set $l2
              local.get $l2
              i32.const 2
              i32.gt_s
              br_if $B16
            end
            local.get $l3
            i32.const 1
            i32.sub
            local.set $l3
            br $L15
          end
        end
        i32.const 3959844 ;; PVPManager_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 0
        i32.const 19270
        call_indirect $primary.table (type $t1)
        if $I19
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $l4
          i32.load offset=148
          i32.load offset=12
          local.set $p1
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $l4
          i32.load offset=140
          i32.load offset=12
          local.set $l2
          i32.const 3959844 ;; PVPManager_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 1
          i32.const 1
          local.get $p1
          local.get $l2
          i32.const 0
          i32.const 19292
          call_indirect $primary.table (type $t7)
        end
        i32.const 3965452 ;; UnityEngine.WaitForSeconds_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $p1
        local.get $p1
        f32.const 0x1p-1 (;=0.5;)
        f32.store offset=8
        local.get $p0
        local.get $p1
        i32.store offset=12
        i32.const 1
        local.set $p1
      end
      local.get $p0
      local.get $p1
      i32.store offset=8
      i32.const 1
      local.set $l3
    end
    local.get $l3
    return)
