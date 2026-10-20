#!/usr/bin/env python3
import argparse, csv, re, sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
A=[]
def ok(cond,msg):
    print(('[OK] ' if cond else '[FAIL] ')+msg)
    if not cond: A.append(msg)

def csvrows(rel):
    p=R/rel
    if not p.exists(): return []
    with open(p,encoding='utf-8-sig',newline='') as f: return list(csv.DictReader(f))

ap=argparse.ArgumentParser(); ap.add_argument('--strict',action='store_true'); args=ap.parse_args()
ok((R/'AGENT.md').exists(),'AGENT.md exists')
ok(not (R/'AGENTS.md').exists() and not (R/'CLAUDE.md').exists(),'no competing root agent contract')
ok((R/'ontology.yaml').exists(),'ontology.yaml exists')
ok((R/'graph_view.md').exists(),'graph_view.md exists')
ok(len(list((R/'notes/concepts').glob('*.md')))>=10,'at least 10 concept notes')

sources=csvrows('results/sources.csv')
ok(len(sources)>=17,f'sources.csv has >=17 rows (found {len(sources)})')
local=[r for r in sources if r.get('origin','').lower().startswith('local')]
external=[r for r in sources if not r.get('origin','').lower().startswith('local')]
ok(len(local)>=7,f'at least 7 local sources in final registry (found {len(local)})')
ok(len(external)>=10,f'at least 10 external sources in final registry (found {len(external)})')
if sources:
    bad=[r for r in sources if not r.get('source_id') or not r.get('title') or (not r.get('doi') and not r.get('url') and not r.get('local_path'))]
    ok(not bad,f'all source rows have id/title/provenance locator ({len(bad)} bad)')
    unv=[r for r in external if r.get('verification_status','') in ('','seed_unverified')]
    ok(not unv,f'external sources are not left seed_unverified ({len(unv)} bad)')

pe=csvrows('results/parameter_evidence.csv')
ok(len(pe)>=30,f'parameter_evidence.csv has >=30 rows (found {len(pe)})')
if pe:
    blocks={r.get('model_block','').strip() for r in pe if r.get('model_block','').strip()}
    ok(len(blocks)>=8,f'parameter evidence covers >=8 model blocks (found {len(blocks)})')
    bad=[r for r in pe if not r.get('parameter_name') or not r.get('source_id') or not r.get('evidence_type') or not r.get('locator')]
    ok(not bad,f'parameter evidence has parameter/source/type/locator ({len(bad)} bad)')

q=R/'results/local_context_examples.md'
ok(q.exists(),'local_context_examples.md exists')
if q.exists():
    t=q.read_text(encoding='utf-8')
    nq=len(re.findall(r'^###\s+',t,re.M))
    ok(nq>=6,f'at least 6 local-context examples (found {nq})')
    ok('SRC-L' in t,'local-context examples cite local source IDs')

rep=R/'report/HW1_environment_context.md'
ok(rep.exists(),'HW1 report exists')
if rep.exists():
    t=rep.read_text(encoding='utf-8')
    for h in ['Онтолог','локальн','провер','DATA GAP','Приложение A','AGENT.md']:
        ok(h.lower() in t.lower(),f'report contains section/topic: {h}')
    agent=(R/'AGENT.md').read_text(encoding='utf-8')
    marker=agent.splitlines()[0].strip()
    ok(marker in t,'report appendix includes AGENT.md content')

status=(R/'STATUS.md').read_text(encoding='utf-8') if (R/'STATUS.md').exists() else ''
diary=(R/'diary.md').read_text(encoding='utf-8') if (R/'diary.md').exists() else ''
ok('Где мы' in status and len(status)>200,'STATUS.md updated')
ok('Точка проверки' in diary and 'Итог проверки' in diary,'diary has generation→verification cycle')

if A:
    print(f'\nHW1 CHECK: FAIL ({len(A)} issues)')
    sys.exit(1)
print('\nHW1 CHECK: PASS')
