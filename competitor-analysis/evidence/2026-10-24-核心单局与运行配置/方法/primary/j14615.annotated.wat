  (func $j14615 (type $t25) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 i32)
    (local $l4 f32)
    i32.const 5140096
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3964256 ;; UIManager_TypeInfo
      call $j922
      i32.const 5140096
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      if $I2
        local.get $p0
        local.get $p0
        f32.load offset=516
        local.get $p2
        f32.add
        f32.store offset=516
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        br_if $B1
        local.get $p0
        i32.load8_u offset=520
        i32.eqz
        if $I3
          local.get $p0
          f32.load offset=516
          local.set $p2
          block $B4
            local.get $p2
            f32.const 0x1.8p+0 (;=1.5;)
            f32.gt
            if $I5
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              call $j923
              i32.const 3958052 ;; LevelManager_TypeInfo
              i32.load
              i32.load offset=92
              i32.load offset=28
              i32.const 2
              i32.eq
              br_if $B4
              local.get $p0
              f32.load offset=516
              local.set $p2
            end
            local.get $p2
            f32.const 0x1p-1 (;=0.5;)
            f32.gt
            i32.eqz
            br_if $B1
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            call $j923
            i32.const 3958052 ;; LevelManager_TypeInfo
            i32.load
            i32.load offset=92
            i32.load offset=28
            i32.const 1
            i32.ne
            br_if $B1
          end
          local.get $p0
          i32.const 1
          i32.store8 offset=520
          i32.const 3964256 ;; UIManager_TypeInfo
          i32.load
          call $j923
          i32.const 3964256 ;; UIManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.load offset=32
          i32.const 1
          i32.const 0
          call $j952 ;; UnityEngine.GameObject$$SetActive
          i32.const 3964256 ;; UIManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load
          i32.const 1
          f32.const 0x0p+0 (;=0;)
          i32.const 0
          call $j8338 ;; UIManager$$SetLoadingBar
          local.get $p0
          i32.const 0
          i32.store offset=532
          return
        end
        local.get $p0
        f32.load offset=532
        local.get $p2
        local.get $p0
        f32.load offset=524
        f32.mul
        f32.add
        local.set $p2
        local.get $p0
        f32.load offset=528
        local.set $l4
        local.get $p2
        local.get $l4
        local.get $p2
        local.get $l4
        f32.lt
        select
        local.set $p2
        local.get $p0
        local.get $p2
        f32.store offset=532
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=28
        local.set $p1
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 56
        i32.const 60
        local.get $p1
        i32.const 1
        i32.eq
        select
        i32.add
        f32.load
        local.set $l4
        local.get $p0
        local.get $p2
        local.get $l4
        local.get $p2
        local.get $l4
        f32.gt
        select
        f32.store offset=532
        i32.const 3964256 ;; UIManager_TypeInfo
        i32.load
        call $j923
        i32.const 3964256 ;; UIManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 1
        local.get $p0
        f32.load offset=532
        i32.const 0
        call $j8338 ;; UIManager$$SetLoadingBar
        return
      end
      i32.const 3964256 ;; UIManager_TypeInfo
      i32.load
      call $j923
      i32.const 3964256 ;; UIManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=32
      i32.const 0
      i32.const 0
      call $j952 ;; UnityEngine.GameObject$$SetActive
    end)
