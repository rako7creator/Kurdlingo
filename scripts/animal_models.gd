class_name AnimalModels
extends RefCounted

static func sphere(n: Node3D,p: Vector3,size: Vector3,col: Color) -> void:WorldProps.sphere(n,p,size,col)
static func bone(n: Node3D,a: Vector3,b: Vector3,r: float,col: Color) -> void:WorldProps.line(n,a,b,r,col)
static func make(k: String) -> Node3D:
	var n=Node3D.new();var dark=Color("292b2d");var ivory=Color("e8dfce")
	var mammals=["bear","rabbit","goat","donkey","pig","fox","wolf","lion","tiger","leopard","elephant","giraffe","zebra","camel","deer","monkey","kangaroo","panda","hedgehog","squirrel","mouse","cow","sheep","horse","cat","dog"]
	var birds=["duck","goose","rooster","chick","pigeon","owl","eagle","parrot","penguin","flamingo","swan","peacock","bird"]
	if k=="kangaroo":
		var fur=Color("aa805c");sphere(n,Vector3(0,.85,0),Vector3(.65,1.1,.5),fur);sphere(n,Vector3(.24,1.57,0),Vector3(.32,.38,.29),fur)
		for side in [-1,1]:
			sphere(n,Vector3(-.2,.4,side*.25),Vector3(.4,.6,.3),fur);bone(n,Vector3(-.2,.25,side*.25),Vector3(.4,.05,side*.25),.085,fur);bone(n,Vector3(.12,1.1,side*.22),Vector3(.4,.85,side*.23),.04,fur);sphere(n,Vector3(.15,1.9,side*.12),Vector3(.1,.38,.12),fur);sphere(n,Vector3(.36,1.6,side*.12),Vector3.ONE*.04,dark)
		bone(n,Vector3(-.25,.55,0),Vector3(-1,.05,0),.12,fur);return n
	if k in mammals:
		var colors={"bear":"79604a","rabbit":"c5b8a1","goat":"c7b89d","donkey":"97918b","pig":"dfa4a1","fox":"c26b35","wolf":"8c9093","lion":"c29c62","tiger":"cf873e","leopard":"c1a06e","elephant":"91999a","giraffe":"cfa365","zebra":"e8e4dd","camel":"b3976c","deer":"a48159","panda":"e7e5db","cow":"e7e1d5","sheep":"dfd7c7","horse":"926546","cat":"bca289","dog":"a28262","mouse":"a4a09b","hedgehog":"897660","squirrel":"a9744c"}
		var col=Color(colors.get(k,"9c8063"));var small=k in ["rabbit","mouse","hedgehog","squirrel","cat"]
		var height=.3 if small else 1.25 if k in ["horse","giraffe","zebra","camel","deer"] else 1.0 if k=="elephant" else .7
		var length=1.55 if k in ["horse","elephant","cow","zebra","camel"] else .7 if small else 1.2
		var depth=.8 if k in ["elephant","pig","panda","cow","bear"] else .45
		sphere(n,Vector3(0,height,0),Vector3(length,.55 if not small else .38,depth),col)
		var neck=1.35 if k=="giraffe" else .65 if k in ["horse","camel","deer"] else .12
		var head=Vector3(length*.43,height+neck+.15,0)
		bone(n,Vector3(length*.3,height,0),head,.13 if k!="elephant" else .24,col)
		if k=="lion":sphere(n,head,Vector3(.65,.69,.61),Color("765238"))
		sphere(n,head,Vector3(.38 if small else .48,.33 if small else .5,.35 if small else .44),col)
		sphere(n,head+Vector3(.22,-.07,0),Vector3(.22 if small else .36,.18 if small else .27,.25),col)
		for side in [-1,1]:
			for x in [-length*.3,length*.3]:
				var hip=Vector3(x,height-.1,side*depth*.34);var knee=Vector3(x+(.06 if x<0 else -.04),height*.45,side*depth*.4)
				bone(n,hip,knee,.045 if small else .085 if k!="elephant" else .15,col);bone(n,knee,Vector3(x,.09,side*depth*.4),.04 if small else .06 if k!="elephant" else .13,col)
				sphere(n,Vector3(x+.04,.055,side*depth*.4),Vector3(.15 if small else .22,.11,.14 if small else .22),dark if k in ["horse","cow","goat","deer","zebra"] else col)
			sphere(n,head+Vector3(.12,.08,side*.18),Vector3(.055,.055,.035),dark)
			var ear=Vector3(.13,.53 if k=="rabbit" else .43 if k=="donkey" else .2,.12)
			sphere(n,head+Vector3(-.08,ear.y*.6,side*.22),ear,col)
			if k=="rabbit":sphere(n,head+Vector3(-.07,.3,side*.224),Vector3(.055,.36,.04),Color("d8ada5"))
			if k in ["goat","cow","giraffe"]:bone(n,head+Vector3(-.04,.2,side*.13),head+Vector3(-.16,.5,side*.25),.035,ivory)
			if k=="deer":
				var base=head+Vector3(-.08,.18,side*.13);var tip=base+Vector3(-.35,.7,side*.24);bone(n,base,tip,.035,Color("6f5840"))
				for i in range(3):bone(n,base.lerp(tip,.35+i*.22),base.lerp(tip,.35+i*.22)+Vector3(.2,.24,side*.1),.025,Color("6f5840"))
			if k=="elephant":
				sphere(n,head+Vector3(-.1,-.02,side*.4),Vector3(.55,.82,.13),col)
				bone(n,head+Vector3(.21,-.15,side*.15),head+Vector3(.59,-.3,side*.16),.045,ivory)
		if k=="elephant":
			for i in range(7):sphere(n,head+Vector3(.26+i*.035,-.15-i*.115,0),Vector3(.2-i*.013,.19,.2-i*.013),col)
		elif k=="rabbit":sphere(n,Vector3(-.4,.28,0),Vector3.ONE*.22,ivory)
		else:
			var tail_end=Vector3(-length*.8,height-.3,0)
			if k in ["fox","squirrel"]:sphere(n,Vector3(-length*.65,height+.12,0),Vector3(.64,.45,.35),col);sphere(n,Vector3(-length*.95,height+.14,0),Vector3(.22,.27,.26),ivory if k=="fox" else col)
			else:bone(n,Vector3(-length*.45,height,0),tail_end,.025 if small else .05,col)
		if k in ["horse","zebra"]:
			bone(n,Vector3(length*.2,height+.25,0),head+Vector3(-.13,.21,0),.09,dark)
		if k=="camel":sphere(n,Vector3(-.2,height+.3,0),Vector3(.65,.7,.58),col)
		if k=="sheep":
			for i in range(22):sphere(n,Vector3(-.5+(i%6)*.18,height+.15+(i%2)*.13,-.24+int(i/6)*.16),Vector3.ONE*.28,ivory)
		if k in ["tiger","zebra","cow","giraffe","leopard"]:
			for side in [-1,1]:
				for i in range(8):
					var p=Vector3(-length*.4+(i%4)*length*.22,height-.1+int(i/4)*.24,side*depth*.47)
					sphere(n,p,Vector3(.09 if k in ["tiger","zebra"] else .22,.38 if k in ["tiger","zebra"] else .19,.03),Color("8d623b") if k=="giraffe" else dark)
		if k=="panda":
			for side in [-1,1]:
				sphere(n,head+Vector3(.08,.04,side*.18),Vector3(.15,.15,.03),dark)
				for x in [-length*.3,length*.3]:bone(n,Vector3(x,height-.1,side*depth*.34),Vector3(x,.11,side*depth*.4),.11,dark)
		if k=="squirrel":
			for i in range(6):sphere(n,Vector3(-.5-.14*sin(i*.5),height+.12+i*.12,0),Vector3(.34,.3,.3),col)
		if k=="rabbit":
			for side in [-1,1]:sphere(n,Vector3(-.22,.22,side*.19),Vector3(.35,.4,.23),col)
		if k=="goat":bone(n,head+Vector3(.08,-.19,0),head+Vector3(.1,-.44,0),.035,col)
		if k=="hedgehog":
			for i in range(40):bone(n,Vector3(-.35+(i%8)*.09,height+.12,-.19+int(i/8)*.09),Vector3(-.4+(i%8)*.09,height+.28,-.19+int(i/8)*.09),.015,dark)
		return n
	if k in birds:
		var water=k in ["duck","goose","swan"]
		var col=Color("e7e3d7") if k in ["goose","swan"] else Color("282d31") if k=="penguin" else Color("dc9fb0") if k=="flamingo" else Color("708957") if k in ["duck","parrot","peacock"] else Color("8d7a63")
		var y=.65 if water else 1.3 if k=="flamingo" else .6
		sphere(n,Vector3(0,y,0),Vector3(1.0 if water else .6,.48 if water else .8,.5),col)
		var head=Vector3(.42,y+(.85 if k in ["swan","flamingo"] else .45),0)
		bone(n,Vector3(.3,y+.1,0),head,.09,col);sphere(n,head,Vector3(.3,.32,.29),Color("527958") if k=="duck" else col)
		bone(n,head+Vector3(.14,0,0),head+Vector3(.4,-.03,0),.065 if water else .045,Color("d5aa52"))
		for side in [-1,1]:
			sphere(n,head+Vector3(.09,.045,side*.12),Vector3.ONE*.04,dark)
			sphere(n,Vector3(-.05,y,side*.25),Vector3(.66,.35,.07),col.darkened(.15))
			bone(n,Vector3(0,y-.2,side*.15),Vector3(.02,.06,side*.15),.025,Color("b49961"));sphere(n,Vector3(.1,.035,side*.15),Vector3(.3,.05,.14),Color("b49961"))
		if k in ["penguin","owl"]:sphere(n,Vector3(.17,y,0),Vector3(.17,.63,.41),ivory)
		if k=="owl":
			for side in [-1,1]:sphere(n,head+Vector3(.12,.02,side*.12),Vector3(.07,.15,.12),ivory)
		if k=="rooster":
			for i in range(4):sphere(n,head+Vector3(-.09+i*.065,.18,0),Vector3(.09,.17,.09),Color("b84e46"))
		if k=="peacock":
			for i in range(13):
				var tip=Vector3(-.55,y+sin(i*PI/12)*1.15,-1.0+i/6.0);bone(n,Vector3(-.3,y,0),tip,.055,Color("3e8176"));sphere(n,tip,Vector3(.05,.16,.11),Color("d5b663"))
		return n
	if k in ["shark","dolphin","whale","seal"]:
		var col=Color("839a9f");sphere(n,Vector3(0,.45,0),Vector3(1.8,.58,.59),col)
		for side in [-1,1]:
			bone(n,Vector3(-.8,.45,0),Vector3(-1.07,.45,side*.45),.08,col);bone(n,Vector3(.05,.4,side*.2),Vector3(-.23,.2,side*.62),.07,col)
			if k=="shark":bone(n,Vector3(-.85,.45,0),Vector3(-1.05,.85,0),.07,col)
			sphere(n,Vector3(.65,.5,side*.22),Vector3.ONE*.04,dark)
		if k=="dolphin":sphere(n,Vector3(.91,.46,0),Vector3(.4,.16,.2),col)
		if k!="seal":bone(n,Vector3(-.05,.62,0),Vector3(-.2,1,0),.09,col)
		return n
	if k=="starfish":
		for i in range(5):bone(n,Vector3.ZERO,Vector3(cos(i*TAU/5),.03,sin(i*TAU/5)),.15,Color("cb8c69"))
		return n
	if k in ["octopus","jellyfish","snail"]:
		var col=Color("bf826e") if k=="octopus" else Color("b0ced1") if k=="jellyfish" else Color("ac9677")
		sphere(n,Vector3(0,.8,0),Vector3(.8,.9,.8) if k=="octopus" else Vector3(1,.5,1) if k=="jellyfish" else Vector3(.8,.8,.4),col)
		if k=="snail":
			sphere(n,Vector3(0,.1,0),Vector3(1.3,.2,.4),col);sphere(n,Vector3(.6,.22,0),Vector3(.22,.3,.25),col)
			for side in [-1,1]:bone(n,Vector3(.6,.3,side*.07),Vector3(.68,.55,side*.13),.015,dark)
		else:
			for i in range(8):
				var a=i*TAU/8
				for j in range(5):
					var radius=.22+j*.14 if k=="octopus" else .3
					sphere(n,Vector3(cos(a)*radius,.4-j*.07 if k=="octopus" else .55-j*.12,sin(a)*radius),Vector3.ONE*(.16-j*.015 if k=="octopus" else .07),col)
		return n
	if k=="ant":
		for x in [-.4,0,.35]:sphere(n,Vector3(x,.3,0),Vector3(.4,.32,.28),dark)
		for side in [-1,1]:
			for x in [-.25,0,.25]:bone(n,Vector3(x,.25,0),Vector3(x-.15,0,side*.45),.02,dark)
		return n
	if k=="turtle":
		sphere(n,Vector3(0,.3,0),Vector3(.85,.55,.7),Color("786f47"));sphere(n,Vector3(.6,.25,0),Vector3(.32,.27,.28),Color("8c9e69"))
		for side in [-1,1]:
			for x in [-.28,.28]:bone(n,Vector3(x,.18,side*.2),Vector3(x+.1,.05,side*.45),.07,Color("8c9e69"))
		return n
	# Existing specialised reptiles, insects and habitats retain their own meshes.
	AnnexProps.animal(n,k)
	return n
