  (func $j22239 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 f32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140131
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
      call $j922
      i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
      call $j922
      i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
      call $j922
      i32.const 5140131
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=624
    local.get $p1
    i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
    i32.load
    call $j947
    local.set $l4
    i32.const 0
    local.set $p2
    loop $L1
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p2
      local.get $l4
      i32.load offset=12
      i32.lt_s
      if $I2
        local.get $l4
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        i32.const 0
        i32.const 0
        call $j1275 ;; DG.Tweening.ShortcutExtensions$$DOKill
        drop
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $p0
        f32.load offset=636
        local.get $p0
        f32.load offset=632
        f32.mul
        i32.const 1
        local.get $l4
        i32.load offset=12
        local.get $p2
        i32.sub
        i32.sub
        f32.convert_i32_s
        f32.mul
        local.set $l6
        f32.const -0x1p+0 (;=-1;)
        f32.const 0x1p+0 (;=1;)
        local.get $p2
        i32.const 1
        i32.and
        select
        local.get $p0
        f32.load offset=640
        f32.mul
        local.set $l8
        local.get $l3
        local.get $p0
        i32.load offset=620
        local.get $p1
        i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1062 ;; UnityEngine.Transform$$get_position
        local.get $l3
        f32.load offset=8
        local.set $l9
        local.get $l3
        f32.load offset=4
        local.set $l7
        local.get $l3
        f32.load
        local.set $l10
        local.get $l3
        local.get $p0
        i32.load offset=620
        local.get $p1
        i32.const 4005772 ;; Method$System.Collections.Generic.List<Transform>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j4991 ;; UnityEngine.Transform$$get_up
        local.get $l10
        local.get $l3
        f32.load
        local.get $l6
        f32.mul
        f32.add
        local.set $l10
        local.get $l7
        local.get $l3
        f32.load offset=4
        local.get $l6
        f32.mul
        f32.add
        local.set $l7
        local.get $l9
        local.get $l3
        f32.load offset=8
        local.get $l6
        f32.mul
        f32.add
        local.set $l9
        i32.const 5156931
        i32.load8_u
        i32.eqz
        if $I3
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5156931
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $l5
        local.get $l8
        f32.const 0x0p+0 (;=0;)
        local.get $p2
        select
        local.set $l6
        local.get $l10
        local.get $l5
        f32.load offset=60
        local.get $l6
        f32.mul
        f32.add
        local.set $l8
        local.get $l7
        local.get $l5
        f32.load offset=64
        local.get $l6
        f32.mul
        f32.add
        local.set $l7
        local.get $l9
        local.get $l5
        f32.load offset=68
        local.get $l6
        f32.mul
        f32.add
        local.set $l6
        local.get $l4
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l8
        local.get $p0
        f32.load offset=688
        i32.const 0
        i32.const 0
        call $j5575 ;; DG.Tweening.ShortcutExtensions$$DOMoveX
        local.get $p0
        i32.load offset=664
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l4
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l7
        local.get $p0
        f32.load offset=688
        i32.const 0
        i32.const 0
        call $j8541 ;; DG.Tweening.ShortcutExtensions$$DOMoveY
        local.get $p0
        i32.load offset=672
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $l4
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j979 ;; UnityEngine.Component$$get_transform
        local.get $l6
        local.get $p0
        f32.load offset=688
        i32.const 0
        i32.const 0
        call $j20151 ;; DG.Tweening.ShortcutExtensions$$DOMoveZ
        local.get $p0
        i32.load offset=668
        i32.const 4039312 ;; Method$DG.Tweening.TweenSettingsExtensions.SetEase<TweenerCore<Vector3, Vector3, VectorOptions>>()
        i32.load
        call $j1137
        drop
        local.get $p2
        i32.const 1
        i32.add
        local.set $p2
        br $L1
      end
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0)
