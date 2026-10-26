import math
from modelkit import *

def antique(id):
    if id=='jadevase':
        lathe('vase',[(-.4,.17),(-.31,.24),(-.10,.29),(.1,.24),(.26,.10),(.39,.12)],1)
        ring('mouth',(0,0,.39),.11,.027,2);disc('foot',(0,0,-.4),.19,.07,2)
        ring('neck_band',(0,0,.24),.10,.022,2)
    elif id=='jadepeanut':
        for s in [-1,1]:ball('peanut_lobe',(s*.17,0,0),(.27,.19,.22),9,20,10)
        for x in [-.29,-.14,.14,.29]:
            tube('shell_seam',[(x,-.16,-.10),(x,-.20,0),(x,-.16,.10)],.014,2)
        ring('pendant_ring',(.39,0,.02),.07,.026,2,rotation=(math.pi/2,0,0))
    elif id=='jadecarp':
        ball('fish_body',(0,0,0),(.34,.15,.21),1,24,12)
        for s in [-1,1]:
            o=ball('tail',(.36,0,s*.10),(.18,.06,.11),12);o.rotation_euler.y=s*.4
        raw_mesh('dorsal',[(-.15,0,.14),(.12,0,.17),(.02,0,.33),(-.15,.04,.14),(.12,.04,.17),(.02,.04,.33)],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)],12)
        for y in [-.145,.145]:ball('eye',(-.22,y,.07),(.04,.023,.04),2,12,6)
    elif id=='jadetiger':
        ball('body',(0,0,0),(.32,.16,.15),2)
        ball('head',(-.28,0,.13),(.16,.16,.16),2)
        for x in [-.21,.20]:
            for y in [-.12,.12]:ball('leg',(x,y,-.14),(.075,.065,.13),2)
        for y in [-.105,.105]:ball('round_ear',(-.28,y,.26),(.065,.045,.065),2,12,6)
        for x in [-.10,.06,.20]:tube('back_stripe',[(x,-.12,.10),(x,0,.16),(x,.12,.10)],.018,6)
        for y in [-.13,.13]:ball('eye',(-.36,y,.17),(.023,.016,.023),5,12,6)
        tube('curled_tail',[(.27,0,.02),(.40,0,.08),(.42,0,.23),(.32,0,.26)],.035,2)
    elif id=='jadetalisman':
        box('jade_plaque',(0,0,0),(.48,.14,.65),1,.06)
        ring('cord_loop',(0,0,.39),.075,.025,2,rotation=(math.pi/2,0,0))
        for x in [-.10,.10]:box('raised_symbol',(x,-.085,0),(.04,.026,.32),2,.009)
        box('symbol_cross',(0,-.085,0),(.26,.027,.04),2,.009)
    elif id=='goldring':
        ring('gold_band',(0,0,0),.26,.065,2,rotation=(math.pi/2,0,0))
        box('gem_seat',(0,0,.29),(.24,.18,.09),2,.025)
        ball('blue_gem',(0,0,.35),(.12,.09,.09),4,12,6)
    elif id=='goldchime':
        lathe('bell_body',[(-.34,.31),(-.26,.29),(.02,.25),(.26,.16)],2)
        ring('bell_lip',(0,0,-.33),.29,.035,9)
        ring('hanging_loop',(0,0,.33),.10,.035,2,rotation=(math.pi/2,0,0))
        for j in range(8):
            a=j*math.tau/8
            ball('bell_stud',(.25*math.cos(a),.25*math.sin(a),-.02),(.025,.025,.025),6,10,5)
    elif id=='jadechime':
        box('left_arm',(-.14,0,.06),(.48,.15,.17),1,.035,(0,.48,0))
        box('right_arm',(.15,0,.07),(.48,.15,.17),1,.035,(0,-.48,0))
        ring('suspension',(0,0,.26),.065,.025,2,rotation=(math.pi/2,0,0))
        tube('gold_inlay',[(-.34,-.084,.14),(0,-.084,-.03),(.34,-.084,.15)],.012,2)
    elif id=='jadeleaf':
        o=ball('leaf_pendant',(0,0,0),(.20,.08,.36),12,20,10)
        tube('central_vein',[(0,-.08,-.30),(0,-.093,0),(0,-.07,.30)],.015,2)
        for s in [-1,1]:
            for z in [-.15,.04]:tube('side_vein',[(0,-.09,z),(s*.14,-.07,z+.12)],.010,2)
        ring('hanging_eye',(0,0,.39),.06,.025,2,rotation=(math.pi/2,0,0))
    elif id=='jadelock':
        box('lock_body',(0,0,0),(.51,.16,.27),2,.07)
        for x in [-.26,.26]:ball('lock_shoulder',(x,0,.06),(.12,.09,.11),2)
        ring('lock_loop',(0,0,.27),.14,.035,6,rotation=(math.pi/2,0,0))
        disc('raised_medallion',(0,-.093,0),.08,.025,10,rotation=(math.pi/2,0,0))
    elif id=='jadeteapot':
        ball('pot_body',(0,0,0),(.28,.23,.23),1,24,12)
        tube('spout',[(-.22,0,.01),(-.37,0,.13),(-.45,0,.27)],.064,1)
        ring('handle',(.26,0,.06),.18,.04,2,rotation=(math.pi/2,0,0))
        disc('lid',(0,0,.22),.19,.05,1);ball('lid_knob',(0,0,.28),(.05,.05,.05),2)
        ring('foot',(0,0,-.20),.15,.026,2)
    elif id=='jadebeads':
        for j in range(12):
            a=j*math.tau/12
            ball('jade_bead',(.30*math.cos(a),.30*math.sin(a),0),(.085,.085,.085),2 if j%4==0 else 1,14,7)
        ring('string',(0,0,0),.30,.018,2)
        ball('drop_bead',(0,-.39,-.06),(.105,.13,.095),1)
    else:raise ValueError(id)

