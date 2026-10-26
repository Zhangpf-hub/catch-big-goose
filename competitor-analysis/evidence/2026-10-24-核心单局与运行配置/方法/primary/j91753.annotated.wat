  (func $j91753 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139726
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985740 ;; Method$System.Collections.Generic.Dictionary<string, string>.Add()
      call $j922
      i32.const 3985724 ;; Method$System.Collections.Generic.Dictionary<string, string>..ctor()
      call $j922
      i32.const 3942632 ;; System.Collections.Generic.Dictionary<string, string>_TypeInfo
      call $j922
      i32.const 4103164 ;; bbb
      call $j922
      i32.const 4107392 ;; gdt_vid
      call $j922
      i32.const 4104236 ;; click_id
      call $j922
      i32.const 4102244 ;; aaa
      call $j922
      i32.const 4103940 ;; ccc
      call $j922
      i32.const 4113792 ;; req_id
      call $j922
      i32.const 5139726
      i32.const 1
      i32.store8
    end
    local.get $p0
    local.get $p0
    call $j41842) ;; NetDataManager$$GetServerData
