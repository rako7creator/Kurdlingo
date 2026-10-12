from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
c=json.loads((root/'school'/'school_content.json').read_text(encoding='utf8'))
assert len(c['rooms'])==16
assert len({r['id'] for r in c['rooms']})==16
assert {r['floor'] for r in c['rooms']}=={'ground','first'}
assert {r['side'] for r in c['rooms']}=={'left','right'}
assert all(0<=r['band']<=3 and len(r['objects'])<=9 for r in c['rooms'])
mission_ids={m['id'] for m in c['missions']}
assert len(mission_ids)==len(c['missions'])
terms=set(w for r in c['rooms'] for w in r['objects'])
room_ids={r['id'] for r in c['rooms']}
for m in c['missions']:
    for g in m['goals']:
        assert g in terms or g.startswith('talk:') or g.startswith('visit:'),g
        if g.startswith('visit:'):assert g[6:] in room_ids,g
script=(root/'school'/'SchoolModule.gd').read_text()
for required in ['func try_interact()', 'func dismiss_panel()', 'func open_missions()', 'func debug_warp_to_gate()', 'world.inspect_word(canonical)', 'DirAccess.rename_absolute']:
    assert required in script, required
print('PASS: school kit structural/content checks; ',len(c['rooms']),'rooms,',sum(len(r['objects']) for r in c['rooms']),'placed props,',len(terms),'distinct labels,',len(c['missions']),'missions')
print('NOTE: Cannot validate GDScript parsing or Godot runtime without Godot binary.')
