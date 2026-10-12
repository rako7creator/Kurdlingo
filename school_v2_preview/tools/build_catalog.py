import json
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'school'/'school_content.json'
rooms=[
('stairs','Stairwell','ground','left',0,['stairs','handrail','door','window','exit sign','light switch']),
('classroom_a','Classroom A','ground','left',1,['desk','chair','book','pencil','whiteboard','notebook','ruler','school bag','clock']),
('cafeteria','Cafeteria','ground','left',2,['table','chair','cup','plate','apple','lunch tray','water bottle','menu']),
('reception','Reception','ground','left',3,['reception desk','computer','telephone','clock','calendar','printer','noticeboard','visitor book']),
('storage','Storage & Toilets','ground','right',0,['toilet','sink','mirror','soap','towel','storage box','shelf','bin']),
('classroom_b','Classroom B','ground','right',1,['desk','chair','book','pen','notebook','paper','map','backpack','blackboard']),
('principal','Principal Office','ground','right',2,['desk','chair','computer','bookshelf','telephone','file cabinet','calendar','lamp']),
('kitchen','School Kitchen','ground','right',3,['refrigerator','oven','cupboard','kettle','plate','spoon','bread','milk']),
('science','Science Laboratory','first','left',0,['microscope','beaker','test tube','flask','thermometer','gloves','safety goggles','science book']),
('computers','Computer Classroom','first','left',1,['computer','monitor','keyboard','computer mouse','headphones','printer','tablet','router']),
('art','Art & Music Room','first','left',2,['paintbrush','paint','palette','canvas','guitar','drum','piano','music stand']),
('library','School Library','first','left',3,['book','bookshelf','dictionary','atlas','magazine','bookmark','reading table','library card']),
('language','Language Classroom','first','right',0,['whiteboard','alphabet poster','flashcards','dictionary','headphones','microphone','notebook','clock']),
('teachers','Teachers Office','first','right',1,['desk','chair','laptop','printer','folder','calendar','coffee cup','noticeboard']),
('first_toilet','Upper Bathrooms','first','right',2,['toilet','sink','mirror','soap','hand dryer','towel','light switch']),
('reading','Reading & Study','first','right',3,['book','chair','table','reading lamp','dictionary','map','notebook','globe'])]
# No unreviewed translations invented. English aliases map to existing canonical IDs where established.
aliases={'school bag':'backpack','computer mouse':None,'bookshelf':None,'whiteboard':'daily_whiteboard','reading table':'table','reading lamp':None,'coffee cup':'cup','science book':'book','water bottle':None,'reception desk':'desk','visitor book':'book'}
mission=[
 {'id':'classroom_five','name':'Find five classroom objects','goals':['desk','chair','book','pencil','whiteboard'],'xp':40},
 {'id':'computer_parts','name':'Find the computer parts','goals':['monitor','keyboard','computer mouse'],'xp':30},
 {'id':'science_discovery','name':'Discover science tools','goals':['microscope','beaker','safety goggles'],'xp':30},
 {'id':'library_visit','name':'Reach the upstairs library','goals':['visit:library'],'xp':20},
 {'id':'teacher_chat','name':'Speak with a teacher','goals':['talk:teacher'],'xp':20},
 {'id':'cafeteria_lunch','name':'Explore the cafeteria','goals':['cup','plate','apple'],'xp':30},
 {'id':'art_materials','name':'Discover art supplies','goals':['paintbrush','paint','canvas'],'xp':30},
 {'id':'language_room','name':'Visit the language classroom','goals':['visit:language'],'xp':20},
 {'id':'read_a_book','name':'Study a library book','goals':['visit:library','book'],'xp':20},
 {'id':'school_tour','name':'Complete the school tour','goals':['visit:classroom_a','visit:science','visit:computers','visit:library','talk:teacher'],'xp':50}
]
obj={'version':1,'about':'School learning content: draft labels use canonical project translations when possible. Unmatched translations must be reviewed.','aliases':aliases,'rooms':[{'id':r[0],'label':r[1],'floor':r[2],'side':r[3],'band':r[4],'objects':r[5]} for r in rooms],'missions':mission}
out.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('generated',out,'rooms',len(rooms),'object instances',sum(len(r[5]) for r in rooms),'unique words',len({w for r in rooms for w in r[5]}))
