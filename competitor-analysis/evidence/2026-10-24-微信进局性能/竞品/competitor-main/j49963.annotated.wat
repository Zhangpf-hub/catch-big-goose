  (func $j49963 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i64)
    global.get $primary.global$0
    i32.const 96
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    local.get $p2
    i32.load offset=28
    i32.eqz
    if $I0
      i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
      call $j922
      i32.const 3963888 ;; System.Type_TypeInfo
      call $j922
      local.get $p2
      call $j978
    end
    local.get $l3
    i32.const 0
    i32.store offset=92
    local.get $p2
    i32.load offset=28
    i32.load
    local.set $l5
    i32.const 3963888 ;; System.Type_TypeInfo
    i32.load
    call $j923
    local.get $l5
    i32.const 0
    call $j943 ;; System.Type$$GetTypeFromHandle
    local.set $l5
    local.get $p0
    local.get $l5
    local.get $p1
    local.get $l3
    i32.const 92
    i32.add
    i32.const 0
    call $j15790 ;; Kunpo.AssetManager$$getAssetRequestContainer
    local.set $p1
    block $B1
      block $B2
        local.get $l3
        i32.load offset=92
        local.set $l4
        block $B3
          local.get $l4
          i32.eqz
          br_if $B3
          local.get $l4
          i32.const 28
          i32.add
          i32.const 0
          call $j3090 ;; UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationHandle$$get_Status
          i32.const 2
          i32.eq
          if $I4
            local.get $l3
            i32.const 0
            i32.store offset=92
            br $B3
          end
          local.get $l3
          i32.load offset=92
          local.set $l4
          local.get $l4
          br_if $B2
        end
        i32.const 0
        call $j15788 ;; Kunpo.AssetManager$$getOrCreateAssetRequest
        local.set $l4
        local.get $l3
        local.get $l4
        i32.store offset=92
        i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
        i32.load
        call $j923
        local.get $l3
        i32.const 56
        i32.add
        local.get $p2
        i32.load offset=28
        i32.load offset=4
        i32.load
        local.get $p2
        i32.load offset=28
        i32.load offset=4
        i32.const 0
        local.get $p0
        call $j1499
        local.get $l3
        i32.const -64
        i32.sub
        local.set $l6
        local.get $l3
        local.get $l6
        i64.load
        i64.store offset=80
        local.get $l3
        local.get $l3
        i64.load offset=56
        i64.store offset=72
        local.get $p2
        i32.load offset=28
        i32.load offset=12
        i32.load
        local.set $l7
        local.get $p2
        i32.load offset=28
        i32.load offset=12
        local.set $p2
        local.get $l3
        local.get $l3
        i64.load offset=80
        i64.store offset=32
        local.get $l3
        local.get $l3
        i64.load offset=72
        i64.store offset=24
        local.get $l3
        i32.const 56
        i32.add
        local.get $l7
        local.get $p2
        i32.const 0
        local.get $l3
        i32.const 24
        i32.add
        call $j1499
        local.get $l6
        i32.load
        local.set $p2
        local.get $l3
        local.get $p2
        i32.store offset=48
        local.get $l3
        local.get $p2
        i32.store offset=16
        local.get $l3
        i64.load offset=56
        local.set $l8
        local.get $l3
        local.get $l8
        i64.store offset=40
        local.get $l3
        local.get $l8
        i64.store offset=8
        local.get $l4
        local.get $p1
        local.get $p0
        local.get $l5
        local.get $l3
        i32.const 8
        i32.add
        i32.const 0
        call $j15786 ;; Kunpo.AssetRequest$$SetHandle
        br $B1
      end
      local.get $l4
      i32.const 0
      call $j15787 ;; Kunpo.AssetRequest$$AddHandleRef
      local.get $l3
      i32.load offset=92
      i32.const 0
      call $j3915 ;; Kunpo.AssetRequest$$get_IsDone
      i32.eqz
      br_if $B1
      i32.const 3951380 ;; UnityEngine.AddressableAssets.Addressables_TypeInfo
      i32.load
      call $j923
      local.get $l3
      i32.const 72
      i32.add
      local.get $p2
      i32.load offset=28
      i32.load offset=4
      i32.load
      local.get $p2
      i32.load offset=28
      i32.load offset=4
      i32.const 0
      local.get $p0
      call $j1499
    end
    local.get $l3
    i32.load offset=92
    local.set $p0
    local.get $l3
    i32.const 96
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)
