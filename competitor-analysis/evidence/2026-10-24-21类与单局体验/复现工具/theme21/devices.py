import math
from modelkit import *

def screen(loc,size,color=8):
    box('bezel',loc,size,5,.035)
    box('display',(loc[0],loc[1]-.025,loc[2]),(size[0]*.85,size[1],size[2]*.78),color,.025)

def electronics(id):
    if id=='tablet':
        box('tablet_body',(0,0,0),(.72,.10,.94),14,.06)
        screen((0,-.052,.015),(.65,.025,.81),8)
        box('home_bar',(0,-.071,-.38),(.16,.02,.02),7,.006)
        disc('rear_camera',(-.24,.066,.31),.06,.045,5,rotation=(math.pi/2,0,0))
        box('side_button',(.36,0,.24),(.03,.045,.13),2,.009)
    elif id=='keyboard':
        box('keyboard_base',(0,0,0),(.94,.49,.13),1,.05)
        for row in range(3):
            for col in range(8):box('keycap',(-.38+col*.108,-.15+row*.135,.085),(.084,.10,.05),7 if (col+row)%5 else 10,.012,segments=1)
        box('spacebar',(0,-.22,.085),(.39,.07,.05),2,.012)
    elif id=='monitor':
        box('back_case',(0,0,.16),(.88,.14,.55),8,.055)
        screen((0,-.085,.18),(.79,.025,.45),15)
        box('support',(0,.02,-.18),(.12,.14,.29),6,.025)
        box('foot',(0,0,-.34),(.49,.32,.07),8,.025)
        box('power_light',(.29,-.092,-.07),(.035,.02,.018),12,.004)
    elif id=='television':
        box('tv_case',(0,0,.04),(.85,.27,.59),6,.055)
        screen((-.06,-.15,.05),(.60,.045,.45),8)
        for z in [-.07,.12]:disc('control',(.335,-.155,z),.048,.04,2,rotation=(math.pi/2,0,0))
        for x in [-.27,.27]:box('tv_foot',(x,0,-.31),(.12,.23,.12),5,.02)
    elif id=='printer':
        box('printer_body',(0,0,0),(.72,.48,.32),7,.045)
        box('scanner_lid',(0,.03,.20),(.69,.42,.09),8,.025)
        box('output_slot',(0,-.25,-.04),(.47,.025,.085),5,.012)
        box('paper',(0,-.38,-.02),(.38,.33,.025),7,.008)
        box('paper_tray',(0,.23,.21),(.48,.08,.24),1,.018,(-.2,0,0))
        for x in [.19,.26]:disc('status_button',(x,-.11,.25),.022,.015,12,vertices=12)
    elif id=='router':
        box('router_box',(0,0,-.11),(.66,.43,.18),9,.045)
        for x in [-.25,.25]:
            box('antenna_hinge',(x,.12,.0),(.09,.08,.10),5,.02)
            box('thick_antenna',(x,.13,.26),(.065,.065,.50),7,.025,(0,x*.4,0))
        for x in [-.16,0,.16]:ball('status_light',(x,-.222,-.08),(.022,.012,.022),12,10,5)
        for x in [-.12,.12]:box('port',(x,.225,-.10),(.13,.025,.07),5,.007)
    elif id=='usbdrive':
        box('usb_shell',(0,0,-.11),(.30,.15,.54),10,.06)
        box('metal_connector',(0,0,.28),(.23,.11,.25),7,.018)
        for x in [-.055,.055]:box('connector_recess',(x,-.06,.30),(.04,.018,.065),5,.004)
        ring('key_loop',(0,0,-.42),.07,.025,2,rotation=(math.pi/2,0,0))
    elif id=='powerbank':
        box('battery_case',(0,0,0),(.43,.22,.79),2,.065)
        box('end_panel',(0,0,.37),(.36,.18,.065),5,.02)
        for x in [-.09,.09]:box('port',(x,-.005,.406),(.12,.08,.018),7,.008)
        for x in [-.12,-.04,.04,.12]:box('charge_light',(x,-.117,.20),(.028,.02,.025),12,.006)
    elif id=='microphone':
        ball('grille_head',(0,0,.28),(.21,.21,.22),6,24,12)
        for z in [.16,.25,.34]:ring('grille_ring',(0,0,z),.20 if z<.3 else .195,.012,7)
        lathe('grip',[(-.40,.075),(-.27,.09),(.12,.10)],3,segments=20)
        box('switch',(0,-.101,-.12),(.055,.025,.12),5,.015)
        disc('end_cap',(0,0,-.4),.08,.045,5)
    elif id=='gamepad':
        box('central_body',(0,0,0),(.56,.17,.30),4,.07)
        for x in [-.30,.30]:
            o=ball('grip',(x,0,-.07),(.20,.12,.25),4,20,10);o.rotation_euler.y=-x*.65
        for loc,size in [((-.27,-.135,.02),(.17,.04,.06)),((-.27,-.135,.02),(.06,.04,.17))]:box('dpad',loc,size,5,.015)
        for x,z,c in [(.24,.10,0),(.32,.02,13),(.24,-.06,12),(.16,.02,10)]:disc('action_button',(x,-.13,z),.034,.035,c,rotation=(math.pi/2,0,0),vertices=16)
        for x in [-.10,.10]:disc('thumbstick',(x,-.14,-.07),.054,.04,5,rotation=(math.pi/2,0,0))
    elif id=='flashlight':
        lathe('grip',[(-.42,.10),(-.30,.13),(.10,.13),(.20,.24),(.40,.24)],0,segments=24)
        disc('reflector',(0,0,.405),.21,.02,7)
        disc('bulb',(0,0,.42),.09,.02,13)
        for z in [-.25,-.13,-.01]:ring('grip_ridge',(0,0,z),.13,.018,5)
        box('switch',(0,-.13,.07),(.075,.03,.10),7,.015)
    elif id=='alarmclock':
        disc('clock_case',(0,0,0),.30,.17,13,rotation=(math.pi/2,0,0))
        disc('clock_face',(0,-.094,0),.26,.025,7,rotation=(math.pi/2,0,0))
        for x in [-.22,.22]:
            ball('bell',(x,0,.31),(.13,.12,.09),2)
            box('foot',(x,0,-.29),(.065,.12,.15),5,.018,(0,-x*.5,0))
        tube('bell_bridge',[(-.18,0,.30),(0,0,.42),(.18,0,.30)],.027,5)
        box('hour_hand',(-.05,-.116,.04),(.15,.02,.035),5,.006,(0,-.5,0))
        box('minute_hand',(.01,-.12,.085),(.028,.025,.20),0,.006)
        for j in range(12):
            a=j*math.tau/12
            box('hour_tick',(.22*math.sin(a),-.116,.22*math.cos(a)),(.018,.018,.035),5,.004,(0,a,0))
    else:raise ValueError(id)
