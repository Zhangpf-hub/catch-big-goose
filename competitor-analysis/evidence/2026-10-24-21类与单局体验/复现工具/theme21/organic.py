import math
from modelkit import *

def fruit(id):
    if id=='watermelon':
        ball('melon',(0,0,0),(.36,.33,.47),12,24,12)
        for i in range(7):
            a=i*math.tau/7
            tube('rind_stripe',[(.364*math.sin(t)*math.cos(a),.334*math.sin(t)*math.sin(a),.474*math.cos(t)) for t in [.12+j*(math.pi-.24)/14 for j in range(15)]],.016,1)
        stem(.5,1)
    elif id=='pineapple':
        ball('fruit_body',(0,0,-.08),(.30,.30,.39),2,20,10)
        for row in range(4):
            z=-.30+row*.15
            for j in range(10):
                a=(j+row*.5)*math.tau/10
                box('rind_diamond',(.29*math.cos(a),.29*math.sin(a),z),(.07,.045,.08),9,.009,(0,.2,a+math.pi/2),1)
        for j in range(7):
            a=j*math.tau/7
            o=leaf('crown',(.12*math.sin(a),.12*math.cos(a),.36),.24,.055,12,-a)
            o.rotation_euler.x=.9
        stem(.40,12)
    elif id=='peach':
        for s in [-1,1]:ball('peach_lobe',(s*.095,0,0),(.255,.30,.34),10,20,10)
        tube('crease',[(0,-.29,-.19),(0,-.307,0),(0,-.25,.23)],.012,0)
        stem(.36);leaf('leaf',(.14,0,.40),.19,.07,12,.7)
    elif id=='kiwi':
        disc('brown_skin',(0,0,0),.36,.24,6)
        disc('green_cut',(0,0,.123),.329,.019,12)
        disc('pale_core',(0,0,.135),.09,.018,9,vertices=16)
        for i in range(14):
            a=i*math.tau/14
            o=ball('seed',(.20*math.cos(a),.20*math.sin(a),.143),(.016,.031,.008),5,8,4);o.rotation_euler.z=a-math.pi/2
    elif id=='mango':
        o=ball('curved_fruit',(0,0,0),(.29,.24,.43),2,24,12)
        for v in o.data.vertices:v.co.x+=.11*(v.co.z/.43)**2
        stem(.45);leaf('mango_leaf',(.12,0,.48),.17,.055,12,.6)
    elif id=='coconut':
        ball('thick_shell',(0,0,0),(.36,.34,.39),6,24,12)
        for x,z in [(-.09,.17),(.09,.17),(0,.02)]:ball('germination_eye',(x,-.32,z),(.045,.018,.045),5,12,6)
        for i in range(5):
            a=i*math.tau/5
            tube('shell_ridge',[(.362*math.sin(t)*math.cos(a),.342*math.sin(t)*math.sin(a),.392*math.cos(t)) for t in [.2+j*(math.pi-.4)/12 for j in range(13)]],.012,9)
    elif id=='blueberry':
        for x,y,z in [(-.20,0,0),(.19,0,.03),(0,.19,.12)]:
            ball('berry',(x,y,z),(.22,.21,.22),4)
            for j in range(5):
                a=j*math.tau/5
                leaf('calyx',(x+.045*math.sin(a),y+.045*math.cos(a),z+.207),.06,.022,3,-a)
        tube('connecting_branch',[(-.2,0,.15),(0,.12,.23),(.19,0,.18)],.025,1)
    elif id=='dragonfruit':
        ball('pink_rind',(0,0,0),(.29,.28,.43),10,24,12)
        for row in range(3):
            for j in range(5):
                a=(j+.4*row)*math.tau/5
                o=leaf('thick_scale',(.25*math.sin(a),.25*math.cos(a),-.24+row*.23),.12,.045,12,-a)
                o.rotation_euler.x=.8
        stem(.43,12)
    elif id=='avocado':
        ball('skin_lower',(0,0,-.12),(.30,.22,.31),12,20,10)
        ball('skin_upper',(0,0,.16),(.23,.20,.27),12,20,10)
        ball('cut_flesh',(0,-.19,-.025),(.257,.055,.363),9,20,10)
        ball('large_pit',(0,-.245,-.10),(.125,.075,.135),6)
        stem(.40)
    elif id=='pomegranate':
        ball('red_body',(0,0,0),(.34,.33,.36),0,24,12)
        lathe('crown_base',[(.31,.075),(.42,.09),(.46,.11)],6)
        for j in range(6):
            a=j*math.tau/6
            box('crown_tip',(.095*math.cos(a),.095*math.sin(a),.47),(.045,.045,.12),0,.012,segments=1)
    elif id=='persimmon':
        for x in [-.10,.10]:
                for y in [-.10,.10]:ball('fruit_lobe',(x,y,0),(.235,.235,.245),2)
        radial_leaves(.23,4,.09,.08,.18,12);stem(.31)
    elif id=='starfruit':
        verts=[]
        for z in [-.32,.32]:
            verts.extend(((.36 if j%2==0 else .19)*math.cos(j*math.pi/5),(.36 if j%2==0 else .19)*math.sin(j*math.pi/5),z) for j in range(10))
        faces=[tuple(reversed(range(10))),tuple(range(10,20))]+[(j,(j+1)%10,(j+1)%10+10,j+10) for j in range(10)]
        raw_mesh('five_ridge_body',verts,faces,13)
        for j in range(5):
            a=j*math.tau/5
            tube('green_edge',[(.36*math.cos(a),.36*math.sin(a),-.30),(.36*math.cos(a),.36*math.sin(a),.30)],.017,12)
    else:raise ValueError(id)

