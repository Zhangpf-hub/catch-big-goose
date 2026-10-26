  (func $j95009 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140184
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4026524 ;; Method$UnityEngine.GameObject.GetComponent<ParticleSystem>()
      call $j922
      i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
      call $j922
      i32.const 4031864 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5140184
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    call $j2065 ;; Kunpo.AssetRequest$$get_Result
    local.set $p1
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p1
    i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
    i32.load
    call $j968
    i32.const 4031864 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
    i32.load
    call $j1874
    i32.const 4026524 ;; Method$UnityEngine.GameObject.GetComponent<ParticleSystem>()
    i32.load
    call $j1136
    i32.store offset=76)
