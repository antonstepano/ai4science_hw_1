#!/usr/bin/env python3
import argparse, json, math, re
from collections import Counter
from pathlib import Path

WORD=re.compile(r"[A-Za-zА-Яа-яЁё0-9µμ]+", re.UNICODE)

def toks(s):
    return [x.lower() for x in WORD.findall(s) if len(x)>1]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('query')
    ap.add_argument('--top',type=int,default=8)
    ap.add_argument('--source',default=None)
    a=ap.parse_args()
    path=Path(__file__).resolve().parents[1]/'library/chunks.jsonl'
    docs=[json.loads(x) for x in path.read_text(encoding='utf-8').splitlines() if x.strip()]
    if a.source: docs=[d for d in docs if d['source_id']==a.source]
    q=toks(a.query)
    if not q:
        raise SystemExit('Empty query')
    df=Counter()
    dt=[]
    for d in docs:
        c=Counter(toks(d['text'])); dt.append(c)
        for t in set(q):
            if c[t]: df[t]+=1
    N=max(len(docs),1)
    scored=[]
    for d,c in zip(docs,dt):
        score=0.0
        for t in q:
            if c[t]: score += (1+math.log(c[t]))*math.log((N+1)/(df[t]+1)+1)
        # phrase bonus
        low=d['text'].lower()
        if a.query.lower() in low: score += 8
        if score>0: scored.append((score,d))
    scored.sort(key=lambda x:x[0], reverse=True)
    for rank,(score,d) in enumerate(scored[:a.top],1):
        text=d['text']
        # compact excerpt around first matching token
        lo=text.lower(); positions=[lo.find(t) for t in q if lo.find(t)>=0]
        p=min(positions) if positions else 0
        start=max(0,p-280); end=min(len(text),p+1000)
        excerpt=text[start:end]
        print(f"[{rank}] score={score:.2f} {d['source_id']} page={d['page']} chunk={d['chunk']} file={d['file']}")
        print(excerpt)
        print('-'*80)
if __name__=='__main__': main()
