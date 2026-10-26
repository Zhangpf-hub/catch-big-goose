  (func $j23326 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32)
    i32.const 5139964
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3937352 ;; UnityEngine.GameObject_var
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3963888 ;; System.Type_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4053984 ;; Method$EndlessLevelMa.<>c__DisplayClass20_0.<LoadLongLevel>b__0()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3968436 ;; EndlessLevelMa.<>c__DisplayClass20_0_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4120628 ;; 关卡列表数为0
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139964
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      block $B2
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load8_u offset=28
        if $I3
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.eq
          br_if $B2
        end
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        block $B4
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.ne
          br_if $B4
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          local.set $p2
          local.get $p0
          i32.eqz
          br_if $B4
          local.get $p2
          i32.load8_u offset=4
          i32.eqz
          br_if $B4
          local.get $p0
          i32.const 1
          i32.const 0
          i32.const 5294
          call_indirect $primary.table (type $t4)
        end
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 0
        i32.store8 offset=4
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.store offset=32
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p0
        i32.store offset=24
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        drop
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        i32.eqz
        br_if $B2
        i32.const 0
        local.set $p0
        i32.const 3968436 ;; EndlessLevelMa.<>c__DisplayClass20_0_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $l5
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 1
        i32.store8 offset=28
        i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $p2
        local.get $p2
        i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
        i32.load
        i32.const 9529
        call_indirect $primary.table (type $t3)
        i32.const 4001964 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Count()
        i32.load
        drop
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        i32.load offset=12
        i32.const 1
        i32.lt_s
        br_if $B1
        loop $L5
          block $B6
            i32.const 3954604 ;; EndlessLevelMa_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            i32.const 3954604 ;; EndlessLevelMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=8
            i32.const 0
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            i32.const 10930
            call_indirect $primary.table (type $t5)
            i32.load offset=24
            i32.load offset=12
            local.set $l4
            i32.const 3954604 ;; EndlessLevelMa_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            i32.const 3954604 ;; EndlessLevelMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=8
            i32.const 0
            i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
            i32.load
            i32.const 10930
            call_indirect $primary.table (type $t5)
            local.set $l3
            local.get $p0
            local.get $l4
            i32.ge_s
            br_if $B6
            local.get $l3
            i32.load offset=24
            local.get $p0
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            local.set $l3
            block $B7
              local.get $l3
              if $I8
                i32.const 0
                local.set $l4
                local.get $l3
                i32.load offset=8
                br_if $B7
              end
              i32.const 1
              local.set $l4
            end
            block $B9
              local.get $l4
              br_if $B9
              i32.const 3954604 ;; EndlessLevelMa_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              local.get $p2
              i32.const 3954604 ;; EndlessLevelMa_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=8
              i32.const 0
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              i32.load offset=24
              local.get $p0
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
              i32.load
              i32.const 5419
              call_indirect $primary.table (type $t5)
              br_if $B9
              i32.const 3954604 ;; EndlessLevelMa_TypeInfo
              i32.load
              i32.const 735
              call_indirect $primary.table (type $t0)
              local.get $p2
              i32.const 3954604 ;; EndlessLevelMa_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=8
              i32.const 0
              i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
              i32.load
              i32.const 10930
              call_indirect $primary.table (type $t5)
              i32.load offset=24
              local.get $p0
              i32.const 2
              i32.shl
              i32.add
              i32.load offset=16
              i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
              i32.load
              i32.const 101753
              call_indirect $primary.table (type $t4)
            end
            local.get $p0
            i32.const 1
            i32.add
            local.set $p0
            br $L5
          end
        end
        local.get $l3
        i32.load offset=64
        local.set $p0
        block $B10
          local.get $p0
          if $I11
            i32.const 0
            local.set $l3
            local.get $p0
            i32.load offset=8
            br_if $B10
          end
          i32.const 1
          local.set $l3
        end
        block $B12
          local.get $l3
          br_if $B12
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          local.get $p2
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=8
          i32.const 0
          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
          i32.load
          i32.const 10930
          call_indirect $primary.table (type $t5)
          i32.load offset=64
          i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
          i32.load
          i32.const 5419
          call_indirect $primary.table (type $t5)
          br_if $B12
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.const 735
          call_indirect $primary.table (type $t0)
          local.get $p2
          i32.const 3954604 ;; EndlessLevelMa_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=8
          i32.const 0
          i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
          i32.load
          i32.const 10930
          call_indirect $primary.table (type $t5)
          i32.load offset=64
          i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
          i32.load
          i32.const 101753
          call_indirect $primary.table (type $t4)
        end
        i32.const 3946412 ;; System.Collections.Generic.List<AssetLoadConfig>_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $l4
        local.get $l4
        i32.const 3998480 ;; Method$System.Collections.Generic.List<AssetLoadConfig>..ctor()
        i32.load
        i32.const 9529
        call_indirect $primary.table (type $t3)
        i32.const 0
        local.set $p0
        loop $L13
          i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
          i32.load
          drop
          local.get $p0
          local.get $p2
          i32.load offset=12
          i32.lt_s
          if $I14
            local.get $p2
            local.get $p0
            i32.const 4004944 ;; Method$System.Collections.Generic.List<string>.get_Item()
            i32.load
            i32.const 10930
            call_indirect $primary.table (type $t5)
            local.set $l6
            i32.const 3937352 ;; UnityEngine.GameObject_var
            i32.load
            local.set $l3
            i32.const 3963888 ;; System.Type_TypeInfo
            i32.load
            i32.const 735
            call_indirect $primary.table (type $t0)
            local.get $l3
            i32.const 0
            i32.const 918
            call_indirect $primary.table (type $t2)
            local.set $l7
            i32.const 3951796 ;; Kunpo.AssetLoadConfig_TypeInfo
            i32.load
            i32.const 137618
            call_indirect $primary.table (type $t1)
            local.set $l3
            local.get $l3
            i32.const 1
            i32.store8 offset=20
            local.get $l3
            i32.const 1
            i32.store8 offset=12
            local.get $l3
            local.get $l6
            i32.store offset=8
            local.get $l3
            local.get $l7
            i32.store offset=16
            local.get $l3
            i32.const 0
            i32.store8 offset=20
            local.get $l3
            i32.const 1
            i32.store8 offset=12
            local.get $l4
            local.get $l3
            i32.const 3998484 ;; Method$System.Collections.Generic.List<AssetLoadConfig>.Add()
            i32.load
            i32.const 101753
            call_indirect $primary.table (type $t4)
            local.get $p0
            i32.const 1
            i32.add
            local.set $p0
            br $L13
          end
        end
        i32.const 3951800 ;; Kunpo.AssetLoader_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $p0
        local.get $p0
        i32.const 0
        i32.const 5312
        call_indirect $primary.table (type $t3)
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        local.get $l5
        i32.const 3954604 ;; EndlessLevelMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.store offset=8
        i32.const 3939040 ;; System.Action<bool>_TypeInfo
        i32.load
        i32.const 137618
        call_indirect $primary.table (type $t1)
        local.set $p2
        local.get $p2
        local.get $l5
        i32.const 4053984 ;; Method$EndlessLevelMa.<>c__DisplayClass20_0.<LoadLongLevel>b__0()
        i32.load
        i32.const 0
        i32.const 9548
        call_indirect $primary.table (type $t6)
        local.get $p0
        local.get $l4
        local.get $p2
        local.get $p1
        i32.const 0
        i32.const 5313
        call_indirect $primary.table (type $t7)
      end
      return
    end
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 4120628 ;; 关卡列表数为0
    i32.load
    i32.const 0
    i32.const 5662
    call_indirect $primary.table (type $t3))
