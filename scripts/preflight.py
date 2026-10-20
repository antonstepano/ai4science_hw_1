#!/usr/bin/env python3
from pathlib import Path
import csv, json, sys, subprocess
R=Path(__file__).resolve().parents[1]
errors=[]
for p in ['AGENT.md','INDEX.md','TASK_ONE_SHOT.md','ontology.yaml','library/chunks.jsonl','library/local_manifest.csv','library/seed/sources_seed.csv','data/input/Lunar_Dust_Data_Collection_By_Research_Blocks.xlsx','checks/check_hw1.py']:
    if not (R/p).exists(): errors.append('missing '+p)
try:
    rows=list(csv.DictReader(open(R/'library/local_manifest.csv',encoding='utf-8-sig')))
    if len(rows)<8: errors.append(f'local sources {len(rows)} < 8')
except Exception as e: errors.append('manifest: '+str(e))
try:
    chunks=sum(1 for _ in open(R/'library/chunks.jsonl',encoding='utf-8'))
    if chunks<50: errors.append(f'local chunks {chunks} < 50')
except Exception as e: errors.append('chunks: '+str(e))
print(f'[preflight] root={R}')
print('[preflight] local library:', len(rows) if 'rows' in locals() else '?', 'sources; chunks:', chunks if 'chunks' in locals() else '?')
if errors:
    for e in errors: print('[FAIL]',e)
    sys.exit(1)
print('[OK] project structure and local context are ready')
