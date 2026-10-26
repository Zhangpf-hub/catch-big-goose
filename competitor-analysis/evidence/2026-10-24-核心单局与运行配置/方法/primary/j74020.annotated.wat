  (func $j74020 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 f32) (local $l11 f32) (local $l12 f32) (local $l13 f32)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5127074
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
      i32.const 5127074
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $l6
    local.get $l6
    i32.const 1
    i32.le_u
    if $I1
      local.get $p0
      i32.load offset=16
      local.set $l2
      local.get $p0
      i32.const -1
      i32.store offset=8
      loop $L2
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $l3
        local.get $l2
        i32.load offset=152
        i32.load offset=12
        i32.lt_s
        if $I3
          local.get $p1
          i32.const -64
          i32.sub
          local.get $l2
          i32.load offset=152
          local.get $l3
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          i32.const 0
          call $j1418 ;; UnityEngine.Transform$$get_localScale
          block $B4
            block $B5
              local.get $p1
              f32.load offset=64
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              f32.load offset=128
              f32.const 0x1.fae148p-1 (;=0.99;)
              f32.mul
              f32.lt
              i32.eqz
              br_if $B5
              local.get $l2
              i32.load8_u offset=536
              i32.eqz
              br_if $B5
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l5
              local.get $p1
              i32.const -64
              i32.sub
              local.get $l5
              i32.const 0
              call $j1418 ;; UnityEngine.Transform$$get_localScale
              local.get $p1
              f32.load offset=72
              local.set $l8
              local.get $p1
              f32.load offset=68
              local.set $l9
              local.get $p1
              f32.load offset=64
              local.set $l10
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I6
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
              local.set $l11
              local.get $l2
              i32.const 480
              i32.const 464
              local.get $l2
              i32.load8_u offset=484
              select
              i32.add
              f32.load
              local.set $l7
              local.get $l4
              f32.load offset=12
              local.get $l7
              f32.mul
              local.set $l12
              local.get $l4
              f32.load offset=16
              local.get $l7
              f32.mul
              local.set $l13
              local.get $l11
              local.get $l7
              f32.mul
              local.set $l11
              local.get $l2
              i32.load offset=152
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              f32.load offset=128
              local.set $l7
              local.get $l12
              local.get $l7
              f32.mul
              local.set $l12
              local.get $p1
              local.get $l8
              local.get $l11
              local.get $l7
              f32.mul
              f32.add
              f32.store offset=56
              local.get $p1
              local.get $p1
              i32.load offset=56
              i32.store offset=8
              local.get $p1
              local.get $l9
              local.get $l13
              local.get $l7
              f32.mul
              f32.add
              f32.store offset=52
              local.get $p1
              local.get $l10
              local.get $l12
              f32.add
              f32.store offset=48
              local.get $p1
              local.get $p1
              i64.load offset=48
              i64.store
              local.get $l5
              local.get $p1
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
              br $B4
            end
            local.get $l2
            i32.load8_u offset=484
            if $I7
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              i32.eqz
              br_if $B4
            end
            local.get $l2
            local.get $l2
            i32.load offset=152
            local.get $l3
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            i32.const 1
            f32.const 0x1p+0 (;=1;)
            i32.const 0
            call $j6450 ;; LevelManager$$CheckRigid
          end
          local.get $l3
          i32.const 1
          i32.add
          local.set $l3
          br $L2
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
          i32.const -64
          i32.sub
          local.get $l2
          i32.load offset=168
          local.get $l3
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          i32.const 0
          call $j1418 ;; UnityEngine.Transform$$get_localScale
          block $B10
            block $B11
              local.get $p1
              f32.load offset=64
              f32.const 0x1.fae148p-1 (;=0.99;)
              f32.lt
              i32.eqz
              br_if $B11
              local.get $l2
              i32.load8_u offset=536
              i32.eqz
              br_if $B11
              local.get $l2
              i32.load offset=168
              local.get $l3
              i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
              i32.load
              call $j947
              i32.const 0
              call $j979 ;; UnityEngine.Component$$get_transform
              local.set $l5
              local.get $p1
              i32.const -64
              i32.sub
              local.get $l5
              i32.const 0
              call $j1418 ;; UnityEngine.Transform$$get_localScale
              local.get $p1
              f32.load offset=72
              local.set $l7
              local.get $p1
              f32.load offset=68
              local.set $l8
              local.get $p1
              f32.load offset=64
              local.set $l9
              i32.const 5142879
              i32.load8_u
              i32.eqz
              if $I12
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
              local.set $l10
              local.get $l9
              local.get $l4
              f32.load offset=12
              f32.const 0x1.99999ap-4 (;=0.1;)
              f32.mul
              f32.add
              local.set $l9
              local.get $l8
              local.get $l4
              f32.load offset=16
              f32.const 0x1.99999ap-4 (;=0.1;)
              f32.mul
              f32.add
              local.set $l8
              local.get $p1
              local.get $l7
              local.get $l10
              f32.const 0x1.99999ap-4 (;=0.1;)
              f32.mul
              f32.add
              f32.store offset=40
              local.get $p1
              local.get $p1
              i32.load offset=40
              i32.store offset=24
              local.get $p1
              local.get $l8
              f32.store offset=36
              local.get $p1
              local.get $l9
              f32.store offset=32
              local.get $p1
              local.get $p1
              i64.load offset=32
              i64.store offset=16
              local.get $l5
              local.get $p1
              i32.const 16
              i32.add
              i32.const 0
              call $j1159 ;; UnityEngine.Transform$$set_localScale
              br $B10
            end
            local.get $l2
            local.get $l2
            i32.load offset=168
            local.get $l3
            i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
            i32.load
            call $j947
            i32.const 2
            f32.const 0x1p+0 (;=1;)
            i32.const 0
            call $j6450 ;; LevelManager$$CheckRigid
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
      i32.load offset=12
      i32.store offset=12
      local.get $p0
      i32.const 1
      i32.store offset=8
    end
    local.get $p1
    i32.const 80
    i32.add
    global.set $primary.global$0
    local.get $l6
    i32.const 2
    i32.lt_u
    return)
