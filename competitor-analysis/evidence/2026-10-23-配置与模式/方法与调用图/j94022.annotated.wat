  (func $j94022 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5139984
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3952324 ;; bool_TypeInfo
      call $j922
      i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
      call $j922
      i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
      call $j922
      i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
      call $j922
      i32.const 3955500 ;; GameSceneMa_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4083892 ;; IsWin
      call $j922
      i32.const 5139984
      i32.const 1
      i32.store8
    end
    block $B1
      block $B2
        block $B3
          block $B4
            block $B5
              local.get $p1
              i32.const 2
              i32.sub
              br_table $B5 $B1 $B3 $B4 $B2
            end
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            block $B6
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              br_if $B6
              i32.const 3955500 ;; GameSceneMa_TypeInfo
              i32.load
              i32.load offset=92
              i32.load
              i32.const 1
              i32.const 0
              call $j9019 ;; GameSceneMa$$ShowMainLevelContent
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              br_if $B6
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=28
              i32.const 2
              i32.ne
              br_if $B6
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              i32.const 5142651
              i32.load8_u
              i32.eqz
              if $I7
                i32.const 3959288 ;; NetDataManager_TypeInfo
                call $j922
                i32.const 5142651
                i32.const 1
                i32.store8
              end
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              call $j923
              i32.const 3959288 ;; NetDataManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=32
              i32.load offset=36
              i32.load offset=8
              i32.const 0
              i32.gt_s
              br_if $B6
              i32.const 0
              i32.const 0
              call $j13413 ;; ThinkingManager$$LosePlayerTime
              i32.const 0
              i32.const 0
              call $j13414 ;; ThinkingManager$$LosePlayerMatchCount
            end
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            block $B8
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=12
              i32.const 3
              i32.ne
              if $I9
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                call $j923
                i32.const 3958052 ;; LevelManager_TypeInfo
                i32.load
                i32.load offset=92
                i32.load offset=12
                i32.const 7
                i32.ne
                br_if $B8
              end
              i32.const 3955500 ;; GameSceneMa_TypeInfo
              i32.load
              i32.load offset=92
              i32.load
              i32.const 1
              i32.const 0
              call $j9019 ;; GameSceneMa$$ShowMainLevelContent
            end
            i32.const 3962304 ;; SpLevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 0
            call $j4012 ;; SpLevelManager$$CurLevelIsSpLevel
            i32.eqz
            br_if $B1
            i32.const 3955500 ;; GameSceneMa_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            i32.const 1
            i32.const 0
            call $j9019 ;; GameSceneMa$$ShowMainLevelContent
            br $B1
          end
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3958052 ;; LevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=12
          i32.eqz
          if $I10
            local.get $p0
            i32.load offset=12
            i32.const 0
            call $j19893 ;; LevelManager.StateAPI$$DelayToLose
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=12
            br_if $B1
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=28
            i32.const 2
            i32.ne
            br_if $B1
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 5142651
            i32.load8_u
            i32.eqz
            if $I11
              i32.const 3959288 ;; NetDataManager_TypeInfo
              call $j922
              i32.const 5142651
              i32.const 1
              i32.store8
            end
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            call $j923
            i32.const 3959288 ;; NetDataManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=32
            i32.load offset=36
            i32.load offset=8
            i32.const 0
            i32.gt_s
            br_if $B1
            i32.const 9999
            i32.const 0
            call $j13413 ;; ThinkingManager$$LosePlayerTime
            i32.const 9999
            i32.const 0
            call $j13414 ;; ThinkingManager$$LosePlayerMatchCount
            br $B1
          end
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 0
          call $j4012 ;; SpLevelManager$$CurLevelIsSpLevel
          i32.eqz
          br_if $B1
          local.get $p0
          i32.load offset=12
          i32.const 0
          call $j19893 ;; LevelManager.StateAPI$$DelayToLose
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.eqz
        if $I12
          i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
          i32.load
          call $j924
          local.set $p0
          local.get $p0
          i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
          i32.load
          call $j967
          local.get $p2
          i32.const 1
          i32.store8 offset=15
          i32.const 3952324 ;; bool_TypeInfo
          i32.load
          local.get $p2
          i32.const 15
          i32.add
          call $j935
          local.set $p1
          local.get $p0
          i32.const 4083892 ;; IsWin
          i32.load
          local.get $p1
          i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
          i32.load
          call $j953
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          i32.const 206
          local.get $p0
          i32.const 0
          i32.const 0
          i32.const 0
          call $j1082 ;; Kunpo.KUIManager$$OpenUI
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.eq
        if $I13
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962304 ;; SpLevelManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=4
          i32.const 0
          call $j2670 ;; SpLevelManager$$GetSpWindow
          local.set $p1
          local.get $p1
          i32.eqz
          br_if $B1
          i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
          i32.load
          call $j924
          local.set $p0
          local.get $p0
          i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
          i32.load
          call $j967
          local.get $p2
          i32.const 1
          i32.store8 offset=14
          i32.const 3952324 ;; bool_TypeInfo
          i32.load
          local.get $p2
          i32.const 14
          i32.add
          call $j935
          local.set $l3
          local.get $p0
          i32.const 4083892 ;; IsWin
          i32.load
          local.get $l3
          i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
          i32.load
          call $j953
          local.get $p1
          i32.load offset=16
          local.set $p1
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          local.get $p1
          local.get $p0
          i32.const 0
          i32.const 0
          i32.const 0
          call $j1082 ;; Kunpo.KUIManager$$OpenUI
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 20
        i32.eq
        if $I14
          i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
          i32.load
          call $j924
          local.set $p0
          local.get $p0
          i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
          i32.load
          call $j967
          local.get $p2
          i32.const 1
          i32.store8 offset=13
          i32.const 3952324 ;; bool_TypeInfo
          i32.load
          local.get $p2
          i32.const 13
          i32.add
          call $j935
          local.set $p1
          local.get $p0
          i32.const 4083892 ;; IsWin
          i32.load
          local.get $p1
          i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
          i32.load
          call $j953
          i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
          i32.load
          call $j923
          i32.const 852
          local.get $p0
          i32.const 0
          i32.const 0
          i32.const 0
          call $j1082 ;; Kunpo.KUIManager$$OpenUI
          br $B1
        end
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 9
        i32.ne
        br_if $B1
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 0
        call $j2670 ;; SpLevelManager$$GetSpWindow
        local.set $p1
        local.get $p1
        i32.eqz
        br_if $B1
        i32.const 3942244 ;; System.Collections.Generic.Dictionary<string, object>_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p0
        i32.const 3984988 ;; Method$System.Collections.Generic.Dictionary<string, object>..ctor()
        i32.load
        call $j967
        local.get $p2
        i32.const 1
        i32.store8 offset=12
        i32.const 3952324 ;; bool_TypeInfo
        i32.load
        local.get $p2
        i32.const 12
        i32.add
        call $j935
        local.set $l3
        local.get $p0
        i32.const 4083892 ;; IsWin
        i32.load
        local.get $l3
        i32.const 3984996 ;; Method$System.Collections.Generic.Dictionary<string, object>.Add()
        i32.load
        call $j953
        local.get $p1
        i32.load offset=16
        local.set $p1
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        local.get $p0
        i32.const 0
        i32.const 0
        i32.const 0
        call $j1082 ;; Kunpo.KUIManager$$OpenUI
        br $B1
      end
      local.get $p1
      i32.const 11
      i32.ne
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 6
      i32.eq
      if $I15
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 0
        call $j2670 ;; SpLevelManager$$GetSpWindow
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=12
        local.set $p0
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        i32.const 0
        i32.const 0
        i32.const 0
        call $j1082 ;; Kunpo.KUIManager$$OpenUI
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 20
      i32.eq
      if $I16
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 851
        i32.const 0
        i32.const 0
        i32.const 0
        i32.const 0
        call $j1082 ;; Kunpo.KUIManager$$OpenUI
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 9
      i32.ne
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 0
      call $j2670 ;; SpLevelManager$$GetSpWindow
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=12
      local.set $p0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      i32.const 0
      i32.const 0
      i32.const 0
      call $j1082 ;; Kunpo.KUIManager$$OpenUI
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)
