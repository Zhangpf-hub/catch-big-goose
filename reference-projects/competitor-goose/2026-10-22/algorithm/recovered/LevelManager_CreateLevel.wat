;; LevelManager$$CreateLevel
;; Function-table index: 17828; signature checked. Compiled WASM, not C# source.
  (func $j43549 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32) (local $l11 i32) (local $l12 i32) (local $l13 i32) (local $l14 i32) (local $l15 i32) (local $l16 i32) (local $l17 i32) (local $l18 i32) (local $l19 i32) (local $l20 i32) (local $l21 i64) (local $l22 f32) (local $l23 f32) (local $l24 f32) (local $l25 f64)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $l6
    local.get $l6
    global.set $primary.global$0
    i32.const 5140092
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356
      call $j922
      i32.const 3981344
      call $j922
      i32.const 3981340
      call $j922
      i32.const 3981364
      call $j922
      i32.const 3941228
      call $j922
      i32.const 3957596
      call $j922
      i32.const 3996096
      call $j922
      i32.const 3996100
      call $j922
      i32.const 3996104
      call $j922
      i32.const 3996108
      call $j922
      i32.const 3996112
      call $j922
      i32.const 3996092
      call $j922
      i32.const 3946100
      call $j922
      i32.const 3958052
      call $j922
      i32.const 4001592
      call $j922
      i32.const 3997944
      call $j922
      i32.const 4004508
      call $j922
      i32.const 3997896
      call $j922
      i32.const 3997956
      call $j922
      i32.const 4004888
      call $j922
      i32.const 4001608
      call $j922
      i32.const 4001624
      call $j922
      i32.const 4001580
      call $j922
      i32.const 3997940
      call $j922
      i32.const 3997952
      call $j922
      i32.const 3997888
      call $j922
      i32.const 4004504
      call $j922
      i32.const 4004876
      call $j922
      i32.const 4001964
      call $j922
      i32.const 4004940
      call $j922
      i32.const 4001656
      call $j922
      i32.const 4001968
      call $j922
      i32.const 4004944
      call $j922
      i32.const 3997960
      call $j922
      i32.const 4001660
      call $j922
      i32.const 3997900
      call $j922
      i32.const 3997948
      call $j922
      i32.const 4004528
      call $j922
      i32.const 3946992
      call $j922
      i32.const 3947604
      call $j922
      i32.const 3946304
      call $j922
      i32.const 3946288
      call $j922
      i32.const 3947688
      call $j922
      i32.const 3946300
      call $j922
      i32.const 3959304
      call $j922
      i32.const 3961880
      call $j922
      i32.const 3950800
      call $j922
      i32.const 4084980
      call $j922
      i32.const 4121944
      call $j922
      i32.const 4081424
      call $j922
      i32.const 4120840
      call $j922
      i32.const 4121940
      call $j922
      i32.const 4063796
      call $j922
      i32.const 4124956
      call $j922
      i32.const 5140092
      i32.const 1
      i32.store8
    end
    local.get $l6
    i32.const 0
    i32.store offset=40
    local.get $l6
    i64.const 0
    i64.store offset=32
    local.get $l6
    i64.const 0
    i64.store offset=24
    local.get $l6
    i32.const 0
    i32.store offset=20
    local.get $p0
    i32.load offset=380
    local.set $p1
    local.get $l6
    i32.const 24
    i32.add
    i32.const 20
    call $j948
    i32.const 3946304
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 3997952
    i32.load
    call $j965
    local.get $l6
    local.get $p2
    i32.store offset=24
    i32.const 3946304
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 3997952
    i32.load
    call $j965
    local.get $l6
    local.get $p2
    i32.store offset=28
    i32.const 3946288
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 3997888
    i32.load
    call $j965
    local.get $l6
    local.get $p2
    i32.store offset=32
    i32.const 3946288
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 3997888
    i32.load
    call $j965
    local.get $l6
    local.get $p2
    i32.store offset=36
    i32.const 3946300
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    i32.const 3997940
    i32.load
    call $j965
    local.get $l6
    local.get $p2
    i32.store offset=40
    local.get $p1
    local.get $l6
    i32.load offset=40
    i32.store offset=44
    local.get $l6
    i64.load offset=32
    local.set $l21
    local.get $p1
    local.get $l21
    i32.wrap_i64
    i32.store offset=36
    local.get $p1
    local.get $l21
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=40
    local.get $l6
    i64.load offset=24
    local.set $l21
    local.get $p1
    local.get $l21
    i32.wrap_i64
    i32.store offset=28
    local.get $p1
    local.get $l21
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=32
    i32.const 0
    local.set $p1
    loop $L1
      block $B2
        local.get $p0
        i32.load offset=380
        local.set $p2
        i32.const 4001964
        i32.load
        drop
        local.get $p0
        i32.load offset=380
        i32.load offset=24
        i32.load offset=12
        local.get $p1
        i32.le_s
        br_if $B2
        local.get $p2
        i32.load offset=28
        local.set $p2
        i32.const 3947688
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 4004876
        i32.load
        call $j965
        local.get $p2
        local.get $l3
        i32.const 3997956
        i32.load
        call $j955
        local.get $p0
        i32.load offset=380
        i32.load offset=32
        local.set $p2
        i32.const 3947688
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 4004876
        i32.load
        call $j965
        local.get $p2
        local.get $l3
        i32.const 3997956
        i32.load
        call $j955
        local.get $p0
        i32.load offset=380
        i32.load offset=36
        local.set $p2
        i32.const 3946992
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 4001580
        i32.load
        call $j965
        local.get $p2
        local.get $l3
        i32.const 3997896
        i32.load
        call $j955
        local.get $p0
        i32.load offset=380
        i32.load offset=40
        local.set $p2
        i32.const 3946992
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 4001580
        i32.load
        call $j965
        local.get $p2
        local.get $l3
        i32.const 3997896
        i32.load
        call $j955
        local.get $p0
        i32.load offset=380
        i32.load offset=44
        local.set $p2
        i32.const 3947604
        i32.load
        call $j924
        local.set $l3
        local.get $l3
        i32.const 4004504
        i32.load
        call $j965
        local.get $p2
        local.get $l3
        i32.const 3997944
        i32.load
        call $j955
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p2
    i32.load offset=24
    local.set $l8
    local.get $l8
    i32.const 0
    i32.const 4001968
    i32.load
    call $j947
    local.set $p2
    local.get $p2
    i32.load offset=24
    i32.load offset=12
    local.get $p2
    i32.load offset=28
    i32.load offset=12
    i32.sub
    local.set $l12
    local.get $p2
    i32.load offset=24
    local.set $l13
    local.get $p2
    i32.load offset=28
    local.set $l14
    local.get $p0
    i32.load offset=380
    local.set $p1
    local.get $p1
    i32.load offset=32
    local.set $l15
    local.get $p1
    i32.load offset=36
    local.set $l17
    local.get $p1
    i32.load offset=40
    local.set $l16
    local.get $p1
    i32.load offset=44
    local.set $l18
    local.get $p1
    i32.load offset=28
    local.set $l19
    loop $L3
      local.get $p1
      i32.load offset=12
      i32.load offset=12
      local.get $l4
      i32.gt_s
      if $I4
        i32.const 0
        local.set $p1
        i32.const 3946100
        i32.load
        call $j924
        local.set $l10
        local.get $l10
        i32.const 3996092
        i32.load
        call $j1878
        local.get $l13
        local.get $l14
        local.get $l4
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 1
        i32.sub
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.set $l11
        loop $L5
          i32.const 4001964
          i32.load
          drop
          local.get $p1
          local.get $l8
          i32.load offset=12
          i32.lt_s
          if $I6
            local.get $l10
            local.get $l8
            local.get $p1
            i32.const 4001968
            i32.load
            call $j947
            i32.load offset=36
            local.get $l4
            i32.const 2
            i32.shl
            i32.add
            f32.load offset=16
            local.get $p1
            i32.const 3996096
            i32.load
            call $j1790
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L5
          end
        end
        i32.const 0
        local.set $p1
        i32.const 3950800
        i32.load
        local.get $p2
        i32.load offset=32
        local.get $l4
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 1
        i32.add
        call $j939
        local.set $l3
        i32.const 4063796
        i32.load
        local.set $l5
        local.get $l11
        i32.const 4120840
        i32.load
        local.get $l5
        local.get $l5
        local.get $l5
        local.get $l5
        i32.const 0
        call $j1120
        local.set $l5
        local.get $l3
        local.get $l5
        call $j930
        local.get $l3
        local.get $l5
        i32.store offset=16
        loop $L7
          local.get $p1
          local.get $p2
          i32.load offset=32
          local.get $l4
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.lt_s
          if $I8
            local.get $l10
            i32.const 3996104
            i32.load
            call $j7388
            local.set $l5
            local.get $l6
            local.get $l5
            i32.store offset=20
            local.get $p0
            i32.load offset=380
            i32.load offset=28
            local.get $l5
            i32.const 3997960
            i32.load
            call $j947
            local.get $l11
            i32.const 4004888
            i32.load
            call $j955
            local.get $l6
            i32.const 20
            i32.add
            i32.const 0
            call $j1012
            local.set $l5
            local.get $l3
            local.get $l5
            call $j930
            local.get $l3
            local.get $p1
            i32.const 1
            i32.add
            i32.const 2
            i32.shl
            i32.add
            local.get $l5
            i32.store offset=16
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L7
          end
        end
        i32.const 3959304
        i32.load
        call $j923
        local.get $p1
        call $j10702
        if $I9
          local.get $l3
          i32.const 0
          call $j22836
          i32.const 0
          i32.const 0
          call $j1221
        end
        local.get $l4
        i32.const 1
        i32.add
        local.set $l4
        local.get $p0
        i32.load offset=380
        local.set $p1
        br $L3
      end
    end
    i32.const 3941228
    i32.load
    call $j924
    local.set $l11
    local.get $l11
    i32.const 3981340
    i32.load
    call $j967
    i32.const 0
    local.set $p1
    loop $L10
      local.get $p2
      i32.load offset=40
      local.set $l3
      local.get $l3
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I11
        local.get $l11
        local.get $l14
        i32.load offset=12
        local.get $p1
        i32.const 1
        i32.add
        i32.add
        local.get $l3
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        f32.load offset=16
        i32.const 3981344
        i32.load
        call $j47126
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L10
      end
    end
    local.get $p0
    local.get $p1
    call $j43539
    loop $L12
      i32.const 4001964
      i32.load
      drop
      local.get $l7
      local.get $l8
      i32.load offset=12
      i32.lt_s
      if $I13
        i32.const 3946100
        i32.load
        call $j924
        local.set $l10
        local.get $l10
        i32.const 3996092
        i32.load
        call $j1878
        block $B14
          block $B15
            local.get $l8
            local.get $l7
            i32.const 4001968
            i32.load
            call $j947
            local.set $l4
            local.get $l4
            i32.load offset=48
            local.set $l5
            local.get $l5
            if $I16
              i32.const 0
              local.set $p1
              local.get $l5
              i32.load offset=12
              local.set $p2
              local.get $p2
              local.set $l3
              local.get $p2
              br_if $B15
            end
            local.get $l14
            i32.load offset=12
            local.set $p1
            loop $L17
              local.get $p1
              i32.const 1
              i32.add
              local.set $p1
              local.get $p1
              local.get $l13
              i32.load offset=12
              i32.le_s
              if $I18
                local.get $l10
                f32.const 0x1p+0 (;=1;)
                local.get $p1
                i32.const 3996096
                i32.load
                call $j1790
                br $L17
              end
            end
            local.get $l12
            local.set $p2
            br $B14
          end
          loop $L19
            local.get $p1
            local.get $l3
            i32.ge_s
            br_if $B14
            local.get $l10
            f32.const 0x1p+0 (;=1;)
            local.get $l5
            local.get $p1
            i32.const 2
            i32.shl
            i32.add
            i32.load offset=16
            i32.const 3996096
            i32.load
            call $j1790
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            local.get $l4
            i32.load offset=48
            local.set $l5
            local.get $l5
            i32.load offset=12
            local.set $l3
            br $L19
          end
          unreachable
        end
        local.get $l4
        i32.load offset=52
        local.set $p1
        local.get $l4
        i32.load offset=76
        local.set $l3
        block $B20
          local.get $l3
          if $I21
            i32.const 0
            local.set $l5
            local.get $l3
            i32.load offset=8
            br_if $B20
          end
          i32.const 1
          local.set $l5
        end
        block $B22
          local.get $l5
          br_if $B22
          local.get $l4
          i32.load offset=76
          local.set $p1
          i32.const 3961880
          i32.load
          call $j923
          i32.const 4081424
          i32.load
          local.get $p1
          i32.const 0
          i32.const 0
          call $j4622
          local.set $l3
          local.get $l3
          local.get $l4
          i32.load offset=52
          i32.add
          local.set $p1
          i32.const 3959304
          i32.load
          call $j923
          local.get $p1
          call $j1600
          i32.eqz
          br_if $B22
          local.get $l6
          local.get $l7
          i32.store offset=16
          i32.const 3957596
          i32.load
          local.get $l6
          i32.const 16
          i32.add
          call $j935
          local.set $l5
          local.get $l6
          local.get $l3
          i32.store offset=12
          i32.const 3957596
          i32.load
          local.get $l6
          i32.const 12
          i32.add
          call $j935
          local.set $l3
          i32.const 5
          i32.const 4121940
          i32.load
          local.get $l5
          local.get $l3
          i32.const 0
          call $j1060
          i32.const 0
          call $j1429
        end
        local.get $p1
        local.get $p0
        local.get $l7
        local.get $p1
        call $j43538
        i32.sub
        local.get $p1
        local.get $l7
        local.get $p1
        call $j43534
        i32.add
        local.set $l3
        i32.const 1
        local.set $p1
        local.get $l4
        i32.load offset=44
        i32.const 3
        i32.div_s
        local.get $p0
        local.get $l7
        i32.const 1
        call $j22248
        i32.sub
        local.set $l4
        block $B23
          local.get $l3
          i32.const 1
          i32.ge_s
          if $I24
            local.get $l4
            i32.const 1
            local.get $l4
            i32.const 1
            i32.gt_s
            select
            local.set $p1
            local.get $p2
            local.get $p1
            local.get $p1
            local.get $p2
            i32.gt_s
            select
            local.set $p1
            local.get $p1
            i32.const 1
            local.get $p1
            i32.const 1
            i32.gt_s
            select
            local.set $p1
            local.get $l3
            local.get $p1
            i32.le_s
            br_if $B23
          end
          i32.const 4124956
          i32.load
          i32.const 0
          i32.const 0
          call $j1648
          local.get $p1
          local.set $l3
        end
        i32.const 3959304
        i32.load
        call $j923
        local.get $p1
        call $j1600
        if $I25
          local.get $l6
          local.get $l7
          i32.store offset=16
          i32.const 3957596
          i32.load
          local.get $l6
          i32.const 16
          i32.add
          call $j935
          local.set $p1
          local.get $l6
          local.get $l3
          i32.store offset=12
          i32.const 3957596
          i32.load
          local.get $l6
          i32.const 12
          i32.add
          call $j935
          local.set $p2
          i32.const 4121944
          i32.load
          local.get $p1
          local.get $p2
          i32.const 0
          call $j1060
          i32.const 0
          i32.const 0
          call $j1221
        end
        i32.const 0
        local.set $p1
        local.get $p0
        i32.load offset=380
        i32.load offset=36
        local.get $l7
        i32.const 3997900
        i32.load
        call $j947
        local.set $p2
        loop $L26
          local.get $p1
          local.get $l3
          i32.lt_s
          if $I27
            local.get $l10
            i32.const 3996112
            i32.load
            call $j2054
            local.set $l4
            local.get $p2
            local.get $l4
            i32.const 4001592
            i32.load
            call $j1149
            local.get $l10
            local.get $l4
            i32.const 3996108
            i32.load
            call $j22334
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L26
          end
        end
        local.get $l7
        i32.const 1
        i32.add
        local.set $l7
        br $L12
      end
    end
    loop $L28
      i32.const 4001964
      i32.load
      drop
      local.get $l9
      local.get $l8
      i32.load offset=12
      i32.lt_s
      if $I29
        local.get $l8
        local.get $l9
        i32.const 4001968
        i32.load
        call $j947
        local.set $p2
        i32.const 3958052
        i32.load
        call $j923
        i32.const 6
        local.set $p1
        i32.const 0
        local.set $l4
        i32.const 3958052
        i32.load
        i32.load offset=92
        i32.load8_u offset=80
        i32.eqz
        if $I30
          local.get $p2
          i32.load offset=44
          local.set $p1
        end
        local.get $p1
        i32.const 3
        i32.div_s
        local.get $p0
        local.get $l9
        local.get $p1
        call $j22248
        i32.sub
        local.set $p2
        local.get $l17
        local.get $l9
        i32.const 3997900
        i32.load
        call $j947
        local.set $p1
        f32.const 0x0p+0 (;=0;)
        local.set $l22
        local.get $l16
        local.get $l9
        i32.const 3997900
        i32.load
        call $j947
        local.set $l3
        loop $L31
          i32.const 4001656
          i32.load
          drop
          local.get $l4
          local.get $p1
          i32.load offset=12
          i32.lt_s
          if $I32
            local.get $l22
            local.get $l11
            local.get $p1
            local.get $l4
            i32.const 4001660
            i32.load
            call $j947
            i32.const 3981364
            i32.load
            call $j15242
            f32.add
            local.set $l22
            local.get $l4
            i32.const 1
            i32.add
            local.set $l4
            br $L31
          end
        end
        local.get $p2
        i32.const 1
        local.get $p2
        i32.const 1
        i32.gt_s
        select
        local.set $l5
        local.get $l5
        f32.convert_i32_s
        local.set $l23
        i32.const 0
        local.set $l4
        loop $L33
          i32.const 4001656
          i32.load
          drop
          local.get $l4
          local.get $p1
          i32.load offset=12
          i32.const 1
          i32.sub
          i32.lt_s
          if $I34
            local.get $l23
            local.get $l11
            local.get $p1
            local.get $l4
            i32.const 4001660
            i32.load
            call $j947
            i32.const 3981364
            i32.load
            call $j15242
            f32.mul
            local.get $l22
            f32.div
            local.set $l24
            i32.const 5155396
            i32.load8_u
            i32.eqz
            if $I35
              i32.const 3958620
              call $j922
              i32.const 5155396
              i32.const 1
              i32.store8
            end
            i32.const 3958620
            i32.load
            call $j923
            local.get $l24
            f64.promote_f32
            call $j1188
            local.set $l25
            block $B36
              local.get $l25
              f64.abs
              f64.const 0x1p+31 (;=2.14748e+09;)
              f64.lt
              if $I37
                local.get $l25
                i32.trunc_f64_s
                local.set $p2
                br $B36
              end
              i32.const -2147483648
              local.set $p2
            end
            local.get $l3
            local.get $p2
            i32.const 4001592
            i32.load
            call $j1149
            local.get $l5
            local.get $p2
            i32.sub
            local.set $l5
            local.get $l4
            i32.const 1
            i32.add
            local.set $l4
            br $L33
          end
        end
        local.get $l3
        local.get $l5
        i32.const 4001592
        i32.load
        call $j1149
        local.get $l9
        i32.const 1
        i32.add
        local.set $l9
        br $L28
      end
    end
    i32.const 0
    local.set $l3
    loop $L38
      i32.const 4001964
      i32.load
      drop
      local.get $l3
      local.get $l8
      i32.load offset=12
      i32.lt_s
      if $I39
        local.get $l8
        local.get $l3
        i32.const 4001968
        i32.load
        call $j947
        i32.load offset=44
        i32.const 3
        i32.div_s
        local.set $p1
        local.get $p0
        i32.load offset=448
        local.set $p2
        block $B40
          local.get $p2
          i32.eqz
          br_if $B40
          local.get $p2
          i32.load offset=12
          local.set $p2
          local.get $p2
          i32.eqz
          br_if $B40
          local.get $l3
          local.get $p2
          i32.load offset=12
          i32.ge_s
          br_if $B40
          local.get $p1
          local.get $p2
          local.get $l3
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.sub
          local.set $p1
          local.get $p1
          i32.const 1
          local.get $p1
          i32.const 1
          i32.gt_s
          select
          local.set $p1
        end
        local.get $p1
        f32.convert_i32_s
        local.set $l22
        i32.const 0
        local.set $p1
        local.get $l18
        local.get $l3
        i32.const 3997948
        i32.load
        call $j947
        local.set $l12
        local.get $l16
        local.get $l3
        i32.const 3997900
        i32.load
        call $j947
        local.set $p2
        loop $L41
          i32.const 4001656
          i32.load
          drop
          local.get $p1
          local.get $p2
          i32.load offset=12
          i32.lt_s
          if $I42
            local.get $l12
            local.get $p2
            local.get $p1
            i32.const 4001660
            i32.load
            call $j947
            f32.convert_i32_s
            local.get $l22
            f32.div
            i32.const 4004508
            i32.load
            call $j3189
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L41
          end
        end
        local.get $l3
        i32.const 1
        i32.add
        local.set $l3
        br $L38
      end
    end
    local.get $l13
    i32.load offset=12
    local.set $l9
    i32.const 0
    local.set $l5
    loop $L43
      local.get $l9
      i32.const 1
      i32.sub
      local.set $l9
      local.get $l9
      local.get $l14
      i32.load offset=12
      i32.ge_s
      if $I44
        i32.const 0
        local.set $l3
        local.get $l9
        i32.const 1
        i32.add
        local.set $l4
        i32.const 3946100
        i32.load
        call $j924
        local.set $p2
        local.get $p2
        i32.const 3996092
        i32.load
        call $j1878
        local.get $l13
        local.get $l9
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.set $l10
        i32.const 0
        local.set $p1
        i32.const 0
        local.set $l12
        loop $L45
          i32.const 4001964
          i32.load
          drop
          local.get $p1
          local.get $l8
          i32.load offset=12
          i32.lt_s
          if $I46
            local.get $l17
            local.get $p1
            i32.const 3997900
            i32.load
            call $j947
            local.set $l7
            local.get $l18
            local.get $p1
            i32.const 3997948
            i32.load
            call $j947
            local.set $l11
            local.get $l16
            local.get $p1
            i32.const 3997900
            i32.load
            call $j947
            local.set $l20
            local.get $l7
            local.get $l4
            i32.const 4001608
            i32.load
            call $j1432
            if $I47
              local.get $l7
              local.get $l4
              i32.const 4001624
              i32.load
              call $j43274
              local.set $l7
              local.get $p2
              local.get $l11
              local.get $l7
              i32.const 4004528
              i32.load
              call $j4080
              local.get $p1
              i32.const 3996096
              i32.load
              call $j1790
              local.get $l20
              local.get $l7
              i32.const 4001660
              i32.load
              call $j947
              i32.const 3
              i32.mul
              local.get $l12
              i32.add
              local.set $l12
            end
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L45
          end
        end
        loop $L48
          local.get $l3
          local.get $l12
          i32.ge_s
          br_if $L43
          i32.const 0
          local.set $p1
          block $B49
            local.get $p2
            i32.const 3996100
            i32.load
            call $j5716
            br_if $B49
            loop $L50
              i32.const 4001964
              i32.load
              drop
              local.get $p1
              local.get $l8
              i32.load offset=12
              i32.ge_s
              br_if $B49
              i32.const 3958052
              i32.load
              call $j923
              i32.const 6
              local.set $l4
              i32.const 3958052
              i32.load
              i32.load offset=92
              i32.load8_u offset=80
              i32.eqz
              if $I51
                local.get $l8
                local.get $p1
                i32.const 4001968
                i32.load
                call $j947
                i32.load offset=44
                local.set $l4
              end
              local.get $l15
              local.get $p1
              i32.const 3997960
              i32.load
              call $j947
              local.set $l7
              i32.const 4004940
              i32.load
              drop
              local.get $l4
              local.get $l7
              i32.load offset=12
              i32.gt_s
              if $I52
                local.get $p2
                f32.const 0x1p+0 (;=1;)
                local.get $p1
                i32.const 3996096
                i32.load
                call $j1790
              else
                local.get $p1
                i32.const 1
                i32.add
                local.set $p1
                br $L50
              end
            end
          end
          local.get $p2
          i32.const 3996100
          i32.load
          call $j5716
          i32.eqz
          br_if $L43
          local.get $p2
          i32.const 3996112
          i32.load
          call $j2054
          local.set $p1
          i32.const 3958052
          i32.load
          call $j923
          i32.const 6
          local.set $l4
          i32.const 3958052
          i32.load
          i32.load offset=92
          i32.load8_u offset=80
          i32.eqz
          if $I53
            local.get $l8
            local.get $p1
            i32.const 4001968
            i32.load
            call $j947
            i32.load offset=44
            local.set $l4
          end
          local.get $l15
          local.get $p1
          i32.const 3997960
          i32.load
          call $j947
          local.set $l7
          i32.const 4004940
          i32.load
          drop
          block $B54
            local.get $l4
            local.get $l7
            i32.load offset=12
            i32.gt_s
            if $I55
              local.get $l15
              local.get $p1
              i32.const 3997960
              i32.load
              call $j947
              local.get $l10
              i32.const 4004888
              i32.load
              call $j955
              br $B54
            end
            local.get $l3
            i32.const 1
            i32.sub
            local.set $l3
            local.get $p2
            local.get $p1
            i32.const 3996108
            i32.load
            call $j22334
          end
          local.get $l3
          i32.const 1
          i32.add
          local.set $l3
          br $L48
        end
        unreachable
      end
    end
    loop $L56
      block $B57
        i32.const 0
        local.set $p1
        i32.const 4001964
        i32.load
        drop
        local.get $l5
        local.get $l8
        i32.load offset=12
        i32.ge_s
        br_if $B57
        loop $L58
          local.get $l19
          local.get $l5
          i32.const 3997960
          i32.load
          call $j947
          local.set $p2
          i32.const 4004940
          i32.load
          drop
          local.get $p1
          local.get $p2
          i32.load offset=12
          i32.lt_s
          if $I59
            local.get $l15
            local.get $l5
            i32.const 3997960
            i32.load
            call $j947
            local.get $l19
            local.get $l5
            i32.const 3997960
            i32.load
            call $j947
            local.get $p1
            i32.const 4004944
            i32.load
            call $j947
            i32.const 4004888
            i32.load
            call $j955
            local.get $p1
            i32.const 1
            i32.add
            local.set $p1
            br $L58
          end
        end
        local.get $l5
        i32.const 1
        i32.add
        local.set $l5
        br $L56
      end
    end
    local.get $p0
    i32.const 4084980
    i32.load
    i32.const 0
    call $j1451
    i32.const 3958052
    i32.load
    call $j923
    i32.const 3958052
    i32.load
    i32.load offset=92
    i32.load offset=12
    if $I60
      i32.const 3958052
      i32.load
      call $j923
      i32.const 3958052
      i32.load
      i32.load offset=92
      drop
    end
    local.get $p0
    i32.const 4084980
    i32.load
    i32.const 0
    call $j1559
    drop
    i32.const 3951356
    i32.load
    call $j923
    i32.const 3951356
    i32.load
    i32.load offset=92
    i32.load offset=28
    local.set $p0
    local.get $p0
    if $I61
      local.get $p0
      i32.load offset=32
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      global.set $__wasm_split_waitTableId
      global.get $__wasm_split_waitTableId
      call_indirect $primary.table (type $t0)
    end
    local.get $l6
    i32.const 48
    i32.add
    global.set $primary.global$0)
