  (func $j41823 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    i32.const 5139786
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939024 ;; System.Action<AsyncOperation>_TypeInfo
      call $j922
      i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
      call $j922
      i32.const 3985884 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.get_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4055924 ;; Method$NetDataManager.<>c__DisplayClass96_0.<loadAvatarUrl>b__0()
      call $j922
      i32.const 3969876 ;; NetDataManager.<>c__DisplayClass96_0_TypeInfo
      call $j922
      i32.const 4111868 ;; null
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4069256 ;; 1
      call $j922
      i32.const 4106328 ;; empty
      call $j922
      i32.const 4069136 ;; 0
      call $j922
      i32.const 5139786
      i32.const 1
      i32.store8
    end
    i32.const 3969876 ;; NetDataManager.<>c__DisplayClass96_0_TypeInfo
    i32.load
    call $j924
    local.set $p3
    local.get $p3
    local.get $p0
    i32.store offset=12
    local.get $p3
    local.get $p1
    i32.store offset=16
    local.get $p3
    local.get $p2
    i32.store offset=20
    block $B1
      block $B2
        block $B3
          block $B4
            local.get $p3
            i32.load offset=16
            i32.const 4063796 ;; 
            i32.load
            i32.const 0
            call $j949 ;; System.String$$op_Equality
            br_if $B4
            local.get $p3
            i32.load offset=16
            local.set $p0
            local.get $p0
            i32.eqz
            br_if $B4
            local.get $p0
            i32.const 4111868 ;; null
            i32.load
            i32.const 0
            call $j949 ;; System.String$$op_Equality
            i32.eqz
            br_if $B3
          end
          local.get $p3
          i32.load offset=20
          local.set $p0
          local.get $p0
          i32.eqz
          br_if $B2
          br $B1
        end
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=40
        local.get $p3
        i32.load offset=12
        i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
        i32.load
        call $j1040
        if $I5
          local.get $p3
          i32.load offset=20
          local.set $p0
          local.get $p0
          i32.eqz
          br_if $B2
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          local.get $p0
          i32.const 1
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=40
          local.get $p3
          i32.load offset=12
          i32.const 3985884 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.get_Item()
          i32.load
          call $j1033
          call $j2630
          return
        end
        block $B6
          block $B7
            local.get $p3
            i32.load offset=16
            i32.const 4069136 ;; 0
            i32.load
            i32.const 0
            call $j949 ;; System.String$$op_Equality
            br_if $B7
            local.get $p3
            i32.load offset=16
            i32.const 4069256 ;; 1
            i32.load
            i32.const 0
            call $j949 ;; System.String$$op_Equality
            br_if $B7
            local.get $p3
            i32.load offset=16
            i32.const 4106328 ;; empty
            i32.load
            i32.const 0
            call $j949 ;; System.String$$op_Equality
            i32.eqz
            br_if $B6
          end
          local.get $p3
          i32.load offset=20
          local.set $p0
          local.get $p0
          i32.eqz
          br_if $B2
          br $B1
        end
        local.get $p3
        local.get $p3
        i32.load offset=16
        i32.const 1
        i32.const 0
        call $j18457 ;; UnityEngine.Networking.UnityWebRequestTexture$$GetTexture
        i32.store offset=8
        local.get $p3
        i32.load offset=8
        i32.const 0
        call $j2662 ;; UnityEngine.Networking.UnityWebRequest$$SendWebRequest
        local.set $p0
        i32.const 3939024 ;; System.Action<AsyncOperation>_TypeInfo
        i32.load
        call $j924
        local.set $p1
        local.get $p1
        local.get $p3
        i32.const 4055924 ;; Method$NetDataManager.<>c__DisplayClass96_0.<loadAvatarUrl>b__0()
        i32.load
        i32.const 0
        call $j969
        local.get $p0
        local.get $p1
        i32.const 0
        call $j2253 ;; UnityEngine.AsyncOperation$$add_completed
      end
      return
    end
    local.get $p0
    i32.const 0
    i32.const 0
    call $j2630)
