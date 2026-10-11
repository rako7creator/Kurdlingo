class_name SchoolProps
extends RefCounted
# Original models built in metres. Each silhouette follows the named real object.
const WOOD=Color("b98c62")
const PAPER=Color("f4ecd8")
const DARK=Color("304c58")
const BLUE=Color("639dad")
const RED=Color("c66d59")
const METAL=Color("c3d0cf")
static func b(n:Node3D,p:Vector3,s:Vector3,c:Color=PAPER)->MeshInstance3D:return WorldProps.box(n,p,s,c)
static func c(n:Node3D,p:Vector3,r:float,h:float,col:Color=METAL)->MeshInstance3D:return WorldProps.cylinder(n,p,r,h,col)
static func l(n:Node3D,a:Vector3,z:Vector3,r:float=.012,col:Color=DARK)->void:WorldProps.line(n,a,z,r,col)
static func tag(n:Node3D,t:String,p:Vector3,scale_factor:float=.0018)->void:
	var text=AccurateProps.tag(n,t,p,scale_factor);text.rotation.y=PI;text.modulate=DARK
static func table(n:Node3D,w:float=1.2,d:float=.65,h:float=.75)->void:
	b(n,Vector3(0,h,0),Vector3(w,.06,d),WOOD)
	for x in [-w*.42,w*.42]:
		for z in [-d*.4,d*.4]:b(n,Vector3(x,h*.5,z),Vector3(.045,h,.045),DARK)
static func book(n:Node3D,k:String)->void:
	b(n,Vector3(0,.025,0),Vector3(.24,.04,.32),PAPER)
	for y in [.003,.048]:b(n,Vector3(0,y,0),Vector3(.26,.008,.34),BLUE if k!="register" else RED)
	b(n,Vector3(-.13,.026,0),Vector3(.012,.055,.34),WOOD)
	for i in range(5):b(n,Vector3(.01,.056,-.1+i*.04),Vector3(.16,.002,.004),DARK)
	if k=="atlas":
		for x in [-.07,.04]:WorldProps.sphere(n,Vector3(x,.058,0),Vector3(.09,.006,.17),Color("89aa78"))
	if k=="notebook":
		for i in range(9):var r=AnnexProps.ring(n,Vector3(-.12,.05,-.14+i*.035),.013,DARK);r.rotation.z=PI/2
static func document(n:Node3D,k:String)->void:
	b(n,Vector3(0,.005,0),Vector3(.21,.01,.3),PAPER)
	for i in range(9):b(n,Vector3(0,.012,-.11+i*.024),Vector3(.16 if i%3 else .12,.002,.003),BLUE)
	if k=="calendar" or k=="timetable":
		for x in range(5):b(n,Vector3(-.09+x*.045,.013,0),Vector3(.002,.002,.26),RED)
