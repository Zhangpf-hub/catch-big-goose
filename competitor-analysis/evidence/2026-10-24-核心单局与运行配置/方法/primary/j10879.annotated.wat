  (func $j10879 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 f32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140164
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3962284 ;; SoundManager_TypeInfo
      call $j922
      i32.const 3964172 ;; UIGamePage_TypeInfo
      call $j922
      i32.const 3964212 ;; UIGooseWordGuide_TypeInfo
      call $j922
      i32.const 4086608 ;; NewGuide10{0}
      call $j922
      i32.const 4080888 ;; Guide{0}
      call $j922
      i32.const 5140164
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load8_u offset=444
      i32.eqz
      br_if $B1
      local.get $p1
      if $I2
        local.get $p0
        i32.load offset=832
        local.get $p2
        i32.ge_s
        br_if $B1
        local.get $p0
        local.get $p2
        i32.store offset=832
        local.get $p3
        local.get $p2
        i32.store offset=12
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $p3
        i32.const 12
        i32.add
        call $j935
        local.set $p1
        i32.const 4086608 ;; NewGuide10{0}
        i32.load
        local.get $p1
        i32.const 0
        call $j1006 ;; System.String$$Format
        local.set $p1
        i32.const 3953096 ;; ConfigManager_TypeInfo
        i32.load
        call $j923
        local.get $p1
        i32.const 0
        call $j4435 ;; ConfigManager$$GetTeachData
        local.set $p1
        local.get $p1
        if $I3
          local.get $p1
          i32.load offset=24
          local.set $l4
          local.get $p1
          i32.load offset=28
          f32.load offset=20
          local.set $l5
          i32.const 3964212 ;; UIGooseWordGuide_TypeInfo
          i32.load
          call $j923
          local.get $l4
          local.get $l5
          i32.const 0
          call $j34149 ;; UIGooseWordGuide$$ShowWord
          local.get $p1
          i32.load offset=16
          i32.const 0
          call $j34150 ;; UIGooseWordGuide$$PlayWordSound
          local.get $p3
          local.get $p2
          i32.store offset=8
          i32.const 3957596 ;; int_TypeInfo
          i32.load
          local.get $p3
          i32.const 8
          i32.add
          call $j935
          local.set $p1
          i32.const 2
          i32.const 4080888 ;; Guide{0}
          i32.load
          local.get $p1
          i32.const 0
          call $j1006 ;; System.String$$Format
          i32.const 0
          call $j1429 ;; GameManager$$LogInColor
        end
        block $B4
          block $B5
            local.get $p2
            i32.const 1
            i32.sub
            br_table $B5 $B4 $B1
          end
          i32.const 3962284 ;; SoundManager_TypeInfo
          i32.load
          call $j923
          i32.const 3962284 ;; SoundManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          local.set $p1
          i32.const 3959504 ;; UnityEngine.Object_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 0
          call $j1022 ;; UnityEngine.Object$$op_Implicit
          if $I6
            i32.const 3962284 ;; SoundManager_TypeInfo
            i32.load
            call $j923
            i32.const 3962284 ;; SoundManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load
            local.get $p0
            f32.load offset=828
            i32.const 0
            call $j19975 ;; SoundManager$$SetMusicVolume
          end
          i32.const 3964172 ;; UIGamePage_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.const 1
          local.get $p0
          i32.load offset=152
          i32.const 0
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          i32.const 0
          call $j6988 ;; UIGamePage$$ShowHand
          local.get $p0
          i32.load offset=816
          local.set $p1
          i32.const 3959504 ;; UnityEngine.Object_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 0
          call $j1022 ;; UnityEngine.Object$$op_Implicit
          i32.eqz
          br_if $B1
          local.get $p0
          i32.load offset=152
          i32.const 0
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          local.set $p1
          i32.const 3959504 ;; UnityEngine.Object_TypeInfo
          i32.load
          call $j923
          local.get $p1
          i32.const 0
          call $j1022 ;; UnityEngine.Object$$op_Implicit
          i32.eqz
          br_if $B1
          local.get $p0
          i32.load offset=816
          local.get $p0
          i32.load offset=152
          i32.const 0
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          i32.const 0
          call $j8984 ;; HighlightPlus.HighlightEffect$$SetTarget
          local.get $p0
          i32.load offset=816
          i32.const 1
          i32.const 0
          call $j3070 ;; HighlightPlus.HighlightEffect$$SetHighlighted
          br $B1
        end
        i32.const 3964172 ;; UIGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 0
        i32.const 0
        i32.const 0
        call $j6988 ;; UIGamePage$$ShowHand
        br $B1
      end
      i32.const 3962284 ;; SoundManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962284 ;; SoundManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p0
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      if $I7
        i32.const 3962284 ;; SoundManager_TypeInfo
        i32.load
        call $j923
        i32.const 3962284 ;; SoundManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        f32.const 0x1p+0 (;=1;)
        i32.const 0
        call $j19975 ;; SoundManager$$SetMusicVolume
      end
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      i32.load
      call $j923
      i32.const 801
      i32.const 0
      call $j1327 ;; Kunpo.KUIManager$$CloseUI
    end
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0)
