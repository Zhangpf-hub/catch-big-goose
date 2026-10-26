  (func $j94019 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139989
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
      call $j922
      i32.const 3961680 ;; SeasonLevelMa_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4076524 ;; DailyChallenge
      call $j922
      i32.const 4086068 ;; Monopoly
      call $j922
      i32.const 4085312 ;; MajiangModeLevel
      call $j922
      i32.const 4094136 ;; TaoYuanSpLevel
      call $j922
      i32.const 4121848 ;; 对战开始
      call $j922
      i32.const 4122428 ;; 开始联机对战
      call $j922
      i32.const 4084592 ;; LevelSlot
      call $j922
      i32.const 4075248 ;; CollegeExamSpLevel
      call $j922
      i32.const 4121196 ;; 即将开始
      call $j922
      i32.const 5139989
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=48
    local.set $l3
    i32.const 3955516 ;; GameTypeEnum_TypeInfo
    i32.load
    local.set $p1
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.set $l2
    local.get $p0
    i32.const -1
    i32.store offset=4
    local.get $p0
    local.get $p1
    i32.store
    local.get $p0
    local.get $l2
    i32.load offset=12
    i32.store offset=8
    block $B1
      local.get $l3
      local.get $p0
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 3983688 ;; Method$System.Collections.Generic.Dictionary<string, bool>.ContainsKey()
      i32.load
      call $j1040
      if $I2
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B3
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B3
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4084592 ;; LevelSlot
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B3
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 0
      call $j2628 ;; Anniversary.AnniversaryHelper$$get_Instance
      i32.const 0
      call $j24734 ;; Anniversary.AnniversaryHelper$$IsInAnniveraryLevel
      if $I4
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B5
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B5
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4076524 ;; DailyChallenge
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B5
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B6
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B6
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4075248 ;; CollegeExamSpLevel
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B6
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B7
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B7
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4085312 ;; MajiangModeLevel
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B7
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B8
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B8
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4094136 ;; TaoYuanSpLevel
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B8
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B9
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B9
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 4086068 ;; Monopoly
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        br_if $B9
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      block $B10
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 6
        i32.ne
        br_if $B10
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962304 ;; SpLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        local.set $p1
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        call $j6444 ;; LongLevelActiveMa$$IsLongLevelName
        i32.eqz
        br_if $B10
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.eqz
        br_if $B1
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.load offset=44
        local.set $p1
        block $B11
          local.get $p1
          if $I12
            i32.const 0
            local.set $l2
            local.get $p1
            i32.load offset=8
            br_if $B11
          end
          i32.const 1
          local.set $l2
        end
        local.get $l2
        br_if $B1
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        call $j923
        i32.const 3958316 ;; LongLevelActiveMa_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=20
        i32.load offset=44
        local.set $p1
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 601
        local.get $p1
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
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
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4121196 ;; 即将开始
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 3
      i32.eq
      if $I14
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4122428 ;; 开始联机对战
        i32.load
        f32.const 0x1p+0 (;=1;)
        f32.const 0x0p+0 (;=0;)
        i32.const 0
        call $j1952 ;; Kunpo.KUIManager$$OpenATip
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
      br_if $B1
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 9
      i32.eq
      if $I15
        i32.const 3961680 ;; SeasonLevelMa_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j38362 ;; SeasonLevelMa$$GetCurLevelTipStr
        local.set $p1
        block $B16
          local.get $p1
          if $I17
            i32.const 0
            local.set $l2
            local.get $p1
            i32.load offset=8
            br_if $B16
          end
          i32.const 1
          local.set $l2
        end
        local.get $l2
        br_if $B1
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 1605
        local.get $p1
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 7
      i32.ne
      br_if $B1
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 600
      i32.const 4121848 ;; 对战开始
      i32.load
      f32.const 0x1p+0 (;=1;)
      f32.const 0x0p+0 (;=0;)
      i32.const 0
      call $j1952 ;; Kunpo.KUIManager$$OpenATip
    end
    local.get $p0
    i32.const 16
    i32.add
    global.set $primary.global$0)