def farm(id):
    if id=='tomato':
        ball('tomato',(0,0,0),(.36,.35,.31),0,24,12);radial_leaves(.30);stem(.38,12)
    elif id=='potato':
        o=ball('irregular_tuber',(0,0,0),(.43,.26,.29),9,24,12)
        for v in o.data.vertices:v.co.y+=.035*math.sin(v.co.x*14)*math.cos(v.co.z*8)
        for x,z in [(-.22,.1),(.05,.19),(.25,-.04),(-.1,-.16)]:ball('eye',(x,-.245,z),(.027,.015,.021),6,10,5)
    elif id=='cabbage':
        ball('pale_heart',(0,0,.05),(.22,.22,.37),9)
        for j in range(6):
            a=j*math.tau/6
            o=ball('enclosing_leaf',(.14*math.sin(a),.14*math.cos(a),-.02),(.18,.18,.33),1)
            o.rotation_euler.y=.20*math.cos(a);o.rotation_euler.x=.20*math.sin(a)
        disc('white_stalk',(0,0,-.32),.13,.10,7,vertices=16)
    elif id=='broccoli':
        lathe('stem',[(-.4,.08),(-.12,.12),(.12,.11)],1,segments=16)
        for j in range(6):
            a=j*math.tau/6
            tube('branch',[(.025*math.sin(a),.025*math.cos(a),-.07),(.15*math.sin(a),.15*math.cos(a),.12)],.055,1)
            ball('floret',(.20*math.sin(a),.20*math.cos(a),.17),(.19,.19,.19),12)
        ball('top_floret',(0,0,.27),(.22,.22,.19),12)
    elif id=='bellpepper':
        for j in range(3):
            a=j*math.tau/3
            ball('pepper_lobe',(.12*math.sin(a),.12*math.cos(a),0),(.20,.20,.34),0,20,10)
        tube('curved_stem',[(0,0,.29),(0,0,.43),(.10,0,.46)],.045,12)
    elif id=='cucumber':
        lathe('cucumber_body',[(-.46,.045),(-.38,.10),(-.18,.14),(.1,.13),(.36,.10),(.44,.045)],12,segments=20)
        for j in range(6):
            a=j*math.tau/6
            tube('light_rib',[(.105*math.cos(a),.105*math.sin(a),-.34),(.145*math.cos(a),.145*math.sin(a),-.12),(.13*math.cos(a),.13*math.sin(a),.20),(.08*math.cos(a),.08*math.sin(a),.37)],.013,1)
        for z in [-.22,0,.21]:
            for j in range(5):
                a=(j+.5)*math.tau/5
                ball('skin_bump',(.125*math.sin(a),.125*math.cos(a),z),(.02,.02,.026),1,8,4)
    elif id=='onion':
        lathe('purple_bulb',[(-.31,.10),(-.25,.26),(-.06,.34),(.13,.28),(.28,.12),(.44,.045)],3)
        for j in range(7):
            a=j*math.tau/7
            tube('onion_layer',[(r*math.sin(a),r*math.cos(a),z) for z,r in [(-.27,.16),(-.1,.34),(.12,.29),(.29,.11),(.43,.045)]],.011,14)
        disc('root_disc',(0,0,-.32),.11,.045,9)
    elif id=='radish':
        lathe('white_root',[(-.45,.025),(-.28,.11),(.0,.19),(.23,.18),(.32,.11)],7)
        for j in range(5):
            a=j*math.tau/5
            leaf('green_top',(.1*math.sin(a),.1*math.cos(a),.36),.19,.06,12,-a)
        stem(.4,12)
    elif id=='garlic':
        for j in range(6):
            a=j*math.tau/6
            ball('garlic_clove',(.13*math.sin(a),.13*math.cos(a),0),(.14,.14,.25),9)
        lathe('neck',[(.16,.11),(.40,.04)],7,segments=16)
        disc('root',(0,0,-.23),.14,.05,6)
    elif id=='wateringcan':
        lathe('can',[(-.25,.22),(-.19,.29),(.18,.29),(.27,.21)],8)
        tube('spout',[(.22,0,-.05),(.43,0,.12),(.60,0,.30)],.07,8)
        disc('sprinkler',(.60,0,.30),.11,.08,2,rotation=(0,.8,0))
        ring('handle',(-.23,0,.30),.23,.043,2,rotation=(math.pi/2,0,0))
        disc('fill_lid',(0,0,.27),.12,.04,7)
    elif id=='egg':
        o=ball('egg_shell',(0,0,.015),(.25,.25,.40),9,24,12)
        for v in o.data.vertices:
            t=(v.co.z+.4)/.8;v.co.x*=1-.25*t;v.co.y*=1-.25*t
        ring('egg_cup',(0,0,-.30),.18,.055,7)
    elif id=='shovel':
        box('blade',(0,0,-.28),(.46,.10,.36),4,.055)
        disc('wood_handle',(0,0,.10),.045,.60,6,vertices=16)
        ring('grip',(0,0,.48),.12,.04,2,rotation=(math.pi/2,0,0))
        box('blade_rib',(0,-.06,-.21),(.06,.03,.30),8,.012)
    else:raise ValueError(id)
