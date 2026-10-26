  (func $j38177 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5140318
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4089160 ;; PayShowData.config
      call $j922
      i32.const 4091896 ;; Server/
      call $j922
      i32.const 4077112 ;; DouYinMiniPay.config
      call $j922
      i32.const 4089916 ;; RPData.config
      call $j922
      i32.const 4068428 ;; /
      call $j922
      i32.const 4113232 ;; prod
      call $j922
      i32.const 4105668 ;; dev
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4073640 ;; CDNDirectPlayData.config
      call $j922
      i32.const 4089056 ;; PassRewardData.config
      call $j922
      i32.const 5140318
      i32.const 1
      i32.store8
    end
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.load offset=80
    i32.const 4091896 ;; Server/
    i32.load
    i32.const 4113232 ;; prod
    i32.const 4105668 ;; dev
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.load offset=112
    i32.const 2
    i32.eq
    select
    i32.load
    i32.const 4068428 ;; /
    i32.load
    i32.const 0
    call $j1151 ;; System.String$$Concat
    local.set $p0
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                local.get $p1
                br_table $B6 $B5 $B4 $B3 $B2 $B1
              end
              local.get $p0
              i32.const 4089916 ;; RPData.config
              i32.load
              i32.const 0
              call $j962 ;; System.String$$Concat
              return
            end
            local.get $p0
            i32.const 4077112 ;; DouYinMiniPay.config
            i32.load
            i32.const 0
            call $j962 ;; System.String$$Concat
            return
          end
          local.get $p0
          i32.const 4089160 ;; PayShowData.config
          i32.load
          i32.const 0
          call $j962 ;; System.String$$Concat
          return
        end
        local.get $p0
        i32.const 4073640 ;; CDNDirectPlayData.config
        i32.load
        i32.const 0
        call $j962 ;; System.String$$Concat
        return
      end
      local.get $p0
      i32.const 4089056 ;; PassRewardData.config
      i32.load
      i32.const 0
      call $j962 ;; System.String$$Concat
      return
    end
    i32.const 4063796 ;; 
    i32.load
    return)