static func make(k:String)->Node3D:
	var n=Node3D.new()
	match k:
		"flower":
			l(n,Vector3.ZERO,Vector3(0,.15,0),.006,Color("62875f"));WorldProps.sphere(n,Vector3(0,.16,0),Vector3(.035,.026,.035),Color("d1ae57"))
			for i in range(6):WorldProps.sphere(n,Vector3(cos(i*TAU/6)*.035,.16,sin(i*TAU/6)*.035),Vector3(.045,.018,.045),Color("f4cfb8"))
		"book","notebook","atlas","register":book(n,k)
		"document","calendar":document(n,k)
		"timetable":
			b(n,Vector3(0,.4,0),Vector3(.8,.8,.04),BLUE);b(n,Vector3(0,.4,-.028),Vector3(.74,.74,.012),PAPER)
			for i in range(6):
				b(n,Vector3(-.32+i*.13,.4,-.038),Vector3(.006,.65,.006),BLUE);b(n,Vector3(0,.1+i*.12,-.038),Vector3(.66,.006,.006),BLUE)
			tag(n,"WEEKLY TIMETABLE",Vector3(0,.72,-.044),.001)
		"certificate","noticeboard","map","art_frame":
			b(n,Vector3(0,.4,0),Vector3(.65,.8,.04),WOOD);b(n,Vector3(0,.4,-.026),Vector3(.59,.74,.008),PAPER)
			if k=="map":
				for i in range(7):WorldProps.sphere(n,Vector3(sin(i*1.9)*.2,.14+i*.075,-.034),Vector3(.14,.1,.009),Color("88ad79"))
			elif k=="art_frame":
				for i in range(12):WorldProps.sphere(n,Vector3(sin(i)*.18,.13+i*.045,-.034),Vector3(.09,.09,.008),[BLUE,RED,Color("e0bb60")][i%3])
			elif k=="noticeboard":
				for i in range(6):b(n,Vector3(-.17+(i%2)*.33,.15+int(i/2)*.23,-.034),Vector3(.23,.17,.008),[PAPER,BLUE,RED][i%3])
			else:tag(n,"CERTIFICATE",Vector3(0,.61,-.033),.0012);for i in range(5):b(n,Vector3(0,.25+i*.055,-.034),Vector3(.4,.005,.006),BLUE)
		"desk","lab_bench","carrel","reception":
			table(n,1.2 if k=="desk" else 2,.65 if k=="desk" else .85)
			if k=="carrel":
				for x in [-1,1]:b(n,Vector3(x,.94,0),Vector3(.035,.4,.85),WOOD)
				b(n,Vector3(0,.94,.42),Vector3(2,.4,.035),WOOD)
			if k=="reception":b(n,Vector3(0,.38,-.37),Vector3(2,.72,.06),BLUE);b(n,Vector3(.75,.98,-.3),Vector3(.5,.06,.35),WOOD)
		"book_trolley","magazine_rack","return_box","trophy_cabinet":
			var w=.9;var h=1.1 if k!="trophy_cabinet" else 1.8
			for x in [-w*.5,w*.5]:b(n,Vector3(x,h*.5,0),Vector3(.05,h,.4),WOOD)
			for y in [.12,h*.5,h]:
				b(n,Vector3(0,y,0),Vector3(w,.05,.4),WOOD)
				if k!="return_box":
					for i in range(8):b(n,Vector3(-.35+i*.09,y+.12,.08),Vector3(.06,.23,.2),[RED,BLUE,PAPER][i%3])
			if k=="return_box":b(n,Vector3(0,h*.5,-.21),Vector3(w,h,.04),BLUE);b(n,Vector3(0,.85,-.236),Vector3(.55,.07,.008),DARK);tag(n,"BOOK RETURN",Vector3(0,.6,-.24),.0018)
			if k=="book_trolley":
				for x in [-.37,.37]:
					for z in [-.17,.17]:c(n,Vector3(x,.06,z),.06,.04,DARK).rotation.z=PI/2
		"bookmark","ruler":
			b(n,Vector3(0,.008,0),Vector3(.28,.016,.04),BLUE if k=="bookmark" else WOOD)
			for i in range(25):b(n,Vector3(-.13+i*.011,.018,-.015),Vector3(.002,.003,.015 if i%5==0 else .007),DARK)
		"bookend":b(n,Vector3(0,.01,0),Vector3(.15,.02,.2),BLUE);b(n,Vector3(0,.1,.09),Vector3(.15,.2,.02),BLUE)
		"pencil_case","lunch_box","first_aid":
			b(n,Vector3(0,.05,0),Vector3(.25,.1,.13),RED if k=="first_aid" else BLUE);b(n,Vector3(0,.105,0),Vector3(.24,.012,.12),PAPER)
			if k=="first_aid":b(n,Vector3(0,.113,0),Vector3(.08,.007,.022),RED);b(n,Vector3(0,.113,0),Vector3(.022,.007,.08),RED)
			else:l(n,Vector3(-.11,.115,0),Vector3(.11,.115,0),.003,DARK)
		"pencils","brushes","pen":
			for i in range(1 if k=="pen" else 7):
				var p=Vector3(-.045+i*.015,.012,i%2*.015)
				l(n,p,p+Vector3(0,0,.18),.006,[BLUE,RED,Color("d3b05b")][i%3]);l(n,p+Vector3(0,0,.18),p+Vector3(0,0,.21),.004,WOOD)
		"sharpener":b(n,Vector3(0,.02,0),Vector3(.035,.04,.027),METAL);c(n,Vector3(0,.02,-.016),.009,.004,DARK).rotation.x=PI/2
		"eraser":b(n,Vector3(0,.016,0),Vector3(.14,.032,.045),BLUE);b(n,Vector3(0,.002,0),Vector3(.14,.01,.045),DARK)
		"protractor":
			for i in range(25):l(n,Vector3(cos(i*PI/24)*.09,.01,sin(i*PI/24)*.09),Vector3(cos(i*PI/24)*.1,.01,sin(i*PI/24)*.1),.0015,DARK)
			AccurateProps.curve(n,[Vector3(-.1,.01,0),Vector3(-.08,.01,.07),Vector3(0,.01,.1),Vector3(.08,.01,.07),Vector3(.1,.01,0),Vector3(-.1,.01,0)],.004,BLUE)
		"set_square":
			l(n,Vector3(-.12,.01,-.07),Vector3(.12,.01,-.07),.012,BLUE);l(n,Vector3(.12,.01,-.07),Vector3(-.12,.01,.1),.012,BLUE);l(n,Vector3(-.12,.01,.1),Vector3(-.12,.01,-.07),.012,BLUE)
		"compass":l(n,Vector3(0,.02,.1),Vector3(-.05,.02,-.1),.006,METAL);l(n,Vector3(0,.02,.1),Vector3(.05,.02,-.1),.006,BLUE)
		"whiteboard","screen":
			b(n,Vector3(0,.7,0),Vector3(1.8,1.15,.06),METAL);b(n,Vector3(0,.7,-.037),Vector3(1.72,1.08,.012),PAPER);b(n,Vector3(0,.1,-.1),Vector3(1.8,.04,.2),METAL)
			if k=="whiteboard":tag(n,"LEARN · EXPLORE · CREATE",Vector3(0,.84,-.05),.0023);tag(n,"English / Sorani",Vector3(0,.51,-.05),.002)
		"backpack":
			WorldProps.sphere(n,Vector3(0,.2,0),Vector3(.3,.42,.18),BLUE);b(n,Vector3(0,.14,-.1),Vector3(.23,.17,.035),RED)
			for x in [-.11,.11]:AccurateProps.curve(n,[Vector3(x,.34,.08),Vector3(x,.2,.16),Vector3(x,.07,.08)],.016,DARK)
			AccurateProps.curve(n,[Vector3(-.07,.38,0),Vector3(-.07,.45,0),Vector3(.07,.45,0),Vector3(.07,.38,0)],.015,DARK)
		"test_tubes":
			for y in [.04,.19]:b(n,Vector3(0,y,0),Vector3(.4,.025,.18),WOOD)
			for i in range(6):c(n,Vector3(-.16+i*.065,.18,0),.019,.28,Color("acd7d7"));c(n,Vector3(-.16+i*.065,.11,0),.016,.13,[BLUE,RED,Color("e0bd70")][i%3])
		"conical_flask","measuring_cylinder","beaker","mug":
			var r=.06 if k!="measuring_cylinder" else .026;var h=.15 if k!="measuring_cylinder" else .28
			AccurateProps.lathe(n,[Vector2(0,0),Vector2(r,.005),Vector2(r,h*.6),Vector2(r*.4 if k=="conical_flask" else r,h),Vector2(r*.35 if k=="conical_flask" else r*.88,h),Vector2(r*.8,.01)],BLUE if k=="mug" else Color("a4cbcf"))
			if k=="mug":AnnexProps.ring(n,Vector3(.078,.08,0),.045,BLUE).rotation.x=PI/2
			else:for i in range(5):b(n,Vector3(0,.04+i*h*.14,-r-.003),Vector3(.024,.002,.004),DARK)
		"burner":c(n,Vector3(0,.014,0),.06,.028,DARK);c(n,Vector3(0,.11,0),.018,.18,METAL);l(n,Vector3(0,.05,0),Vector3(.08,.05,0),.01,METAL)
		"goggles":
			for x in [-.04,.04]:b(n,Vector3(x,.025,0),Vector3(.075,.045,.022),BLUE);l(n,Vector3(x,.025,0),Vector3(x*1.6,.025,.07),.006,DARK)
			l(n,Vector3(-.008,.025,0),Vector3(.008,.025,0),.005,DARK)
		"lab_coat","uniform":
			b(n,Vector3(0,.6,0),Vector3(.47,.7,.15),PAPER if k=="lab_coat" else BLUE)
			for x in [-.31,.31]:var sleeve=b(n,Vector3(x,.68,0),Vector3(.15,.58,.16),PAPER if k=="lab_coat" else BLUE);sleeve.rotation.z=-sign(x)*.2
			for y in [.38,.5,.62,.74]:WorldProps.sphere(n,Vector3(0,y,-.084),Vector3.ONE*.02,DARK)
			for x in [-.13,.13]:b(n,Vector3(x,.4,-.09),Vector3(.12,.11,.014),PAPER)
			l(n,Vector3(0,.94,0),Vector3(0,1.05,0),.015,WOOD);b(n,Vector3(0,.08,0),Vector3(.6,.04,.3),WOOD)
		"molecule":
			var pts=[Vector3(0,.25,0),Vector3(-.16,.12,.1),Vector3(.18,.13,.07),Vector3(0,.47,0),Vector3(0,.19,-.2)]
			for i in range(pts.size()):WorldProps.sphere(n,pts[i],Vector3.ONE*.13,[DARK,RED,PAPER][i%3]);if i>0:l(n,pts[0],pts[i],.018,METAL)
		"skeleton":
			c(n,Vector3(0,.02,0),.24,.04,DARK);l(n,Vector3(0,.03,.08),Vector3(0,1.4,.08),.02,METAL);WorldProps.sphere(n,Vector3(0,1.52,0),Vector3(.2,.26,.19),PAPER)
			for x in [-.048,.048]:WorldProps.sphere(n,Vector3(x,1.54,-.09),Vector3(.053,.055,.018),DARK)
			WorldProps.sphere(n,Vector3(0,1.495,-.097),Vector3(.025,.035,.012),DARK)
			for x in range(6):b(n,Vector3(-.045+x*.018,1.455,-.09),Vector3(.012,.025,.012),PAPER)
			l(n,Vector3(0,.67,0),Vector3(0,1.35,0),.025,PAPER)
			for side in [-1,1]:
				for j in range(7):AccurateProps.curve(n,[Vector3(0,1.3-j*.055,.025),Vector3(side*.18,1.29-j*.055,-.03),Vector3(side*.14,1.24-j*.055,-.1),Vector3(0,1.23-j*.055,-.12)],.014,PAPER)
				l(n,Vector3(side*.12,.67,0),Vector3(side*.14,.36,-.02),.035,PAPER);l(n,Vector3(side*.14,.36,-.02),Vector3(side*.13,.09,0),.025,PAPER)
				l(n,Vector3(0,1.33,0),Vector3(side*.23,1.3,0),.025,PAPER);l(n,Vector3(side*.23,1.3,0),Vector3(side*.31,.98,0),.025,PAPER);l(n,Vector3(side*.31,.98,0),Vector3(side*.3,.76,-.03),.02,PAPER)
		"balance":
			b(n,Vector3(0,.015,0),Vector3(.4,.03,.25),WOOD);l(n,Vector3(0,.03,0),Vector3(0,.4,0),.024,METAL);l(n,Vector3(-.25,.39,0),Vector3(.25,.39,0),.015,METAL)
			for x in [-.25,.25]:c(n,Vector3(x,.15,0),.1,.025,METAL);for z in [-.06,.06]:l(n,Vector3(x,.39,0),Vector3(x,.16,z),.003,DARK)
		"eyewash","drinking_fountain":
			b(n,Vector3(0,.43,0),Vector3(.43,.86,.33),METAL);c(n,Vector3(0,.87,0),.21,.045,METAL)
			for x in [-.07,.07]:l(n,Vector3(x,.86,0),Vector3(x,.95,0),.017,BLUE);c(n,Vector3(x,.96,0),.022,.015,METAL)
		"computer":
			b(n,Vector3(0,.3,0),Vector3(.54,.35,.055),DARK);b(n,Vector3(0,.3,-.035),Vector3(.5,.3,.01),BLUE);l(n,Vector3(0,.01,.03),Vector3(0,.17,.03),.02,METAL);b(n,Vector3(0,.014,0),Vector3(.25,.028,.16),DARK)
			for i in range(4):b(n,Vector3(-.1,.23+i*.04,-.043),Vector3(.23,.008,.002),PAPER)
		"computer_tower":
			b(n,Vector3(0,.23,0),Vector3(.2,.46,.4),DARK);b(n,Vector3(0,.38,-.207),Vector3(.16,.04,.01),METAL)
			for y in [.12,.17,.22]:b(n,Vector3(0,y,-.207),Vector3(.13,.006,.01),METAL)
		"printer_3d":
			b(n,Vector3(0,.035,0),Vector3(.5,.07,.5),DARK)
			for x in [-.23,.23]:
				for z in [-.23,.23]:l(n,Vector3(x,.07,z),Vector3(x,.6,z),.022,DARK)
			b(n,Vector3(0,.62,0),Vector3(.5,.04,.5),BLUE);l(n,Vector3(-.23,.38,0),Vector3(.23,.38,0),.018,METAL);b(n,Vector3(.04,.35,0),Vector3(.09,.12,.09),RED);c(n,Vector3(0,.14,0),.07,.18,BLUE)
		"projector":
			b(n,Vector3(0,.065,0),Vector3(.3,.13,.24),PAPER);c(n,Vector3(-.08,.065,-.13),.038,.035,DARK).rotation.x=PI/2
			for x in range(7):b(n,Vector3(.02+x*.017,.065,-.126),Vector3(.006,.07,.007),DARK)
		"robotics":
			b(n,Vector3(0,.09,0),Vector3(.25,.12,.3),BLUE)
			for x in [-.15,.15]:
				for z in [-.1,.1]:c(n,Vector3(x,.05,z),.055,.04,DARK).rotation.z=PI/2
			for x in [-.075,.075]:WorldProps.sphere(n,Vector3(x,.22,-.09),Vector3.ONE*.055,METAL)
			l(n,Vector3(0,.15,0),Vector3(0,.3,.08),.015,RED)
		"stapler":b(n,Vector3(0,.01,0),Vector3(.04,.02,.14),DARK);var lever=b(n,Vector3(0,.04,0),Vector3(.04,.025,.14),RED);lever.rotation.x=-.17
		"paper_clip":AccurateProps.curve(n,[Vector3(-.01,.005,0),Vector3(-.01,.005,.035),Vector3(.01,.005,.035),Vector3(.01,.005,-.035),Vector3(-.02,.005,-.035),Vector3(-.02,.005,.035)],.0018,METAL)
		"easel":
			for x in [-.32,.32]:l(n,Vector3(x,.04,0),Vector3(x*.25,1.5,0),.025,WOOD)
			l(n,Vector3(0,1.4,0),Vector3(0,0,.45),.025,WOOD);b(n,Vector3(0,.85,-.04),Vector3(.65,.7,.035),PAPER);b(n,Vector3(0,.49,-.07),Vector3(.8,.055,.13),WOOD)
			for i in range(5):WorldProps.sphere(n,Vector3(-.22+i*.1,.7+sin(i)*.13,-.065),Vector3(.13,.17,.008),[BLUE,RED,Color("deb868")][i%3])
		"palette","paint_box","xylophone":
			b(n,Vector3(0,.02,0),Vector3(.3,.04,.17),WOOD)
			for i in range(8):b(n,Vector3(-.13+i*.037,.048,0),Vector3(.028,.016,.12 if k!="xylophone" else .15-i*.008),[RED,BLUE,Color("d5b758"),Color("89ae79")][i%4])
		"music_stand":
			l(n,Vector3(0,.03,0),Vector3(0,.95,0),.018,DARK)
			for i in range(3):l(n,Vector3(0,.2,0),Vector3(cos(i*TAU/3)*.25,0,sin(i*TAU/3)*.25),.016,DARK)
			var plate=b(n,Vector3(0,.9,-.03),Vector3(.48,.32,.025),DARK);plate.rotation.x=-.25
		"tambourine":
			c(n,Vector3(0,.025,0),.12,.05,WOOD);c(n,Vector3(0,.053,0),.107,.008,PAPER)
			for i in range(8):c(n,Vector3(cos(i*TAU/8)*.12,.025,sin(i*TAU/8)*.12),.022,.006,METAL)
		"violin":
			for z in [-.09,.09]:WorldProps.sphere(n,Vector3(0,.025,z),Vector3(.16,.05,.15),WOOD)
			b(n,Vector3(0,.032,0),Vector3(.1,.047,.15),WOOD);b(n,Vector3(0,.045,.23),Vector3(.035,.035,.24),DARK)
			for x in [-.012,0,.012]:l(n,Vector3(x,.07,-.13),Vector3(x,.07,.35),.0015,METAL)
			l(n,Vector3(.17,.025,-.18),Vector3(.17,.025,.35),.007,WOOD)
		"lunch_tray":b(n,Vector3(0,.01,0),Vector3(.35,.02,.25),METAL);for x in [-.16,.16]:b(n,Vector3(x,.027,0),Vector3(.02,.034,.25),BLUE);for z in [-.115,.115]:b(n,Vector3(0,.027,z),Vector3(.35,.034,.02),BLUE)
		"towel_dispenser":b(n,Vector3(0,.17,0),Vector3(.26,.34,.12),PAPER);b(n,Vector3(0,.1,-.067),Vector3(.22,.08,.008),DARK);b(n,Vector3(0,.015,-.06),Vector3(.18,.15,.003),PAPER)
		"recycling":
			b(n,Vector3(0,.3,0),Vector3(.38,.6,.38),BLUE);b(n,Vector3(0,.61,0),Vector3(.41,.04,.41),DARK);tag(n,"RECYCLE",Vector3(0,.4,-.196),.0016)
		"thermometer":b(n,Vector3(0,.012,0),Vector3(.14,.024,.025),PAPER);b(n,Vector3(.015,.026,0),Vector3(.03,.003,.014),BLUE);l(n,Vector3(-.07,.012,0),Vector3(-.09,.012,0),.005,METAL)
		"wheelchair":
			b(n,Vector3(0,.46,0),Vector3(.4,.04,.4),BLUE);b(n,Vector3(0,.72,.18),Vector3(.4,.48,.04),BLUE)
			for x in [-.29,.29]:
				var wheel=AnnexProps.ring(n,Vector3(x,.29,.08),.29,DARK);wheel.rotation.z=PI/2
				for i in range(12):l(n,Vector3(x,.29,.08),Vector3(x,.29+cos(i*TAU/12)*.26,.08+sin(i*TAU/12)*.26),.005,METAL)
				l(n,Vector3(x,.1,-.33),Vector3(x,.58,-.25),.02,METAL);c(n,Vector3(x,.07,-.33),.07,.04,DARK).rotation.z=PI/2;l(n,Vector3(x,.61,-.22),Vector3(x,.61,.16),.025,DARK)
		"bell":c(n,Vector3(0,.13,0),.12,.24,Color("c6a858"));c(n,Vector3(0,.01,0),.16,.025,Color("c6a858"));l(n,Vector3(0,.25,0),Vector3(0,.32,0),.025,DARK)
		"clock":
			c(n,Vector3(0,.2,0),.2,.035,WOOD).rotation.x=PI/2;c(n,Vector3(0,.2,-.02),.18,.01,PAPER).rotation.x=PI/2
			for i in range(12):b(n,Vector3(sin(i*TAU/12)*.15,.2+cos(i*TAU/12)*.15,-.029),Vector3(.012,.02,.004),DARK)
			l(n,Vector3(0,.2,-.032),Vector3(.06,.26,-.032),.006,DARK);l(n,Vector3(0,.2,-.032),Vector3(-.09,.25,-.032),.005,DARK)
		"extinguisher":c(n,Vector3(0,.22,0),.09,.44,RED);b(n,Vector3(0,.47,0),Vector3(.13,.035,.05),DARK);AccurateProps.curve(n,[Vector3(.06,.47,0),Vector3(.14,.4,0),Vector3(.14,.16,0)],.012,DARK);b(n,Vector3(0,.26,-.093),Vector3(.1,.14,.008),PAPER)
		"trophy":
			b(n,Vector3(0,.02,0),Vector3(.2,.04,.2),WOOD);c(n,Vector3(0,.14,0),.025,.22,Color("dbb760"));c(n,Vector3(0,.29,0),.095,.15,Color("dbb760"))
			for x in [-.12,.12]:AnnexProps.ring(n,Vector3(x,.29,0),.07,Color("dbb760")).rotation.x=PI/2
		"umbrella_stand":
			c(n,Vector3(0,.2,0),.15,.4,DARK);for x in [-.06,.06]:l(n,Vector3(x,.15,0),Vector3(x,.6,0),.014,WOOD);AccurateProps.curve(n,[Vector3(x,.6,0),Vector3(x+.02,.67,0),Vector3(x+.06,.65,0)],.015,WOOD)
		"coat_hook":l(n,Vector3(0,0,0),Vector3(0,.09,-.06),.012,METAL);l(n,Vector3(0,.09,-.06),Vector3(0,.16,-.04),.012,METAL)
		_:push_error("Unknown school model: "+k)
	return n