def dessert(id):
    if id=='chocolate':
        box('chocolate_base',(0,0,0),(.64,.84,.13),6,.025)
        for y in [-.27,0,.27]:
            for x in [-.16,.16]:box('chocolate_square',(x,y,.09),(.27,.23,.10),6,.025)
        box('wrapper_corner',(.20,-.31,-.02),(.27,.24,.15),9,.012,(0,0,.12))
    elif id=='lollipop':
        disc('thick_sweet',(0,0,.18),.28,.13,10,rotation=(math.pi/2,0,0))
        tube('cream_spiral',[(.018*t*math.cos(t),-.078,.18+.018*t*math.sin(t)) for t in [j*.16 for j in range(80)]],.016,7)
        disc('sweet_stick',(0,0,-.22),.027,.60,7,vertices=16)
    elif id=='popsicle':
        box('ice_body',(0,0,.08),(.40,.18,.62),8,.075)
        box('fruit_dip',(0,0,.24),(.405,.185,.30),10,.06)
        box('wood_stick',(0,0,-.35),(.09,.07,.33),9,.035)
        for x in [-.10,0,.10]:box('pressed_groove',(x,-.099,.03),(.018,.018,.26),15,.007)
    elif id=='wafer':
        for z,c in [(-.08,9),(-.02,6),(.04,9),(.10,6),(.16,9)]:box('wafer_layer',(0,0,z),(.65,.49,.065),c,.012)
        for x in [-.23,-.08,.08,.23]:box('waffle_ridge',(x,0,.205),(.022,.45,.026),2,.006)
        for y in [-.16,0,.16]:box('waffle_cross',(0,y,.205),(.60,.022,.026),2,.006)
    elif id=='swissroll':
        disc('golden_roll',(0,0,0),.29,.55,9,rotation=(math.pi/2,0,0))
        disc('cream_end',(0,-.281,0),.24,.017,7,rotation=(math.pi/2,0,0))
        tube('rolled_filling',[(.017*t*math.cos(t),-.295,.017*t*math.sin(t)) for t in [j*.15 for j in range(85)]],.022,6)
    elif id=='eggtart':
        lathe('tart_crust',[(-.12,.24),(-.07,.30),(.10,.34)],9)
        disc('custard',(0,0,.10),.29,.045,2)
        for j in range(12):
            a=j*math.tau/12
            ball('fluted_rim',(.30*math.cos(a),.30*math.sin(a),.075),(.045,.045,.08),9,10,5)
        for x,y in [(-.10,.08),(.12,.06),(.02,-.12)]:ball('baked_patch',(x,y,.128),(.035,.05,.008),6,10,5)
    elif id=='pancake':
        for z in [-.13,0,.13]:disc('pancake',(0,0,z),.34,.11,9)
        ring('syrup_rim',(0,0,.193),.23,.025,6)
        box('butter',(0,0,.23),(.16,.15,.06),13,.02,(0,0,.24))
    elif id=='pretzel':
        pts=[(-.08,0,-.23),(-.31,0,-.04),(-.30,0,.22),(-.11,0,.31),(.02,0,.15),(.16,0,-.15),(.28,0,-.03),(.29,0,.22),(.12,0,.31),(-.02,-.07,.15),(-.17,-.07,-.15),(.09,-.07,-.23)]
        tube('continuous_dough',pts,.075,6)
        for x,z in [(-.25,.15),(.24,.13),(-.13,-.12),(.12,-.12)]:box('coarse_salt',(x,-.075,z),(.035,.024,.027),7,.004)
    elif id=='toast':
        box('bread_crust',(0,0,-.03),(.57,.18,.53),6,.06)
        ball('rounded_top',(0,0,.24),(.29,.09,.17),6)
        box('bread_center',(0,-.105,-.01),(.47,.04,.43),9,.05)
        ball('inner_top',(0,-.10,.21),(.235,.025,.13),9)
    elif id=='dumpling':
        ball('bun_body',(0,0,-.025),(.31,.30,.23),9,24,12)
        for j in range(8):
            a=j*math.tau/8
            tube('pleat',[(.24*math.cos(a),.24*math.sin(a),.07),(.12*math.cos(a),.12*math.sin(a),.22),(.045*math.cos(a),.045*math.sin(a),.28)],.019,7)
        ring('closed_pinched_top',(0,0,.25),.052,.025,9)
        disc('base_skin',(0,0,-.23),.25,.05,7)
    elif id=='mooncake':
        disc('cake_body',(0,0,0),.32,.24,2)
        for j in range(16):
            a=j*math.tau/16
            ball('fluted_edge',(.30*math.cos(a),.30*math.sin(a),0),(.035,.035,.12),9,10,5)
        ring('embossed_rim',(0,0,.125),.24,.018,6)
        box('center_stamp',(0,0,.14),(.17,.17,.026),6,.02)
    elif id=='teacup':
        lathe('cup',[(-.35,.17),(.30,.26)],10)
        disc('lid',(0,0,.32),.28,.06,7)
        disc('lid_top',(0,0,.36),.24,.03,10)
        o=disc('thick_straw',(.08,0,.52),.026,.37,2,vertices=16);o.rotation_euler.y=.14
        ring('cup_band',(0,0,-.10),.205,.027,9)
    else:raise ValueError(id)
