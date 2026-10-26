  (func $j94027 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139990
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3964040 ;; UIBattleGamePage_TypeInfo
      call $j922
      i32.const 3964128 ;; UIEndlessLevelGamePage_TypeInfo
      call $j922
      i32.const 3964172 ;; UIGamePage_TypeInfo
      call $j922
      i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
      call $j922
      i32.const 5139990
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 1
    local.set $p0
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              block $B6
                block $B7
                  block $B8
                    i32.const 3958052 ;; LevelManager_TypeInfo
                    i32.load
                    i32.load offset=92
                    i32.load offset=12
                    local.set $p1
                    local.get $p1
                    br_table $B8 $B7 $B2 $B6 $B2 $B2 $B5 $B2 $B2 $B3 $B4
                  end
                  i32.const 3964172 ;; UIGamePage_TypeInfo
                  i32.load
                  i32.load offset=92
                  i32.load
                  local.set $p0
                  br $B1
                end
                i32.const 3964040 ;; UIBattleGamePage_TypeInfo
                i32.load
                i32.load offset=92
                i32.load
                local.set $p0
                br $B1
              end
              i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
              i32.load
              i32.load offset=92
              i32.load
              local.set $p0
              br $B1
            end
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=4
            i32.const 0
            call $j19974 ;; SpLevelManager$$HasGameWindowCreate
            return
          end
          local.get $p1
          i32.const 20
          i32.ne
          br_if $B2
          i32.const 3964128 ;; UIEndlessLevelGamePage_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          local.set $p0
          br $B1
        end
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 0
        call $j19974 ;; SpLevelManager$$HasGameWindowCreate
        local.set $p0
      end
      local.get $p0
      return
    end
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    i32.const 0
    call $j971 ;; UnityEngine.Object$$op_Inequality
    return)
