  (func $j10385 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140298
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4123272 ;; 无此key
      call $j922
      i32.const 4081428 ;; HotFixSpLevel
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140298
      i32.const 1
      i32.store8
    end
    local.get $p2
    i32.const 8
    i32.add
    local.set $l4
    local.get $l4
    i32.const 0
    i32.store offset=4
    i32.const 4063796 ;; 
    i32.load
    local.set $l3
    local.get $p0
    local.get $p1
    local.get $l3
    local.get $l3
    local.get $l3
    local.get $l3
    local.get $p2
    call $j1120 ;; GameManager$$StringAppend
    local.set $l3
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i32.const 4081428 ;; HotFixSpLevel
    i32.load
    local.get $l3
    local.get $p2
    call $j3816 ;; ServerFileCreate$$GetHotFixData
    block $B1
      block $B2
        block $B3
          block $B4
            local.get $p2
            i32.load
            i32.const 256
            i32.and
            if $I5
              local.get $p2
              i32.load offset=4
              local.set $p0
              i32.const 4610948
              i32.const 0
              i32.store
              i32.const 4398
              local.get $p0
              i32.const 0
              call $fimport$2
              local.set $p0
              i32.const 4610948
              i32.load
              local.set $p1
              i32.const 4610948
              i32.const 0
              i32.store
              local.get $p1
              i32.const 1
              i32.ne
              br_if $B3
              i32.const 2539788
              call $fimport$0
              local.set $p0
              call $fimport$1
              i32.const 2539788
              call $fimport$9
              i32.eq
              if $I6
                local.get $p0
                call $fimport$7
                local.set $p0
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 704
                i32.const 3959500 ;; object_TypeInfo
                call $fimport$3
                local.set $p1
                i32.const 4610948
                i32.load
                local.set $l3
                i32.const 4610948
                i32.const 0
                i32.store
                block $B7
                  local.get $l3
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $p0
                  i32.load
                  i32.load
                  local.set $l3
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 705
                  local.get $p1
                  local.get $l3
                  call $fimport$2
                  local.set $p1
                  i32.const 4610948
                  i32.load
                  local.set $l3
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $l3
                  i32.const 1
                  i32.eq
                  br_if $B7
                  local.get $p1
                  if $I8
                    local.get $l4
                    i32.load offset=4
                    local.set $p1
                    local.get $l4
                    local.get $p1
                    i32.const 2
                    i32.shl
                    i32.add
                    local.get $p0
                    i32.load
                    i32.store
                    local.get $l4
                    local.get $p1
                    i32.const 1
                    i32.add
                    i32.store offset=4
                    call $fimport$15
                    local.get $l4
                    local.get $l4
                    i32.load offset=4
                    i32.const 1
                    i32.sub
                    i32.store offset=4
                    br $B4
                  end
                  i32.const 4
                  call $fimport$14
                  local.set $p1
                  local.get $p1
                  local.get $p0
                  i32.load
                  i32.store
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  i32.const 706
                  local.get $p1
                  i32.const 2539788
                  i32.const 0
                  call $fimport$5
                  i32.const 4610948
                  i32.load
                  local.set $p0
                  i32.const 4610948
                  i32.const 0
                  i32.store
                  local.get $p0
                  i32.const 1
                  i32.ne
                  br_if $B1
                end
                call $fimport$4
                local.set $p0
                call $fimport$1
                drop
                i32.const 4610948
                i32.const 0
                i32.store
                i32.const 369
                call $fimport$6
                i32.const 4610948
                i32.load
                local.set $p1
                i32.const 4610948
                i32.const 0
                i32.store
                local.get $p1
                i32.const 1
                i32.eq
                br_if $B2
              end
              local.get $p0
              call $fimport$10
              unreachable
            end
            i32.const 4123272 ;; 无此key
            i32.load
            local.get $p0
            local.get $p1
            i32.const 0
            call $j1011 ;; System.String$$Concat
            local.set $p0
            i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
            i32.load
            call $j923
            local.get $p0
            i32.const 0
            call $j1075 ;; UnityEngine.Debug$$LogWarning
          end
          i32.const 1
          local.set $p0
        end
        local.get $p2
        i32.const 16
        i32.add
        global.set $primary.global$0
        local.get $p0
        return
      end
      i32.const 0
      call $fimport$0
      drop
      call $fimport$1
      drop
      call $j944
    end
    unreachable)
