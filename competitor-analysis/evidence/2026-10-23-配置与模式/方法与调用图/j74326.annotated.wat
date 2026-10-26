  (func $j74326 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32)
    i32.const 5127079
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
      call $j922
      i32.const 4003056 ;; Method$System.Collections.Generic.List<ObjectUnit>.RemoveAt()
      call $j922
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      call $j922
      i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 4120132 ;; 仅剩一个空位
      call $j922
      i32.const 5127079
      i32.const 1
      i32.store8
    end
    i32.const -1
    local.set $p1
    block $B1
      block $B2
        block $B3
          local.get $p0
          i32.load offset=8
          br_table $B3 $B2 $B1
        end
        local.get $p0
        i32.load offset=20
        local.set $l3
        local.get $p0
        i32.const -1
        i32.store offset=8
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.load offset=16
        i32.const 1
        i32.eq
        local.set $p1
        local.get $l3
        i32.const 140
        i32.const 156
        local.get $p1
        select
        i32.add
        i32.load
        local.set $l6
        local.get $l3
        i32.const 148
        i32.const 164
        local.get $p1
        select
        i32.add
        i32.load
        local.set $l5
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=28
        local.set $l7
        i32.const 1
        local.set $l2
        i32.const 1
        local.set $l4
        loop $L4
          block $B5
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $l2
            local.get $l5
            i32.load offset=12
            i32.ge_s
            br_if $B5
            i32.const 1
            local.set $p1
            block $B6
              local.get $l5
              local.get $l2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              local.get $l5
              local.get $l2
              i32.const 1
              i32.sub
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              i32.const 0
              call $j949 ;; System.String$$op_Equality
              i32.eqz
              br_if $B6
              local.get $l4
              i32.const 1
              i32.add
              local.set $p1
              local.get $p1
              i32.const 3
              i32.ne
              br_if $B6
              local.get $l3
              local.get $l5
              local.get $l2
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.load offset=12
              i32.const 0
              call $j43531 ;; LevelManager$$GetTriple
              i32.const 3951356 ;; ActionManager_TypeInfo
              i32.load
              call $j923
              i32.const 3951356 ;; ActionManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=232
              local.set $p1
              local.get $p1
              if $I7
                local.get $l5
                local.get $l2
                i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                i32.load
                call $j947
                i32.load offset=12
                local.set $l4
                local.get $p1
                i32.load offset=32
                local.get $l4
                local.get $p1
                i32.load offset=20
                local.get $p1
                i32.load offset=12
                global.set $__wasm_split_waitTableId
                global.get $__wasm_split_waitTableId
                call_indirect $primary.table (type $t2)
              end
              i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
              i32.load
              call $j924
              local.set $l4
              local.get $l4
              i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
              i32.load
              call $j965
              i32.const 0
              local.set $p1
              loop $L8
                local.get $p1
                i32.const 3
                i32.lt_s
                if $I9
                  local.get $l6
                  local.get $l5
                  local.get $l2
                  local.get $p1
                  i32.sub
                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                  i32.load
                  call $j947
                  i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
                  i32.load
                  call $j1387
                  drop
                  local.get $l4
                  local.get $l5
                  local.get $l2
                  local.get $p1
                  i32.sub
                  i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
                  i32.load
                  call $j947
                  i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
                  i32.load
                  call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
                  local.get $l5
                  local.get $l2
                  local.get $p1
                  i32.sub
                  i32.const 4003056 ;; Method$System.Collections.Generic.List<ObjectUnit>.RemoveAt()
                  i32.load
                  call $j1330
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
              block $B10
                i32.const 0
                call $j6451 ;; LevelManager$$CanUseNewAnim
                if $I11
                  local.get $l3
                  i32.load offset=612
                  local.get $l4
                  local.get $p0
                  f32.load offset=24
                  local.get $p0
                  i32.load offset=16
                  local.get $l2
                  call $j43498 ;; LevelObjAnimManager$$CombieObj
                  local.get $l3
                  local.get $l4
                  local.get $l7
                  local.get $p0
                  i32.load offset=16
                  local.get $p0
                  f32.load offset=24
                  i32.const 0
                  call $j22252 ;; LevelManager$$DestroyAnim
                  local.set $p1
                  br $B10
                end
                local.get $l3
                local.get $l4
                local.get $l7
                local.get $p0
                i32.load offset=16
                f32.const 0x0p+0 (;=0;)
                i32.const 0
                call $j22252 ;; LevelManager$$DestroyAnim
                local.set $p1
              end
              local.get $l3
              local.get $p1
              i32.const 0
              call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
              drop
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3
              local.set $l4
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              br_if $B5
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=28
              i32.const 2
              i32.ne
              br_if $B5
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              i32.const 5142651
              i32.load8_u
              i32.eqz
              if $I12
                i32.const 3959288 ;; NetDataManager_TypeInfo
                call $j922
                i32.const 5142651
                i32.const 1
                i32.store8
              end
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=32
              i32.load offset=36
              i32.load offset=8
              i32.const 0
              i32.gt_s
              br_if $B5
              local.get $l3
              i32.load offset=204
              i32.const 1
              i32.add
              local.set $l2
              local.get $l3
              local.get $l2
              i32.store offset=204
              block $B13
                local.get $l2
                i32.const 10
                i32.le_s
                if $I14
                  block $B15
                    local.get $l2
                    i32.const 1
                    i32.sub
                    i32.const 2
                    i32.lt_u
                    br_if $B15
                    local.get $l2
                    i32.const 5
                    i32.eq
                    br_if $B15
                    local.get $l2
                    i32.const 10
                    i32.ne
                    br_if $B5
                  end
                  local.get $l3
                  i32.load offset=204
                  local.set $l2
                  br $B13
                end
                local.get $l2
                i32.const 50
                i32.le_s
                if $I16
                  local.get $l2
                  i32.const 20
                  i32.eq
                  br_if $B13
                  local.get $l2
                  i32.const 50
                  i32.eq
                  br_if $B13
                  br $B5
                end
                local.get $l2
                i32.const 200
                i32.eq
                br_if $B13
                local.get $l2
                i32.const 100
                i32.ne
                br_if $B5
              end
              local.get $l2
              i32.const 0
              call $j13414 ;; ThinkingManager$$LosePlayerMatchCount
              br $B5
            end
            local.get $l2
            i32.const 1
            i32.add
            local.set $l2
            local.get $p1
            local.set $l4
            br $L4
          end
        end
        i32.const 3959844 ;; PVPManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j4671 ;; PVPManager$$IsInPVPGaming
        if $I17
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $l5
          i32.load offset=12
          local.set $p1
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $l6
          i32.load offset=12
          local.set $l2
          i32.const 3959844 ;; PVPManager_TypeInfo
          i32.load
          call $j923
          i32.const 1
          local.get $l4
          i32.const 3
          i32.eq
          local.get $p1
          local.get $l2
          i32.const 0
          call $j21434 ;; PVPManager$$SyncSendSelfBaseAction
        end
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
        i32.load
        drop
        block $B18
          local.get $l5
          i32.load offset=12
          local.get $l3
          i32.load offset=144
          i32.load offset=12
          i32.const 1
          i32.sub
          i32.ne
          br_if $B18
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          block $B19
            i32.const 0
            call $j2087 ;; LevelManager$$HasTwoPlayer
            i32.eqz
            if $I20
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 600
              local.set $p1
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=28
              i32.const 1
              i32.ne
              br_if $B19
              br $B18
            end
            i32.const 602
            i32.const 603
            local.get $p0
            i32.load offset=16
            i32.const 1
            i32.eq
            select
            local.set $p1
          end
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 4120132 ;; 仅剩一个空位
          i32.load
          f32.const 0x1p+0 (;=1;)
          f32.const 0x0p+0 (;=0;)
          i32.const 0
          call $j1952 ;; Kunpo.KUIManager$$OpenATip
        end
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        i32.const 4005768 ;; Method$System.Collections.Generic.List<Transform>.get_Count()
        i32.load
        drop
        block $B21
          local.get $l5
          i32.load offset=12
          local.get $l3
          i32.load offset=144
          i32.load offset=12
          i32.lt_s
          br_if $B21
          i32.const 3959844 ;; PVPManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j4671 ;; PVPManager$$IsInPVPGaming
          if $I22
            i32.const 3959844 ;; PVPManager_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j41320 ;; PVPManager$$FullContent
            br $B21
          end
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j2087 ;; LevelManager$$HasTwoPlayer
          i32.eqz
          if $I23
            local.get $l3
            i32.const 0
            i32.const 0
            call $j14618 ;; LevelManager$$PrepareLose
            br $B21
          end
          local.get $l3
          i32.const 2
          i32.const 2
          i32.const 1
          local.get $p0
          i32.load offset=16
          i32.const 1
          i32.eq
          select
          i32.const 0
          call $j14627 ;; LevelManager$$BattleLose
        end
        i32.const 3951296 ;; ABPackManager_TypeInfo
        i32.load
        call $j923
        block $B24
          i32.const 0
          call $j6690 ;; ABPackManager$$get_NewPlayerGuideABType
          i32.const 1
          i32.eq
          if $I25
            local.get $l4
            i32.const 3
            i32.eq
            local.set $p1
            local.get $l3
            i32.const 1
            i32.const 3
            i32.const 2
            local.get $p1
            select
            i32.const 0
            call $j10879 ;; LevelManager$$NewGuide
            local.get $l3
            local.get $p1
            i32.const 0
            call $j43520 ;; LevelManager$$NewGuideClickObj
            br $B24
          end
          local.get $l3
          local.get $l4
          i32.const 3
          i32.eq
          i32.const 0
          call $j43505 ;; LevelManager$$TeachClickObj
        end
        local.get $p0
        i32.const 0
        i32.store offset=12
        i32.const 1
        local.set $p1
        i32.const 1
        local.set $l2
      end
      local.get $p0
      local.get $p1
      i32.store offset=8
    end
    local.get $l2
    return)
