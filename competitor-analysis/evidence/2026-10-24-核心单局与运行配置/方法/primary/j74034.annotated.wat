  (func $j74034 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i64) (local $l8 f32) (local $l9 f32) (local $l10 f32) (local $l11 f32)
    global.get $primary.global$0
    i32.const 192
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127076
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3963584 ;; TimerManager_TypeInfo
      call $j922
      i32.const 5127076
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $l6
    local.get $l6
    i32.const 2
    i32.le_u
    if $I1
      local.get $p0
      i32.load offset=16
      local.set $l2
      local.get $p0
      i32.const -1
      i32.store offset=8
      block $B2
        local.get $l2
        i32.load8_u offset=56
        if $I3
          i32.const 3963584 ;; TimerManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 3963584 ;; TimerManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=8
          i32.store offset=12
          i32.const 1
          local.set $l2
          br $B2
        end
        local.get $l2
        i32.const 0
        call $j4380 ;; LevelManager$$CheckObjMaxHeight
        loop $L4
          i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
          i32.load
          drop
          local.get $l3
          local.get $l2
          i32.load offset=152
          i32.load offset=12
          i32.lt_s
          if $I5
            local.get $p1
            i32.const 176
            i32.add
            local.get $l2
            i32.load offset=152
            local.get $l3
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            i32.const 0
            call $j979 ;; UnityEngine.Component$$get_transform
            i32.const 0
            call $j1062 ;; UnityEngine.Transform$$get_position
            local.get $p1
            i32.load offset=184
            local.set $l4
            local.get $p1
            local.get $l4
            i32.store offset=168
            local.get $p1
            local.get $l4
            i32.store offset=40
            local.get $p1
            i64.load offset=176
            local.set $l7
            local.get $p1
            local.get $l7
            i64.store offset=160
            local.get $p1
            local.get $l7
            i64.store offset=32
            local.get $l2
            local.get $p1
            i32.const 32
            i32.add
            i32.const 1
            i32.const 0
            call $j22243 ;; LevelManager$$HasObjLose
            if $I6
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l4
              local.get $p1
              i32.const 176
              i32.add
              local.get $l2
              i32.const 1
              i32.const 0
              call $j4699 ;; LevelManager$$ThrowPos
              local.get $p1
              i32.load offset=184
              local.set $l5
              local.get $p1
              local.get $l5
              i32.store offset=152
              local.get $p1
              local.get $l5
              i32.store offset=24
              local.get $p1
              i64.load offset=176
              local.set $l7
              local.get $p1
              local.get $l7
              i64.store offset=144
              local.get $p1
              local.get $l7
              i64.store offset=16
              local.get $l4
              local.get $p1
              i32.const 16
              i32.add
              i32.const 0
              call $j1289 ;; UnityEngine.Transform$$set_position
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              local.get $p1
              call $j21511 ;; ObjectUnit$$DeletVel
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 1
              local.get $p1
              call $j7288 ;; ObjectUnit$$SetVisible
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              i32.const 0
              local.get $p1
              call $j4344 ;; ObjectUnit$$HideRigid
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l5
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I7
                i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                call $j922
                i32.const 5142879
                i32.const 1
                i32.store8
              end
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.load
              i32.load offset=92
              local.set $l4
              local.get $l4
              f32.load offset=20
              local.set $l9
              local.get $l4
              f32.load offset=16
              local.set $l10
              local.get $l4
              f32.load offset=12
              local.set $l11
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              f32.load offset=128
              local.set $l8
              local.get $p1
              local.get $l9
              local.get $l8
              f32.mul
              f32.store offset=136
              local.get $p1
              local.get $p1
              i32.load offset=136
              i32.store offset=8
              local.get $p1
              local.get $l10
              local.get $l8
              f32.mul
              f32.store offset=132
              local.get $p1
              local.get $l11
              local.get $l8
              f32.mul
              f32.store offset=128
              local.get $p1
              local.get $p1
              i64.load offset=128
              i64.store
              local.get $l5
              local.get $p1
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
            end
            local.get $l3
            i32.const 1
            i32.add
            local.set $l3
            br $L4
          end
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        block $B8
          i32.const 0
          call $j2087 ;; LevelManager$$HasTwoPlayer
          i32.eqz
          br_if $B8
          i32.const 0
          local.set $l3
          loop $L9
            i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
            i32.load
            drop
            local.get $l3
            local.get $l2
            i32.load offset=168
            i32.load offset=12
            i32.ge_s
            br_if $B8
            local.get $p1
            i32.const 176
            i32.add
            local.get $l2
            i32.load offset=168
            local.get $l3
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            i32.const 0
            call $j979 ;; UnityEngine.Component$$get_transform
            i32.const 0
            call $j1062 ;; UnityEngine.Transform$$get_position
            local.get $p1
            i32.load offset=184
            local.set $l4
            local.get $p1
            local.get $l4
            i32.store offset=120
            local.get $p1
            local.get $l4
            i32.store offset=88
            local.get $p1
            i64.load offset=176
            local.set $l7
            local.get $p1
            local.get $l7
            i64.store offset=112
            local.get $p1
            local.get $l7
            i64.store offset=80
            local.get $l2
            local.get $p1
            i32.const 80
            i32.add
            i32.const 2
            i32.const 0
            call $j22243 ;; LevelManager$$HasObjLose
            if $I10
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l4
              local.get $p1
              i32.const 176
              i32.add
              local.get $l2
              i32.const 2
              i32.const 0
              call $j4699 ;; LevelManager$$ThrowPos
              local.get $p1
              i32.load offset=184
              local.set $l5
              local.get $p1
              local.get $l5
              i32.store offset=104
              local.get $p1
              local.get $l5
              i32.store offset=72
              local.get $p1
              i64.load offset=176
              local.set $l7
              local.get $p1
              local.get $l7
              i64.store offset=96
              local.get $p1
              local.get $l7
              i64.store offset=64
              local.get $l4
              local.get $p1
              i32.const -64
              i32.sub
              i32.const 0
              call $j1289 ;; UnityEngine.Transform$$set_position
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              local.get $p1
              call $j21511 ;; ObjectUnit$$DeletVel
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 1
              local.get $p1
              call $j7288 ;; ObjectUnit$$SetVisible
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              i32.const 0
              local.get $p1
              call $j4344 ;; ObjectUnit$$HideRigid
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l4
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I11
                i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
                call $j922
                i32.const 5142879
                i32.const 1
                i32.store8
              end
              i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
              i32.load
              i32.load offset=92
              local.set $l5
              local.get $p1
              local.get $l5
              i32.load offset=20
              i32.store offset=56
              local.get $p1
              local.get $l5
              i32.load offset=12
              i64.extend_i32_u
              local.get $l5
              i32.load offset=16
              i64.extend_i32_u
              i64.const 32
              i64.shl
              i64.or
              i64.store offset=48
              local.get $l4
              local.get $p1
              i32.const 48
              i32.add
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
            end
            local.get $l3
            i32.const 1
            i32.add
            local.set $l3
            br $L9
          end
          unreachable
        end
        i32.const 3963584 ;; TimerManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 3963584 ;; TimerManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=8
        i32.store offset=12
        i32.const 2
        local.set $l2
      end
      local.get $p0
      local.get $l2
      i32.store offset=8
    end
    local.get $p1
    i32.const 192
    i32.add
    global.set $primary.global$0
    local.get $l6
    i32.const 3
    i32.lt_u
    return)
