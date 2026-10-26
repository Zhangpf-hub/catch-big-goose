  (func $j24626 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5121035
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3938912 ;; System.Action<AsyncOperationHandle<IList<IResourceLocation>>>_TypeInfo
      call $j922
      i32.const 4016196 ;; Method$UnityEngine.AddressableAssets.Addressables.Release<IList<IResourceLocation>>()
      call $j922
      i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
      call $j922
      i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
      call $j922
      i32.const 3975936 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.add_Completed()
      call $j922
      i32.const 3975940 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.get_Result()
      call $j922
      i32.const 3987084 ;; Method$System.Collections.Generic.Dictionary<Type, Func<string, bool, AssetRequest>>.get_Item()
      call $j922
      i32.const 3945192 ;; System.Collections.Generic.ICollection<IResourceLocation>_TypeInfo
      call $j922
      i32.const 3945812 ;; System.Collections.Generic.IList<IResourceLocation>_TypeInfo
      call $j922
      i32.const 3957048 ;; UnityEngine.ResourceManagement.ResourceLocations.IResourceLocation_TypeInfo
      call $j922
      i32.const 5121035
      i32.const 1
      i32.store8
    end
    local.get $p2
    i64.const 0
    i64.store offset=24
    local.get $p2
    i64.const 0
    i64.store offset=16
    block $B1
      block $B2
        block $B3
          local.get $p0
          local.get $p1
          local.get $p2
          call $j15789 ;; Kunpo.AssetManager$$getLoadedAssetRequest
          local.set $l3
          local.get $l3
          i32.eqz
          if $I4
            i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
            i32.load
            call $j923
            local.get $p2
            local.get $p0
            local.get $p1
            i32.const 0
            call $j15914 ;; UnityEngine.AddressableAssets.Addressables$$LoadResourceLocationsAsync
            local.get $p2
            local.get $p2
            i64.load offset=8
            i64.store offset=24
            local.get $p2
            local.get $p2
            i64.load
            i64.store offset=16
            i32.const 3938912 ;; System.Action<AsyncOperationHandle<IList<IResourceLocation>>>_TypeInfo
            i32.load
            call $j924
            local.set $l3
            local.get $l3
            i32.const 0
            i32.const 4016196 ;; Method$UnityEngine.AddressableAssets.Addressables.Release<IList<IResourceLocation>>()
            i32.load
            i32.const 0
            call $j969
            local.get $p2
            i32.const 16
            i32.add
            local.get $l3
            i32.const 3975936 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.add_Completed()
            i32.load
            call $j4820
            local.get $p2
            i32.const 16
            i32.add
            i32.const 3975940 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.get_Result()
            i32.load
            call $j2135
            i32.eqz
            br_if $B3
            local.get $p2
            i32.const 16
            i32.add
            i32.const 3975940 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.get_Result()
            i32.load
            call $j2135
            local.set $l3
            i32.const 0
            i32.const 3945192 ;; System.Collections.Generic.ICollection<IResourceLocation>_TypeInfo
            i32.load
            local.get $l3
            call $j951
            i32.const 1
            i32.lt_s
            br_if $B3
            i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=28
            local.get $p1
            i32.const 3987084 ;; Method$System.Collections.Generic.Dictionary<Type, Func<string, bool, AssetRequest>>.get_Item()
            i32.load
            call $j1033
            local.set $l3
            local.get $p2
            i32.const 16
            i32.add
            i32.const 3975940 ;; Method$UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle<IList<IResourceLocation>>.get_Result()
            i32.load
            call $j2135
            local.set $l4
            i32.const 0
            i32.const 3945812 ;; System.Collections.Generic.IList<IResourceLocation>_TypeInfo
            i32.load
            local.get $l4
            i32.const 0
            call $j1018
            local.set $l4
            local.get $l3
            i32.const 7
            i32.const 3957048 ;; UnityEngine.ResourceManagement.ResourceLocations.IResourceLocation_TypeInfo
            i32.load
            local.get $l4
            call $j951
            i32.const 1
            call $j15021
            local.set $l3
          end
          local.get $l3
          i32.const 28
          i32.add
          i32.const 0
          call $j3912 ;; UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle$$get_IsDone
          i32.eqz
          br_if $B2
          local.get $l3
          local.get $p2
          call $j11542 ;; Kunpo.AssetRequest$$AddRef
          local.get $l3
          local.get $p2
          call $j2065 ;; Kunpo.AssetRequest$$get_Result
          local.set $p0
          local.get $p2
          i32.const 32
          i32.add
          global.set $primary.global$0
          local.get $p0
          return
        end
        i32.const 4123812 ;; 未找到资源（{0}：{1}）
        call $j925
        local.get $p0
        local.get $p1
        i32.const 0
        call $j1060 ;; System.String$$Format
        local.set $p0
        br $B1
      end
      i32.const 4122608 ;; 必须提前加载资源（{0}：{1}）
      call $j925
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1060 ;; System.String$$Format
      local.set $p0
    end
    i32.const 3957916 ;; Kunpo.KunpoException_TypeInfo
    call $j925
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.const 0
    call $j1488 ;; Kunpo.KunpoException$$.ctor
    local.get $p1
    i32.const 4018064 ;; Method$Kunpo.AssetManager.GetAsset()
    call $j925
    call $j929
    unreachable)
