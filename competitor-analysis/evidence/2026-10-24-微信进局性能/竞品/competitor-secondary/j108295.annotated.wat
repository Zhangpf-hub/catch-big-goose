  (func $j108295 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5121041
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3937420 ;; UnityEngine.ResourceManagement.ResourceProviders.IAssetBundleResource_var
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3963888 ;; System.Type_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5121041
      i32.const 1
      i32.store8
    end
    i32.const 3937420 ;; UnityEngine.ResourceManagement.ResourceProviders.IAssetBundleResource_var
    i32.load
    local.set $p1
    i32.const 3963888 ;; System.Type_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    local.get $p1
    i32.const 0
    i32.const 918
    call_indirect $primary.table (type $t2)
    i32.const 0
    local.get $p0
    call $j24624) ;; Kunpo.AssetManager$$Release
